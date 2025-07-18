@EndUserText.label: 'Creditor Aging Cube'
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

@Analytics.dataCategory: #CUBE
@VDM.viewType: #COMPOSITE
@ObjectModel: {
  supportedCapabilities: [ #ANALYTICAL_PROVIDER ],
  modelingPattern: #ANALYTICAL_CUBE
}
define view entity ZCUBE_CreditorAging
  with parameters

    @EndUserText.label: 'Company'
    @Consumption.valueHelpDefinition: [{entity.name: 'I_CompanyCodeStdVH', entity.element: 'CompanyCode'  }]
    pCompany  : bukrs,

    @EndUserText.label: 'To (Posting Date)'
    @Consumption.derivation: { lookupEntity: 'I_MySessionContext',
        resultElement: 'UserLocalDate', binding: [
        { targetElement : 'UserID' , type : #SYSTEM_FIELD, value : '#USER' } ]
       }
    pAsOnDate : budat,


    @EndUserText.label: 'From (Posting Date)'
    @Consumption.defaultValue: '15,30,45,60,90'
    pDaysStr  : z_daysrange

  as select from ZTBLF_CreditorAging
                 (pCompany:$parameters.pCompany,
                 pAsOnDate:$parameters.pAsOnDate,
                 pDaysStr:$parameters.pDaysStr) as rec
  association [0..1] to ZDIM_Supplier as _Supplier on $projection.PartyCode = _Supplier.Supplier

{

  @Consumption.semanticObject: 'Z_SupplierCompany'
  @ObjectModel.foreignKey.association: '_Supplier'
  @Consumption.valueHelpDefinition: [{entity.name: 'Z_SupplierCompany', entity.element: 'Supplier',
     additionalBinding: [{usage: #FILTER_AND_RESULT, localParameter: 'pCompany', element: 'CompanyCode'}]}]
  cast(PartyCode as lifnr preserving type)    as PartyCode,

  @EndUserText.label: 'City'
  _Supplier.City,

  @EndUserText.label: 'State'
  _Supplier.Region,

  @EndUserText.label: 'Country'
  _Supplier.Country,

  @EndUserText.label: 'Posting Date'
  PostingDate,

  @EndUserText.label: 'Due Date'
  NetDueDate,

  @EndUserText.label: 'Journal Entry No.'
  AccountingDocument                          as DocNo,

  @EndUserText.label: 'Entry Type'
  AccountingDocumentType                      as DocType,

  @EndUserText.label: 'Closing Bal Amt'
  concat_with_space(
          cast(Balance as abap.char(20)),
          case when Balance < 0 then 'Cr' else 'Dr' end,
          1
        )                                     as ClosingBal,


  @EndUserText.label: 'Doc Amt'
  @DefaultAggregation: #SUM
  DocAmt,

  @EndUserText.label: 'Doc Bal Amt'
  @DefaultAggregation: #SUM
  VutRefRcptAmt,

  @EndUserText.label: 'Due Amt'
  @DefaultAggregation: #SUM
  case when DueAmt > 0 then 0 else DueAmt end as DueAmt,

  @EndUserText.label: 'NoDue Amt'
  @DefaultAggregation: #SUM
  case when DueAmt > 0 then DueAmt else 0 end +
   NoDueAmt                                   as NoDueAmt,

  @Semantics.text: true
  @EndUserText.label: 'Due Days'
  DueDays,

  @Semantics.text: true
  @EndUserText.label: 'Range'
  Range,

  _Supplier
}
