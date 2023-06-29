Valide payload
curl -v http://localhost:9090/userSignUp -H "Content-type:application/json" -d "{\"username\": \"John\", \"password\": \"John@123\"}"


Invalid payload
curl -v http://localhost:9090/userSignUp -H "Content-type:application/json" -d "{\"username\": \"John\", \"password\": \"John @123\"}"