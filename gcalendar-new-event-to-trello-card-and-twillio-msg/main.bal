import ballerina/http;
import ballerinax/trello;
import ballerinax/trigger.google.calendar;
import ballerinax/twilio;
import ballerina/log;

// Google Calendar configuration parameters
configurable calendar:ListenerConfig config = ?;

// Trello configuration parameters
configurable string trelloApiKey = ?;
configurable string trelloApiToken = ?;
configurable string trelloListId = ?;

// Twillio configuration parameters

configurable string twAccountSId = ?;
configurable string twAuthToken = ?;
configurable string twFromMobile = ?;
configurable string twToMobile = ?;

trello:ApiKeysConfig apiKeyConfig = {
    key: trelloApiKey,
    token: trelloApiToken
};

twilio:TokenBasedAuthentication twilioAuth = {
    accountSId: twAccountSId,
    authToken: twAuthToken
};

http:RetryConfig retryConfig = {
    // The initial retry interval in seconds.
    interval: 3,

    // The number of retry attempts before stopping.
    count: 3,

    // The multiplier of the retry interval exponentially increases the retry interval.
    backOffFactor: 2.0,

    // The upper limit of the retry interval is in seconds. If the `interval` into the `backOffFactor`
    // value exceeded the `maxWaitInterval` interval value, `maxWaitInterval` is considered as the retry interval.
    maxWaitInterval: 20
};

listener http:Listener httpListener = new (8090);
listener calendar:Listener calendarListener = new (config, httpListener);
final trello:Client trello = check new (apiKeyConfig, {retryConfig});
final twilio:Client twilio = check new ({twilioAuth, retryConfig});

service calendar:CalendarService on calendarListener {

    remote function onNewEvent(calendar:Event payload) returns error? {
        do {
            // Add the card to the Trello list
            trello:Cards card = calEventToTrelloCard(payload);
            _ = check trello->addCards(card);

            // Send SMS notification
            string twillioMsg = calEventToMessage(payload);
            _ = check twilio->sendSms(twFromMobile, twToMobile, twillioMsg);

        } on fail var e {
            // Log the error and add the event to the dead letter queue
            log:printError(string `Failed to process the calender event:${payload.id}`, 'error = e);
            toDeadLetterChannel(payload, e);
        }
    }

    remote function onEventDelete(calendar:Event payload) returns error? {
    }

    remote function onEventUpdate(calendar:Event payload) returns error? {
    }
}

function calEventToTrelloCard(calendar:Event calEvent) returns trello:Cards => {
    name: calEvent.summary,
    due: calEvent.end?.dateTime,
    idList: trelloListId,
    desc: string `New event is created on Google Calendar: ${calEvent.summary ?: ""}. 
        The event starts on ${calEvent.'start?.dateTime ?: ""} and ends on ${calEvent.end?.dateTime ?: ""}`
};

function calEventToMessage(calendar:Event calEvent) returns string =>
    string `New event is created : ${calEvent.summary ?: ""} starts on ${calEvent.'start?.dateTime ?: ""} 
    ends on ${calEvent.end?.dateTime ?: ""}`;

function toDeadLetterChannel(calendar:Event calEvent, error e) {
    // Add the event to the dead letter queue
}

