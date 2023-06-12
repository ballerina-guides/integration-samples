import ballerina/http;
import ballerinax/slack;

configurable string slackToken = ?;

type Blog record {
    string title;
    string content;
};

Blog[] blogs = [];

service /blog on new http:Listener(9090) {
    slack:Client slackClient;

    public function init() returns error? {
        slack:ConnectionConfig slackConfig = {
            auth: {
                token: slackToken
            }
        };
        self.slackClient = check new(slackConfig);
    }

    resource function get .() returns Blog[] {
        return blogs;
    }

    resource function post .(@http:Payload Blog blog) returns error? {
        future<error?> slackFuture = start self.notifySlack(blog);
        blogs.push(blog);
        check wait slackFuture;
    }

    function notifySlack(Blog blog) returns error? {
        slack:Message messageParams = {
            channelName: "Test Channel",
            text: "New Blog is created : " + blog.title
        };
        _ = check self.slackClient->postMessage(messageParams);
    }
}