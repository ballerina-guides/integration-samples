import ballerina/log;
import ballerinax/googleapis.drive;
import ballerinax/microsoft.onedrive;

configurable string gDriveAccessToken = ?;
configurable string gDriveFolderId = ?;

configurable string oneDriveAccessToken = ?;
configurable string oneDrivePath = ?;

configurable boolean filesOverridable = ?;

public function main() returns error? {
    drive:Client gDrive = check new ({auth: {token: gDriveAccessToken}});
    onedrive:Client oneDrive = check new ({auth: {token: oneDriveAccessToken}});

    string gDriveQuery = string `'${gDriveFolderId}' in parents and trashed = false`;
    stream<drive:File> filesInGDrive = check gDrive->getAllFiles(gDriveQuery);

    foreach drive:File file in filesInGDrive {
        string? fileName = file?.name;
        string? fileId = file?.id;
        boolean writable = false;

        if fileName is () || fileId is () {
            log:printError("File name or ID not found");
            continue;
        }
        if !filesOverridable {
            boolean|error isExistingFile = checkIfFileExistsInOneDrive(fileName, oneDrive);
            if isExistingFile is error {
                log:printError("Searching files in Microsoft OneDrive failed!", isExistingFile);
                continue;
            }
            writable = !isExistingFile;
        }
        if filesOverridable || writable {
            drive:FileContent|error fileContent = gDrive->getFileContent(fileId);
            if fileContent is error {
                log:printError("Retrieving file from Google Drive failed!", fileContent);
                continue;
            }
            onedrive:DriveItemData|error driveItemData = oneDrive->
                    uploadFileToFolderByPath(oneDrivePath, fileName, fileContent?.content,
                    fileContent?.mimeType);
            if driveItemData is error {
                log:printError("Uploading file to Microsoft OneDrive failed!", driveItemData);
                continue;
            }
            log:printInfo(string `File ${fileName} uploaded successfully!`);
        }
    }
}

isolated function checkIfFileExistsInOneDrive(string fileName, onedrive:Client onedriveEndpoint) returns boolean|error {
    stream<onedrive:DriveItemData, onedrive:Error?> searchDriveItems = check onedriveEndpoint->searchDriveItems(
        fileName);
    return check searchDriveItems.next() !is ();
}
