# GitHub Issue Summary Report to Email

This example [GitHub](https://www.github.com/) generates an issue summary report and emails to a specified email 
address using GitHub and Ballerina integration.

## Use case
Managers always like summaries. This example generates a report out of the issues reported at a GitHub repository.
It contains information on how many issues are assigned to each contributor to the project, total issues opened, and total
issues closed so far. You could configure this report to be generated daily and emailed out to the specified email address.
It will provide continuous feedback about the project issue status.

## Prerequisites
* GitHub account
* Email account

## Configuration
Create a file called `Config.toml` at the root of the project.

### Config.toml
```
[<ORG_NAME>.github_issue_summary_to_email]
githubAccessToken = "<GITHUB_ACCESS_TOKEN>"  
repoName = "<REPO_NAME>"
orgName = "<REPO_OWNER>"
recipientAddress = "<RECIPIENT_EMAILADDRESS>"
smtpPassword = "<SMTP_PASSWORD>"
smtpUsername = "<SMTP_USERNAME>"
smtpHost = "<SMTP_HOST_NAME>"
fromAddress = "<SMTP_FROM_ADDRESS>"
```
* GITHUB_ACCESS_TOKEN - obtain a [Personal access token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token) or [GitHub OAuth App token](https://docs.github.com/en/developers/apps/creating-an-oauth-app).
* REPO_NAME - [create a repository](https://docs.github.com/en/get-started/quickstart/create-a-repo)
* RECIPIENT_ADDRESS - an email address

## Testing
Run the Ballerina project by executing `bal run` from the root.
Once successfully executed, the GitHub issue summary report will be sent to the specified email.
