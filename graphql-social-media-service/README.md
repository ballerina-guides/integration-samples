# Social Media GraphQL Service Using Ballerina

## Introduction

GraphQL is an exciting query language for APIs that empowers clients to specify the exact data they need. It is an excellent choice for building social media services, where users often require specific data, such as a list of posts by a particular user or the latest posts from a specific topic.

In this project, we will develop a dynamic social media service using Ballerina and GraphQL. This service will enable users to register, create posts, delete posts, and subscribe to posts.

The service will utilize a MySQL database for data persistence and Apache Kafka for handling GraphQL subscriptions.

## What You'll Build

You'll construct a user-friendly social media service that allows users to register and create posts.

The social media service will expose a GraphQL API. We will leverage the Ballerina GraphQL module to develop this API.

Data will be stored in a MySQL database, and the Ballerina persist module will handle data persistence. Additionally, the Ballerina Kafka module will be used for managing GraphQL subscriptions.

## Prerequisites

To complete this project, you will need the following:

* [Ballerina Distribution](https://ballerina.io/downloads/)
* A Text Editor or an IDE (We recommend using VS Code with the [Ballerina plugin](https://marketplace.visualstudio.com/items?itemName=wso2.ballerina))
* Docker

## Design

Below is the GraphQL schema for our social media service:

```graphql
type Query {
  "Returns a list of users."
  users: [User!]!
  "Returns the user with the given ID."
  user(
    "ID of the user"
    id: String!
  ): User!
  "Returns a list of posts by a user."
  posts(
    "ID of the user"
    id: String
  ): [Post!]!
}

type Mutation {
  "Creates a new user."
  createUser(
    "User to be created"
    user: NewUser!
  ): User!
  "Deletes a user. Only the user can delete their own account. Returns an authentication/authorization error if the user cannot be authenticated/authorized."
  deleteUser(
    "ID of the user"
    id: String!
  ): User!
  "Creates a new post. Returns an authentication error if the user is not authenticated."
  createPost(
    "Post to be created"
    newPost: NewPost!
  ): Post!
  "Deletes a post with the given ID. Returns authentication/authorization errors if the user cannot be authenticated/authorized."
  deletePost(
    "ID of the post"
    id: String!
  ): Post!
}

type Subscription {
  "Subscribe to new posts."
  newPosts: Post!
}

"Represents a user in the GraphQL schema."
type User {
  "The user's ID."
  id: String!
  "The user's name."
  name: String!
  "The user's age."
  age: Int!
  "Posts made by the user."
  posts: [Post!]!
}

"Represents a post in the GraphQL schema."
type Post {
  "The post's ID."
  id: String!
  "The post's title."
  title: String!
  "The post's content."
  content: String!
  "The post's author."
  author: User!
}

"Represents the input for creating a new user in the GraphQL schema."
input NewUser {
  "The user's name."
  name: String!
  "The user's age."
  age: Int!
}

"Represents the input for creating a new post in the GraphQL schema."
input NewPost {
  "The post's title."
  title: String!
  "The post's content."
  content: String!
}
```

## Implementation

This section describes the implementation of our social media GraphQL service.

### Source Code

The source code is organized as a Ballerina package and contains the following files:

- `auth.bal`: Contains code related to authentication and authorization functionalities.
- `db.bal`: Contains code related to database operations.
- `kafka_utils.bal`: Contains code for publishing and subscribing to new posts using Kafka.
- `service.bal`: Contains the code for the Ballerina GraphQL service.
- `types.bal`: Contains the code for the types used in the Ballerina GraphQL service, which correspond to the types in the generated GraphQL schema.
- `utils.bal`: Contains utility functions for the Ballerina GraphQL service.
- `persist/model.bal`: Contains the code for the data models used for data persistence.

Additionally, there are generated files created by the Ballerina persist module, which are located in the `generated` directory. These files can be regenerated using the following command:

```bash
bal persist generate
```

> **Note:** The `script.sql` file inside the generated directory has been modified to update the table creation and database creation queries. If you regenerate the files, make sure to review and confirm the changes.

### Configurations

The `Config.toml` file contains the configurations for the Ballerina GraphQL service. Below is a sample configuration file:

- The `graphql_social_media.db` section includes the configurations for the MySQL database.
- The `serviceConfigs` section includes the configurations for the Ballerina GraphQL service.

```toml
[graphql_social_media.db]
host = "localhost"
port = 3306
user = "root"
password = "Test@123"
database = "ballerina_social_media"

[serviceConfigs]
port = 9090
graphiqlPath = "/graphiql"
```

### Authentication/Authorization

For simplicity, we handle authentication and authorization using the same user ID used for user registration.

The user ID should be sent as the `Authorization` header in the GraphQL request. This is required for creating new posts, deleting posts, and deleting users.

## Deployment

### Deploying the MySQL Database

The `docker-compose.yml` file contains the configurations for deploying the MySQL database and the Kafka broker with a Zookeeper instance. You can modify the configurations before deploying the Docker containers.

Open a terminal and execute the following command to deploy the MySQL database:

```bash
docker-compose up -d
```

### Deploying the Ballerina GraphQL Service

Open a terminal, navigate to the root directory of the project, and execute the following command to deploy the Ballerina GraphQL service:

```bash
bal run
```

This will start the service on port 9090.

## Testing

The Ballerina GraphQL package provides a built-in GraphiQL UI that can be used to test the GraphQL service.

To enable the GraphiQL UI, use the `graphiql` field in the GraphQL service configuration.

```ballerina
@graphql:SetServiceConfig {
    graphiql: {
        enabled: true
    }
}
```

> **Note:** The sample code enables the GraphiQL UI.

The GraphiQL UI can be accessed using the following URL:

> http://localhost:9090/graphiql

You can use this UI to test the GraphQL service interactively.

Additionally, you can automate testing using the [Ballerina test framework](https://ballerina.io/learn/test-ballerina-code/write-tests/).
