#!/usr/bin/env bash

docker-compose up mysql -d 
docker exec kirakira-mysql-1 rm db.sql
docker cp ./backend/db.sql kirakira-mysql-1:/db.sql
docker exec kirakira-mysql-1 mysql --user=root --password=kirakira -e "USE kirakira; SOURCE /db.sql; INSERT INTO user(username, email, password) VALUES('admin', 'mail@example.com', '\$2a\$12\$AyNInFMs4SOjtOGY9MvPcO6bFwKKNXgOMh9CEQbcq.o9cmjtKHtFS'); INSERT INTO user_admin(user_id) VALUES(1);"
docker-compose up frontend backend -d
echo "You can now access the dev environment on https://localhost:1234"
echo "Admin Account: username: 'admin', email: 'mail@example.com', password: '12345678'"
