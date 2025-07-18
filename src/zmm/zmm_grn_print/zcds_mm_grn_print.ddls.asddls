@EndUserText.label: 'i_operationalacctgdocitem CDS'
@Search.searchable: false
//@ObjectModel.query.implementedBy: 'ABAP:ZCL_CN_DN_SCREEN_CLASS'
@UI.headerInfo: {typeName: 'cn_dn PRINT'}



@UI.presentationVariant: [
  {
    sortOrder: [
      { by: 'postingdate', direction: #DESC }
    ]
  }
]
define view entity ZCDS_MM_GRN_PRINT as select from I_MaterialDocumentItem_2 as a
left outer join I_MaterialDocumentHeader_2 as b on a.MaterialDocument = b.MaterialDocument and a.MaterialDocumentYear = b.MaterialDocumentYear
left outer join zgateentryheader as c on b.MaterialDocumentHeaderText = c.gateentryno
left outer join I_PurchaseOrderAPI01 as d on a.PurchaseOrder = d.PurchaseOrder
left outer join I_Supplier as e on d.Supplier = e.Supplier
{
  @Search.defaultSearchElement: true
    @UI.selectionField : [{ position:1 }]
    @UI.lineItem : [{ position:1, label:'AccountingDocument' }]
    // @EndUserText.label: 'Accounting document'
    key a.MaterialDocument,
    
    @Search.defaultSearchElement: true
    @UI.selectionField : [{ position:10 }]
    @UI.lineItem : [{ position:10, label:'AccountingDocument' }]
    // @EndUserText.label: 'Accounting document'
    key a.CompanyCode,
    
    @Search.defaultSearchElement: true
    @UI.selectionField : [{ position:20 }]
    @UI.lineItem : [{ position:20, label:'AccountingDocument' }]
    // @EndUserText.label: 'Accounting document'
    key a.MaterialDocumentYear,
    
     @Search.defaultSearchElement: true
    @UI.selectionField : [{ position:30 }]
    @UI.lineItem : [{ position:30, label:'AccountingDocument' }]
    // @EndUserText.label: 'Accounting document'
    key a.GoodsMovementType,
    
    @Search.defaultSearchElement: true
    @UI.selectionField : [{ position:30 }]
    @UI.lineItem : [{ position:30, label:'IsCancelled' }]
    // @EndUserText.label: 'Accounting document'
     a.GoodsMovementIsCancelled,
     
      @Search.defaultSearchElement: true
    @UI.selectionField : [{ position:30 }]
    @UI.lineItem : [{ position:30, label:'IsCancelled' }]
    // @EndUserText.label: 'Accounting document'
     a.PostingDate,
     
     c.gateentryno as GateEntryNo,
     c.vehicleno as VehicleNo,
     e.Supplier as Supplier,
     e.SupplierName as SupplierName
    
}


where
  (
  
      ( a.GoodsMovementType = '101' and a.PurchaseOrder is not initial )
       or a.GoodsMovementType = '305'
      
      
    //or a.AccountingDocumentType       = 'KG'
//    or a.AccountingDocumentType       = 'DG'
//    or a.AccountingDocumentType       = 'DD'
  )
   //and   a.FinancialAccountType = 'K' 

group by a.MaterialDocument, a.MaterialDocumentYear, a.CompanyCode ,a.GoodsMovementType,a.GoodsMovementIsCancelled,a.PostingDate,
    c.gateentryno,
    c.vehicleno,
    e.Supplier,
    e.SupplierName

