CREATE DATABASE IF NOT EXISTS apollo_social_media;

USE apollo_social_media;

CREATE TABLE
    IF NOT EXISTS user (
        id VARCHAR(36) NOT NULL PRIMARY KEY,
        age INT NOT NULL,
        name VARCHAR(255) NOT NULL
    );

CREATE TABLE
    IF NOT EXISTS post (
        id VARCHAR(36) NOT NULL PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        content TEXT NOT NULL,
        user_id VARCHAR(36) NOT NULL,
        FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE CASCADE
    );
