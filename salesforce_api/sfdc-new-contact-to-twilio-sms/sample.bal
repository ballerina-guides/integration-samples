import ballerina/http;
import ballerina/log;
import ballerinax/trigger.salesforce as sfdcListener;
import ballerinax/twilio;

// Types
type SalesforceListenerConfig record {
    string username;
    string password;
};

type TwilioClientConfig record {
    string accountSId;
    string authToken;
};

// Constants
const string COMMA = ",";
const string EQUAL_SIGN = "=";
const string CLOSING_BRACKET = "}";
const string NO_STRING = "";
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
    channelName: CHANNEL_NAME,
    environment: "Sandbox"
});

@display { label: "Salesforce New Contact to Twilio SMS" }
service sfdcListener:RecordService on sfdcEventListener {
    remote function onCreate(sfdcListener:EventData payload) returns error? {
        string firstName = NO_STRING;
        string lastName = NO_STRING;
        map<json> contactMap = payload.changedData;
        string[] nameParts = re `,`.split(contactMap["Name"].toString());
        if nameParts.length() >= 2 {
            firstName = re `=`.split(nameParts[0])[1];
            lastName = re `=`.split(re `\}`.replace(nameParts[1], ""))[1];
        } else {
            lastName = re `=`.split(re `\}`.replace(nameParts[0], ""))[1];
        }
        string createdDate = check payload.changedData.CreatedDate;
        string message = string `New contact is created! | Name: ${firstName} ${lastName} | Created Date: ${createdDate}`;
        twilio:Client twilioClient = check new ({
            twilioAuth: {
                accountSId: twilioClientConfig.accountSId,
                authToken: twilioClientConfig.authToken
            }
        });
        twilio:SmsResponse response = check twilioClient->sendSms(fromNumber, toNumber, message);
        log:printInfo("SMS(SID: "+ response.sid +") sent successfully");
    }

    remote function onUpdate(sfdcListener:EventData payload) returns error? {
        return;
    }

    remote function onDelete(sfdcListener:EventData payload) returns error? {
        return;
    }

    remote function onRestore(sfdcListener:EventData payload) returns error? {
        return;
    }
}

service /ignore on new http:Listener(8090) {}