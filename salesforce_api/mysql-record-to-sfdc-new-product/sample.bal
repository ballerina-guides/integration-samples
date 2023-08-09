import ballerinax/salesforce as sfdc;
import ballerinax/mysql;
import ballerina/sql;

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

// Types
type GSheetOAuth2Config record {
    string clientId;
    string clientSecret;
    string refreshToken;
    string refreshUrl = "https://www.googleapis.com/oauth2/v3/token";
};

type SalesforceOAuth2Config record {
    string clientId;
    string clientSecret;
    string refreshToken;
    string refreshUrl = "https://test.salesforce.com/services/oauth2/token";
};

// Constants
const int HEADINGS_ROW = 1;

//mysql
configurable int port = ?;
configurable string host = ?;
configurable string user = ?;
configurable string database = ?;
configurable string password = ?;

// Salesforce configuration parameters
configurable SalesforceOAuth2Config salesforceOAuthConfig = ?;
configurable string salesforceBaseUrl = ?;



sfdc:Client sfdcClient = check new ({
    baseUrl: salesforceBaseUrl,
    auth: {
        clientId: salesforceOAuthConfig.clientId,
        clientSecret: salesforceOAuthConfig.clientSecret,
        refreshToken: salesforceOAuthConfig.refreshToken,
        refreshUrl: salesforceOAuthConfig.refreshUrl
    }
});


public function main() returns error? {
    mysql:Client dbClient = check new (host = host, user = user, password = password, database = database, port = port, options = {});

    stream<ProductRecieved, error?> streamOutput = check dbClient->query(`SELECT name, unitType, currencyISO, productId FROM products WHERE processed = false`);
    ProductRecieved[] productsRecieved = check from ProductRecieved items in streamOutput
        select items;
    foreach ProductRecieved prductRecieved in productsRecieved {
        Product product = {
            Name: prductRecieved.name,
            Product_Unit__c: prductRecieved.unitType,
            CurrencyIsoCode: prductRecieved.currencyISO
        };
        sfdc:CreationResponse create = check sfdcClient->create("Product2", product);
        sql:ExecutionResult executeResult = check dbClient->execute(`UPDATE products SET processed = true WHERE productId = ${prductRecieved.productId}`);
    }
        
}
