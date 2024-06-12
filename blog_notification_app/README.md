# Blog Notification Application

This application demonstrates how to write a simple blog backend application using Ballerina. It also sends slack notification to a slack channel when a new blog is added.

## Prerequisites

### Setting up Slack tokens
1. Visit https://api.slack.com/apps 
2. Click `Create New App` and select the `From scratch` option.
3. Create the app by providing an `App name` and selecting the workspace on where to send the notifications. 
4. In the `Add features and functionality` section, Click `Permissions`.
5. Go to the `Scopes` section and add necessary OAuth scopes in `User Token Scopes` section. (`channels:history`, `channels:read`, `channels:write`, `chat:write`, `emoji:read`, `files:read`, `files:write`, `groups:read`, `reactions:read`, `users:read`, `users:read.email`)
6. Go back to the `Basic Information` section of your Slack App. Then go to the `Install your app section` and install the app to the workspace by clicking the `Install to Workspace` button.
7. Get your User OAuth token from the `OAuth & Permissions` section of your Slack App


### Configuring the Slack token
1. Create a file named `Config.toml` in the blog_app directory and add the following content to it. Replace the `slackToken` with the token you got from the previous step.

```
slackToken = <token>
```

## Running the Sample

- Run the ballerina application `bal run`

## Testing the Sample


- Create a blog
```
curl --location 'http://localhost:9090/blog' \
--header 'Content-Type: application/json' \
--data-raw '{
    "title": "Sample Blog",
    "content": "This is a sample blog"
}'
```
- You should see a slack notification in the configured slack channel.
