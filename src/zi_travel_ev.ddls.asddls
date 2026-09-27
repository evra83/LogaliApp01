@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Interface Entity'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_TRAVEL_EV
  as select from ztravel_ev
  association [1..1] to /DMO/I_Customer as _customer on $projection.CustomerId = _customer.CustomerID
  association [1..1] to /DMO/I_Agency   as _agency   on $projection.AgencyId   = _agency.AgencyID
  //composition of target_data_source_name as _association_name
{
  key travel_uuid           as Traveluuid,
      travel_id             as TravelId,
      agency_id             as AgencyId,
      customer_id           as CustomerId,
      begin_date            as BeginDate,
      end_date              as EndDate,
      currency_code         as CurrencyCode,
      @Semantics.amount.currencyCode : 'CurrencyCode'
      booking_fee           as BookingFee,
      @Semantics.amount.currencyCode : 'CurrencyCode'
      total_price           as TotalPrice,
      description           as Description,
      overall_status        as OverallStatus,
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      //Associations
      _customer,
      _agency
}
