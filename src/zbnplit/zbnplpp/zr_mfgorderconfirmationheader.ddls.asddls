@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manufacturing Order Confirmation Header'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_MfgOrderConfirmationHeader
  as select from ZR_MfgOrderConfirmation
{
  key ManufacturingOrder,
  key MfgOrderConfirmationGroup,
  key MfgOrderConfirmation,
  key MaterialDocument,
  key MaterialDocumentYear,

      ManufacturingOrderCategory,
      ManufacturingOrderType,
      OrderInternalID,
      MfgOrderConfirmationEntryDate,
      MfgOrderConfirmationEntryTime,
      Plant,
      CompanyCode,
      ControllingArea,
      ProfitCenter,
      WorkCenterText,
      ShiftDefinition,
      PostingDate
}
group by
  ManufacturingOrder,
  MfgOrderConfirmationGroup,
  MfgOrderConfirmation,
  MaterialDocument,
  MaterialDocumentYear,

  ManufacturingOrderCategory,
  ManufacturingOrderType,
  OrderInternalID,
  MfgOrderConfirmationEntryDate,
  MfgOrderConfirmationEntryTime,
  Plant,
  CompanyCode,
  ControllingArea,
  ProfitCenter,
  WorkCenterText,
  ShiftDefinition,
  PostingDate
