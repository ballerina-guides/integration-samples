# Springboot and Ballerina

A sample code base which touches key features of each technology. The sample is based on a simple API written for a social-media site which has users and associated posts. Following is the high level component diagram.

<img src="springboot-and-ballerina.png" alt="drawing" width='500'/>

Following are the features used for the implementation

1. Configuring verbs and URLs
2. Error handlers for sending customized error messages
3. Adding constraints/validations
4. OpenAPI specification for Generating API docs
5. Accessing database
6. Configurability
7. HTTP client 
8. Resiliency - Retry
9. Docker image generation

# Setting up each environment

## Spring boot
Run the `springboot-docker-compose.yml` docker compose setup.
```sh
docker compose -f springboot-docker-compose.yml up
```

## Spring boot (Reactive)
Run the `springboot-reactive-docker-compose.yml` docker compose setup.
```sh
docker compose -f springboot-reactive-docker-compose.yml up
```

## Ballerina
Run the `ballerina-docker-compose.yml` docker compose setup.
```sh
docker compose -f ballerina-docker-compose.yml up
```

# Try out
## Spring boot (Default and Reactive)
- To send request open `springboot-social-media.http` file using VS Code with `REST Client` extension

## Ballerina
- To send request open `ballerina-social-media.http` file using VS Code with `REST Client` extension

