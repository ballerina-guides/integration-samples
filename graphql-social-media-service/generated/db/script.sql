-- AUTO-GENERATED FILE.

-- This file is an auto-generated file by Ballerina persistence layer for model.

-- Please verify the generated scripts and execute them against the target DB server.

CREATE DATABASE IF NOT EXISTS ballerina_social_media;

USE ballerina_social_media;

CREATE TABLE
    IF NOT EXISTS `User` (
        `id` VARCHAR(191) NOT NULL,
        `name` VARCHAR(191) NOT NULL,
        `age` INT NOT NULL,
        PRIMARY KEY(`id`)
    );

CREATE TABLE
    IF NOT EXISTS `Post` (
        `id` VARCHAR(191) NOT NULL,
        `title` VARCHAR(191) NOT NULL,
        `content` VARCHAR(191) NOT NULL,
        `authorId` VARCHAR(191) NOT NULL,
        CONSTRAINT FK_AUTHOR FOREIGN KEY(`authorId`) REFERENCES `User`(`id`),
        PRIMARY KEY(`id`)
    );
