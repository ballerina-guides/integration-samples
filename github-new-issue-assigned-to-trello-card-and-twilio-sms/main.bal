import ballerinax/trello;
import ballerinax/trigger.github;
import ballerinax/twilio;

configurable string githubUser = ?;

configurable string twilioAccountSid = ?;
configurable string twilioAuthToken = ?;
configurable string twilioFrom = ?;
configurable string twilioTo = ?;

configurable string trelloApiKey = ?;
configurable string trelloApiToken = ?;
configurable string trelloListId = ?;

final trello:Client trello = check new ({
    key: trelloApiKey,
    token: trelloApiToken
});

final twilio:Client twilio = check new ({
    twilioAuth: {
        accountSId: twilioAccountSid,
        authToken: twilioAuthToken
    }
});

service github:IssuesService on new github:Listener() {
    remote function onAssigned(github:IssuesEvent payload) returns error? {
        if payload.issue.assignee?.login != githubUser {
            return;
        }
        string message = string `Github new issue assigned!${"\n"}Title: ${payload.issue.title}${"\n"}URL: ${payload.issue.html_url}${"\n"}`;
        _ = check twilio->sendSms(twilioFrom, twilioTo, message);
        
        trello:Cards card = transform(payload.issue.title, message);
        var _ = check trello->addCards(card);

    }

    remote function onOpened(github:IssuesEvent payload) returns error? {
        return;
    }
    remote function onClosed(github:IssuesEvent payload) returns error? {
        return;
    }
    remote function onReopened(github:IssuesEvent payload) returns error? {
        return;
    }
    remote function onUnassigned(github:IssuesEvent payload) returns error? {
        return;
    }
    remote function onLabeled(github:IssuesEvent payload) returns error? {
        return;
    }
    remote function onUnlabeled(github:IssuesEvent payload) returns error? {
        return;
    }
}

function transform(string title, string message) returns trello:Cards => {
    name: title,
    idList: trelloListId,
    desc: message
};
