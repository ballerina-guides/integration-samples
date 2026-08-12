import ballerina/io;
import ballerina/workflow;

type Claim record {|
    string claimId;
    string policyNo;
    decimal amount;
|};

@workflow:Workflow
function claimProcessingWorkflow(workflow:Context ctx, Claim claim) returns string|error {
    boolean verified = check ctx->callActivity(verifyClaim, {"claim": claim});
    if !verified {
        return string `Claim ${claim.claimId} was rejected during verification.`;
    }
    string paymentRef = check ctx->callActivity(makePayment, {"claimId": claim.claimId, "amount": claim.amount});
    return string `Claim ${claim.claimId} approved. Payment reference: ${paymentRef}`;
}

@workflow:Activity
function verifyClaim(Claim claim) returns boolean|error {
    io:println(string `Verifying claim ${claim.claimId} against policy ${claim.policyNo}`);
    return claim.amount <= 1000.0d;
}

@workflow:Activity
function makePayment(string claimId, decimal amount) returns string|error {
    io:println(string `Paying ${amount} for claim ${claimId}`);
    return string `PAY-${claimId}`;
}

public function main() returns error? {
    string workflowId = check workflow:run(claimProcessingWorkflow,
            {claimId: "CLM-001", policyNo: "POL-1234", amount: 750.0d});
    io:println("Workflow started with ID: " + workflowId);

    // Blocks until the workflow completes or the timeout (in seconds) is reached.
    anydata result = check workflow:getWorkflowResult(workflowId, 60);
    io:println("Result: " + result.toString());
}
