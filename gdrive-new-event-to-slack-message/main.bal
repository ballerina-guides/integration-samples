import ballerinax/slack;
import ballerinax/trigger.google.drive;

configurable string slackToken = ?;
configurable string slackChannel = ?;
final slack:Client slackClient = check new ({auth: {token: slackToken}});

configurable drive:ListenerConfig driveListenerConfig = ?;
listener drive:Listener driveListener = new (driveListenerConfig);

service drive:DriveService on driveListener {

    remote function onFileCreate(drive:Change changeInfo) returns error? {
        slack:Message message = transform(changeInfo);
        _ = check slackClient->postMessage(message);
    }

    remote function onFolderCreate(drive:Change changeInfo) returns error? {
    }

    remote function onFileUpdate(drive:Change changeInfo) returns error? {
    }

    remote function onFolderUpdate(drive:Change changeInfo) returns error? {
    }

    remote function onDelete(drive:Change changeInfo) returns error? {
    }

    remote function onFileTrash(drive:Change changeInfo) returns error? {
    }

    remote function onFolderTrash(drive:Change changeInfo) returns error? {
    }
}

function transform(drive:Change changeInfo) returns slack:Message => {
    channelName: slackChannel,
    text: string `New file ${changeInfo.file?.name ?: ""} added to GDrive at ${changeInfo.time ?: ""} .`
};
