
@EndUserText.label: 'cds of ZGOODS_TFR_NOTE'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZCDS_GOODS_TFR_NOTE 
  as select distinct from I_MaterialDocumentItem_2 as a
{
  @EndUserText.label: 'Material Document'
  @UI.selectionField: [{ position: 10 }]
  @UI.lineItem:       [{ position: 10, label: 'Material Document' }]
  @Search.defaultSearchElement: true
  key a.MaterialDocument,

  @EndUserText.label: 'Company Code'
  @UI.selectionField: [{ position: 20 }]
  @UI.lineItem:       [{ position: 20, label: 'Company Code' }]
  @Search.defaultSearchElement: true
  key a.CompanyCode,

//  @EndUserText.label: 'Material Document Item'
//  @UI.lineItem:       [{ position: 30, label: 'Material Document Item' }]
//  key a.MaterialDocumentItem,

  @EndUserText.label: 'Plant'
  @UI.selectionField: [{ position: 40 }]
  @UI.lineItem:       [{ position: 40, label: 'Plant' }]
  @Search.defaultSearchElement: true
  a.Plant,

  @EndUserText.label: 'Movement Type'
  @UI.lineItem:       [{ position: 50, label: 'Movement Type' }]
  @Search.defaultSearchElement: true
  a.GoodsMovementType,

  @EndUserText.label: 'Posting Date'
  @UI.lineItem:       [{ position: 60, label: 'Posting Date' }]
  @Search.defaultSearchElement: true
  a.PostingDate

}
where a.GoodsMovementType = '311'


 
