# GitHub pull requests to Google Sheets

Read open GitHub pull requests with the GitHub connector, then append their URL, title, state, creation time, and update time through the Google Sheets connector. This is the complete Consuming Services source displayed on the homepage. Both services are live; there is no mock backend. Re-running appends another header and duplicate rows.

## Prerequisites and dependencies

- Ballerina 2201.14.0 (`bal version`). `ballerinax/github` 4.6.0 and `ballerinax/googleapis.sheets` 4.0.0 are declared in `Ballerina.toml` and locked in `Dependencies.toml`; build with `bal build --locking-mode=hard` to keep the verified versions. The build reports that two GitHub-connector transitive dependencies were published before Update 12; a `--locking-mode=soft` build was also checked and succeeds with the same warning.
- A GitHub token with read access to the configured repository, or a fine-grained token with Pull requests read permission.
- A Google account, Sheets API enabled, OAuth access token with spreadsheet edit scope, and a spreadsheet containing a `pull-requests` worksheet. Access tokens expire; refresh yours before running.

## Run and verify

Copy `Config.toml.example` to `Config.toml` and replace the placeholders. Keep the real file private. From this directory run `bal build --locking-mode=hard` and `bal run --locking-mode=hard`. The GitHub connector calls GitHub's GraphQL API for open pull requests and returns a stream. The sample appends the header `URL, Title, State, Created At, Updated At`, then one row per pull request. Inspect the `pull-requests` worksheet for rows matching the live response. `expected-row.json` is an illustrative fixture, not a network test; optional GitHub fields may be empty, and the actual rows depend on the repository. Invalid tokens or an inaccessible sheet return an error. The header and rows are appended again on each run.
