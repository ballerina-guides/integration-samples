import ballerinax/mysql;
import ballerinax/salesforce;

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

//mySQL configuration parameters
configurable int port = ?;
configurable string host = ?;
configurable string user = ?;
configurable string database = ?;
configurable string password = ?;

// Salesforce configuration parameters
configurable string salesforceAccessToken = ?;
configurable string salesforceBaseUrl = ?;

salesforce:Client salesforce = check new ({
    baseUrl: salesforceBaseUrl,
    auth: {
        token: salesforceAccessToken
    }
});

mysql:Client mysql = check new (host, user, password, database, port);

public function main() returns error? {
    stream<ProductRecieved, error?> streamOutput = mysql->query(
        `SELECT name, unitType, currencyISO, productId FROM products WHERE processed = false`);
    ProductRecieved[] productsRecieved = check from ProductRecieved items in streamOutput
        select items;
    foreach ProductRecieved prductRecieved in productsRecieved {
        Product product = {
            Name: prductRecieved.name,
            Product_Unit__c: prductRecieved.unitType,
            CurrencyIsoCode: prductRecieved.currencyISO
        };
        _ = check salesforce->create("Product2", product);
        _ = check mysql->execute(
            `UPDATE products SET processed = true WHERE productId = ${prductRecieved.productId}`);
    }
}
