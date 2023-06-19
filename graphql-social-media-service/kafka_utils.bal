import graphql_social_media.db;

import ballerina/log;
import ballerinax/kafka;

configurable decimal POLL_INTERVAL = 100.0;

isolated function publishPost(db:Post post) returns error? {
    kafka:Producer producer = check new (kafka:DEFAULT_URL);
    check producer->send({topic: POST_TOPIC, value: post});
    check producer->close();
}

isolated class PostStreamGenerator {
    private final string consumerGroup;
    private final kafka:Consumer consumer;

    isolated function init(string consumerGroup) returns error? {
        self.consumerGroup = consumerGroup;
        kafka:ConsumerConfiguration consumerConfiguration = {
            groupId: consumerGroup,
            offsetReset: "earliest",
            topics: POST_TOPIC,
            maxPollRecords: 1 // Limit the number of records to be polled at a time
        };
        self.consumer = check new (kafka:DEFAULT_URL, consumerConfiguration);
    }

    public isolated function next() returns record {|Post value;|}|error? {
        db:Post[]|error posts = self.consumer->pollPayload(POLL_INTERVAL);
        if posts is error {
            // Log the error with the consumer group id and return nil
            log:printError("Failed to retrieve data from the Kafka server", posts, id = self.consumerGroup);
            return posts;
        }
        if posts.length() < 1 {
            // Log the warning with the consumer group id and return nil. This will end the subscription as returning
            // nil will be interpreted as the end of the stream.
            log:printWarn("No new posts available", id = self.consumerGroup);
            return;
        }
        return {value: new (posts[0])};
    }
}
