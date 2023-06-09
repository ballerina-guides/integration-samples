# Social Media GraphQL Service Using Ballerina

This project demonstrates how to implement a social media GraphQL service using Ballerina.

## What you'll build

You'll build a simple social media service which allows users to register and post posts.

The social media service is exposed as a GraphQL API. It uses the Ballerina GraphQL module to write the GraphQL API.

The datasource is MySQL database and the Ballerina persist module is used for data persistence.

## Prerequisites

* [Ballerina Distribution](https://ballerina.io/downloads/)
* A Text Editor or an IDE (VS Code with [Ballerina plugin](https://marketplace.visualstudio.com/items?itemName=wso2.ballerina) is recommended)
* Docker

## Design

Following is the GraphQL schema of the social media service.

```graphql
type Query {
  "Returns the list of users."
  users: [User!]!
  "Returns the user with the given ID."
  user(
    "ID of the user"
    id: String!
  ): User!
  "Returns the list of posts from a user."
  posts(
    "ID of the user"
    id: String
  ): [Post!]!
}

"Represents the User type in the GraphQL schema."
type User {
  "The `id` of the User"
  id: String!
  "The `name` of the User"
  name: String!
  "The `age` of the User"
  age: Int!
  "The `posts` posted by the User"
  posts: [Post!]!
}

"Represents the Post type in the GraphQL schema."
type Post {
  "The `id` of the Post"
  id: String!
  "The `title` of the Post"
  title: String!
  "The `content` of the Post"
  content: String!
  "The `author` of the Post"
  author: User!
}

type Mutation {
  "Creates a new user."
  createUser(
    "User to be created"
    user: NewUser!
  ): User!
  "Deletes a user. Only the user can delete their own account. Will return an authentication/authorization error if the user cannot be authenticated/authorized."
  deleteUser(
    "ID of the user"
    id: String!
  ): User!
  "Creates a new post. Can return authentication error if the user is not authenticated."
  createPost(
    "Post to be created"
    newPost: NewPost!
  ): Post!
  "Deletes a post with the given ID. Can return authentication/authorization errors if the user cannot be authenticated/authorized."
  deletePost(
    "ID of the post"
    id: String!
  ): Post!
}

"Represents the NewUser type in the GraphQL schema."
input NewUser {
  "The `name` of the User"
  name: String!
  "The `age` of the User"
  age: Int!
}

"Represents the NewPost type in the GraphQL schema."
input NewPost {
  "The `title` of the Post"
  title: String!
  "The `content` of the Post"
  content: String!
}

type Subscription {
  "Subscribe to new posts."
  newPosts: Post!
}
```

## Implementation

This section describes the implementation of the social media GraphQL service.

### Source Code

The source code is a Ballerina package with the following files:

- `auth.bal`
  Contains the code related to authentication/authorization functionalities.
- `db.bal`
  Contains the code related to database operations.
- `service.bal`
  Contains the code of the Ballerina GraphQL service.
- `types.bal`
  Contains the code for the types used in the Ballerina GraphQL service, which are mappd to the types in the generated GraphQL schema.
- `utils.bal`
  Contains the utility functions of the Ballerina GraphQL service.

There are additional files which are generated by the Ballerina persist module.

### Configurations

The `Config.toml` file contains the configurations of the Ballerina GraphQL service. Following is a sample configuration file.

- The `graphql_social_media.db` section contains the configurations of the MySQL database.
- The `serviceConfigs` section contains the configurations of the Ballerina GraphQL service.

```toml
[graphql_social_media.db]
host = "localhost"
port = 3306
user = "root"
password = "Test@123"
database = "ballerina_social_media"

[serviceConfigs]
port = 9090
```

### Authentication/Authorization

For the sake of simplicity, authentication/authorization is handled using the same user ID which is used to register the user.

The user ID should be sent as the `Authorization` header in the GraphQL request. This is required for creating new posts, deleting posts, and deleting users.

## Deployment

### Deploying the MySQL Database

The `docker-compose.yml` file contains the configurations to deploy the MySQL database. The configurations can be changed before deploying the docker container.

Open a terminal and execute the following command to deploy the MySQL database.

```bash
docker-compose up -d
```

### Deploying the Ballerina GraphQL Service

Open a terminal and navigate to the root directory of the project and execute the following command to deploy the Ballerina GraphQL service.

```bash
bal run
```

This will start the service on port 9090.

## Testing

Ballerina GraphQL package has an inbuilt GraphiQL UI which can be used to test the GraphQL service.

This can be enabled using the `graphiql` field in the GraphQL service configuration.

```ballerina
@graphql:SetServiceConfig {
    graphiql: {
        enabled: true
    }
}
```

> **Note:** This is enabled in the sample code.

Then the GraphiQL UI can be accessed using the following URL.

> http://localhost:9090/graphiql

Use this to test the GraphQL service.

Additionally, test automation can be done using the [Ballerina test framework](https://ballerina.io/learn/test-ballerina-code/write-tests/).