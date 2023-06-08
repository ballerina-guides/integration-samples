import ballerina/io;

public function main() returns error? {
    json studentsJson = {
        "students": [
            {"firstName": "Joy", "lastName": "William"},
            {"firstName": "John", "lastName": "Doe"}
        ]
    };
    xml studentsTransformedXml = check transformJsonToXml(studentsJson);
    io:println(studentsTransformedXml);

    xml orderXml =
        xml `
            <?xml version='1.0' encoding='UTF-8'?>
            <order>
                <products>
                    <product>
                        <price>1</price>
                        <model>Blue pen</model>
                    </product>
                </products>
                <count>3</count>
                <buyer>
                    <name>Amani Peiris</name>
                    <address>20, Main Street</address>
                    <city>Kottawa</city>
                    <province>Western</province>
                    <country>LK</country>
                    <postCode>10230</postCode>
                </buyer>
            </order>`;
    map<json> buyerDetailsTransformedJson = check transformXmlToJsonDirect(orderXml);
    io:println(buyerDetailsTransformedJson);

    buyerDetailsTransformedJson = check transformXmlToJsonViaConversionToJson(orderXml);
    io:println(buyerDetailsTransformedJson);

    buyerDetailsTransformedJson = check transformXmlToJsonViaConversionToRecord(orderXml);
    io:println(buyerDetailsTransformedJson);

    json booksJson = {
        "books": [
            {
                "name": "A Christmas Carol",
                "author": "Charles Dickens",
                "price": "1530",
                "year": 1843
            },
            {
                "name": "Oliwer Twist",
                "author": "Charles Dickens",
                "price": "1323",
                "year": 1838
            },
            {
                "name": "Heidi",
                "author": "Johanna Spyri",
                "price": "1100",
                "year": 1881
            }
        ]
    };
    map<json> booksTransformedJson = check transformJson(booksJson);
    io:println(booksTransformedJson);

    map<json> booksTransformedJsonWithDefaults = check transformJsonWithDefaults(booksJson);
    io:println(booksTransformedJsonWithDefaults);

    Output output = check transformJsonWithDefaultsViaRecords(booksJson);
    io:println(output);
}
