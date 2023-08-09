// import ballerina/http;
// import ballerina/log;
// import ballerina/regex;
// import ballerinax/trigger.salesforce as sfdcListener;
// import ballerinax/twilio;
import ballerinax/salesforce as sfdc;
import ballerina/io;
import ballerinax/twilio;
import ballerina/log;

// Types
type SalesforceListenerConfig record {
    string username;
    string password;
};

type TwilioClientConfig record {
    string accountSId;
    string authToken;
};
type Lead record {
    string Id;
    string FirstName;
    string LastName;
    string Company;
    string Email;
    string Title;
    string Phone;
};

type SalesforceOAuth2Config record {
    string clientId;
    string clientSecret;
    string refreshToken;
    string refreshUrl = "https://login.salesforce.com/services/oauth2/token";
};

configurable SalesforceOAuth2Config salesforceOAuthConfig = ?;

sfdc:Client sfdcClient = check new ({
    baseUrl: "wso2--ballerina.sandbox.my.salesforce.com",
    auth: {
        clientId: salesforceOAuthConfig.clientId,
        clientSecret: salesforceOAuthConfig.clientSecret,
        refreshToken: salesforceOAuthConfig.refreshToken,
        refreshUrl: salesforceOAuthConfig.refreshUrl
    }
});

twilio:Client twilioClient = check new ({
            twilioAuth: {
                accountSId: twilioClientConfig.accountSId,
                authToken: twilioClientConfig.authToken
            }
        });

// Constants
const string COMMA = ",";
const string EQUAL_SIGN = "=";
const string CLOSING_BRACKET = "}";
const string NO_STRING = "";

configurable TwilioClientConfig twilioClientConfig = ?;
configurable string fromNumber = ?;
configurable string toNumber = ?;

public function main() returns error? {
    stream<Lead, error?>|error query = sfdcClient->query("SELECT Id,FirstName,LastName, Company, Email, Title FROM Lead");
    if query !is error {
        record {|Lead value;|}|error? leadValue = query.next();
        while leadValue is record {|Lead value;|} {
            string firstName = leadValue.value.FirstName;
            string lastName = leadValue.value.LastName;
            string company = leadValue.value.Company;
            string email = leadValue.value.Email;
            string title = leadValue.value.Title;
            string message = string `New lead is created! | Name: ${firstName} ${lastName} | Organization: ${company} | Email: ${email} | Title: ${title}`;
            twilio:SmsResponse response = check twilioClient->sendSms(fromNumber, toNumber, message);
            log:printInfo("SMS(SID: "+ response.sid +") sent successfully");
            leadValue = query.next();

        }
    } else {
        io:println(query);
    }
    
}
