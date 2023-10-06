import ballerina/http;
import ballerinax/googleapis.gmail;

configurable string gmailRefreshToken = ?;
configurable string gmailClientId = ?;
configurable string gmailClientSecret = ?;
configurable string gmailRecipient = ?;

configurable string githubPAT = ?;
configurable string githubOrg = ?;
configurable string githubRepo = ?;

type PR record {
    string url;
    string title;
    string created_at;
};

gmail:ConnectionConfig gmailConfig = {
    auth: {
        refreshUrl: gmail:REFRESH_URL,
        refreshToken: gmailRefreshToken,
        clientId: gmailClientId,
        clientSecret: gmailClientSecret
    }
};
final gmail:Client gmailClient = check new (gmailConfig);

final http:Client github = check new ("https://api.github.com");
final map<string> headers = {
    "Accept": "application/vnd.github.v3+json",
    "Authorization": "token " + githubPAT
};

public function main() returns error? {
    PR[] prs = check github->get(string `/repos/${githubOrg}/${githubRepo}/pulls`, headers);
    _ = check gmailClient->sendMessage(transform(prs));

}

function transform(PR[] prs) returns gmail:MessageRequest => {
    recipient: gmailRecipient,
    subject: "[Github Summary] Open PR Details",
    messageBody: constructMailBody(prs),
    contentType: gmail:TEXT_PLAIN
};

function constructMailBody(PR[] prs) returns string {
    string mailBody = string `Total PR Count : ${prs.length()}${"\n"}${"\n"}Title|Created At|Link${"\n"}`;
    foreach var {url, title, created_at} in prs {
        mailBody += string `${title}|${created_at}|${url}${"\n"}`;
    }
    return mailBody;
}
