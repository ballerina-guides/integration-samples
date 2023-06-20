import ballerina/http;
import ballerina/test;

final http:Client personsClient = check new (string `http://localhost:${port}`);

@test:Config {}
function testStudentTransform() returns error? {
    Person person = {
        id: "1004",
        firstName: "Vinnie",
        lastName: "Hickman",
        age: 15,
        country: "UK"
    };

    Person response = check personsClient->/persons.post(person);
    test:assertEquals(response, person);

    Course[] courses = [
        {
            id: "CS6002",
            name: "Computation Structures",
            credits: 4
        },
        {
            id: "CS6003",
            name: "Circuits and Electronics",
            credits: 3
        },
        {
            id: "CM1001",
            name: "Computational Statistics",
            credits: 4
        },
        {
            id: "CS6004",
            name: "Signals and Systems",
            credits: 3
        }
    ];

    Student student = check personsClient->/persons/'1004/enroll.post(courses);
    Student expectedStudent = {
        id: "1004F",
        fullName: "Vinnie Hickman",
        age: "15",
        courses: [
            {
                title: "CS6002 - Computation Structures",
                credits: 4
            },
            {
                title: "CS6003 - Circuits and Electronics",
                credits: 3
            },
            {
                title: "CS6004 - Signals and Systems",
                credits: 3
            }
        ],
        visaType: D_TIER_4_VISA,
        totalCredits: 10
    };

    test:assertEquals(student, expectedStudent, "Student transformation failed");
}

@test:Config {}
function testGetPersons() returns error? {
    Person[] response = check personsClient->/persons;
    test:assertEquals(response, persons.toArray());
}

@test:Config {}
function testPostPerson() returns error? {
    Person person = {"id": "1003","firstName": "John","lastName": "Smith","age": 24,"country": "US"};

    Person response = check personsClient->/persons.post(person);
    test:assertEquals(response, person);
}

@test:Config {
    dependsOn: [testPostPerson]
}
function testPutPerson() returns error? {
    Person person = {
        id: "1003",
        firstName: "Jane",
        lastName: "Smith",
        age: 28,
        country: "LK"
    };

    Person response = check personsClient->/persons.put(person);
    test:assertEquals(response, person);
}
