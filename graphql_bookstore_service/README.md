# GraphQL Bookstore Service
This sample exposes a GraphQL service.

## Use case
In this use case, let’s see how we can implement a GraphQL server using the Ballerina to expose data in memory and data retrieved via another API call.

The information sources for the above operations are as follows.
* Title, published year, ISBN number, author  - Retrieved from the datastore backed by an in-memory table.
* Average rating and rating count - Retrieved from Google  Books API filtered using the ISBN number of the book.  
E.g.: https://www.googleapis.com/books/v1/volumes?q=isbn:9781101042472

# Run the code

Execute `bal run` command within the `graphql_bookstore_service` package directory.

# Test the service

After running the project, a GraphiQL client will be running on localhost:9090/graphiql. Use a web browser to access it.

## Sample Request 1:  Get the titles of all books

GraphQL query: 
```
{allBooks {title}}
```

Response: 
```json
{
 "data": {
   "allBooks": [
     { "title": "Pride and Prejudice" },
     { "title": "Sense and Sensibility" },
     { "title": "War and Peace" },
     { "title": "Anna Karenina" }
   ]
 }
}
```
CURL command  to request the same:
curl -X POST -H "Content-type: application/json" -d '{ "query": "{allBooks {title}}" }' 'http://localhost:9090/graphql'

## Sample Request 2:  Get more details of all books

Users can request the exact information they need in the format they prefer without having different endpoints.

GraphQL query : 
```
{allBooks {title, author, reviews{ratingsCount, averageRating}}}
```

Response :

```json
{
  "data": {
    "allBooks": [
      {
        "title": "Pride and Prejudice",
        "author": "Jane Austen",
        "reviews": {
          "ratingsCount": 1,
          "averageRating": 5
        }
      },
      {
        "title": "Sense and Sensibility",
        "author": "Jane Austen",
        "reviews": {
          "ratingsCount": 3,
          "averageRating": 4
        }
      },
      {
        "title": "War and Peace",
        "author": "Leo Tolstoy",
        "reviews": {
          "ratingsCount": 5,
          "averageRating": 4
        }
      },
      {
        "title": "Anna Karenina",
        "author": "Leo Tolstoy",
        "reviews": {
          "ratingsCount": 1,
          "averageRating": 4
        }
      }
    ]
  }
}
```

CURL command to send the same request:

```
curl -X POST -H "Content-type: application/json" -d '{ "query": "{allBooks {title, author, reviews{ratingsCount, averageRating}}}" }' 'http://localhost:9090/graphql'
```

## Sample Request 3:  Get details of books with input parameter  

GraphQL Query:  
```
{book(isbn: "9780099512240") {title, year}}
```

Response:

```json
{
  "data": {
    "book": {
      "title": "War and Peace",
      "year": 1867
    }
  }
}
```

CURL Command to send the same request:
```
curl -X POST -H "Content-type: application/json" -d '{ "query": "{book(isbn: \"9780099512240\") {title, year}}" }' 'http://localhost:9090/graphql'
```

## Sample Request 4: Mutation to insert data into the database

GraphQL Query:
```
mutation {addBook(isbn: "9781683836223", title: "Harry Potter", author: "J. K. Rowling", year: 2007)
  {isbn}
}
```
Response:

```json
{
 "data": {
   "addBook": 6
 }
}
```

CURL Command to send the same request:
```
curl -X POST -H "Content-type: application/json" -d '{ "query": "mutation {addBook(isbn: \"9781683836223\", title: \"Harry Potter\", author: \"J. K. Rowling\", year: 2007){isbn}}" }' 'http://localhost:9090/graphql'
```
