import ballerina/persist;

import db_persistence.store;

final store:Client cl = check new;

function selectAll() returns store:Book[]|persist:Error {
    stream<store:Book, persist:Error?> bookStr = cl->/books();
    return from store:Book book in bookStr select book;
}

function selectFilteringByKeyId(int id) returns store:Book|persist:Error {
    return cl->/books/[id]();
}

function selectFilteringByAuthor(string author) returns store:Book[]|persist:Error {
    stream<store:Book, persist:Error?> bookStr = cl->/books();
    return from store:Book book in bookStr where book.author == author select book;
}

function insert(store:Book book) returns int|persist:Error {
    int[] ids = check cl->/books.post([book]);
    return ids[0];
}

function update(function (store:Book) returns store:BookUpdate? fn) returns persist:Error? {
    stream<store:Book, persist:Error?> bookStr = cl->/books();
    [int, store:BookUpdate][] itemsToUpdate = [];

    check bookStr.forEach(function (store:Book book) {
        store:BookUpdate? update = fn(book);
        if update !is () {
            itemsToUpdate.push([book.id, update]);
        }
    });

    foreach [int, store:BookUpdate] [id, bookUpdate] in itemsToUpdate {
        _ = check cl->/books/[id].put(bookUpdate);
    }

    // Can't use query expressions on Swan Lake Update 5 due to 
    // https://github.com/ballerina-platform/ballerina-lang/issues/40412
    
    // [int, store:BookUpdate][] itemsToUpdate = check from store:Book book in bookStr
    //                                             let store:BookUpdate? update = fn(book)
    //                                             where update !is ()
    //                                             select [book.id, update];
    // foreach [int, store:BookUpdate] [id, bookUpdate] in itemsToUpdate {
    //     _ = check cl->/books/[id].put(bookUpdate);
    // }
}

function delete(int id) returns persist:Error? {
    _ = check cl->/books/[id].delete();
}
