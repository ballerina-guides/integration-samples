import ballerina/grpc;
import ballerina/protobuf;

public const string FLIGHT_BOOK_DESC = "0A11666C696768745F626F6F6B2E70726F746F120D666C69676874626F6F6B696E6722540A18466C696768745265736572766174696F6E5265717565737412380A0A70617373656E6765727318022003280B32182E666C69676874626F6F6B696E672E50617373656E676572520A70617373656E6765727322410A19466C696768745265736572766174696F6E526573706F6E736512240A0D7265736572766174696F6E4964180120012809520D7265736572766174696F6E496422470A0950617373656E67657212120A046E616D6518012001280952046E616D6512260A0E70617373706F72744E756D626572180220012809520E70617373706F72744E756D62657232770A14466C69676874426F6F6B696E6753657276696365125F0A0A626F6F6B466C6967687412272E666C69676874626F6F6B696E672E466C696768745265736572766174696F6E526571756573741A282E666C69676874626F6F6B696E672E466C696768745265736572766174696F6E526573706F6E7365620670726F746F33";

public isolated client class FlightBookingServiceClient {
    *grpc:AbstractClientEndpoint;

    private final grpc:Client grpcClient;

    public isolated function init(string url, *grpc:ClientConfiguration config) returns grpc:Error? {
        self.grpcClient = check new (url, config);
        check self.grpcClient.initStub(self, FLIGHT_BOOK_DESC);
    }

    isolated remote function bookFlight(FlightReservationRequest|ContextFlightReservationRequest req) returns FlightReservationResponse|grpc:Error {
        map<string|string[]> headers = {};
        FlightReservationRequest message;
        if req is ContextFlightReservationRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("flightbooking.FlightBookingService/bookFlight", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <FlightReservationResponse>result;
    }

    isolated remote function bookFlightContext(FlightReservationRequest|ContextFlightReservationRequest req) returns ContextFlightReservationResponse|grpc:Error {
        map<string|string[]> headers = {};
        FlightReservationRequest message;
        if req is ContextFlightReservationRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("flightbooking.FlightBookingService/bookFlight", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <FlightReservationResponse>result, headers: respHeaders};
    }
}

public type ContextFlightReservationResponse record {|
    FlightReservationResponse content;
    map<string|string[]> headers;
|};

public type ContextFlightReservationRequest record {|
    FlightReservationRequest content;
    map<string|string[]> headers;
|};

@protobuf:Descriptor {value: FLIGHT_BOOK_DESC}
public type FlightReservationResponse record {|
    string reservationId = "";
|};

@protobuf:Descriptor {value: FLIGHT_BOOK_DESC}
public type FlightReservationRequest record {|
    Passenger[] passengers = [];
|};

@protobuf:Descriptor {value: FLIGHT_BOOK_DESC}
public type Passenger record {|
    string name = "";
    string passportNumber = "";
|};

