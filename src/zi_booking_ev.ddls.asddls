@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Interface Entity'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_BOOKING_EV
  as select from zbooking_ev
  association to parent ZI_TRAVEL_EV as _travel on  $projection.travelUuid = _travel.Traveluuid
  composition [0..*] of ZI_BSUPPL_EV as _bookingsuppl
  association [0..1] to /DMO/I_Customer   as _customer   on  $projection.CustomerId = _customer.CustomerID
  association [0..1] to I_Currency        as _currency   on  $projection.CurrencyCode = _currency.Currency
  association [0..1] to /DMO/I_Carrier    as _carrier    on  $projection.AirlaneId = _carrier.AirlineID
  association [0..1] to /DMO/I_Connection as _connection on  $projection.ConnectionId = _connection.ConnectionID
                                                         and $projection.AirlaneId    = _connection.AirlineID
{
  key booking_uuid          as Bookinguuid,
      parent_uuid           as travelUuid,
      booking_id            as BookingId,
      booking_date          as BookingDate,
      customer_id           as CustomerId,
      carrier_id            as AirlaneId,
      connection_id         as ConnectionId,
      flight_date           as FlightDate,
      currency_code         as CurrencyCode,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price          as FlightPrice,
      booking_status        as BookingStatus,
      @Semantics.systemDateTime.lastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      //Associations
      _bookingsuppl,
      _customer,
      _currency,
      _carrier,
      _connection,
      _travel
}
