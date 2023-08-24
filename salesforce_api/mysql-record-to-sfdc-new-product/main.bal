import ballerinax/mysql;
import ballerinax/salesforce as sfdc;

type Product record {
    string Name;
    string Product_Unit__c;
    string CurrencyIsoCode;
};

type ProductRecieved record {
    string name;
    string unitType;
    string currencyISO;
    string productId;
};

const int HEADINGS_ROW = 1;

//mySQL configuration parameters
configurable int port = ?;
configurable string host = ?;
configurable string user = ?;
configurable string database = ?;
configurable string password = ?;

// Salesforce configuration parameters
configurable string salesforceAccessToken = ?;
configurable string salesforceBaseUrl = ?;

sfdc:Client sfdcClient = check new ({
    baseUrl: salesforceBaseUrl,
    auth: {
        token: salesforceAccessToken
    }
});

public function main() returns error? {
    mysql:Client dbClient = check new (host, user, password, database, port);

    stream<ProductRecieved, error?> streamOutput = dbClient->query(
        `SELECT name, unitType, currencyISO, productId FROM products WHERE processed = false`);
    ProductRecieved[] productsRecieved = check from ProductRecieved items in streamOutput
        select items;
    foreach ProductRecieved prductRecieved in productsRecieved {
        Product product = {
            Name: prductRecieved.name,
            Product_Unit__c: prductRecieved.unitType,
            CurrencyIsoCode: prductRecieved.currencyISO
        };
        _ = check sfdcClient->create("Product2", product);
        _ = check dbClient->execute(
            `UPDATE products SET processed = true WHERE productId = ${prductRecieved.productId}`);
    }
}
