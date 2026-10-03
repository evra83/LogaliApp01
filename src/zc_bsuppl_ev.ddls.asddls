@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Suplement Consume'
@Metadata.allowExtensions: true
define view entity ZC_BSUPPL_EV as projection on ZI_BSUPPL_EV
{
    key BookingsupplUuid,
    TravelUuid,
    BookingUuid,
    BookingSupplemetId,
    SupplementId,
    CurrencyCode,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    Price,
    LocalLastChangedAt,
    /* Associations */
    _booking:redirected to parent ZC_BOOKING_EV,
    _product,
    _producttext,
    _travel
}
