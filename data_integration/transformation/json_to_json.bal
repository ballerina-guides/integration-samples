// JSON to JSON transformation

function transformJson(json input) returns map<json>|error => 
    let json[] books = check input.books.ensureType() in 
    {
        items: from json item in books 
                    let map<json> itemBook = check item.ensureType()
                    select {
                        book: map from [string, json] [k, v] in itemBook.entries() 
                                    select [k.toUpperAscii(), v]
                    }
    };

function transformJsonWithDefaults(json input) returns map<json>|error => 
    let json[] books = check input.books.ensureType() in 
    {
        items: from [int, json] [id, item] in books.enumerate() 
                    let map<json> itemBook = check item.ensureType()
                    select <map<json>> {
                        category: "book",
                        price: check float:fromString(check itemBook.price),
                        id: id + 1,
                        properties: {
                            title: check itemBook.name,
                            author: check itemBook.author,
                            year: check itemBook.year
                        }
                    }
    };

type Book record {|
    string name;
    string author;
    string price;
    int year;
|};

type Input record {|
    Book[] books;
|};

type Properties record {|
    string title;
    string author;
    int year;
|};

type TransformedBook record {|
    string category = "book";
    float price;
    int id;
    Properties properties;
|};

type Output record {|
    TransformedBook[] items;
|};

function transformJsonWithDefaultsViaRecords(json input) returns Output|error => 
    let Input inputRec = check input.fromJsonWithType() in 
    {
        items: from [int, Book] [id, book] in inputRec.books.enumerate() 
                    select {
                        price: check float:fromString(book.price),
                        id: id + 1,
                        properties: {
                            title: book.name,
                            author: book.author,
                            year: book.year
                        }
                    }
    };
