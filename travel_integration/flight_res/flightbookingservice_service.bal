import ballerina/grpc;
import ballerina/uuid;

listener grpc:Listener ep = new (9092);

@grpc:Descriptor {value: FLIGHT_BOOK_DESC}
service "FlightBookingService" on ep {

    remote function bookFlight(FlightReservationRequest value) returns FlightReservationResponse|error {
        //TODO: See if Flights are available
        //TODO: Persist to Flights DB
        return {
            reservationId: uuid:createType1AsString()
        };
    }
}

