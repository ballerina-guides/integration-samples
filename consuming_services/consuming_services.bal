import ballerina/http;
import ballerina/io;

configurable string githubToken = ?;
configurable string sheetsAccessToken = ?;
configurable string spreadsheetId = ?;
configurable string sheetName = "Issues";
configurable string githubOwner = "ballerina-platform";
configurable string githubRepo = "ballerina-lang";

type Issue record {|
    int number;
    string title;
    string state;
    string html_url;
    json? pull_request?;
|};

public function main() returns error? {
    http:Client github = check new ("https://api.github.com/repos");
    map<string> headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": "Bearer " + githubToken,
        "User-Agent": "ballerina-integration-samples"
    };
    Issue[] issues = check github->/[githubOwner]/[githubRepo]/issues(headers);
    http:Client sheets = check new ("https://sheets.googleapis.com");
    foreach Issue issue in issues {
        if issue?.pull_request is () {
            http:Request append = new;
            append.setHeader("Authorization", "Bearer " + sheetsAccessToken);
            append.setJsonPayload({values: [[issue.number.toString(),
                issue.title, issue.state, issue.html_url]]});
            string path = "/v4/spreadsheets/" + spreadsheetId +
                "/values/" + sheetName + "!A:D:append?valueInputOption=RAW";
            http:Response response = check sheets->post(path, append);
            if response.statusCode >= 300 {
                return error("Google Sheets append failed");
            }
            io:println("Appended issue #", issue.number);
        }
    }
}
