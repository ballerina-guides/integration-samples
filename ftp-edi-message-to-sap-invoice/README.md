# FTP B2B EDI message to SAP Invoice

This sample reads EDI files from a given FTP location, and creates an [SAP S/4HANA](https://www.sap.com/products/erp/s4hana.html) invoice for each EDI message.

## Use Case

SAP S/4HANA is an ERP system that helps organizations manage their business operations. EDI is a standard format for exchanging business documents between enterprises. EDI messages are commonly used in B2B communications. Therefore, it's important to integrate B2B messaging channels with internal IT to streamline and automate business processes.

This sample shows how EDI messages containing invoices (EDIFACT INVOIC) can be used to automatically create supplier invoices in SAP S/4HANA.

## Prerequisites

Before setting up this integration, you'll need the following:

- FTP Server
- SAP S/4HANA account with permissions to create supplier invoices

### Setting up an FTP server

1. Start FTP server using the command below.
```docker run -d -p <ftp-host-port>:21 -p 21000-21010:21000-21010 -e USERS="<username>|<password>" -e ADDRESS=localhost delfer/alpine-ftp-server```
(E.g. ```docker run -d -p 2100:21 -p 21000-21010:21000-21010 -e USERS="user1|pass1" -e ADDRESS=localhost delfer/alpine-ftp-server```).

> Note that any FTP server with read and write access can be used for this sample. If an FTP server is available, skip this point.

2. Create a folder in the FTP server for input EDI files. (E.g. `samples/invoices`)

3. Copy files in the resources/inputs folder to the FTP folder created for input EDI files.

4. Fill in the fields under the `FTP configuration` section in `Config.toml` with FTP server details and paths for EDI files.

### Setting up an SAP Account

1. If you don't have an SAP account, create one and ensure you have the necessary permissions to create supplier invoices.

2. Obtain your SAP API credentials, including the username and password required for authenticating with the SAP client.

4. Fill in the fields under the `FTP configuration` section in `Config.toml` with SAP credentials.

## Configuration

Create a file called `Config.toml` at the root of the project with the following content:

```toml
ftpNewInvoicesPath="<FTP_INVOICE_DIR_PATH>"

[sapAuthConfig]
username = "<SAP_COMMUNICATION_USERNAME>"
password = "<SAP_COMMUNICATION_USER_PASSWORD>"

[ftpConfig] 
protocol = "ftp"
host = "127.0.0.1"
port = <FTP_HOST_PORT>

[ftpConfig.auth.credentials]
username = "<FTP_SERVER_USERNAME>"
password = "<FTP_SERVER_PASSWORD>"
```

## Testing
1. Run `bal run` to start the integration.
2. Check the SAP S/4HANA system for the newly created invoices.
