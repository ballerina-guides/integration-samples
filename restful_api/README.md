# RESTful albums API

This sample restores the earlier RESTful API example. A Ballerina HTTP service exposes a small in-memory table of albums through list, lookup, and create resources. No external service or account is required. The table is a local fixture; new albums do not persist across restarts.

Requires Ballerina 2201.14.0. The only dependency is `ballerina/http` from the distribution, locked in `Dependencies.toml`. `Config.toml.example` contains the optional local port. Run `bal build` and `bal run` from this directory, then try:

```sh
curl http://localhost:8080/albums/1
curl http://localhost:8080/albums
curl -X POST http://localhost:8080/albums -H 'Content-Type: application/json' -d '{"id":"4","title":"Kind of Blue","artist":"Miles Davis","price":25.00}'
```

The lookup returns `{"id":"1","title":"Blue Train","artist":"John Coltrane","price":56.99}`. The list includes the three built-in albums. A successful POST returns the new album; a second POST using the same ID returns 409 because table keys are unique. Restarting resets the table. A nonexistent ID returns 404.
