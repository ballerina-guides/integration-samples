# GitHub pull requests to Google Sheets

Read the pull requests of a GitHub repository with an HTTP client, bind the response to typed `PR` records, and append each pull request's URL, title, state, creation time, and update time to a Google Sheets worksheet through the Google Sheets connector. Both services are live; there is no mock backend.

## Prerequisites

- Ballerina 2201.14.0 (`bal version`). `ballerinax/googleapis.sheets` 4.0.0 is declared in `Ballerina.toml` and locked in `Dependencies.toml`.
- A [GitHub personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with read access to the configured repository.
- A Google account with the Google Sheets API enabled, an OAuth access token with spreadsheet edit scope (for example, from the [OAuth 2.0 Playground](https://developers.google.com/oauthplayground/)), and a spreadsheet containing a `pull-requests` worksheet. Access tokens expire; refresh yours before running.

## Run

Copy `Config.toml.example` to `Config.toml` and replace the placeholders. Keep the real file private. Optionally set `repository` and `sheetName` to use a different repository or worksheet. Then run:

```sh
bal build
bal run
```

## Verify

The sample appends the header `Issue, Title, State, Created At, Updated At`, then one row per pull request returned by `GET /repos/{repository}/pulls`. Inspect the worksheet for rows matching the live response. `expected-row.json` shows the shape of one row; the actual values depend on the repository. Invalid tokens or an inaccessible sheet return an error. The header and rows are appended again on each run.
