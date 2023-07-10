insert into user_details(id, birth_date, name)
values(1001, current_date(), 'Ranga');

insert into user_details(id, birth_date, name)
values(1002, current_date(), 'Ravi');

insert into user_details(id, birth_date, name)
values(1003, current_date(), 'Sathish');

insert into post(id, description, user_id)
values(2001, 'I want to learn AWS', 1001);

insert into post(id, description, user_id)
values(2002, 'I want to learn DevOps', 1001);

insert into post(id, description, user_id)
values(2003, 'I want to learn GCP', 1002);

insert into post(id, description, user_id)
values(2004, 'I want to learn multi cloud', 1002);
