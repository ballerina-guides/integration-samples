import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

public type BookInsert record {|
    string title;
    string author;
    string isbn;
    int price;
|};

public type Book record {|
    *BookInsert;
    readonly int id;
|};

configurable string host = ?;
configurable string user = ?;
configurable string password = ?;
configurable string database = ?;
configurable int port = ?;

final sql:Client cl = check new mysql:Client(host, user, password, database, port);

function selectAll() returns Book[]|sql:Error {
    stream<Book, sql:Error?> bookStr = cl->query(`SELECT * from Book`);
    return from Book book in bookStr select book;
}

function selectFilteringByKeyId(int id) returns Book|sql:Error {
    return cl->queryRow(`SELECT * FROM Book WHERE id = ${id}`);
}

function selectFilteringByAuthor(string author) returns Book[]|sql:Error {
    stream<Book, sql:Error?> bookStr = cl->query(`SELECT * FROM Book WHERE author = ${author}`);
    return from Book book in bookStr select book;
}

function insert(BookInsert book) returns int|error {
    sql:ExecutionResult executionResult = check cl->execute(`
            INSERT INTO Book (title, author, isbn, price)
            VALUES (${book.title}, ${book.author}, ${book.isbn}, ${book.price});`);
    return executionResult.lastInsertId.ensureType();
}

function update(sql:ParameterizedQuery query) returns sql:Error? {
    _ = check cl->execute(query);
}

function updateAuthorName(string currentName, string updatedName) returns sql:Error? {
    _ = check cl->execute(`UPDATE Book SET author = ${updatedName} WHERE author = ${currentName}`);
}

function delete(int id) returns int|sql:Error? {
    sql:ExecutionResult res = check cl->execute(`DELETE FROM Book WHERE id = ${id}`);
    return res.affectedRowCount;
}
