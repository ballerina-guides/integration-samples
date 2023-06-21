import ballerina/http;
import ballerinax/googleapis.sheets;

type Person record {
    readonly int id;
    string firstName;
    string lastName;
    int age;
    string country;
};

type Course record {
    string id;
    string name;
    int credits;
};

type Student record {
    string id;
    string fullName;
    int age;
    record {
        string title;
        int credits;
    }[] courses;
    int totalCredits;
    string visaType;
};

configurable int port = 8080;
configurable string sheetsAccessToken = ?;
configurable string spreadSheetId = ?;
configurable string sheetName = "enrollments";

final sheets:Client gsheetsClient = check new ({auth: {token: sheetsAccessToken}});

const D_TIER_4_VISA = "D tier-4";

table<Person> key(id) persons = table [
    {
        id: 1001,
        firstName: "John",
        lastName: "Doe",
        age: 25,
        country: "LK"
    },
    {
        id: 1002,
        firstName: "Jane",
        lastName: "Doe",
        age: 23,
        country: "US"
    }
];

var totalCredits = function(int total, record {string id; string name; int credits;} course)
                        returns int => total + (course.id.startsWith("CS") ? course.credits : 0);

function enrollPerson(Person person, Course[] courses) returns Student => let var isForeign = person.country != "LK" in {
        id: person.id.toString() + (isForeign ? "F" : ""),
        age: person.age,
        fullName: person.firstName + " " + person.lastName,
        courses: from var coursesItem in courses
            where coursesItem.id.startsWith("CS")
            select {
                title: coursesItem.id + " - " + coursesItem.name,
                credits: coursesItem.credits
            },
        visaType: isForeign ? D_TIER_4_VISA : "n/a",
        totalCredits: courses.reduce(totalCredits, 0)
    };

service / on new http:Listener(port) {

    resource function get persons() returns Person[] {
        return persons.toArray();
    }

    resource function post persons(Person person) returns http:Conflict|Person {
        if persons.hasKey(person.id) {
            return http:CONFLICT;
        }
        persons.add(person);
        return person;
    }

    resource function put persons(Person person) returns http:NotFound|Person {
        if persons.hasKey(person.id) {
            persons.put(person);
            return person;
        }
        return http:NOT_FOUND;
    }

    resource function post persons/[int id]/enroll(Course[] courses)
            returns Student|http:NotFound|http:InternalServerError {
        if persons.hasKey(id) {
            Person person = persons.get(id);
            Student student = enrollPerson(person, courses);
            do {
                _ = check gsheetsClient->appendValue(spreadSheetId, [
                        student.id,
                        student.fullName,
                        student.age,
                        student.visaType,
                        string:'join(", ", ...from var course in student.courses
                            select course.title),
                        student.totalCredits
                    ], {sheetName: sheetName});
                return student;
            } on fail error err {
                return <http:InternalServerError>{
                    body: err.message()
                };
            }
        }
        return http:NOT_FOUND;
    }
}
