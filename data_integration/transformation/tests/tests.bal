import ballerina/test;

@test:Config
function testTransformJsonToXml() returns error? {
    json studentsJson = {
        "students": [
            {"firstName": "Joy", "lastName": "William"},
            {"firstName": "John", "lastName": "Doe"}
        ]
    };
    xml expected = xml `<?xml version='1.0' encoding='UTF-8'?><students><student><firstName>Joy</firstName><lastName>William</lastName></student><student><firstName>John</firstName><lastName>Doe</lastName></student></students>`;
    xml actual = check transformJsonToXml(studentsJson);
    test:assertEquals(actual, expected);
}

@test:Config {
    dataProvider: testTransformXmlToJsonFunctions
}
function testTransformXmlToJson(function (xml input) returns map<json>|error fn) returns error? {
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
    map<json> expected = {
        name: "Amani Peiris",
        buyer_address: "20, Main Street",
        city: "Kottawa",
        country: "LK",
        postalCode: 10230
    };
    map<json> actual = check fn(orderXml);
    test:assertEquals(actual, expected);
}

function testTransformXmlToJsonFunctions() returns (function (xml input) returns map<json>|error)[][] => [
    [transformXmlToJsonDirect],
    [transformXmlToJsonViaConversionToJson],
    [transformXmlToJsonViaConversionToRecord]
];

final readonly & json booksJson = {
    "books": [
        {
            "name": "A Christmas Carol",
            "author": "Charles Dickens",
            "price": "1530",
            "year": 1843
        },
        {
            "name": "Oliver Twist",
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

@test:Config
function testTransformJson() returns error? {
    json expected = {
        "items": [
            {
                "book": {
                    "NAME": "A Christmas Carol",
                    "AUTHOR": "Charles Dickens",
                    "PRICE": "1530",
                    "YEAR": 1843
                }
            },
            {
                "book": {
                    "NAME": "Oliver Twist",
                    "AUTHOR": "Charles Dickens",
                    "PRICE": "1323",
                    "YEAR": 1838
                }
            },
            {
                "book": {
                    "NAME": "Heidi",
                    "AUTHOR": "Johanna Spyri",
                    "PRICE": "1100",
                    "YEAR": 1881
                }
            }
        ]
    };
    json actual = check transformJson(booksJson);
    test:assertEquals(actual, expected);
}

json expectedTransformedJsonWithDefaults = {
    "items": [
        {
            "category": "book",
            "price": 1530.0,
            "id": 1,
            "properties": {
                "title": "A Christmas Carol",
                "author": "Charles Dickens",
                "year": 1843
            }
        },
        {
            "category": "book",
            "price": 1323.0,
            "id": 2,
            "properties": {
                "title": "Oliver Twist",
                "author": "Charles Dickens",
                "year": 1838
            }
        },
        {
            "category": "book",
            "price": 1100.0,
            "id": 3,
            "properties": {
                "title": "Heidi",
                "author": "Johanna Spyri",
                "year": 1881
            }
        }
    ]
};

@test:Config
function testTransformJsonWithDefaults() returns error? {
    json actual = check transformJsonWithDefaults(booksJson);
    test:assertEquals(actual, expectedTransformedJsonWithDefaults);
}

@test:Config
function testTransformJsonWithDefaultsViaRecords() returns error? {
    json actual = check transformJsonWithDefaultsViaRecords(booksJson);
    test:assertEquals(actual, expectedTransformedJsonWithDefaults);
}
