CREATE DATABASE wordpressdb;
CREATE USER "mysqluser";
GRANT ALL PRIVILEGES ON wordpressdb.* TO 'mysqluser';
FLUSH PRIVILEGES;
