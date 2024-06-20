import ballerina/io;
import ballerina/http;

type Book readonly & record {|
    string id;
    string name;
    string author;
    string genre;
    boolean availability;
    float price;
|};

public function main() returns error? {
    http:Client bookStoreClient = check new("http://localhost:9090");
    // Post books
    // Book[] books = ;
    Book[] books = check bookStoreClient->/books.post([{id: "B001", name: "The Great Gatsby", author: "F. Scott Fitzgerald", genre: "classic", availability: true, price: 500.00}, {id: "B002", name: "The Da Vinci Code", author: "Dan Brown", genre: "thriller", availability: true, price: 600.00}, {id: "B003", name: "The Alchemist", author: "Paulo Coelho", genre: "adventure", availability: true, price: 400.00}]);
    io:println("books added: ", books);

    // Get Book record
    string id = "B001";
    Book book = check bookStoreClient->/books/[id];
    io:println("received book ", book);

}