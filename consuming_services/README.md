# GitHub pull requests to Google Sheets

Read GitHub pull requests with Ballerina's HTTP client, then append their API URL, title, state, creation time, and update time through the Google Sheets connector. This is the complete Consuming Services source displayed on the homepage. Both services are live; there is no mock backend. Re-running appends another header and duplicate rows.

## Prerequisites and dependencies

- Ballerina 2201.14.0 (`bal version`). `ballerina/http` comes with the distribution. `ballerinax/googleapis.sheets` 4.0.0 is declared in `Ballerina.toml` and locked in `Dependencies.toml`; build with `bal build --locking-mode=hard` to keep the verified version.
- A GitHub token with read access to the configured repository, or a fine-grained token with Pull requests read permission.
- A Google account, Sheets API enabled, OAuth access token with spreadsheet edit scope, and a spreadsheet containing a `pull-requests` worksheet. Access tokens expire; refresh yours before running.

## Run and verify

Copy `Config.toml.example` to `Config.toml` and replace the placeholders. Keep the real file private. From this directory run `bal build --locking-mode=hard` and `bal run --locking-mode=hard`. The source calls GitHub's `GET /repos/{repository}/pulls`, appends the literal header `Issue, Title, State, Created At, Updated At`, then appends one row per returned pull request. The first data column contains GitHub's API URL (`url`), not a pull-request number or browser URL; the header is intentionally kept exactly as in the homepage code. Inspect the `pull-requests` worksheet for rows matching the live API response. `expected-row.json` is illustrative, not a network test. Invalid tokens or an inaccessible sheet return an error. The header and rows are appended again on each run.
