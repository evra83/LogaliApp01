@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Suplement Interface Entity'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_BSUPPL_EV
  as select from zbsuppl_ev
{

  key bookingsuppl_uuid     as BookingsupplUuid,
      root_uuid             as TravelUuid,
      parent_uuid           as BookingUuid,
      booking_supplemet_id  as BookingSupplemetId,
      supplemet_id          as SupplemetId,
      currency_code         as CurrencyCode,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      @Semantics.systemDateTime.lastChangedAt: true
      local_last_changed_at as LocalLastChangedAt
}
