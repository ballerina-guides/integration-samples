import ballerina/log;
import ballerina/regex;
import ballerina/time;
import ballerinax/shopify.admin;
import ballerinax/slack;
import ballerina/task;
import ballerina/lang.runtime;

// Shopify configuration parameters
configurable string shopifyServiceUrl = ?;
configurable admin:ApiKeysConfig shopifyAuthConfig = ?;

// Slack configuration parameters
configurable string slackToken = ?;
configurable string slackChannelName = ?;

admin:Client shopifyClient = check new (shopifyAuthConfig, serviceUrl = shopifyServiceUrl);

// Creates a job to be executed by the scheduler.
class Job {

    *task:Job;

    // Executes this function when the scheduled trigger fires.
    public function execute() {
        string date = regex:split(time:utcToString(time:utcNow()), "T")[0];
        string dateStartTime = string:concat(date, "T00:00:00.000000Z");
        string currentTime = time:utcToString(time:utcNow());

        admin:CustomerList|error customerList = shopifyClient->getCustomers(createdAtMin = dateStartTime, createdAtMax = currentTime);

        if customerList is error {
            log:printError(string `Error while getting customers list. ${customerList.message()}`);
            return;
        }

        admin:Customer[]? customers = customerList?.customers;
        if customers is admin:Customer[] {

            string message = "There are " + customers.length().toString() + " new customers for the day " + date + " : \n";

            foreach admin:Customer customer in customers {
                string customerEmail = customer?.email ?: "";
                string customerFirstName = customer?.first_name ?: "";
                string customerLastName = customer?.last_name ?: "";
                string customerInfo = "Customer Email : " + customerEmail + ", Customer First Name : " + customerFirstName + ", Customer Last Name : " + customerLastName + "\n";
                message = string:concat(message, customerInfo);
            }

            slack:Client|error slackClient = new ({auth: {token: slackToken}});
            if slackClient is error {
                log:printError(string `Error while creating slack client. ${slackClient.message()}`);
                return;
            }
            string|error postMessage = slackClient->postMessage({
                channelName: slackChannelName,
                text: message
            });
            if postMessage is string {
                log:printInfo(string `Message posted in Slack channel ${slackChannelName} successfully!`);
            }
        }
    }
}

public function main() returns error? {

    // The occurrence could be update to run the job every day at a given time.
    // But for easy demonstration, sticking to run the job every 5 seconds.
    // Schedules the task to execute the job every 5 second.
    task:JobId id = check task:scheduleJobRecurByFrequency(new Job(), 5);

    // Waits for few seconds.
    runtime:sleep(11);

    // Unschedules the job.
    check task:unscheduleJob(id);
}