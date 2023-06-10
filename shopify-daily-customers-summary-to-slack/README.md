# Shopify daily customer summary to Slack channel

## Scenario

In an e-commerce company, customer acquisition is a key metric for the business. It helps the team understand the effectiveness of their marketing campaigns and outreach efforts. The company uses Shopify for their online store and Slack for internal communication.
To keep everyone informed, the management team wants a daily summary report on new customers, including details like how many customers signed up, their details.

## Application Integration Use Case:

Scheduled to run daily(The provided sample runs more frequently for demonstration purpose), this project fetches new customer details from Shopify, compiles a report, and communicates this information via Slack, offering the management team a valuable snapshot of their daily customer acquisition and facilitating more informed decision-making.

## Setup Shopify account

Follow the steps mentioned in https://lib.ballerina.io/ballerinax/shopify.admin/2.4.1

## Setup Slack account

Follow the steps mentioned in https://lib.ballerina.io/ballerinax/slack/3.3.0

## Update Configurables

Based on your authentication information, please update the `Config.toml` file in this project.
