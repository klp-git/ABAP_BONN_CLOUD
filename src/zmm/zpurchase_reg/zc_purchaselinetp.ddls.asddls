@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Purchase Line Projection View'
@ObjectModel.semanticKey: [ 'Supplierinvoiceitem' ]
@Search.searchable: true
define view entity ZC_purchaselineTP
  as projection on ZR_purchaselineTP as purchaseline
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
  key Companycode ,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
  key Fiscalyearvalue,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
  key Supplierinvoice,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
  key Supplierinvoiceitem,
      Postingdate,
      Plantname,
      Plantgst,
      Plant,
      Product,
      Productname,
      Purchaseorder,
      Purchaseorderitem,
      Baseunit,
      Profitcenter,
      Purchaseordertype,
      Purchaseorderdate,
      Purchasingorganization,
      Purchasinggroup,
      Mrnquantityinbaseunit,
      Mrnpostingdate,
      Hsncode,
      Taxcodename,
      Originalreferencedocument,
      Igst,
      Sgst,
      Cgst,
      NDCGST,
      NDSGST,
      NDIGST,
      Rateigst,
      Ratecgst,
      Ratesgst,
      Isreversed,
      Basicrate,
      Poqty,
      Pouom,
      Netamount,
      Taxamount,
      Roundoff,
      Discount,
      Totalamount,      
      Othercharges,
      Insurance1,

//      Ocean_freight,
//      For_land,
//      Custom_duty,
//      Social_welfare,
//      Comm_charges,
//      Inland,
//      Cha_charges,
//      Demmurage_charges,
//      Local_freight,
//      Pack_charges,
//      Load_charges,
//      Unload_charges,
      Supp_gst,
      Referencedocumentno,
      Transactiontype,
      Grnno,
      SupplierCodeName,
      DeliveryCost,
      RCMIgst,
      RCMCgst,
      RCMSgst,  
      InvoicingPartyCodeName,
      OceanFreightCharges,
      ForLandCharges,
      CustomDutyCharges,
      SocialWelfareCharges,
      CommissionCharges,
      InlandCharges,
      CarrierHandCharges,
      DemmurageCharges,
      LocalFreightCharges,
      PackagingCharges,
//      OtherChargesImp,
      LoadingCharges,
      UnloadingCharges,
      SupplierBillNo,
      SupplierCode,
      PlantCode,
      
      _purchaseinv : redirected to parent ZC_purchaseinvTP

}
