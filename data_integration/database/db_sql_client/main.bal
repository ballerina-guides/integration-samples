import ballerina/io;
import ballerina/sql;

public function main() returns error? {
    check createTableAndAddData();

    Book[] allBooks = check selectAll();
    io:println(allBooks);

    Book book3 = check selectFilteringByKeyId(3);
    io:println(book3);

    Book[] filteredBooks = check selectFilteringByAuthor("Charles Dickens");
    io:println(filteredBooks);

    int id = check insert({
        title: "Great Expectations",
        author: "Charles Dickens",
        price: 1432,
        isbn: "9781503275188"
    });
    io:println(id);
}

function createTableAndAddData() returns error? {
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
