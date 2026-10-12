# GitHub pull requests to Google Sheets

Read GitHub pull requests and append their number, title, state, URL, and creation time to a Google Sheet. This returns to the earlier Consuming Services scenario. It uses the live GitHub and Google Sheets REST APIs through Ballerina's HTTP client; there is no mock backend. Re-running appends duplicates.

## Prerequisites and dependencies

- Ballerina 2201.14.0 (`bal version`). `Ballerina.toml` pins the distribution; `ballerina/http` is supplied with it and its version is recorded in `Dependencies.toml` after `bal build`.
- A GitHub token with read access to the configured repository, or a fine-grained token with Pull requests read permission.
- A Google account, Sheets API enabled, OAuth access token with spreadsheet edit scope, and a spreadsheet containing a `pull-requests` worksheet. Access tokens expire; refresh yours before running.

## Run and verify

Copy `Config.toml.example` to `Config.toml` and replace placeholders. Keep the real file private. From this directory run `bal build` and `bal run`. The source uses GitHub's `GET /repos/{owner}/{repo}/pulls`, then posts each row to the Sheets values append API. Check console lines such as `Appended pull request #123` and inspect the worksheet for matching number, title, state, URL, and creation time. The specific rows depend on the live repository. A read-only fixture of expected columns is in `expected-row.json`; it is illustrative, not a network test. Invalid tokens or an inaccessible sheet return an error.
