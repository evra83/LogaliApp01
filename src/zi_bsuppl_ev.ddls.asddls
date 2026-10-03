@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Suplement Interface Entity'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_BSUPPL_EV
  as select from zbsuppl_ev
  association        to parent ZI_BOOKING_EV  as _booking     on $projection.BookingUuid = _booking.Bookinguuid
  association [1..1] to ZI_TRAVEL_EV          as _travel      on $projection.TravelUuid = _travel.Traveluuid
  association [1..1] to /DMO/I_Supplement     as _product     on $projection.SupplementId = _product.SupplementID
  association [1..*] to /DMO/I_SupplementText as _producttext on $projection.SupplementId = _producttext.SupplementID
{

  key bookingsuppl_uuid     as BookingsupplUuid,
      root_uuid             as TravelUuid,
      parent_uuid           as BookingUuid,
      booking_supplemet_id  as BookingSupplemetId,
      supplemet_id          as SupplementId,
      currency_code         as CurrencyCode,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      @Semantics.systemDateTime.lastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      //Associations
      _booking,
      _travel,
      _product,
      _producttext
}
