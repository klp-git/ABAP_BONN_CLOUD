@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GL Account Statement'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_GLAccountStatement
  as select from I_OperationalAcctgDocItem as item
    inner join   I_JournalEntry            as _JournalEntry on  item.CompanyCode        = _JournalEntry.CompanyCode
                                                            and item.FiscalYear         = _JournalEntry.FiscalYear
                                                            and item.AccountingDocument = _JournalEntry.AccountingDocument
  association [0..1] to I_GLAccountText as _GLAccount on  item.ChartOfAccounts = _GLAccount.ChartOfAccounts
                                                      and item.GLAccount       = _GLAccount.GLAccount
                                                      and _GLAccount.Language  = $session.system_language
{

  key item.CompanyCode,
  key item.AccountingDocument,
  key item.FiscalYear,
  key item.AccountingDocumentItem,

      item.GLAccount,
      _GLAccount.GLAccountName,

      item.Supplier,
      item.Customer,

      item.PostingDate,
      item.DocumentDate,
      item.NetDueDate,
      item.AccountingDocumentType,

      item.ReferenceDocumentType,
      coalesce(
      item.OriginalReferenceDocument,item.AssignmentReference) as OriginalReferenceDocument,
      item.PaymentReference,
      item.InvoiceReference,
      item.SalesDocument,
      item.PurchasingDocument,
      item.DocumentItemText,
      item._JournalEntry.BusinessTransactionType,
      item.CostCenter,
      item.ProfitCenter,
      item.FunctionalArea,
      item.BusinessArea,
      item.BusinessPlace,
      item.Segment,
      item.Plant,
      item.ControllingArea,
      _JournalEntry.ReversalReason,
      _JournalEntry.IsReversal,
      _JournalEntry.IsReversed,

      case when _JournalEntry.IsReversal = 'X'
            or _JournalEntry.IsReversed = 'X'
            then 0
            else 1
            end                                                as IsRevDoc,

      cast( case _JournalEntry.IsReversal
                when '' then ''
                else _JournalEntry.ReversalReferenceDocument
      end as awref preserving type )                           as ReversedReferenceDocument,
      cast( case _JournalEntry.IsReversed
                when '' then ''
                else _JournalEntry.ReversalReferenceDocument
      end as awref preserving type )                           as ReversalReferenceDocument,
      cast( case _JournalEntry.IsReversal
                when '' then ''
                else _JournalEntry.ReverseDocument
      end as abap.char(10) )                                   as ReversedDocument,
      cast( case _JournalEntry.IsReversed
                when '' then ''
                else _JournalEntry.ReverseDocument
      end as abap.char(10) )                                   as ReverseDocument,
      item.IsSalesRelated,

      item.DebitCreditCode,

      item.CompanyCodeCurrency,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      @Aggregation.default: #SUM
      item.AmountInCompanyCodeCurrency
}
where
      item.FiscalPeriod                >  '000'
  and item.AmountInTransactionCurrency <> 0
