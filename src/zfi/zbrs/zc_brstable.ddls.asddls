@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_BRSTABLE
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_BRSTABLE
{
  key AccId,
  key MainGl,
  key OutGl,
  key InGl,
  CompCode,
  HouseBank,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt
  
}
