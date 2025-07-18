
@EndUserText.label: 'ZCDSTCS'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_TCS'
@UI.headerInfo: {
  typeName: 'COUNT',
  typeNamePlural : 'COUNT'
}

define custom entity ZCDSTCS
{

 @UI.lineItem: [{ position: 10 }]
 @UI.selectionField: [{ position: 10 }]
 @EndUserText.label: 'Date'
 @Consumption.valueHelpDefinition: [
  {
    entity: { name: 'ZCDSSALESDATEVH', element: 'BillingDocumentDate' }
  }
]
 key sale_date: abap.dats;
  
 @UI.lineItem: [{ position: 20 }]  
  @UI.selectionField: [{ position: 20 }]
 @EndUserText.label: 'Sale Bill Number'
 @Consumption.valueHelpDefinition: [
  {
    entity: { name: 'ZCDSSALESBILLVH', element: 'DocumentReferenceID' }
  }
]
 key Sale_Bill_No: abap.char(14);

 @UI.lineItem: [{ position: 20.5 }]  
 @UI.selectionField: [{ position: 20.5 }]
 @EndUserText.label: 'Plant Code'
  @Consumption.valueHelpDefinition: [
  {
    entity: { name: 'ZCDSLOCATIONVH', element: 'Plant' }
  }]
 key Plant_code: abap.char(5);
 
 @UI.lineItem: [{ position: 21 }]  
  @UI.selectionField: [{ position: 21 }]
 @EndUserText.label: 'Location'
  @Consumption.valueHelpDefinition: [
  {
    entity: { name: 'ZCDSLOCATIONVH', element: 'PlantName' }
  }]
 key LOCATION: abap.char(40);
 
  
 @UI.lineItem: [{ position: 40 }]  
  @UI.selectionField: [{ position: 40 }]
 @EndUserText.label: 'Account Code'
 @Consumption.valueHelpDefinition: [
  {
    entity: { name: 'ZCDSACCOUNTCOODEVH', element: 'PayerParty' }
  }]
 key ACCOUNT_CODE: abap.char(18);
  

  
  @UI.lineItem: [{ position: 80 }]  
  @Consumption.filter: { hidden: true }
   @EndUserText.label: 'TCS Deduction Rate'
 key TCS_Deduction_Rate: abap.dec(7,4);
  
  @UI.lineItem: [{ position: 90 }]  
  @Consumption.filter: { hidden: true }
   @EndUserText.label: 'TCS Base Amount'
 key TCS_Base_Amount: abap.dec(23,2);
  
  @UI.lineItem: [{ position: 100 }] 
@Consumption.filter: { hidden: true }
   @EndUserText.label: 'TCS Amount'
   
 key TCS_Amount: abap.dec(23,2);
 
  @UI.lineItem: [{ position: 60 }]      
  @EndUserText.label: 'PAN Number'
  @Consumption.filter: { hidden: true }
  Pan_No: abap.char(18);
  
  @UI.lineItem: [{ position: 50 }]  
  @EndUserText.label: 'Customer Name or Party Name'
    @Consumption.filter: { hidden: true }
//  @Consumption.valueHelpDefinition: [
//  {
//    entity: { name: 'ZCDSCUSTOMERNAMEVH', element: 'PayerPartyName' }
//  }]
  partyname: abap.char(18);
  
  @UI.lineItem: [{ position: 70 }]  
  @EndUserText.label: 'TCS Section Code'
      @Consumption.filter: { hidden: true }
  TCS_Code: abap.char(18);
  


}
