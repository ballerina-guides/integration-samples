import ballerinax/kafka;
import ballerina/io;
import ballerinax/salesforce as sfdc;

const string PRICEBOOKID = "";
configurable SalesforceOAuth2Config salesforceOAuthConfig = ?;
configurable string salesforceBaseUrl = ?;
public type ProductPrice readonly & record {
    string Name;
    float UnitPrice;
};

public type ProductPriceUpdate readonly & record {
    float UnitPrice;
};

listener kafka:Listener orderListener = new (kafka:DEFAULT_URL, {
    groupId: "order-group-id",
    topics: "foobar"
});

type SalesforceOAuth2Config record {
    string clientId;
    string clientSecret;
    string refreshToken;
    string refreshUrl = "https://test.salesforce.com/services/oauth2/token";
};

// Salesforce client
sfdc:Client sfdcClient = check new ({
    baseUrl: salesforceBaseUrl,
    auth: {
        clientId: salesforceOAuthConfig.clientId,
        clientSecret: salesforceOAuthConfig.clientSecret,
        refreshToken: salesforceOAuthConfig.refreshToken,
        refreshUrl: salesforceOAuthConfig.refreshUrl
    }
});

service on orderListener {
    remote function onConsumerRecord(ProductPrice[] prices) returns error? {
        foreach ProductPrice price in prices {
            stream<record{},error?> retrievedStream = check sfdcClient->query(string `SELECT Id FROM PricebookEntry WHERE Pricebook2Id = '${PRICEBOOKID}' AND Name = '${price.Name}'`);
            record{}[] retrieved = check from record{} entry in retrievedStream select entry;
            string pricebookEntryId = <string>retrieved[0]["Id"];
            ProductPriceUpdate updatedPrice = {UnitPrice: price.UnitPrice};
            check sfdcClient->update("PricebookEntry", pricebookEntryId, updatedPrice);
        }
    }
}