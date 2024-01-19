import ballerinax/googleapis.sheets;
import ballerinax/salesforce;

public type Contact record {|
    string Id;
    string Email;
|};

// Google sheets configuration parameters
configurable string spreadsheetId = ?;
configurable string worksheetName = ?;
configurable string sheetsAccessToken = ?;

// Salesforce configuration parameters
configurable string salesforceAccessToken = ?;
configurable string salesforceBaseUrl = ?;

sheets:Client sheets = check new ({
    auth: {
        token: sheetsAccessToken
        }
});

salesforce:Client salesforce = check new ({
    baseUrl: salesforceBaseUrl,
    auth: {
        token: salesforceAccessToken
    }
});

public function main() returns error? {
    sheets:Range range = check sheets->getRange(spreadsheetId, worksheetName, "A1:G");
    (int|string|decimal)[] headers = range.values[0];
    foreach (int|string|decimal)[] item in range.values.slice(1) {
        int? indexOfEmail = headers.indexOf("Email");
        if indexOfEmail is int {
            stream<Contact, error?> retrievedStream = check salesforce->query(
                string `SELECT Id, Email FROM Contact WHERE Email='${item[indexOfEmail]}'`);
            if retrievedStream.next() is () {
                record {} newContact = map from int index in 0 ..< headers.length()
                    let int|string|decimal header = headers[index]
                    select [header.toString(), item[index]];
                _ = check salesforce->create("Contact", newContact);
            }
        }
    }
}
