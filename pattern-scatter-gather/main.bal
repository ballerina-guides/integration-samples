import ballerina/http;

configurable string venderAURL = ?;
configurable string venderBURL = ?;
configurable string venderCURL = ?;

type QuoteRequest record {
    string customerName;
    string product;
    int quantity;
};

type Quote record {
    string customerName;
    string product;
    int quantity;
    decimal price;
};

function findBestQuote(QuoteRequest quoteReq) returns Quote {
    // The fork statement starts with one or more named workers, 
    //  which run in parallel with each other 
    fork {
        worker venderA returns Quote|error {
            http:Client venderAEP = check new (venderAURL);
            return venderAEP -> /quote.get(p = quoteReq.product, q = quoteReq.quantity);
        }

        worker venderB returns Quote|error {
            http:Client venderBEP = check new (venderBURL);
            return venderBEP -> /quote.get(p = quoteReq.product, q = quoteReq.quantity);
        }

        worker venderC returns Quote|error {
            http:Client venderCEP = check new (venderBURL);
            return venderCEP -> /quote.get(p = quoteReq.product, q = quoteReq.quantity);
        }
    }

    // Wait for all the workers to finish and collects the results.
    map<Quote|error> quotes = wait {venderA, venderB, venderC};
    return bestQuote(quotes);
}

function bestQuote(map<Quote|error> quotes) returns Quote {
    return {customerName: "John Doe", product: "Ball", quantity: 10, price: 100};
}
