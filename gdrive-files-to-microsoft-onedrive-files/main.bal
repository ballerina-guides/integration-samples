import ballerinax/googleapis.drive;
import ballerinax/microsoft.onedrive;

configurable string gDriveAccessToken = ?;
configurable string gDriveFolderId = ?;

configurable string oneDriveAccessToken = ?;
configurable string oneDrivePath = ?;

configurable boolean filesOverridable = ?;

drive:Client gDrive = check new ({auth: {token: gDriveAccessToken}});
onedrive:Client onedrive = check new ({auth: {token: oneDriveAccessToken}});

public function main() returns error? {
    stream<drive:File> filesInGDrive = check gDrive->getAllFiles(
        string `'${gDriveFolderId}' in parents and trashed = false`
    );

    foreach drive:File file in filesInGDrive {
        string? fileName = file?.name;
        string? fileId = file?.id;
        boolean writable = false;

        if fileName is () || fileId is () {
            continue;
        }
        if !filesOverridable {
            boolean|error isExistingFile = checkIfFileExistsInOneDrive(fileName, onedrive);
            if isExistingFile is error {
                continue;
            }
            writable = !isExistingFile;
        }
        if filesOverridable || writable {
            drive:FileContent|error fileContent = gDrive->getFileContent(fileId);
            if fileContent is error {
                continue;
            }
            onedrive:DriveItemData|error driveItemData = onedrive->
                    uploadFileToFolderByPath(oneDrivePath, fileName, fileContent?.content,
                    fileContent?.mimeType);
            if driveItemData is error {
                continue;
            }
        }
    }
}

isolated function checkIfFileExistsInOneDrive(string fileName, onedrive:Client onedriveEndpoint) returns boolean|error {
    stream<onedrive:DriveItemData, onedrive:Error?> searchDriveItems = check onedriveEndpoint->searchDriveItems(
        fileName);
    return check searchDriveItems.next() !is ();
}
