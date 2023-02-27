import ballerina/http;
import ballerinax/trello;
import ballerinax/trigger.google.calendar;

listener http:Listener httpListener = new (8090);

// Google Calendar configuration parameters
configurable calendar:ListenerConfig config = ?;

// Trello configuration parameters
configurable string trelloApiKey = ?;
configurable string trelloApiToken = ?;
configurable string trelloListId = ?;

listener calendar:Listener calendarListener = new (config, httpListener);

trello:ApiKeysConfig apiKeyConfig = {
    key: trelloApiKey,
    token: trelloApiToken
};

http:CircuitBreakerConfig circuitBreaker = {
    rollingWindow: {
        timeWindow: 10,
        bucketSize: 2,
        requestVolumeThreshold: 0
    },
    failureThreshold: 0.2,
    resetTime: 10,
    statusCodes: [400, 404, 500]
};
final trello:Client trello = check new (apiKeyConfig, {circuitBreaker});

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