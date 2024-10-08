-- AUTO-GENERATED FILE.

-- This file is an auto-generated file by Ballerina persistence layer for model.
-- Please verify the generated scripts and execute them against the target DB server.

DROP TABLE IF EXISTS `Book`;

CREATE TABLE `Book` (
	`id` INT NOT NULL,
	`title` VARCHAR(191) NOT NULL,
	`author` VARCHAR(191) NOT NULL,
	`isbn` VARCHAR(191) NOT NULL,
	`price` INT NOT NULL,
	PRIMARY KEY(`id`)
);
