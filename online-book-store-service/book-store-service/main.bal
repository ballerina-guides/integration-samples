import ballerina/http;
import online_book_store_service.inventory;

inventory:Client inventoryClient = check new ();

type Book readonly & record {|
    string id;
    string name;
    string author;
    string genre;
    boolean availability;
    float price;
|};

service / on new http:Listener(9090) {

    resource function post books(Book[] bookDetails) returns Book[]|error? {
        // Post books
        _ = check inventoryClient->/books.post(bookDetails);
        return bookDetails;
    }

    resource function get books/[string id]() returns json|error? {
        inventory:Book book = check inventoryClient->/books/[id];
        return book.toJson();
    }

}
