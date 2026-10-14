@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Consume'
@Metadata.allowExtensions: true
define root view entity ZC_TRAVEL_EV
    provider contract transactional_query 
    as projection on ZI_TRAVEL_EV
{
    key Traveluuid,
    TravelId,
    @ObjectModel.text.element: ['AgencyName']
    @Consumption.valueHelpDefinition: [{ 
        entity: {
            name: '/DMO/I_Agency', 
            element: 'AgencyID'
        }    
    }]
    AgencyId,
    _agency.Name as AgencyName,
    @ObjectModel.text.element: ['CustomerName']
    @Consumption.valueHelpDefinition: [{ 
		entity: {
			name: '/DMO/I_Customer', 
			element: 'CustomerID'
		}    
	}]
    CustomerId,
    CustomerName,
    BeginDate,
    EndDate,
    @Consumption.valueHelpDefinition: [{
    entity: {
            name: 'I_Currency', 
            element: 'Currency'
        }    
    }]
    CurrencyCode,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    BookingFee,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    TotalPrice,
    Description,
    @ObjectModel.text.element: ['OverallStatusText']
    @Consumption.valueHelpDefinition: [{ 
		entity: {
			name: '/DMO/I_Overall_Status_VH', 
			element: 'OverallStatus'
		}    
	}]
    OverallStatus,
    _overallstatus._Text.Text as OverallStatusText : localized,
    OverallStatusCriticality,
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
