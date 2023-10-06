import ballerina/sql;
import ballerina/test;

@test:BeforeSuite
function addToTable() returns error? {
    // Can alternatively be done via a script.
    _ = check cl->execute(`DROP TABLE Book`);

    _ = check cl->execute(`CREATE TABLE Book (
        id INT NOT NULL AUTO_INCREMENT,
        title VARCHAR(191) NOT NULL,
        author VARCHAR(191) NOT NULL,
        isbn VARCHAR(191) NOT NULL,
        price INT NOT NULL,
        PRIMARY KEY(id)
    )`);

    BookInsert[] books = [
        {title: "A Christmas Carol", author: "Charles Dickens", isbn: "9781503212831", price: 1843},
        {title: "Oliver Twist", author: "Charles Dickens", isbn: "9780141439747", price: 1838},
        {title: "Heidi", author: "Johanna Spyri", isbn: "9780517189672", price: 1811}
    ];
    
    sql:ParameterizedQuery[] insertQueries = from BookInsert {title, author, isbn, price} in books
        select `INSERT INTO Book (title, author, isbn, price)
                VALUES (${title}, ${author}, ${isbn}, ${price})`;
    _ = check cl->batchExecute(insertQueries);
}

@test:Config
function testSelectAll() returns error? {
    Book[] allBooks = check selectAll();
    Book[] expectedBooks = [
        {id: 1, title: "A Christmas Carol", author: "Charles Dickens", isbn: "9781503212831", price: 1843},
        {id: 2, title: "Oliver Twist", author: "Charles Dickens", isbn: "9780141439747", price: 1838},
        {id: 3, title: "Heidi", author: "Johanna Spyri", isbn: "9780517189672", price: 1811}
    ];
    test:assertEquals(allBooks, expectedBooks);
}

@test:Config
function testSelectFilteringByKeyId() returns error? {
    Book book3 = check selectFilteringByKeyId(3);
    test:assertEquals(book3, {id: 3, title: "Heidi", author: "Johanna Spyri", isbn: "9780517189672", price: 1811});

    Book|sql:Error book10 = selectFilteringByKeyId(10);
    test:assertTrue(book10 is sql:Error);
}

@test:Config
function testSelectFilteringByAuthor() returns error? {
    Book[] filteredBooks = check selectFilteringByAuthor("Charles Dickens");
    test:assertEquals(filteredBooks.length(), 2);
    test:assertEquals(filteredBooks, [
        {id: 1, title: "A Christmas Carol", author: "Charles Dickens", isbn: "9781503212831", price: 1843},
        {id: 2, title: "Oliver Twist", author: "Charles Dickens", isbn: "9780141439747", price: 1838}
    ]);
}

@test:Config {
    dependsOn: [testSelectAll, testSelectFilteringByAuthor]
}
function testInsert() returns error? {
    int id = check insert({
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
    _ = check update(`UPDATE Book SET author = 'C. Dickens' WHERE author = 'Charles Dickens'`);

    test:assertEquals(check selectAll(), [
        {id: 1, title: "A Christmas Carol", author: "C. Dickens", isbn: "9781503212831", price: 1843},
        {id: 2, title: "Oliver Twist", author: "C. Dickens", isbn: "9780141439747", price: 1838},
        {id: 3, title: "Heidi", author: "Johanna Spyri", isbn: "9780517189672", price: 1811},
        {id: 4, title: "Great Expectations", author: "C. Dickens", isbn: "9781503275188", price: 1432}
    ]);
}

@test:Config {
    dependsOn: [testUpdate]
}
function testUpdateAuthorName() returns error? {
    _ = check updateAuthorName("C. Dickens", "Charles J. H. Dickens");

    test:assertEquals(check selectAll(), [
        {id: 1, title: "A Christmas Carol", author: "Charles J. H. Dickens", isbn: "9781503212831", price: 1843},
        {id: 2, title: "Oliver Twist", author: "Charles J. H. Dickens", isbn: "9780141439747", price: 1838},
        {id: 3, title: "Heidi", author: "Johanna Spyri", isbn: "9780517189672", price: 1811},
        {id: 4, title: "Great Expectations", author: "Charles J. H. Dickens", isbn: "9781503275188", price: 1432}
    ]);
}

@test:Config {
    dependsOn: [testUpdate]
}
function testDelete() returns error? {
    int? res = check delete(2);
    test:assertEquals(res, 1);
    
    res = check delete(12);
    test:assertEquals(res, 0);
}
