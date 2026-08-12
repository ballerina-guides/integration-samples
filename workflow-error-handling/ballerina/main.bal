import ballerina/http;
import ballerina/io;
import ballerina/workflow;
import ballerina/workflow.management as _;

type PayoutRequest record {|
    string claimId;
    string accountNo;
    decimal amount;
    string currency;
|};

@workflow:Workflow
function claimPayoutWorkflow(workflow:Context ctx, PayoutRequest request) returns string|error {
    decimal localAmount = check ctx->callActivity(convertCurrency,
            {"amount": request.amount, "currency": request.currency},
            retryPolicy = {maxRetries: 3, retryDelay: 2.0, retryBackoff: 2.0});
    string depositRef = check ctx->callActivity(depositPayout,
            {"accountNo": request.accountNo, "amount": localAmount},
            retryPolicy = "OPS");
    string _ = check ctx->callActivity(notifyCustomer,
            {"claimId": request.claimId, "depositRef": depositRef});
    return string `Claim ${request.claimId} paid. Deposit reference: ${depositRef}`;
}

int convertAttempts = 0;

// Simulates a flaky exchange-rate service: the first two calls fail,
// the third succeeds. The AutoRetry policy recovers without any human help.
@workflow:Activity
function convertCurrency(decimal amount, string currency) returns decimal|error {
    convertAttempts += 1;
    if convertAttempts % 3 != 0 {
        return error(string `Exchange rate service is unavailable (attempt ${convertAttempts})`);
    }
    io:println(string `Converted ${amount} ${currency} on attempt ${convertAttempts}`);
    return currency == "USD" ? amount * 300.0d : amount;
}

// Simulates a bank transfer that fails on a malformed account number.
// The HumanReview policy ("OPS") suspends the workflow until an operator
// retries, corrects the input, or rejects the activity.
@workflow:Activity
function depositPayout(string accountNo, decimal amount) returns string|error {
    if !accountNo.startsWith("ACC-") {
        return error(string `Invalid account number: ${accountNo}`);
    }
    io:println(string `Deposited ${amount} to ${accountNo}`);
    return string `DEP-${accountNo}`;
}

@workflow:Activity
function notifyCustomer(string claimId, string depositRef) returns string|error {
    io:println(string `Notified customer: claim ${claimId}, deposit ${depositRef}`);
    return "SENT";
}

service /payouts on new http:Listener(8080) {

    resource function post .(PayoutRequest request) returns json|error {
        string workflowId = check workflow:run(claimPayoutWorkflow, request);
        return {claimId: request.claimId, workflowId, status: "PROCESSING"};
    }

    resource function get [string workflowId]() returns json|error {
        anydata result = check workflow:getWorkflowResult(workflowId, 5);
        return {workflowId, result: check result.cloneWithType(json)};
    }
}
