# Online Book Store Service

## Scenario

The online bookstore has an inventory of books that is constantly updated. They work with several partner companies (e.g., book review websites, book clubs, libraries, etc.), who are interested in accessing this inventory data to keep their users informed about the available books and any updates (like new arrivals, restocked items, etc.).

## Application Integration Use Case:

To achieve this, the online bookstore has created an API that exposes this inventory data. 

* The API allows partners to retrieve information about the books, including title, author, genre, price, availability, etc.

* The API allows partners to make specific search queries, like searching for books based on title, author, genre, etc.

# Prerequisites

The bookstore service uses an inmemory storage utilizing the `bal persist` functionality. You just need to define the record and `bal persist` takes care of the persistence layer.
Please refer to https://ballerina.io/learn/by-example/persist-get-all/ and https://lib.ballerina.io/ballerina/persist/1.0.0 for more information.

