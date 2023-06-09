import ballerina/persist;
import ballerina/test;

import db_persistence.store;

@test:BeforeSuite
function addToTable() returns error? {
    check cleanDb();
    // Can alternatively be added via the script.
    // Auto increment support is not yet available in the persistence layer,
    // but is planned for a future release.
    store:Book[] books = [
        {id: 1, title: "A Christmas Carol", author: "Charles Dickens", isbn: "9781503212831", price: 1843},
        {id: 2, title: "Oliver Twist", author: "Charles Dickens", isbn: "9780141439747", price: 1838},
        {id: 3, title: "Heidi", author: "Johanna Spyri", isbn: "9780517189672", price: 1811}
    ];
    
    foreach store:Book book in books {
        _ = check insert(book);
    }
}

@test:Config
function testSelectAll() returns error? {
    store:Book[] allBooks = check selectAll();
    store:Book[] expectedBooks = [
        {id: 1, title: "A Christmas Carol", author: "Charles Dickens", isbn: "9781503212831", price: 1843},
        {id: 2, title: "Oliver Twist", author: "Charles Dickens", isbn: "9780141439747", price: 1838},
        {id: 3, title: "Heidi", author: "Johanna Spyri", isbn: "9780517189672", price: 1811}
    ];
    test:assertEquals(allBooks, expectedBooks);
}

@test:Config
function testSelectFilteringByKeyId() returns error? {
    store:Book book3 = check selectFilteringByKeyId(3);
    test:assertEquals(book3, {id: 3, title: "Heidi", author: "Johanna Spyri", isbn: "9780517189672", price: 1811});

    store:Book|persist:Error book10 = selectFilteringByKeyId(10);
    test:assertTrue(book10 is persist:Error);
}

@test:Config
function testSelectFilteringByAuthor() returns error? {
    store:Book[] stephenKingBooks = check selectFilteringByAuthor("Charles Dickens");
    test:assertEquals(stephenKingBooks.length(), 2);
    test:assertEquals(stephenKingBooks, [
        {id: 1, title: "A Christmas Carol", author: "Charles Dickens", isbn: "9781503212831", price: 1843},
        {id: 2, title: "Oliver Twist", author: "Charles Dickens", isbn: "9780141439747", price: 1838}
    ]);
}

@test:Config {
    dependsOn: [testSelectAll, testSelectFilteringByAuthor]
}
function testInsert() returns error? {
    int id = check insert({
        id: 4,
        title: "Great Expectations",
        author: "Charles Dickens",
        price: 1432,
        isbn: "9781503275188"
    });
    test:assertEquals(id, 4);
}

@test:Config {
    dependsOn: [testInsert, testSelectFilteringByKeyId, testSelectFilteringByAuthor]
}
function testUpdate() returns error? {
    _ = check update(book => book.price < 1840 ? 
            let store:Book {title, author, isbn, price} = book in
                {title, author, isbn, price: price + 10} : 
            ());

    test:assertEquals(check selectAll(), [
        {id: 1, title: "A Christmas Carol", author: "Charles Dickens", isbn: "9781503212831", price: 1843},
        {id: 2, title: "Oliver Twist", author: "Charles Dickens", isbn: "9780141439747", price: 1848},
        {id: 3, title: "Heidi", author: "Johanna Spyri", isbn: "9780517189672", price: 1821},
        {id: 4, title: "Great Expectations", author: "Charles Dickens", isbn: "9781503275188", price: 1442}
    ]);
}

@test:Config {
    dependsOn: [testUpdate]
}
function testDelete() returns error? {
    check delete(2);
    store:Book|persist:Error book2 = selectFilteringByKeyId(2);
    test:assertTrue(book2 is persist:Error);
    persist:Error err = <persist:Error> book2;
    test:assertEquals(err.message(), "A record does not exist for 'Book' for key 2.");
    
    persist:Error? delError = delete(12);
    test:assertTrue(delError is persist:Error);
    err = <persist:Error> delError;
    test:assertEquals(err.message(), "A record does not exist for 'Book' for key 12.");
}

@test:AfterSuite
function cleanDb() returns error? {
    stream<store:Book, persist:Error?> books = cl->/books();
    check from store:Book {id} in books
    do {
        _ = check cl->/books/[id].delete;
    };
}
