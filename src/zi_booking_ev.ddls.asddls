@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Interface Entity'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_BOOKING_EV
  as select from zbooking_ev
  
{
  key bookinguuid           as Bookinguuid,
      parent_uuid           as ParentUuid,
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
      local_last_changed_at as LocalLastChangedAt
}
