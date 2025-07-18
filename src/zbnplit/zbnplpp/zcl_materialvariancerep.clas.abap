CLASS zcl_materialvariancerep DEFINITION
   PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_amdp_marker_hdb.
    CLASS-METHODS GetMaterialVarianceRep FOR TABLE FUNCTION ZTBLF_MaterialVarianceRep.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_materialvariancerep IMPLEMENTATION.


  METHOD GetMaterialVarianceRep
         BY DATABASE FUNCTION
         FOR HDB
         LANGUAGE SQLSCRIPT
         OPTIONS READ-ONLY
         USING ZR_ManufacturingOrder  zr_materialrequirement  ZR_MfgOrderDocdGoodsMovement.


    ManufacturingOrder =
                    Select
                        *
                    From ZR_ManufacturingOrder
                    Where  productionplant = :pPrdnPlant
                        and companycode = :pCompany
                        and mfgorderdate between :pFromDate and :pToDate;


    OrderConfData = SELECT
                       ordrConf.manufacturingorder,
                       ordrConf.mfgorderconfirmationgroup,
                       ordrConf.mfgorderconfirmation,
                       ordrConf.materialdocument,
                       ordrConf.materialdocumentyear,

                       ordrConf.manufacturingordercategory,
                       ordrConf.manufacturingordertype,

                       ordrConf.mfgorderconfirmationentrydate,
                       ordrConf.mfgorderconfirmationentrytime,
                       ordrConf.plant,
                       ordrConf.companycode,
                       ordrConf.controllingarea,
                       ordrConf.profitcenter,
                       ordrConf.postingdate,
                       ordrConf.confirmationunit,
                       ordrConf.confirmationyieldquantity,
                       ordrConf.confirmationscrapquantity,
                       ordrConf.confirmationreworkquantity,
                       ordrConf.confirmationtotalquantity,
                       ordrConf.productionunit,
                       ordrConf.confyieldqtyinproductionunit,
                       ordrConf.operationunit,
                       ordrConf.opplannedtotalquantity,
                       ordrConf.materialdocumentdate,
                       ordrConf.material,
                       ordrConf.goodsmovementtype,
                       ordrConf.baseunit,
                       Sum( ( case when debitcreditcode = 'H'
                       then -1 else 1 end ) *
                       quantityinbaseunit ) as quantityinbaseunit,
                       CompanyCodeCurrency,
                       Sum( ( case when debitcreditcode = 'H'
                       then -1 else 1 end ) *
                       TotalGoodsMvtAmtInCCCrcy ) as TotalGoodsMvtAmtInCCCrcy
                     from
                      ZR_MfgOrderDocdGoodsMovement as ordrConf
                      inner join :ManufacturingOrder as orders
                        on ordrConf.manufacturingorder = orders.ManufacturingOrder
                     where ordrConf.mandt = session_context('CLIENT') and
                      (ordrConf.ManufacturingOrderType = 'Z111' or ordrConf.ManufacturingOrderType = 'Z112')

                      group by ordrConf.manufacturingorder,
                       ordrConf.mfgorderconfirmationgroup,
                       ordrConf.mfgorderconfirmation,
                       ordrConf.materialdocument,
                       ordrConf.materialdocumentyear,
                       ordrConf.materialdocumentitem,
                       ordrConf.manufacturingordercategory,
                       ordrConf.manufacturingordertype,

                       ordrConf.mfgorderconfirmationentrydate,
                       ordrConf.mfgorderconfirmationentrytime,
                       ordrConf.plant,
                       ordrConf.companycode,
                       ordrConf.controllingarea,
                       ordrConf.profitcenter,
                       ordrConf.postingdate,
                       ordrConf.confirmationunit,
                       ordrConf.confirmationyieldquantity,
                       ordrConf.confirmationscrapquantity,
                       ordrConf.confirmationreworkquantity,
                       ordrConf.confirmationtotalquantity,
                       ordrConf.productionunit,
                       ordrConf.confyieldqtyinproductionunit,
                       ordrConf.operationunit,
                       ordrConf.opplannedtotalquantity,
                       ordrConf.materialdocumentdate,
                       ordrConf.material,
                       ordrConf.goodsmovementtype,
                       ordrConf.baseunit,
                       CompanyCodeCurrency;


    OrderConfMst = select
                       manufacturingorder,
                       mfgorderconfirmationgroup,
                       mfgorderconfirmation,
                       materialdocument,
                       materialdocumentyear,
                       manufacturingordercategory,
                       manufacturingordertype,

                       mfgorderconfirmationentrydate,
                       mfgorderconfirmationentrytime,
                       plant,
                       companycode,
                       controllingarea,
                       profitcenter,
                       postingdate,
                       confirmationunit,
                       confirmationyieldquantity,
                       confirmationscrapquantity,
                       confirmationreworkquantity,
                       confirmationtotalquantity,
                       productionunit,
                       confyieldqtyinproductionunit,
                       operationunit,
                       opplannedtotalquantity,
                       materialdocumentdate
                     from
                      :OrderConfData

                     group by manufacturingorder,
                       mfgorderconfirmationgroup,
                       mfgorderconfirmation,
                       materialdocument,
                       materialdocumentyear,

                       manufacturingordercategory,
                       manufacturingordertype,

                       mfgorderconfirmationentrydate,
                       mfgorderconfirmationentrytime,
                       plant,
                       companycode,
                       controllingarea,
                       profitcenter,
                       postingdate,
                       confirmationunit,
                       confirmationyieldquantity,
                       confirmationscrapquantity,
                       confirmationreworkquantity,
                       confirmationtotalquantity,
                       productionunit,
                       confyieldqtyinproductionunit,
                       operationunit,
                       opplannedtotalquantity,
                       materialdocumentdate;

    IssueSlipWiseItemRate = Select
                               manufacturingorder,
                               materialdocument,
                               materialdocumentyear,
                               material,
                               baseunit,
                               CompanyCodeCurrency as currency,
                               sum (quantityinbaseunit) as quantityinbaseunit,
                               sum( TotalGoodsMvtAmtInCCCrcy ) as TotalGoodsMvtAmtInCCCrcy
                            From :OrderConfData
                            Group By manufacturingorder,
                               materialdocument,
                               materialdocumentyear,
                               material,
                               baseunit,
                               CompanyCodeCurrency;

        OrderWiseItemRate = Select
                               manufacturingorder,
                               material,
                               currency,
                               baseunit,
                               sum (quantityinbaseunit) as quantityinbaseunit,
                               sum( TotalGoodsMvtAmtInCCCrcy ) as TotalGoodsMvtAmtInCCCrcy
                            From :IssueSlipWiseItemRate
                            Group By manufacturingorder,
                               material,
                               baseunit,
                               currency;

    BomReqAsPerOrdr = select
                       ordrconf.manufacturingorder,
                       ordrconf.mfgorderconfirmationgroup,
                       ordrconf.mfgorderconfirmation,
                       ordrconf.materialdocument,
                       ordrconf.materialdocumentyear,
                       ordrconf.manufacturingordercategory,
                       ordrconf.manufacturingordertype,

                       ordrconf.mfgorderconfirmationentrydate,
                       ordrconf.mfgorderconfirmationentrytime,
                       ordrconf.plant,
                       ordrconf.companycode,
                       ordrconf.controllingarea,
                       ordrconf.profitcenter,
                       ordrconf.postingdate,
                       ordrconf.confirmationunit,
                       ordrconf.confirmationyieldquantity,
                       ordrconf.confirmationscrapquantity,
                       ordrconf.confirmationreworkquantity,
                       ordrconf.confirmationtotalquantity,
                       ordrconf.productionunit,
                       ordrconf.confyieldqtyinproductionunit,
                       ordrconf.operationunit,
                       ordrconf.opplannedtotalquantity,
                       ordrconf.materialdocumentdate,
                       Req.material,
                       Req.GoodsMovementType,
                       cast(Round(
                       Sum( ( case when debitcreditcode = 'H'
                               then -1 else 1 end ) * ( case when mfgorder.MfgOrderPlannedTotalQty <> 0 then
                               ( ordrconf.confirmationyieldquantity * Req.requiredquantity) / mfgorder.MfgOrderPlannedTotalQty  end ))
                               ,3) as decimal (13,3) ) as StdReqQty,
                       Req.baseunit
                     from :OrderConfMst as ordrconf
                     inner join :ManufacturingOrder as mfgOrder on Ordrconf.manufacturingorder= mfgorder.manufacturingorder
                      Inner Join zr_materialrequirement as Req
                            on Req.productionorder = ordrconf.manufacturingorder


                     Group By ordrconf.manufacturingorder,
                       ordrconf.mfgorderconfirmationgroup,
                       ordrconf.mfgorderconfirmation,
                       ordrconf.materialdocument,
                       ordrconf.materialdocumentyear,
                       ordrconf.manufacturingordercategory,
                       ordrconf.manufacturingordertype,

                       ordrconf.mfgorderconfirmationentrydate,
                       ordrconf.mfgorderconfirmationentrytime,
                       ordrconf.plant,
                       ordrconf.companycode,
                       ordrconf.controllingarea,
                       ordrconf.profitcenter,
                       ordrconf.postingdate,
                       ordrconf.confirmationunit,
                       ordrconf.confirmationyieldquantity,
                       ordrconf.confirmationscrapquantity,
                       ordrconf.confirmationreworkquantity,
                       ordrconf.confirmationtotalquantity,
                       ordrconf.productionunit,
                       ordrconf.confyieldqtyinproductionunit,
                       ordrconf.operationunit,
                       ordrconf.opplannedtotalquantity,
                       ordrconf.materialdocumentdate,
                       Req.material,
                       Req.GoodsMovementType,
                       Req.baseunit;

    BOMFGOnly = select
                       ordrconf.manufacturingorder,
                       ordrconf.mfgorderconfirmationgroup,
                       ordrconf.mfgorderconfirmation,
                       ordrconf.materialdocument,
                       ordrconf.materialdocumentyear,
                       ordrconf.manufacturingordercategory,
                       ordrconf.manufacturingordertype,

                       ordrconf.mfgorderconfirmationentrydate,
                       ordrconf.mfgorderconfirmationentrytime,
                       ordrconf.plant,
                       ordrconf.companycode,
                       ordrconf.controllingarea,
                       ordrconf.profitcenter,
                       ordrconf.postingdate,
                       ordrconf.confirmationunit,
                       ordrconf.confirmationyieldquantity,
                       ordrconf.confirmationscrapquantity,
                       ordrconf.confirmationreworkquantity,
                       ordrconf.confirmationtotalquantity,
                       ordrconf.productionunit,
                       ordrconf.confyieldqtyinproductionunit,
                       ordrconf.operationunit,
                       ordrconf.opplannedtotalquantity,
                       ordrconf.materialdocumentdate,
                       mfgOrdr.MfgProduct as material,
                       '101' as GoodsMovementType,
                       ordrconf.confirmationyieldquantity as ComponentQty,
                       mfgOrdr.productionunit as UnitOfMeasurement
                     from :OrderConfMst as ordrconf
                      Inner Join :ManufacturingOrder as mfgOrdr
                            on mfgOrdr.manufacturingorder = ordrconf.manufacturingorder;

    Result =
              select   mfgordr.ManufacturingOrder,
                      mfgordr.CompanyCode,
                      mfgordr.ProductionPlant,
                      mfgordr.MfgOrderDate,
                      mfgordr.ManufacturingOrderType,
                      mfgordr.MfgProduct,
                      mfgordr.MfgProductName,
                      mfgordr.bom,
                      mfgordr.BusinessArea,
                      mfgordr.ControllingArea,
                      mfgordr.WorkCenterInternalID,
                      mfgordr.WorkCenterText,
                      mfgordr.ProfitCenter,
                      mfgordr.CostingSheet,
                      mfgordr.ProductionUnit,
                      mfgordr.MfgOrderPlannedTotalQty,
                      mfgordr.MfgOrderConfirmedYieldQty,
                      mfgordr.ActualDeliveredQuantity,

                       Req.mfgorderconfirmationgroup,
                       Req.mfgorderconfirmation,
                       Req.materialdocument,
                       Req.materialdocumentyear,
                       Req.manufacturingordercategory,

                       Req.mfgorderconfirmationentrydate,
                       Req.mfgorderconfirmationentrytime,

                       Req.postingdate,
                       Req.confirmationunit,
                       Req.confirmationyieldquantity,
                       Req.confirmationscrapquantity,
                       Req.confirmationreworkquantity,
                       Req.confirmationtotalquantity,

                       Req.confyieldqtyinproductionunit,
                       Req.operationunit,
                       Req.opplannedtotalquantity,
                       Req.materialdocumentdate,
                       Req.material,
                       Req.GoodsMovementType,
                       Req.StdReqQty as ComponentQty,
                       Req.baseunit as UnitOfMeasurement,
                       IssueRate.currency,
                       cast(Round(
                       ( case when IssueRate.quantityinbaseunit <> 0 then
                       (( IssueRate.TotalGoodsMvtAmtInCCCrcy * Req.StdReqQty) / IssueRate.quantityinbaseunit ) END)
                               ,2) as decimal (13,2) ) as ComponentAmt,
                       Cast( 'Required' as varchar( 20 )) as EntryType
              from :BomReqAsPerOrdr as Req
              Inner Join :ManufacturingOrder as mfgordr
                            ON  Req.manufacturingorder = mfgordr.manufacturingorder
                       Left Outer join :IssueSlipWiseItemRate IssueRate
                            on  Req.manufacturingorder = IssueRate.ManufacturingOrder
                                And Req.materialdocument = IssueRate.materialdocument
                                And Req.materialdocumentyear = IssueRate.materialdocumentyear
                                And Req.material = IssueRate.material

              Union All
              select   mfgordr.ManufacturingOrder,
                      mfgordr.CompanyCode,
                      mfgordr.ProductionPlant,
                      mfgordr.MfgOrderDate,
                      mfgordr.ManufacturingOrderType,
                      mfgordr.MfgProduct,
                      mfgordr.MfgProductName,
                      mfgordr.bom,
                      mfgordr.BusinessArea,
                      mfgordr.ControllingArea,
                      mfgordr.WorkCenterInternalID,
                      mfgordr.WorkCenterText,
                      mfgordr.ProfitCenter,
                      mfgordr.CostingSheet,
                      mfgordr.ProductionUnit,
                      mfgordr.MfgOrderPlannedTotalQty,
                      mfgordr.MfgOrderConfirmedYieldQty,
                      mfgordr.ActualDeliveredQuantity,

                       Req.mfgorderconfirmationgroup,
                       Req.mfgorderconfirmation,
                       Req.materialdocument,
                       Req.materialdocumentyear,
                       Req.manufacturingordercategory,


                       Req.mfgorderconfirmationentrydate,
                       Req.mfgorderconfirmationentrytime,

                       Req.postingdate,
                       Req.confirmationunit,
                       Req.confirmationyieldquantity,
                       Req.confirmationscrapquantity,
                       Req.confirmationreworkquantity,
                       Req.confirmationtotalquantity,

                       Req.confyieldqtyinproductionunit,
                       Req.operationunit,
                       Req.opplannedtotalquantity,
                       Req.materialdocumentdate,
                       Req.material,
                       Req.GoodsMovementType,
                       Req.ComponentQty,
                       Req.UnitOfMeasurement,
                       IssueRate.currency,
                       cast(Round(
                        ( case when IssueRate.quantityinbaseunit <> 0 then
                       (( IssueRate.TotalGoodsMvtAmtInCCCrcy * Req.ComponentQty) / IssueRate.quantityinbaseunit ) END)
                               ,2) as decimal (13,2) ) as ComponentAmt,
                       Cast( 'Required' as varchar( 20 )) as EntryType
              from :BOMFGOnly as Req
              Inner Join :ManufacturingOrder as mfgordr
                            ON  Req.manufacturingorder = mfgordr.manufacturingorder
                            Left Outer join :IssueSlipWiseItemRate IssueRate
                            on  Req.manufacturingorder = IssueRate.ManufacturingOrder
                                And Req.materialdocument = IssueRate.materialdocument
                                And Req.materialdocumentyear = IssueRate.materialdocumentyear
                                And Req.material = IssueRate.material
              Union All

              select
                  mfgordr.ManufacturingOrder,
                  mfgordr.CompanyCode,
                  mfgordr.ProductionPlant,
                  mfgordr.MfgOrderDate,
                  mfgordr.ManufacturingOrderType,
                  mfgordr.MfgProduct,
                  mfgordr.MfgProductName,
                  mfgordr.bom,
                  mfgordr.BusinessArea,
                  mfgordr.ControllingArea,
                      mfgordr.WorkCenterInternalID,
                      mfgordr.WorkCenterText,
                  mfgordr.ProfitCenter,
                  mfgordr.CostingSheet,
                  mfgordr.ProductionUnit,
                  mfgordr.MfgOrderPlannedTotalQty,
                  mfgordr.MfgOrderConfirmedYieldQty,
                  mfgordr.ActualDeliveredQuantity,
                   OrdrConf.mfgorderconfirmationgroup,
                   OrdrConf.mfgorderconfirmation,
                   OrdrConf.materialdocument,
                   OrdrConf.materialdocumentyear,
                   OrdrConf.manufacturingordercategory,


                   OrdrConf.mfgorderconfirmationentrydate,
                   OrdrConf.mfgorderconfirmationentrytime,

                   OrdrConf.postingdate,
                   OrdrConf.confirmationunit,
                   OrdrConf.confirmationyieldquantity,
                   OrdrConf.confirmationscrapquantity,
                   OrdrConf.confirmationreworkquantity,
                   OrdrConf.confirmationtotalquantity,

                   OrdrConf.confyieldqtyinproductionunit,
                   OrdrConf.operationunit,
                   OrdrConf.opplannedtotalquantity,
                   OrdrConf.materialdocumentdate,
                   OrdrConf.material,
                   OrdrConf.GoodsMovementType,
                   OrdrConf.quantityinbaseunit as ComponentQty,
                   OrdrConf.baseunit as UnitOfMeasurement,
                   OrdrConf.CompanyCodeCurrency,
                   OrdrConf.TotalGoodsMvtAmtInCCCrcy,
                   Cast( 'Actual' as varchar( 20 )) as EntryType
              from :OrderConfData as OrdrConf
              Inner Join :ManufacturingOrder as mfgordr
                            ON  OrdrConf.manufacturingorder = mfgordr.manufacturingorder;


      return
          Select  100 as client,
                ManufacturingOrder,
                CompanyCode,
                ProductionPlant,
                MfgOrderDate,
                ManufacturingOrderType,
                MfgProduct,
                MfgProductName,
                bom,
                BusinessArea,
                ControllingArea,
                WorkCenterInternalID,
                WorkCenterText,

                ProfitCenter,
                CostingSheet,
                ProductionUnit,
                MfgOrderPlannedTotalQty,
                MfgOrderConfirmedYieldQty,
                ActualDeliveredQuantity,
                mfgorderconfirmationgroup,
                mfgorderconfirmation,
                materialdocument,
                materialdocumentyear,
                manufacturingordercategory,
                postingdate,
                confirmationunit,
                confirmationyieldquantity,
                confirmationscrapquantity,
                confirmationreworkquantity,
                confirmationtotalquantity,
                confyieldqtyinproductionunit,
                materialdocumentdate,
                Material,
                GoodsMovementType,
                UnitOfMeasurement,
                Sum(case when EntryType = 'Required'
                then ComponentQty else Cast(0.000 as decimal( 13,3 ))
                end) as RequiredQty,
                Sum(case when EntryType = 'Actual'
                then ComponentQty else Cast(0.000 as decimal( 13,3 ))
                end) as ActualQty,
                 Sum(case when EntryType = 'Actual'
                then -ComponentQty else ComponentQty
                end) as DiffQty,
                         Currency,
                Sum(case when EntryType = 'Required'
                then ComponentAmt else Cast(0.00 as decimal( 13,2 ))
                end) as RequiredAmt,
                Sum(case when EntryType = 'Actual'
                then ComponentAmt else Cast(0.00 as decimal( 13,2 ))
                end) as ActualAmt,
                 Sum(case when EntryType = 'Actual'
                then -ComponentAmt else ComponentAmt
                end) as DiffAmt
           From :Result as a
           group by ManufacturingOrder,
                CompanyCode,
                ProductionPlant,
                MfgOrderDate,
                ManufacturingOrderType,
                MfgProduct,
                MfgProductName,
                bom,
                BusinessArea,
                ControllingArea,
                WorkCenterInternalID,
                WorkCenterText,
                ProfitCenter,
                CostingSheet,
                ProductionUnit,
                MfgOrderPlannedTotalQty,
                MfgOrderConfirmedYieldQty,
                ActualDeliveredQuantity,
                mfgorderconfirmationgroup,
                mfgorderconfirmation,
                materialdocument,
                materialdocumentyear,
                manufacturingordercategory,
                postingdate,
                confirmationunit,
                confirmationyieldquantity,
                confirmationscrapquantity,
                confirmationreworkquantity,
                confirmationtotalquantity,
                confyieldqtyinproductionunit,
                materialdocumentdate,
                Material,
                GoodsMovementType,
                UnitOfMeasurement,
                Currency
            Having

                ABS( Sum(case when EntryType = 'Required'
                then ComponentQty else Cast(0.000 as decimal( 13,3 ))
                end)) +

                ABS(Sum(case when EntryType = 'Actual'
                then ComponentQty else Cast(0.000 as decimal( 13,3 ))
                end)) +

                Abs(
                Sum(case when EntryType = 'Required'
                then ComponentAmt else Cast(0.00 as decimal( 13,2 ))
                end)) +

                Abs( Sum(case when EntryType = 'Actual'
                then ComponentAmt else Cast(0.00 as decimal( 13,2 ))
                end) ) <> 0
           ;

  endmethod.
ENDCLASS.
