CREATE TABLE user (
    id INT NOT NULL auto_increment PRIMARY KEY,
    birth_date DATE,
    name VARCHAR(255)
);
CREATE TABLE post (
    id INT NOT NULL auto_increment PRIMARY KEY,
    description VARCHAR(255),
    user_id INT
);

insert into user(birth_date, name)
values(current_date(), 'Ranga');

insert into user(birth_date, name)
values(current_date(), 'Ravi');

insert into user(birth_date, name)
values(current_date(), 'Sathish');

insert into post(description, user_id)
values('I want to learn AWS', 1);

insert into post(description, user_id)
values('I want to learn DevOps', 1);

insert into post(description, user_id)
values('I want to learn GCP', 2);

insert into post(description, user_id)
values('I want to learn multi cloud', 3);
