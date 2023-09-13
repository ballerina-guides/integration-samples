import ballerina/http;
import ballerina/log;
import ballerina/time;
import ballerinax/microsoft.onedrive;
import ballerinax/microsoft.outlook.mail;
import ballerinax/shopify.admin as shopify;

configurable string shopifyServiceUrl = ?;
configurable string xShopifyAccessToken = ?;

configurable string outlookAccessToken = ?;

configurable string oneDriveAccessToken = ?;
configurable string flyerFilePath = ?;

public function main() returns error? {
    shopify:Client shopify = check new ({xShopifyAccessToken: xShopifyAccessToken}, shopifyServiceUrl);
    mail:Client outlook = check new ({ auth: { token: outlookAccessToken }});
    onedrive:Client onedrive = check new ({auth: { token: oneDriveAccessToken}});

    string dateOriginTime = time:utcToString(time:utcAddSeconds(time:utcNow(), -300.0));
    string currentTime = time:utcToString(time:utcNow());

    shopify:CustomerList customerList = check shopify->getCustomers(createdAtMin = dateOriginTime, createdAtMax = currentTime);
    shopify:Customer[] customers = customerList?.customers ?: [];
    mail:Recipient[] recepients = [];
    foreach shopify:Customer customer in customers {
        recepients.push({
            emailAddress: {
                address: customer?.email ?: "",
                name: customer?.first_name ?: ""
            }
        });
    }

    onedrive:File fileContents = check onedrive->downloadFileByPath(flyerFilePath);
    byte[] byteContent = fileContents.content ?: [];

    if customers.length() > 0 {
        mail:FileAttachment attachment = {
            contentBytes: byteContent.toBase64(),
            contentType: "image/png",
            name: "flyer.png"
        };
        mail:MessageContent messageContent = {
            message: {
                subject: "Welcome to Our Store",
                importance: "normal",
                body: {
                    "contentType": "HTML",
                    "content": string `<p> Hi There, <br/>
                        <h2> Welcome to Our Store </h2> <br/>
                        <strong> What happens next? <strong> <br/>
                        Keep an eye on your inbox as we’ll be sending you the best tips for [product/service]. <br/>
                        Want to get more out of Our Store? <br/> visit our store at Shopify </p>` 
                },
                toRecipients: recepients,
                attachments: [attachment]
            },
            saveToSentItems: true
        };
        http:Response response = check outlook->sendMessage(messageContent);
        if response.statusCode == http:STATUS_ACCEPTED {
            log:printInfo(string `Welcome emails sent successfully!`);
        } else {
            return error("Failed to send the email from Outlook", statusCode = response.statusCode);
        }
    }
}
