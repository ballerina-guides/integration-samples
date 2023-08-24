import ballerina/log;
import ballerinax/trigger.salesforce as sfdcListener;
import ballerinax/twilio;

type SalesforceListenerConfig record {|
    string username;
    string password;
|};

type TwilioClientConfig record {|
    string accountSId;
    string authToken;
|};

const string CHANNEL_NAME = "/data/ContactChangeEvent";

// Salesforce configuration parameters
configurable SalesforceListenerConfig salesforceListenerConfig = ?;

// Twilio configuration parameters
configurable TwilioClientConfig twilioClientConfig = ?;
configurable string fromNumber = ?;
configurable string toNumber = ?;

listener sfdcListener:Listener sfdcEventListener = new ({
    username: salesforceListenerConfig.username,
    password: salesforceListenerConfig.password,
    channelName: CHANNEL_NAME
});

final twilio:Client twilioClient = check new ({
    twilioAuth: {
        accountSId: twilioClientConfig.accountSId,
        authToken: twilioClientConfig.authToken
    }
});

service sfdcListener:RecordService on sfdcEventListener {
    isolated remote function onCreate(sfdcListener:EventData payload) returns error? {
        string firstName = "";
        string lastName = "";
        string[] nameParts = re `,`.split(payload.changedData["Name"].toString());
        if nameParts.length() >= 2 {
            firstName = re `=`.split(nameParts[0])[1];
            lastName = re `=`.split(re `\}`.replace(nameParts[1], ""))[1];
        } else {
            lastName = re `=`.split(re `\}`.replace(nameParts[0], ""))[1];
        }
        twilio:SmsResponse response = check twilioClient->sendSms(fromNumber, toNumber,
            string `New contact is created! | Name: ${firstName} ${lastName} | Created Date: 
            ${(check payload.changedData.CreatedDate).toString()}`);
        log:printInfo("SMS(SID: " + response.sid + ") sent successfully");
    }

    isolated remote function onUpdate(sfdcListener:EventData payload) returns error? {
        return;
    }

    isolated remote function onDelete(sfdcListener:EventData payload) returns error? {
        return;
    }

    isolated remote function onRestore(sfdcListener:EventData payload) returns error? {
        return;
    }
}
