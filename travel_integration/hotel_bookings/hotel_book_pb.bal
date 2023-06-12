import ballerina/grpc;
import ballerina/protobuf;

public const string HOTEL_BOOK_DESC = "0A10686F74656C5F626F6F6B2E70726F746F1209686F74656C626F6F6B22B5010A13486F74656C426F6F6B696E6752657175657374121C0A09686F74656C4E616D651801200128095209686F74656C4E616D65121C0A0967756573744E616D65180220012809520967756573744E616D6512200A0B636865636B696E44617465180320012809520B636865636B696E4461746512220A0C636865636B6F757444617465180420012809520C636865636B6F757444617465121C0A096E6F4F66526F6F6D7318052001280552096E6F4F66526F6F6D7322400A18486F74656C5265736572766174696F6E526573706F6E736512240A0D7265736572766174696F6E4964180120012809520D7265736572766174696F6E496432670A13486F74656C426F6F6B696E675365727669636512500A09626F6F6B486F74656C121E2E686F74656C626F6F6B2E486F74656C426F6F6B696E67526571756573741A232E686F74656C626F6F6B2E486F74656C5265736572766174696F6E526573706F6E7365620670726F746F33";

public isolated client class HotelBookingServiceClient {
    *grpc:AbstractClientEndpoint;

    private final grpc:Client grpcClient;

    public isolated function init(string url, *grpc:ClientConfiguration config) returns grpc:Error? {
        self.grpcClient = check new (url, config);
        check self.grpcClient.initStub(self, HOTEL_BOOK_DESC);
    }

    isolated remote function bookHotel(HotelBookingRequest|ContextHotelBookingRequest req) returns HotelReservationResponse|grpc:Error {
        map<string|string[]> headers = {};
        HotelBookingRequest message;
        if req is ContextHotelBookingRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("hotelbook.HotelBookingService/bookHotel", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <HotelReservationResponse>result;
    }

    isolated remote function bookHotelContext(HotelBookingRequest|ContextHotelBookingRequest req) returns ContextHotelReservationResponse|grpc:Error {
        map<string|string[]> headers = {};
        HotelBookingRequest message;
        if req is ContextHotelBookingRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("hotelbook.HotelBookingService/bookHotel", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <HotelReservationResponse>result, headers: respHeaders};
    }
}

public client class HotelBookingServiceHotelReservationResponseCaller {
    private grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendHotelReservationResponse(HotelReservationResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextHotelReservationResponse(ContextHotelReservationResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public type ContextHotelReservationResponse record {|
    HotelReservationResponse content;
    map<string|string[]> headers;
|};

public type ContextHotelBookingRequest record {|
    HotelBookingRequest content;
    map<string|string[]> headers;
|};

@protobuf:Descriptor {value: HOTEL_BOOK_DESC}
public type HotelReservationResponse record {|
    string reservationId = "";
|};

@protobuf:Descriptor {value: HOTEL_BOOK_DESC}
public type HotelBookingRequest record {|
    string hotelName = "";
    string guestName = "";
    string checkinDate = "";
    string checkoutDate = "";
    int noOfRooms = 0;
|};

