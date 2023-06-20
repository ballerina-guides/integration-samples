import ballerina/http;

type Person record {
    string id;
    string firstName;
    string lastName;
    int age;
    string country;
};

type Course record {
    readonly string id;
    string name;
    int credits;
};

type Student record {
    string id;
    string fullName;
    string age;
    record {
        string title;
        int credits;
    }[] courses;
    int totalCredits;
    string visaType;
};

const D_TIER_4_VISA = "D tier-4";

var totalCredits = function(int total, record {string id; string name; int credits;} course) returns int => total + (course.id.startsWith("CS") ? course.credits : 0);

function transform(Person person, Course[] courses) returns Student => let var isForeign = person.country != "LK" in {
        id: person.id + (isForeign ? "F" : ""),
        age: person.age.toString(),
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

configurable int port = 8080;

table<Course> key(id) courses = table [
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
    }
];

service / on new http:Listener(port) {

    resource function get courses() returns Course[] {
        return courses.toArray();
    }

    resource function post courses(Course course) returns Course|http:Conflict {
        if courses.hasKey(course.id) {
            return http:CONFLICT;
        }
        courses.add(course);
        return course;
    }

    resource function put courses(Course course) returns Course|http:NotFound {
        if courses.hasKey(course.id) {
            courses.put(course);
            return course;
        }
        return http:NOT_FOUND;
    }
}
