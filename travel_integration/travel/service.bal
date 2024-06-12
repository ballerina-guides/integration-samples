import ballerina/http;

final VehicleRentServiceClient carEp = check new ("http://localhost:9091");
final FlightBookingServiceClient flightEp = check new ("http://localhost:9092");
final HotelBookingServiceClient hotelEp = check new ("http://localhost:9093");

type VehicleReservation record {
    VEHICLE_TYPE 'type;
    int count;
};

type Booking record {
    string username;
    Passenger[] passengers;
    VehicleReservation vehicle;
    HotelBookingRequest hotelBooking;
};

type BookingResponse record {
    string username;
    string vehicleResId;
    string flightResId;
    string hotelResId;
};

service / on new http:Listener(9090) {
    resource function post booking(@http:Payload Booking booking) returns BookingResponse|error {

        VehicleRentRequest rentCarRequest = {'type: booking.vehicle.'type, count: booking.vehicle.count};
        VehicleReservationResponse rentCarResponse = check carEp->rentCar(rentCarRequest);

        FlightReservationRequest bookFlightRequest = {passengers: booking.passengers};
        FlightReservationResponse bookFlightResponse = check flightEp->bookFlight(bookFlightRequest);
        
        HotelReservationResponse bookHotelResponse = check hotelEp->bookHotel(booking.hotelBooking);

        return {
            flightResId: bookFlightResponse.reservationId,
            hotelResId: bookHotelResponse.reservationId,
            vehicleResId: rentCarResponse.reservationId,
            username: booking.username
        };
    }
}
