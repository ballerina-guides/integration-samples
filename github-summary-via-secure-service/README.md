# GitHub summary via secure service

This sample sends a summary of GitHub pull requests via a secure HTTP service.

## Use case

This secure HTTP service will send a summary of GitHub pull requests of the configured GitHub repo.

## Prerequisites

* GitHub account
* SSL certificates

### Obtaining SSL certificates for the service

Generate SSL certificates for the service using OpenSSL. For testing purposes, you can generate a self-signed certificate.

### Setting up GitHub PAT

1. Follow the instructions in [Creating a personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) to generate a PAT

## Configuration

Create a file called `Config.toml` at the root of the project.

### Config.toml

```
pulicCertPath= "<REFRESH_TOKEN>"
privateKeyPath= "<CLIENT_ID>"

githubPAT = "<GITHIB_PAT>"
githubRepo = "<GITHUB_REPO>"
```

## Testing

- Run the program by executing `bal run` from the root. 
