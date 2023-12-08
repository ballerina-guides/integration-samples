import ballerina/mime;
import ballerinax/googleapis.gmail;
import ballerinax/openai.chat;
import ballerinax/salesforce as sf;

type Email record {|
    string 'from;
    string subject;
    string body;
|};

type Name record {|
    string firstName__c;
    string lastName__c;
|};

type Lead record {|
    *Name;
    string email__c;
    string phoneNumber__c;
    string company__c;
    string designation__c;
|};

configurable string gmailAccessToken = ?;
configurable string openAIKey = ?;
configurable string salesforceBaseUrl = ?;
configurable string salesforceAccessToken = ?;

gmail:Client gmail = check new ({auth: {token: gmailAccessToken}});
chat:Client openAiChat = check new ({auth: {token: openAIKey}});
sf:Client salesforce = check new ({baseUrl: salesforceBaseUrl, auth: {token: salesforceAccessToken}});

public function main() returns error? {
    gmail:LabelList labelList = check gmail->listLabels("me");
    string[] labelIdsToMatch = from gmail:Label {name, id} in labelList.labels
        where ["Lead"].indexOf(name) != ()
        select id;
    gmail:MsgSearchFilter searchFilter = {
        includeSpamTrash: false,
        labelIds: labelIdsToMatch
    };
    gmail:MailThread[] matchingMailThreads = check from gmail:MailThread mailThread
        in check gmail->listThreads(filter = searchFilter)
        select mailThread;
    foreach gmail:MailThread mailThread in matchingMailThreads {
        _ = check gmail->modifyThread(mailThread.id, [], labelIdsToMatch);
    }
    gmail:Message[] matchingEmails = [];
    foreach gmail:MailThread mailThread in matchingMailThreads {
        gmail:MailThread response = check gmail->readThread(mailThread.id);
        matchingEmails.push((<gmail:Message[]>response.messages)[0]);
    }
    Email[] emails = from gmail:Message message in matchingEmails
        let Email|error email = parseEmail(message)
        where email is Email
        select email;
    Lead[] leads = from Email email in emails
        let Lead? lead = check generateLead(email, openAiChat)
        where lead is Lead
        select lead;
    from Lead lead in leads
    do {
        _ = check salesforce->create("EmailLead__c", lead);
    };
}

function parseEmail(gmail:Message message) returns Email|error {
    do {
        gmail:MessageBodyPart bodyPart = check message.emailBodyInText.ensureType(gmail:MessageBodyPart);
        string bodyPartText = check bodyPart.data.ensureType(string);
        string body = check mime:base64Decode(bodyPartText).ensureType(string);

        return {
            'from: check message.headerFrom.ensureType(string),
            subject: check message.headerSubject.ensureType(string),
            body: body
        };
    } on fail error e {
        return e;
    }
}

function generateLead(Email email, chat:Client openAiChat) returns Lead|error {
    chat:CreateChatCompletionRequest request = {
        model: "gpt-3.5-turbo",
        messages: [
            {
                role: "user",
                content: string
            `Extract the following details in JSON from the email.
                {
                    firstName__c: string, // Mandatory
                    lastName__c: string, // Mandatory
                    email__c: string // Mandatory
                    phoneNumber__c: string, // With country code. Use N/A if unable to find
                    company__c: string, // Mandatory
                    designation__c: string // Not mandatory. Use N/A if unable to find
                }

            Here is the email:    
            {
                from: ${email.'from},
                subject: ${email.subject},
                body: ${email.body}
            }`
            }
        ]
    };

    do {
        chat:CreateChatCompletionResponse response = check openAiChat->/chat/completions.post(request);
        if response.choices.length() < 1 {
            check error("Unable to find any choices in the response.");
        }
        string content = check response.choices[0].message?.content.ensureType(string);
        return check content.fromJsonStringWithType(Lead);
    } on fail error e {
        return e;
    }
};
