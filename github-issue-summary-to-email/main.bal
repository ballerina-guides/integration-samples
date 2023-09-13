import ballerina/email;
import ballerina/log;
import ballerinax/github;

// Github client configuration parameters
configurable string githubAccessToken = ?;
configurable string orgName = ?;
configurable string repoName = ?;

// Email client configuration parameters
configurable string smtpPassword = ?;
configurable string smtpUsername = ?;
configurable string smtpHost = ?;

// Email configuration parameters 
configurable string recipientAddress = ?;
configurable string fromAddress = ?;

public function main() returns error? {
    github:Client github = check new ({
        auth: {
            token: githubAccessToken
        }
    });
    email:SmtpClient email = check new (host = smtpHost, username = smtpUsername, password = smtpPassword);

    //Get collaborator list
    string assigneeSummary = "";
    stream<github:User, github:Error?> collaborators = check github->getCollaborators(orgName, repoName);
    check collaborators.forEach(function(github:User user) {
        string query = string `repo:${orgName}/${repoName} is:issue assignee:${user.login}`;
        github:SearchResult|github:Error issuesForAssignee = github->search(query, github:SEARCH_TYPE_ISSUE, 1);
        if issuesForAssignee is github:SearchResult {
            string userName = user?.name ?: "Unknown";
            assigneeSummary += string `${userName} : ${issuesForAssignee.issueCount} ${"\n"}`;
        } else {
            log:printError("Error while searching issues of an assignee.", 'error = issuesForAssignee);
        }
    });

    //Get open issues
    string query = string `repo:${orgName}/${repoName} is:issue is:open`;
    github:SearchResult|github:Error openIssues = github->search(query, github:SEARCH_TYPE_ISSUE, 1);
    if openIssues is github:Error {
        log:printError("Error while searching open issues.", 'error = openIssues);
    }
    int totalOpenIssueCount = openIssues is github:SearchResult ? openIssues.issueCount : 0;

    //Get closed issues
    query = string `repo:${orgName}/${repoName} is:issue is:closed`;
    github:SearchResult|github:Error closedIssues = github->search(query, github:SEARCH_TYPE_ISSUE, 1);
    if closedIssues is github:Error {
        log:printError("Error while searching closed issues.", 'error = closedIssues);
    }
    int totalClosedIssueCount = closedIssues is github:SearchResult ? closedIssues.issueCount : 0;

    //Send email
    string issueSummary = string `ISSUE SUMMARY REPORT${"\n\n"}Repository Name: ${repoName}
        ${"\n"}Total Issues Open: ${totalOpenIssueCount} ${"\n"}Total Issues Closed: ${totalClosedIssueCount}
        ${"\n\n"}Issue Count by Assignee: ${"\n"}${assigneeSummary} ${"\n"}`;
    email:Message message = {
        to: recipientAddress,
        'from: fromAddress,
        subject: "Git Issue Summary",
        body: issueSummary
    };
    check email->sendMessage(message);
    log:printInfo("Email sent successfully!");
}
