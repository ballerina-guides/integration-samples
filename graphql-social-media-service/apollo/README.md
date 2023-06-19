# Social Media GraphQL Service Using Apollo

This repository contains source code for a simple social media service exposed via a GraphQL API. Following is the GraphQL schema for the GraphQL service.

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

This is a GraphQL service written in typescript using the Apollo GraphQL library. The project is a NodeJS project that uses ExpressJS and Apollo GraphQL along with MySQL2 and other helper libraries.

### Source Code

The `ts/src` directory contains all the source codes for the project.

This directory contains four more directories.
- `auth` directory

  This directory contains the source code related to auth functionalities.
- `db` directory

  This directory contains the source code to define database operations.
- `graphql` directory

  This directory contains the source code to define the GraphQL functionalities including the schema and the resolvers.
- `types` directory

  This directory contains the typescript type definitions that are used in the project.

The `index.ts` and the `utils` ts files under the `src` directories are used to define the main functionality of the GraphQL server.

### Configurations

The `config` directory contains the `default.json` file that contains the default configs for the project. They can be
overridden at the runtime as needed.

### Resources

The `resources` directory includes the database initialization script.


### Run the Service

1. Download and install [NodeJS](https://nodejs.org/en/download)
2. Download and install [MySQL](https://www.mysql.com/downloads/)
3. Run the docker image for the Database using the following command:

    ```shell
    docker compose -f docker-compose-apollo-db.yml up
    ```

    OR

    Execute the `init_db.sql` file in the MySQL CLI.
    ```shell
    source resources/init_db.sql
    ```
4. Run the GraphQL service using by executing the following command:
   ```shell
   npm start
   ```

   > Alternatively, execute the following command to live-reload the server when developing:
   ```shell
   npm start dev
   ```

   This will log something similar to this:
   ```shell
   🚀 Server ready at http://localhost:4000/graphql
   ```

5. Open the link in a browser to access the GraphQL service using the Apollo sandbox.
