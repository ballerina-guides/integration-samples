import ballerina/http;
import ballerina/test;

final http:Client coursesClient = check new (string `http://localhost:${port}`);

@test:Config {}
function testStudentTransform() returns error? {
    Person person = {
        id: "1001",
        firstName: "Vinnie",
        lastName: "Hickman",
        age: 15,
        country: "UK"
    };

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

    Student student = transform(person, courses);
    Student expectedStudent = {
        id: "1001F",
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
function testGetCourses() returns error? {
    Course[] response = check coursesClient->/courses;
    test:assertEquals(response, courses.toArray());
}

@test:Config {}
function testPostCourse() returns error? {
    Course course = {
        id: "CS6005",
        name: "Computer Networks",
        credits: 4
    };

    Course response = check coursesClient->/courses.post(course);
    test:assertEquals(response, course);
}

@test:Config {
    dependsOn: [testPostCourse]
}
function testPutCourse() returns error? {
    Course course = {
        id: "CS6005",
        name: "Computer Networks",
        credits: 2
    };

    Course response = check coursesClient->/courses.put(course);
    test:assertEquals(response, course);
}
