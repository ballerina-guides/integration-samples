import ballerina/grpc;
import ballerina/uuid;

listener grpc:Listener ep = new (9091);

@grpc:Descriptor {value: CAR_RENT_DESC}
service "VehicleRentService" on ep {

    remote function rentCar(VehicleRentRequest value) returns VehicleReservationResponse|error {
        //TODO: See if Vehicles are available
        //TODO: Persist to Vehicles DB
        return {
            reservationId: uuid:createType1AsString()
        };
    }
}

