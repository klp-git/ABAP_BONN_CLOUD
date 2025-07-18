@EndUserText.label: 'TABLE FOR TAX CODE'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_TableForTaxCode
  as select from ZWHT_TAXCODE
  association to parent ZI_TableForTaxCode_S as _TableForTaxCodeAll on $projection.SingletonID = _TableForTaxCodeAll.SingletonID
{
  key COUNTRY as Country,
  key OFFICIALWHLDGTAXCODE as Officialwhldgtaxcode,
  key WITHHOLDINGTAXCODE as Withholdingtaxcode,
  WITHHOLDINGTAXTYPE as Withholdingtaxtype,
  WHLDGTAXRELEVANTPERCENT as Whldgtaxrelevantpercent,
  WITHHOLDINGTAXPERCENT as Withholdingtaxpercent,
  GLACCOUNT as Glaccount,
  @Semantics.user.createdBy: true
  CREATED_BY as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  CREATED_AT as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  @Consumption.hidden: true
  LOCAL_LAST_CHANGED_BY as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  @Consumption.hidden: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  LAST_CHANGED_AT as LastChangedAt,
  @Consumption.hidden: true
  1 as SingletonID,
  _TableForTaxCodeAll
  
}
