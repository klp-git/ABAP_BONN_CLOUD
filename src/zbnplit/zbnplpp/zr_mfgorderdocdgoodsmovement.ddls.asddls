@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material Issue (Goods Movement)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_MfgOrderDocdGoodsMovement
  as select from    I_MfgOrderDocdGoodsMovement as A

    inner join      I_ManufacturingOrder        as Ordr       on A.ManufacturingOrder = Ordr.ManufacturingOrder

    inner join      ZR_USER_CMPY_ACCESS         as _cmpAccess on  _cmpAccess.CompCode = Ordr.CompanyCode
                                                              and _cmpAccess.userid   = $session.user

    left outer join I_MfgOrderConfirmation      as B          on  A.GoodsMovement     = B.MaterialDocument
                                                              and A.GoodsMovementYear = B.MaterialDocumentYear
{
  key A.GoodsMovement     as MaterialDocument,
  key A.GoodsMovementYear as MaterialDocumentYear,
  key A.GoodsMovementItem as MaterialDocumentItem,
      A.ManufacturingOrder,

      Ordr.CompanyCode,
      Ordr.ProfitCenter,

      B.MfgOrderConfirmationGroup,
      B.MfgOrderConfirmation,
      B.MfgOrderConfirmationEntryDate,
      B.MfgOrderConfirmationEntryTime,
      B.ConfirmationUnit,

      @Semantics.quantity.unitOfMeasure: 'ConfirmationUnit'
      B.ConfirmationYieldQuantity,
      @Semantics.quantity.unitOfMeasure: 'ConfirmationUnit'
      B.ConfirmationScrapQuantity,
      @Semantics.quantity.unitOfMeasure: 'ConfirmationUnit'
      B.ConfirmationReworkQuantity,
      @Semantics.quantity.unitOfMeasure: 'ConfirmationUnit'
      B.ConfirmationTotalQuantity,

      B.ProductionUnit,
      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      B.ConfYieldQtyInProductionUnit,
      B.OperationUnit,
      @Semantics.quantity.unitOfMeasure: 'OperationUnit'
      B.OpPlannedTotalQuantity,

      A.ManufacturingOrderCategory,
      A.ManufacturingOrderType,
      A.ProductionPlant   as Plant,
      A.Material,
      A.GoodsMovementPlant,

      A.Reservation,
      A.ReservationItem,
      A.ReservationRecordType,
      A.ReservationIsFinallyIssued,

      A.StorageLocation,
      A.Batch,
      A.InventoryValuationType,
      A.DebitCreditCode,
      A.GoodsMovementType,
      A.GoodsMovementRefDocType,
      A.InventorySpecialStockType,

      A.WBSElementInternalID,

      A.ControllingArea,
      A.GLAccount,
      A.PostingDate,
      A.DocumentDate      as MaterialDocumentDate,
      A.BaseUnit,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      A.QuantityInBaseUnit,
      A.EntryUnit,
      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      A.QuantityInEntryUnit,
      A.CompanyCodeCurrency,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      A.TotalGoodsMvtAmtInCCCrcy

}
where
  (
          A.ManufacturingOrderType = 'Z111'
    or    A.ManufacturingOrderType = 'Z112'
  ) //only Production and Packing Entries
  and(
    (
          B.IsReversed             is initial // Exclude Reversed Entries
      and B.IsReversal             is initial
    )
    or(
          B.IsReversed             is null // Adjusted Entries
      and B.IsReversal             is null
    )
  )
