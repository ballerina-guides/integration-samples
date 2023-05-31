import ballerina/io;
import ballerina/websub;

@websub:SubscriberServiceConfig {
    target: [
        "https://api.github.com/hub", 
        "https://github.com/<YOUR_ORGANIZATION>/<REPOSITORY>/events/push.json"
    ],
    secret: "<YOUR_SECRET_KEY>",
    httpConfig: {
        auth: {
            token: "<YOUR_AUTH_TOKEN>"
        }
    }
}
service on new websub:Listener(9090) {
    remote function onEventNotification(websub:ContentDistributionMessage event) returns error? {

        // Get the expected json payload
        json retrievedContent = check event.content.ensureType();

        // Handle the new event
        if retrievedContent.zen is string {
            int hookId = check retrievedContent.hook_id;
            io:println(string `PingEvent received for webhook [${hookId}]`);
        } else if retrievedContent.ref is string {
            string repositoryName = check retrievedContent.repository.name;
            io:println(string `PushEvent received for [${repositoryName}]`);
        }
    }
}
