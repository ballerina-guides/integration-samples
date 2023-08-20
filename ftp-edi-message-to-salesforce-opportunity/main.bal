import ballerinax/edifact.d03a.retail.mREQOTE;

import ballerina/io;
import ballerinax/salesforce as sf;
import ballerina/ftp;

configurable ftp:ClientConfiguration ftpConfig = ?;
configurable sf:ConnectionConfig salesforceConfig = ?;
configurable string salesforcePriceBookId = ?;

public function main() returns error? {
    sf:Client sfClient = check new (salesforceConfig);
    ftp:Client ftpClient = check new ftp:Client(ftpConfig);
    ftp:FileInfo[] quoteList = check ftpClient->list("/ftp/user1/techpulse/new-quotes");
    foreach ftp:FileInfo quoteFile in quoteList {
        if !quoteFile.name.endsWith(".edi") {
            continue;
        }
        stream<byte[] & readonly, io:Error?> fileStream = check ftpClient->get(quoteFile.path);
        string quoteText = check streamToString(fileStream);
        mREQOTE:EDI_REQOTE_Request_for_quote_message quote = check mREQOTE:fromEdiString(quoteText);
        QuoteRequest quoteRequest = check transformQuoteRequest(quote);
        stream<record {|string Id;|}, error?> accQuery = check sfClient->query(
            string `SELECT Id FROM Account WHERE Name = '${quoteRequest.accountName}'`);
        record {|record {|string Id;|} value;|}? account = check accQuery.next();
        if account is () {
            return error("Account not found. Account name: " + quoteRequest.accountName);
        }
        Opportunity opp = {
            Name: quoteRequest.oppName,
            AccountId: account.value.Id,
            Pricebook2Id: salesforcePriceBookId
        };
        string oppId = "";
        stream<record {|string Id;|}, error?> oppQuery = check sfClient->query(
            string `SELECT Id FROM Opportunity WHERE Name = '${quoteRequest.oppName}'`);
        record {|record {|string Id;|} value;|}? existingOpp = check oppQuery.next();
        if existingOpp is () {
            sf:CreationResponse oppResult = check sfClient->create("Opportunity", opp);
            oppId = oppResult.id;
        } else {
            oppId = existingOpp.value.Id;
        }
        foreach ItemData item in quoteRequest.itemData {
            stream<PriceBookEntry, error?> query = check sfClient->query(string `SELECT UnitPrice FROM PricebookEntry WHERE Pricebook2Id = '01s6C000000UN4PQAW' AND Product2Id = '${item.itemId}'`);
            record {|PriceBookEntry value;|}? unionResult = check query.next();
            if unionResult is () {
                return error(string `Pricebook entry not found. Opportunity name: ${quoteRequest.oppName}, Item ID: ${item.itemId}`);
            }
            OpportunityProduct oppProduct = {
                OpportunityId: oppId,
                Product2Id: item.itemId,
                Quantity: item.quantity,
                UnitPrice: unionResult.value.UnitPrice
            };
            _ = check sfClient->create("OpportunityLineItem", oppProduct);
        }
        check ftpClient->put("/ftp/user1/techpulse/processed-quotes/" + quoteFile.name, quoteText.toBytes());
        check ftpClient->delete(quoteFile.path);
    }
}

function transformQuoteRequest(mREQOTE:EDI_REQOTE_Request_for_quote_message quote) returns QuoteRequest|error {
    QuoteRequest quoteRequest = {accountName: "", oppName: ""};
    mREQOTE:Segment_group_1_GType[] segmentGroup1 = quote.Segment_group_1;
    foreach mREQOTE:Segment_group_1_GType ref in segmentGroup1 {
        if ref.REFERENCE.REFERENCE.Reference_code_qualifier == "AES" {
            string? oppId = ref.REFERENCE.REFERENCE.Reference_identifier;
            if oppId is () {
                return error("Opportunity ID is not given");
            }
            quoteRequest.oppName = oppId;
        }
    }
    mREQOTE:Segment_group_11_GType[] segmentGroup11 = quote.Segment_group_11;
    foreach mREQOTE:Segment_group_11_GType party in segmentGroup11 {
        if party.NAME_AND_ADDRESS.Party_function_code_qualifier == "BY" {
            string? prospectId = party.NAME_AND_ADDRESS?.PARTY_IDENTIFICATION_DETAILS?.Party_identifier;
            if prospectId is () {
                return error("Prospect identifier not available in quote.");
            }
            quoteRequest.accountName = prospectId;
        }
    }
    mREQOTE:Segment_group_27_GType[] items = quote.Segment_group_27;
    foreach mREQOTE:Segment_group_27_GType item in items {
        string? itemId = item.LINE_ITEM.Line_item_identifier;
        if itemId is () {
            return error("Item ID is not given");
        }
        ItemData itemData = {itemId};
        mREQOTE:QUANTITY_Type[] quantities = item.QUANTITY;
        foreach mREQOTE:QUANTITY_Type quantity in quantities {
            if quantity.QUANTITY_DETAILS.Quantity_type_code_qualifier == "21" {
                int|error amount = int:fromString(quantity.QUANTITY_DETAILS.Quantity);
                if amount is error {
                    return error("Quantity must be a valid number.");
                }
                itemData.quantity = amount;
                break;
            }
        }
        quoteRequest.itemData.push(itemData);
    }
    return quoteRequest;
}

function streamToString(stream<byte[] & readonly, io:Error?> inStream) returns string|error {
    byte[] content = [];
    check inStream.forEach(function (byte[] & readonly chunk) {
        content.push(...chunk);
    });
    return string:fromBytes(content);
}


