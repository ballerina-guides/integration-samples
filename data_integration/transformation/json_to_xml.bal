// JSON to XML transformation

function transformJsonToXml(json input) returns xml|error => 
    let json[] students = check input.students.ensureType() in 
    <xml> xml `<?xml version='1.0' encoding='UTF-8'?><students>${
                    from json student in students
                        let string firstName = check student.firstName,
                            string lastName = check student.lastName
                        select xml `<student><firstName>${
                                        firstName}</firstName><lastName>${
                                        lastName}</lastName></student>`
               }</students>`;
