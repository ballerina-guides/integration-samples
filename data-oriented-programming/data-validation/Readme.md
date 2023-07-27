# Service Description:

The service supports creating user records.

## Service Endpoints:
POST /users - Create a new user record.

### Create a New User (Valid):
```bash
curl -v http://localhost:9090/user -H "Content-type:application/json" -d "{\"username\": \"John\", \"password\": \"John@123\"}"
```

### Create a New User (Invalid - Password):
```bash
curl -v http://localhost:9090/user -H "Content-type:application/json" -d "{\"username\": \"John\", \"password\": \"John @123\"}"
```