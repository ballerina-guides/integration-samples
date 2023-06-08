import ballerina/xmldata;

// XML to JSON transformation

function transformXmlToJsonDirect(xml input) returns map<json>|error =>
    let xml<xml:Element> buyer = input/<buyer>,
        xml:Element buyerElement = check buyer[0].ensureType() in
    {
        name: (buyerElement/<name>).data(),
        buyer_address: (buyerElement/<address>).data(),
        city: (buyerElement/<city>).data(),
        country: (buyerElement/<country>).data(),
        postalCode: check int:fromString((buyerElement/<postCode>).data())
    };

function transformXmlToJsonViaConversionToJson(xml input) returns map<json>|error =>
    let xml<xml:Element> buyer = input/<buyer>,
        json buyerJson = check (check xmldata:toJson(buyer)).buyer in
    {
        name: check buyerJson.name,
        buyer_address: check buyerJson.address,
        city: check buyerJson.city,
        country: check buyerJson.country,
        postalCode: check int:fromString(check buyerJson.postCode)
    };

type Buyer record {
    string name;
    string address;
    string city;
    string country;
    int postCode;
};

function transformXmlToJsonViaConversionToRecord(xml orderXml) returns map<json>|error =>
    let xml<xml:Element> buyer = orderXml/<buyer>,
        record {| Buyer buyer; |} buyerFromXml = check xmldata:fromXml(buyer),
        Buyer buyerRec = buyerFromXml.buyer in
    {
        name: buyerRec.name,
        buyer_address: buyerRec.address,
        city: buyerRec.city,
        country: buyerRec.country,
        postalCode: buyerRec.postCode
    };
