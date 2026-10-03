@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Consume'
@Metadata.allowExtensions: true
define view entity ZC_BOOKING_EV 
as projection on ZI_BOOKING_EV
{
    key Bookinguuid,
    travelUuid,
    BookingId,
    BookingDate,
    CustomerId,
    AirlaneId,
    ConnectionId,
    FlightDate,
    CurrencyCode,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    FlightPrice,
    BookingStatus,
    LocalLastChangedAt,
    /* Associations */
    _bookingsuppl: redirected to composition child ZC_BSUPPL_EV,
    _carrier,
    _connection,
    _currency,
    _customer,
    _travel: redirected to parent ZC_TRAVEL_EV
}
