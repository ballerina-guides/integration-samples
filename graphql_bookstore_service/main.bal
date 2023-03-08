import ballerina/graphql;
import ballerina/http;

configurable boolean enableGraphiql = ?;

type VolumeInfo record {
    int averageRating?;
    int ratingsCount?;
    string maturityRating?;
};

type GoogleBook record {
    record {
        VolumeInfo volumeInfo;
    }[] items; //Anonymous record defined in-line
};

type Review record {|
    int averageRating?;
    int ratingsCount?;
    string maturityRating?;
|};

type BookData record {|
    readonly string isbn;
    string title;
    int year;
    string author;
|};

final table<BookData> key(isbn) books = table [
    {isbn: "9780679405429", title: "Pride and Prejudice", year: 1813, author: "Jane Austen"},
    {isbn: "9780486290492", title: "Sense and Sensibility", year: 1811, author: "Jane Austen"},
    {isbn: "9780099512240", title: "War and Peace", year: 1867, author: "Leo Tolstoy"},
    {isbn: "9781101042472", title: "Anna Karenina", year: 1878, author: "Leo Tolstoy"}
];

final http:Client bookEp = check new ("https://www.googleapis.com");

service class Book {
    private final readonly & BookData bookData;

    function init(BookData bookData) {
        self.bookData = bookData.cloneReadOnly();
    }

    resource function get isbn() returns string {
        return self.bookData.isbn;
    }

    resource function get title() returns string {
        return self.bookData.title;
    }

    resource function get year() returns int {
        return self.bookData.year;
    }

    resource function get author() returns string {
        return self.bookData.author;
    }

    resource function get reviews() returns Review|error {
        string isbn = self.bookData.isbn;
        GoogleBook googleBook = check bookEp->/books/v1/volumes.get(q = string `isbn:${isbn}`);
        return let var volInfo = googleBook.items[0].volumeInfo in {
                averageRating: volInfo.averageRating,
                ratingsCount: volInfo.ratingsCount,
                maturityRating: volInfo.maturityRating
            };
    }
}

@graphql:ServiceConfig {
    graphiql: {
        enabled: enableGraphiql
    }
}
service /graphql on new graphql:Listener(9090) {
    resource function get book(string isbn) returns Book? {
        BookData? data = books[isbn];
        return data is BookData ? new Book(data) : ();
    }

    resource function get allBooks() returns Book[] {
        return from var bookData in books
            select new Book(bookData);
    }

    remote function addBook(string isbn, string title, string author, int year) returns Book|error {
        BookData bookData = {isbn, title, year, author};
        books.add(bookData);
        return new Book(bookData);
    }
}
