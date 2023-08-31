import ballerina/email;
import ballerina/log;
import ballerinax/newsapi;

//News API configuration
configurable newsapi:ApiKeysConfig apiKeyConfig = ?;
configurable string emailAddress = ?;
configurable string smtpPassword = ?;
configurable string smtpUsername = ?;
configurable string smtpHost = ?;
configurable string fromAddress = ?;

public function main() returns error? {
    newsapi:Client newsapi = check new (apiKeyConfig, {}, "https://newsapi.org/v2");
    email:SmtpClient smtpClient = check new (smtpHost, smtpUsername, smtpPassword);
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
    email:Message email = {
        to: emailAddress,
        'from: fromAddress,
        subject: "BBC Headlines",
        body: mailBody
    };
    check smtpClient->sendMessage(email);
    log:printInfo("Email sent successfully!");
}
