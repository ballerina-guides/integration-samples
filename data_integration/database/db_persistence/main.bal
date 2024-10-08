import db_persistence.store;

import ballerina/io;
import ballerina/persist;

public function main() returns error? {
    check clearTableAndAddData();

    store:Book[] allBooks = check selectAll();
    io:println(allBooks);

    store:Book book3 = check selectFilteringByKeyId(3);
    io:println(book3);

    store:Book[] filteredBooks = check selectFilteringByAuthor("Charles Dickens");
    io:println(filteredBooks);

    int id = check insert({
        id: 4,
        title: "Great Expectations",
        author: "Charles Dickens",
        price: 1432,
        isbn: "9781503275188"
    });
    io:println(id);
}

function clearTableAndAddData() returns error? {
    stream<store:Book, persist:Error?> str = cl->/books();
    check from store:Book {id} in str
    do {
        _ = check cl->/books/[id].delete;
    };

    store:Book[] books = [
        {id: 1, title: "A Christmas Carol", author: "Charles Dickens", isbn: "9781503212831", price: 1843},
        {id: 2, title: "Oliver Twist", author: "Charles Dickens", isbn: "9780141439747", price: 1838},
        {id: 3, title: "Heidi", author: "Johanna Spyri", isbn: "9780517189672", price: 1811}
    ];
    
    foreach store:Book book in books {
        _ = check insert(book);
    }
}
