@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Consume'
@Metadata.allowExtensions: true
define root view entity ZC_TRAVEL_EV
    provider contract transactional_query 
    as projection on ZI_TRAVEL_EV
{
    key Traveluuid,
    TravelId,
    AgencyId,
    CustomerId,
    BeginDate,
    EndDate,
    CurrencyCode,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    BookingFee,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    TotalPrice,
    Description,
    OverallStatus,
    @Semantics.user.createdBy: true
    LocalCreatedBy,
    @Semantics.systemDateTime.createdAt: true
    LocalCreatedAt,
    @Semantics.user.lastChangedBy: true
    LocalLastChangedBy,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    LocalLastChangedAt,
    @Semantics.systemDateTime.lastChangedAt: true
    LastChangedAt,
    /* Associations */
    _agency,
    _booking: redirected to composition child ZC_BOOKING_EV,
    _currency,
    _customer,
    _overallstatus
}
