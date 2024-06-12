import ballerina/grpc;
import ballerina/uuid;

listener grpc:Listener ep = new (9093);

@grpc:Descriptor {value: HOTEL_BOOK_DESC}
service "HotelBookingService" on ep {

    remote function bookHotel(HotelBookingRequest value) returns HotelReservationResponse|error {
        //TODO: See if hotel is available
        //TODO: Persist to Hotel DB
        return {
            reservationId: uuid:createType1AsString()
        };
    }
}

