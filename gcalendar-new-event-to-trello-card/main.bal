import ballerina/http;
import ballerinax/trello;
import ballerinax/trigger.google.calendar;

// Google Calendar configuration parameters
configurable calendar:ListenerConfig calendarListenerConfig = ?;

// Trello configuration parameters
configurable string trelloApiKey = ?;
configurable string trelloApiToken = ?;
configurable string trelloListId = ?;

trello:ApiKeysConfig apiKeyConfig = {
    key: trelloApiKey,
    token: trelloApiToken
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
final trello:Client trello = check new (apiKeyConfig, {retryConfig});

listener http:Listener httpListener = new (8090);
listener calendar:Listener calendarListener = new (calendarListenerConfig, httpListener);
service calendar:CalendarService on calendarListener {

    remote function onNewEvent(calendar:Event payload) returns error? {
        // Mapping from Google Calendar Event to Trello Card
        trello:Cards card = transform(payload);

        // Add the card to the Trello list
        var _ = check trello->addCards(card);
    }

    remote function onEventDelete(calendar:Event payload) returns error? {
    }

    remote function onEventUpdate(calendar:Event payload) returns error? {
    }
}

function transform(calendar:Event calEvent) returns trello:Cards => {
    name: calEvent.summary,
    due: calEvent.end?.dateTime,
    idList: trelloListId,
    desc: string `New event is created on Google Calendar: ${calEvent.summary ?: ""}. 
        The event starts on ${calEvent.'start?.dateTime ?: ""} and ends on ${calEvent.end?.dateTime ?: ""}`
};
