import ballerina/log;
import ballerinax/googleapis.gmail as gmail;
import ballerina/mime;
import ballerinax/salesforce as sfdc;
import ballerina/lang.runtime;
import ballerinax/openai.chat as openAI;

configurable GmailOAuth2Config gmailOAuth2Config = ?;
gmail:ConnectionConfig gmailConfig = {
    auth: {
        refreshUrl: gmail:REFRESH_URL,
        refreshToken: gmailOAuth2Config.refreshToken,
        clientId: gmailOAuth2Config.clientId,
        clientSecret: gmailOAuth2Config.clientSecret
    }
};

configurable SalesforceOAuth2Config salesforceOAuth2Config = ?;
sfdc:ConnectionConfig sfdcConfig = {
    baseUrl: salesforceOAuth2Config.baseUrl,
    auth: {
        clientId: salesforceOAuth2Config.clientId,
        clientSecret: salesforceOAuth2Config.clientSecret,
        refreshToken: salesforceOAuth2Config.refreshToken,
        refreshUrl: salesforceOAuth2Config.refreshUrl
    }
};

configurable string openAIKey = ?;

final string label = "Lead";

public function main() returns error? {
    while true {
        Email[] emails = check getEmails(label);

        Lead[] leads = [];
        from Email email in emails
        do {
            Lead|error lead = generateLead(email.'from, email.subject, email.body);
            if lead is Lead {
                leads.push(lead);
            }
        };

        check addLeadsToSalesforce(leads);

        runtime:sleep(600);
    }
}

function getEmails(string label) returns Email[]|error {
    gmail:Client gmailClient = check new (gmailConfig);

    string[] labelIdsToMatch = check getLabelIds(gmailClient, [label]);
    if (labelIdsToMatch.length() == 0) {
        error e = error("Unable to find any labels to match.");
        return e;
    }

    gmail:MailThread[] matchingMailThreads = check getMatchingMailThreads(gmailClient, labelIdsToMatch);
    removeLabels(gmailClient, matchingMailThreads, labelIdsToMatch);

    gmail:Message[] matchingEmails = getMatchingEmails(gmailClient, matchingMailThreads);

    Email[] emails = [];
    from gmail:Message message in matchingEmails
    do {
        Email|error email = parseEmail(message);
        if email is Email {
            emails.push(email);
        }    
    };
    
    return emails;
}

function getLabelIds(gmail:Client gmailClient, string[] labelsToMatch) returns string[]|error {
    gmail:LabelList labelList = check gmailClient->listLabels("me");

    return from gmail:Label label in labelList.labels
        where labelsToMatch.indexOf(label.name) != ()
        select label.id;
}

function getMatchingMailThreads(gmail:Client gmailClient, string[] labelIdsToMatch) returns gmail:MailThread[]|error {
    gmail:MsgSearchFilter searchFilter = {
        includeSpamTrash: false,
        labelIds: labelIdsToMatch
    };

    stream<gmail:MailThread, error?>|error mailThreadStream = gmailClient->listThreads(filter = searchFilter);
    if mailThreadStream is error {
        return mailThreadStream;
    }

    return check from gmail:MailThread mailThread in mailThreadStream
        select mailThread;
}

function removeLabels(gmail:Client gmailClient, gmail:MailThread[] mailThreads, string[] labelIds) {
    from gmail:MailThread mailThread in mailThreads
    do {
        gmail:MailThread|error removeLabelResponse = gmailClient->modifyThread(mailThread.id, [], labelIds);
        if removeLabelResponse is error {
            log:printError("An error occured in removing the labels from the thread.", removeLabelResponse, removeLabelResponse.stackTrace(), threadId = mailThread.id, labelIds = labelIds);
        }
    };
}

function getMatchingEmails(gmail:Client gmailClient, gmail:MailThread[] mailThreads) returns gmail:Message[] {
    gmail:Message[] messages = [];
    _ = from gmail:MailThread mailThread in mailThreads
        do {
            gmail:MailThread|error response = gmailClient->readThread(mailThread.id);
            if response is error {
                log:printError("An error occured while reading the email.", response, response.stackTrace(), threadId = mailThread.id);
            } else {
                messages.push((<gmail:Message[]>response.messages)[0]);
            }
        };

    return messages;
}

function parseEmail(gmail:Message message) returns Email|error {
    string 'from = <string>message.headerFrom;
    string subject = <string>message.headerSubject;
    string body = <string>(check mime:base64Decode(<string>(<gmail:MessageBodyPart>message.emailBodyInText).data));

    return {
        'from: 'from,
        subject: subject,
        body: body
    };
}

function generateLead(string 'from, string subject, string body) returns Lead|error {
    openAI:Client openAIClient = check new ({
        auth: {token: openAIKey}
    });

    openAI:CreateChatCompletionRequest request = {
        model: "gpt-3.5-turbo",
        messages: [
            {
                role: "user",
                content: string `
            Extract the following details in JSON from the email.
                {
                    firstName__c: string, // Mandatory
                    lastName__c: string, // Mandatory
                    email__c: string // Mandatory
                    phoneNumber__c: string, // With country code. Use N/A if unable to find
                    company__c: string, // Mandatory
                    designation__c: string // Not mandator. Use N/A if unable to find
                }

            Here is the email:    
            {
                from: ${'from},
                subject: ${subject},
                body: ${body}
            }
        `
            }
        ]
    };

    openAI:CreateChatCompletionResponse response = check openAIClient->/chat/completions.post(request);

    Lead result = check (<string>response.choices[0].message?.content).fromJsonStringWithType(Lead);
    return result;
}

function addLeadsToSalesforce(Lead[] leads) returns error? {
    sfdc:Client sfdcClient = check new (sfdcConfig);

    from Lead lead in leads
    do {
        sfdc:CreationResponse|error createResponse = check sfdcClient->create("EmailLead__c", lead);
        if createResponse is error {
            log:printError("An error occured while creating a Lead object on salesforce.", createResponse, createResponse.stackTrace(), lead = lead);
        } else {
            log:printInfo("Lead successfully created.", lead = lead);
        }
    };
}
