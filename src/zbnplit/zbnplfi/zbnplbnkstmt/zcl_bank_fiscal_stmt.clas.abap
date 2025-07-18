CLASS zcl_bank_fiscal_stmt DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_amdp_marker_hdb.
    CLASS-METHODS get_data_bank_statement FOR TABLE FUNCTION ztblf_bank_statement.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_bank_fiscal_stmt IMPLEMENTATION.

  METHOD get_data_bank_statement
           BY DATABASE FUNCTION FOR HDB
           LANGUAGE SQLSCRIPT
           OPTIONS READ-ONLY
           USING ZC_BankStatement ZR_BillingDocumentRef ZR_PurchaseDocumentRef ZR_PaymentDocumentRef.

    RETURN
        select
          100 as CLIENT,
          item.fiscalyear,
          item.companycode,
          item.BankCode,

          item.glaccount,

          row_number ( ) over( order by item.postingdate Desc, item.accountingdocument Desc, item.AccountingDocumentItem Desc) srno,
          item.postingdate,
          item.documentdate,
          item.accountingdocumenttype,
          item.accountingdocument,

          item.referencedocumenttype,
          item.originalreferencedocument,
          cast(


          case item.accountingdocumenttype
          when 'RV'
          then 'To Inv. No. ' || BillingRef.InvNo ||
          ' Dtd. '|| To_varchar ( BillingDocumentDate , 'DD-MM-YYYY' ) || ( CASE when SalesOrders is null then  '' ELSE ' against SO. ' || SalesOrders END ) || ( CASE when OutBoundDlvs is null then '' ELSE ' Dlv. No. ' || OutBoundDlvs END )
          WHEN 'KR'
          then coalesce( 'By Bill No. ' || PurchaseRef.supplierinvoiceidbyinvcgparty || ' against entry no. ' || PurchaseRef.supplierinvoicewthnfiscalyear ||
          coalesce( ' Dtd. ' || To_varchar ( PurchaseRef.documentdate , 'DD-MM-YYYY' ), '') || coalesce( ' against PO. ' || PurchaseOrder ,''),
          'By Invoice ' || pymtref.OffsettingAccountName ||' against ref. '|| pymtref.AssignmentReference
          || ' ' || item.documentitemtext)
          WHEN 'DZ'
          then 'By payment received  ' || pymtref.OffsettingAccountName ||' against ref. '|| pymtref.AssignmentReference
          || ' ' || PaymentReference ||' Inv. Ref. '|| InvoiceReference || ' Doc.' || SalesDocument || PurchasingDocument || item.documentitemtext
          when 'KG'
          then 'To Credit Document ' || pymtref.OffsettingAccountName ||' against ref. '|| pymtref.AssignmentReference
          || ' ' || item.documentitemtext
          when 'RE'
          then 'By Bill No. ' || PurchaseRef.supplierinvoiceidbyinvcgparty || ' against entry no. ' || PurchaseRef.supplierinvoicewthnfiscalyear ||
          coalesce( ' Dtd. ' || To_varchar ( PurchaseRef.documentdate , 'DD-MM-YYYY' ), '') || coalesce( ' against PO. ' || PurchaseOrder ,'')

          WHEN 'EZ'
          then 'To payment made to '|| pymtref.OffsettingAccountName  ||' against ref. '|| pymtref.AssignmentReference
          || ' ' || item.documentitemtext
          when 'KZ'
          then 'To payment made to '|| pymtref.OffsettingAccountName  ||' against ref. '|| pymtref.AssignmentReference
          || ' ' || item.documentitemtext
          else
          (CASE when item.documentitemtext is null or length( item.documentitemtext ) <= 2 then 'Pymt. Ref ' || PaymentReference ||' Inv. Ref. '|| InvoiceReference || ' Doc.' || SalesDocument || PurchasingDocument ELSE DocumentItemText end)
          END

          as varchar( 500 )) documentitemtext,

          item.BusinessTransactionType,
          item.CostCenter,
          item.ProfitCenter,
          item.FunctionalArea,
          item.BusinessArea,
          item.BusinessPlace,
          item.Segment,
          item.Plant,
          item.ControllingArea,
          item.ReversalReason,
          item.IsReversal,
          item.IsReversed,
          item.ReversedReferenceDocument,
          item.ReversalReferenceDocument,
          item.ReversedDocument,
          item.ReverseDocument,
          item.companycodecurrency,
          item.debitcreditcode,
          item.amountincompanycodecurrency,
          item.creditamountincmpcdcrcy,
          item.debitamountincmpcdcrcy,
          sum (item.amountincompanycodecurrency)
          over (order by item.postingdate Desc, item.accountingdocument Desc, item.AccountingDocumentItem Desc
                rows between  current row and unbounded following  ) as runningbalance
    from
        ZC_BankStatement( :pCompanyCode , :pBankAccountInternalId, :pFromDate, :pToDate, :pIsRevDoc) as item
        Left outer Join
             (
                SELECT x.companycode, x.FiscalYear, x.accountingdocument, x.billingdocument,x.InvNo,x.BillingDocumentDate,
                string_agg( SalesOrder , ', ' ) as SalesOrders,
                  string_agg( OutBoundDlv , ', ' ) as OutBoundDlvs
                from ZR_BillingDocumentRef as x
                group by x.companycode, x.FiscalYear, x.accountingdocument, x.billingdocument, x.InvNo,x.BillingDocumentDate
            ) as BillingRef
            on item.accountingdocument = BillingRef.accountingdocument
                and item.companycode = BillingRef.companycode
                and item.FiscalYear = BillingRef.FiscalYear
                and item.accountingdocumenttype = 'RV'
        Left outer join
            (
                SELECT p.companycode, p.fiscalyear, p.supplierinvoicewthnfiscalyear, p.supplierinvoiceidbyinvcgparty, p.documentdate,
                 string_agg( p.purchaseorder , ', ' ) as PurchaseOrder
                    From ZR_PurchaseDocumentRef as p
                    group by p.companycode, p.fiscalyear, p.supplierinvoicewthnfiscalyear, p.supplierinvoiceidbyinvcgparty, p.documentdate
            ) as PurchaseRef
            on item.originalreferencedocument = PurchaseRef.supplierinvoicewthnfiscalyear
                and item.companycode= PurchaseRef.companycode
                and (item.accountingdocumenttype = 'RE' or item.accountingdocumenttype = 'KR')

        Left outer join
            ZR_PaymentDocumentRef as pymtref
            ON pymtref.accountingdocument = item.accountingdocument
            and pymtref.accountingdocumentitem = item.accountingdocumentitem
            and pymtref.FiscalYear = item.FiscalYear
            and pymtref.companycode = item.companycode

    order by srno Desc;

  ENDMETHOD.

ENDCLASS.
