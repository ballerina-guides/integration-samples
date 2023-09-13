import ballerina/log;
import ballerinax/googleapis.sheets;
import ballerinax/salesforce;

public type Contact record {|
    string Id;
    string Email;
|};

const int HEADINGS_ROW = 1;

// Google sheets configuration parameters
configurable string spreadsheetId = ?;
configurable string worksheetName = ?;
configurable string duplicateWorksheetName = ?;
configurable string gSheetsAccessToken = ?;

// Salesforce configuration parameters
configurable string salesforceAccessToken = ?;
configurable string salesforceBaseUrl = ?;

sheets:Client sheets = check new ({auth: {token: gSheetsAccessToken}});

salesforce:Client salesforce = check new ({
    baseUrl: salesforceBaseUrl,
    auth: {
        token: salesforceAccessToken
    }
});

public function main() returns error? {
    sheets:Range range = check sheets->getRange(spreadsheetId, worksheetName, "A1:G");
    (int|string|decimal)[] headers = range.values[0];
    foreach (int|string|decimal)[] item in range.values.slice(HEADINGS_ROW) {
        int? indexOfEmail = headers.indexOf("Email");
        if indexOfEmail is () {
            return error("Email column not found");
        }
        stream<Contact, error?> retrievedStream = check salesforce->query(
            string `SELECT Id, Email FROM Contact WHERE Email='${item[indexOfEmail]}'`);
        if retrievedStream.next() !is () {
            log:printInfo(string `Contact already exists. Email : ${item[indexOfEmail]}`);
            _ = check sheets->appendValue(spreadsheetId, item, {sheetName: duplicateWorksheetName});
            continue;
        }
        record {} newContact = map from int index in 0 ..< headers.length()
            let int|string|decimal header = headers[index]
            select [header.toString(), item[index]];
        _ = check salesforce->create("Contact", newContact);
        log:printInfo(string `Contact created successfully!. Email : ${item[indexOfEmail]}`);
    }
}
