import ballerina/graphql;
import xlibb/pipe;

@graphql:ServiceConfig {
    graphiql: {
        enabled: true
    }
}
service /graphql on new graphql:Listener(9000) {
    
    private final pipe:Pipe donationPipe = new(5);
    private decimal totalAmount = 0;

    resource function get donations() returns decimal {
        lock {
            return self.totalAmount;
        }
    }

    remote function donate(decimal amount) returns string|error {
        lock {
            self.totalAmount += amount;
            check self.donationPipe.produce(self.totalAmount, -1);
        }
        return "Thanks!";
    }

    resource function subscribe donations() returns stream<decimal, error?>|error {
        return check self.donationPipe.consumeStream(-1);
    }
}

