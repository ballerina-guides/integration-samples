CREATE TABLE users (
    id INT NOT NULL auto_increment PRIMARY KEY,
    birth_date DATE,
    name VARCHAR(255)
);
CREATE TABLE posts (
    id INT NOT NULL auto_increment PRIMARY KEY,
    description VARCHAR(255),
    user_id INT
);

insert into users(birth_date, name)
values(current_date(), 'Ranga');

insert into users(birth_date, name)
values(current_date(), 'Ravi');

insert into users(birth_date, name)
values(current_date(), 'Sathish');

insert into posts(description, user_id)
values('I want to learn AWS', 1);

insert into posts(description, user_id)
values('I want to learn DevOps', 1);

insert into posts(description, user_id)
values('I want to learn GCP', 2);

insert into posts(description, user_id)
values('I want to learn multi cloud', 3);
