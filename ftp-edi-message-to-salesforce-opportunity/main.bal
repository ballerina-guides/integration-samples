import ballerina/ftp;
import ballerina/http;
import ballerinax/edifact.d03a.retail.mREQOTE;
import ballerinax/salesforce as sf;

configurable ftp:ClientConfiguration ftpConfig = ?;
configurable string ftpNewQuotesPath = ?;
configurable string ftpProcessedQuotesPath = ?;
configurable string salesforceBaseUrl = ?;
configurable http:OAuth2RefreshTokenGrantConfig salesforceAuth = ?;
configurable string salesforcePriceBookId = ?;

sf:Client salesforce = check new ({baseUrl: salesforceBaseUrl, auth: salesforceAuth});
ftp:Client fileServer = check new ftp:Client(ftpConfig);

public function main() returns error? {
    ftp:FileInfo[] quoteList = check fileServer->list(ftpNewQuotesPath);
    foreach ftp:FileInfo quoteFile in quoteList {
        string quoteText = check fileServer->getText(quoteFile.path);
        mREQOTE:EDI_REQOTE_REQOTE quote = check mREQOTE:fromEdiString(quoteText);
        QuoteRequest quoteRequest = check transformQuoteRequest(quote);
        stream<Id, error?> accQuery = check salesforce->query(
            string `SELECT Id FROM Account WHERE Name = '${quoteRequest.accountName}'`
        );
        record {|Id value;|}? account = check accQuery.next();
        check accQuery.close();
        if account is () {
            return error("Account not found. Account name: " + quoteRequest.accountName);
        }
        Opportunity opp = {
            Name: quoteRequest.oppName,
            AccountId: account.value.Id,
            Pricebook2Id: salesforcePriceBookId
        };
        string oppId = check getOpportunityId(quoteRequest, opp);
        check createOpportunityLineItems(quoteRequest, oppId);
        check fileServer->move(quoteFile.path, string `${ftpProcessedQuotesPath}/${quoteFile.name}`);
    }
}

function createOpportunityLineItems(QuoteRequest quoteRequest, string oppId) returns error? {
    foreach ItemData item in quoteRequest.itemData {
        stream<PriceBookEntry, error?> query = check salesforce->query(
                string `SELECT UnitPrice FROM PricebookEntry WHERE Pricebook2Id = 
                    '${salesforcePriceBookId}' AND Product2Id = '${item.itemId}'`
            );
        record {|PriceBookEntry value;|}? unionResult = check query.next();
        check query.close();
        if unionResult is () {
            return error(string `Pricebook entry not found. Opportunity name: ${quoteRequest.oppName}, Item ID: ${item.itemId}`);
        }
        OpportunityProduct oppProduct = {
            OpportunityId: oppId,
            Product2Id: item.itemId,
            Quantity: item.quantity,
            UnitPrice: unionResult.value.UnitPrice
        };
        _ = check salesforce->create("OpportunityLineItem", oppProduct);
    }
}

function getOpportunityId(QuoteRequest quoteRequest, Opportunity opp) returns string|error {
    stream<Id, error?> oppQuery = check salesforce->query(
            string `SELECT Id FROM Opportunity WHERE Name = '${quoteRequest.oppName}'`);
    record {|Id value;|}? existingOpp = check oppQuery.next();
    check oppQuery.close();
    if existingOpp is () {
        sf:CreationResponse oppResult = check salesforce->create("Opportunity", opp);
        return oppResult.id;
    }
    return existingOpp.value.Id;
}
