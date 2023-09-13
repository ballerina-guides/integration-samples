import ballerina/email;
import ballerina/log;
import ballerinax/newsapi;

// News API configuration
configurable newsapi:ApiKeysConfig apiKeyConfig = ?;

// Email client configuration parameters
configurable string smtpPassword = ?;
configurable string smtpUsername = ?;
configurable string smtpHost = ?;

// Email configuration parameters
configurable string fromAddress = ?;
configurable string emailAddress = ?;

public function main() returns error? {
    newsapi:Client newsapi = check new (apiKeyConfig, {}, "https://newsapi.org/v2");
    email:SmtpClient email = check new (smtpHost, smtpUsername, smtpPassword);
    newsapi:WSNewsTopHeadlineResponse topHeadlines = check newsapi->listTopHeadlines(sources = "bbc-news", page = 1);
    newsapi:WSNewsArticle[]? articles = topHeadlines?.articles;
    if articles is () || articles.length() == 0 {
        log:printInfo("No news found");
        return;
    }
    string mailBody = "BBC top news are,\n";
    foreach newsapi:WSNewsArticle article in articles {
        string? title = article?.title;
        if title is string {
            mailBody = mailBody + string `${title}${"\n"}`;
        }
    }
    email:Message message = {
        to: emailAddress,
        'from: fromAddress,
        subject: "BBC Headlines",
        body: mailBody
    };
    check email->sendMessage(message);
    log:printInfo("Email sent successfully!");
}
