import ballerina/http;
import ballerinax/googleapis.sheets;

configurable string githubPAT = ?;
configurable string sheetsAccessToken = ?;
configurable string spreadSheetId = ?;
configurable string sheetName = "Sheet1";

type PR record {
    string url;
    string title;
    string state;
    string created_at;
    string updated_at;
};

public function main1() returns error? {
    http:Client github = check new ("https://api.github.com/repos");
    map<string> headers = {
        "Accept": "application/vnd.github.v3+json",
        "Authorization": "token " + githubPAT
    };
    
    // Network data == program data
    PR[] prs = check github->/octocat/Hello\-World/pulls(headers);

    sheets:Client gsheets = check new ({auth: {token: sheetsAccessToken}});
    check gsheets->appendRowToSheet(spreadSheetId, sheetName,
            ["Issue", "Title", "State", "Created At", "Updated At"]);

    foreach var {url, title, state, created_at, updated_at} in prs {
        check gsheets->appendRowToSheet(spreadSheetId, sheetName,
                [url, title, state, created_at, updated_at]);
    }
}
