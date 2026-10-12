# GitHub issues to Google Sheets

Read GitHub issues, skip pull requests returned by GitHub's issues endpoint, and append issue number, title, state, and URL to a Google Sheet. This uses the live GitHub and Google Sheets REST APIs through Ballerina's HTTP client; there is no mock backend. Re-running appends duplicates.

## Prerequisites and dependencies

- Ballerina 2201.14.0 (`bal version`). `Ballerina.toml` pins the distribution; `ballerina/http` is supplied with it and its version is recorded in `Dependencies.toml` after `bal build`.
- A GitHub token with read access to the configured repository, or a fine-grained token with Issues read permission.
- A Google account, Sheets API enabled, OAuth access token with spreadsheet edit scope, and a spreadsheet containing an `Issues` worksheet. Access tokens expire; refresh yours before running.

## Run and verify

Copy `Config.toml.example` to `Config.toml` and replace placeholders. Keep the real file private. From this directory run `bal build` and `bal run`. The source uses GitHub's `GET /repos/{owner}/{repo}/issues`, filters pull requests, then posts each row to the Sheets values append API. Check console lines such as `Appended issue #123` and inspect the worksheet for matching number, title, state, and URL. The specific rows depend on the live repository. A read-only fixture of expected columns is in `expected-row.json`; it is illustrative, not a network test. Invalid tokens or an inaccessible sheet return an error.
