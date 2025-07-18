@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Employees Line Items Selected GL'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_EMPSelGLLineItems
  with parameters
    pCompanyCode : bukrs,
    pFromDate    : budat,
    pToDate      : budat
  as select from I_GLAccountLineItem as item
    inner join   ZR_USER_CMPY_ACCESS as _cmpAccess on  _cmpAccess.CompCode = item.CompanyCode
                                                   and _cmpAccess.userid   = $session.user
    inner join   I_Supplier          as _Supplier  on  item.Supplier                  = _Supplier.Supplier
                                                   and _Supplier.SupplierAccountGroup = 'Z005' -- Only Emplyoees
{
  item.GLAccount,
  item.Supplier                                                                                                                                                                                   as EmpCode,
  item.CompanyCodeCurrency,

  @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
  sum(case when  item.PostingDate <= $parameters.pFromDate then item.AmountInCompanyCodeCurrency else abap.curr'0.00' end )                                                                       as OpeningAmt,

  @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
  sum(case when item.PostingDate between $parameters.pFromDate and $parameters.pToDate and item.AmountInCompanyCodeCurrency < 0 then -item.AmountInCompanyCodeCurrency else abap.curr'0.00' end ) as CreditAmt,

  @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
  sum(case when item.PostingDate between $parameters.pFromDate and $parameters.pToDate and item.AmountInCompanyCodeCurrency > 0 then item.AmountInCompanyCodeCurrency else abap.curr'0.00' end )  as DebitAmt,

  @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
  sum(case when  item.PostingDate <= $parameters.pToDate then item.AmountInCompanyCodeCurrency else abap.curr'0.00' end )                                                                         as ClosingAmt
}
where
       item.SourceLedger                =  '0L'
  and  item.IsReversal                  <> 'X'
  and  item.IsReversed                  <> 'X'
  and  item.FiscalPeriod                >  '000'
  and  item.CompanyCode                 = $parameters.pCompanyCode
  and  item.PostingDate                 <= $parameters.pToDate
  and  item.AmountInCompanyCodeCurrency <> 0
  and(
       item.GLAccount                   =  '0012220000'
    or item.GLAccount                   =  '0012221000'
    or item.GLAccount                   =  '0021517100'
    or item.GLAccount                   =  '0012221100'
  )
group by
  item.GLAccount,
  item.Supplier,
  item.CompanyCodeCurrency
