import ballerina/grpc;
import ballerina/protobuf;

public const string CAR_RENT_DESC = "0A0E6361725F72656E742E70726F746F120B76656869636C6572656E7422590A1256656869636C6552656E7452657175657374122D0A047479706518012001280E32192E76656869636C6572656E742E56454849434C455F5459504552047479706512140A05636F756E741802200128055205636F756E7422420A1A56656869636C655265736572766174696F6E526573706F6E736512240A0D7265736572766174696F6E4964180120012809520D7265736572766174696F6E49642A330A0C56454849434C455F5459504512080A0442494B45100012070A03434152100112070A0356414E100212070A03425553100332690A1256656869636C6552656E745365727669636512530A0772656E74436172121F2E76656869636C6572656E742E56656869636C6552656E74526571756573741A272E76656869636C6572656E742E56656869636C655265736572766174696F6E526573706F6E7365620670726F746F33";

public isolated client class VehicleRentServiceClient {
    *grpc:AbstractClientEndpoint;

    private final grpc:Client grpcClient;

    public isolated function init(string url, *grpc:ClientConfiguration config) returns grpc:Error? {
        self.grpcClient = check new (url, config);
        check self.grpcClient.initStub(self, CAR_RENT_DESC);
    }

    isolated remote function rentCar(VehicleRentRequest|ContextVehicleRentRequest req) returns VehicleReservationResponse|grpc:Error {
        map<string|string[]> headers = {};
        VehicleRentRequest message;
        if req is ContextVehicleRentRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("vehiclerent.VehicleRentService/rentCar", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <VehicleReservationResponse>result;
    }

    isolated remote function rentCarContext(VehicleRentRequest|ContextVehicleRentRequest req) returns ContextVehicleReservationResponse|grpc:Error {
        map<string|string[]> headers = {};
        VehicleRentRequest message;
        if req is ContextVehicleRentRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("vehiclerent.VehicleRentService/rentCar", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <VehicleReservationResponse>result, headers: respHeaders};
    }
}

public type ContextVehicleRentRequest record {|
    VehicleRentRequest content;
    map<string|string[]> headers;
|};

public type ContextVehicleReservationResponse record {|
    VehicleReservationResponse content;
    map<string|string[]> headers;
|};

@protobuf:Descriptor {value: CAR_RENT_DESC}
public type VehicleRentRequest record {|
    VEHICLE_TYPE 'type = BIKE;
    int count = 0;
|};

@protobuf:Descriptor {value: CAR_RENT_DESC}
public type VehicleReservationResponse record {|
    string reservationId = "";
|};

public enum VEHICLE_TYPE {
    BIKE, CAR, VAN, BUS
}

