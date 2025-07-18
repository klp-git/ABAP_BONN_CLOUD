CLASS zcl_purchasejob_lines DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .

    INTERFACES if_oo_adt_classrun .
    METHODS Purchaseregister.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_purchasejob_lines IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
      ( selname = 'S_ID'    kind = if_apj_dt_exec_object=>select_option datatype = 'C' length = 10 param_text = 'My ID'                                      changeable_ind = abap_true )
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 80 param_text = 'My Description'   lowercase_ind = abap_true changeable_ind = abap_true )
      ( selname = 'P_COUNT' kind = if_apj_dt_exec_object=>parameter     datatype = 'I' length = 10 param_text = 'My Count'                                   changeable_ind = abap_true )
      ( selname = 'P_SIMUL' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length =  1 param_text = 'Full Processing' checkbox_ind = abap_true  changeable_ind = abap_true )
    ).

    " Return the default parameters values here
    et_parameter_val = VALUE #(
      ( selname = 'S_ID'    kind = if_apj_dt_exec_object=>select_option sign = 'I' option = 'EQ' low = '4711' )
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'My Default Description' )
      ( selname = 'P_COUNT' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = '200' )
      ( selname = 'P_SIMUL' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = abap_false )
    ).
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    TYPES ty_id TYPE c LENGTH 10.

    DATA s_id    TYPE RANGE OF ty_id.
    DATA p_descr TYPE c LENGTH 80.
    DATA p_count TYPE i.
    DATA p_simul TYPE abap_boolean.
    DATA processfrom TYPE d.

    DATA: jobname   TYPE cl_apj_rt_api=>ty_jobname.
    DATA: jobcount  TYPE cl_apj_rt_api=>ty_jobcount.
    DATA: catalog   TYPE cl_apj_rt_api=>ty_catalog_name.
    DATA: template  TYPE cl_apj_rt_api=>ty_template_name.

    DATA: lt_purchinvlines     TYPE STANDARD TABLE OF zpurchinvlines,
          wa_purchinvlines     TYPE zpurchinvlines,
          lt_purchinvprocessed TYPE STANDARD TABLE OF zpurchinvproc,
          wa_purchinvprocessed TYPE zpurchinvproc.


****************************************************************************************
    DATA maxpostingdate TYPE d.
    DATA deleteString TYPE c LENGTH 4.
    DATA: lv_tstamp TYPE timestamp, lv_date TYPE d, lv_time TYPE t, lv_dst TYPE abap_bool.

    GET TIME STAMP FIELD DATA(lv_timestamp).

    GET TIME STAMP FIELD lv_tstamp.
    CONVERT TIME STAMP lv_tstamp TIME ZONE sy-zonlo INTO DATE lv_date TIME lv_time DAYLIGHT SAVING TIME lv_dst.

    deleteString = |{ lv_date+6(2) }| && |{ lv_time+0(2) }|.


*    IF deleteString = '2217'.
    IF deleteString = p_descr+7(4).
      DELETE FROM zpurchinvlines WHERE supplierinvoice IS NOT INITIAL.
      DELETE FROM zpurchinvproc WHERE supplierinvoice IS NOT INITIAL.
      COMMIT WORK.
    ENDIF.

    SELECT FROM zpurchinvlines
      FIELDS MAX( postingdate )
      WHERE supplierinvoice IS NOT INITIAL
      INTO @maxpostingdate .
    IF maxpostingdate IS INITIAL.
      maxpostingdate = 20010101.
    ELSE.
      maxpostingdate = maxpostingdate - 30.
    ENDIF.
****************************************************************************************


    " Getting the actual parameter values
    LOOP AT it_parameters INTO DATA(ls_parameter).
      CASE ls_parameter-selname.
        WHEN 'S_ID'.
          APPEND VALUE #( sign   = ls_parameter-sign
                          option = ls_parameter-option
                          low    = ls_parameter-low
                          high   = ls_parameter-high ) TO s_id.
        WHEN 'P_DESCR'. p_descr = ls_parameter-low.
        WHEN 'P_COUNT'. p_count = ls_parameter-low.
        WHEN 'P_SIMUL'. p_simul = ls_parameter-low.
      ENDCASE.
    ENDLOOP.
    IF deleteString = p_descr+7(4).
      DELETE FROM zpurchinvlines WHERE supplierinvoice IS NOT INITIAL.
      DELETE FROM zpurchinvproc WHERE supplierinvoice IS NOT INITIAL.
      COMMIT WORK.
    ENDIF.
    TRY.
*      read own runtime info catalog
        cl_apj_rt_api=>get_job_runtime_info(
                         IMPORTING
                           ev_jobname        = jobname
                           ev_jobcount       = jobcount
                           ev_catalog_name   = catalog
                           ev_template_name  = template ).

      CATCH cx_apj_rt.
        CLEAR p_count.
    ENDTRY.
    Purchaseregister( ).


  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    Purchaseregister( ).
  ENDMETHOD.


  METHOD Purchaseregister.
    DATA processfrom TYPE d.
    DATA p_simul TYPE abap_boolean.
    DATA p_descr TYPE c LENGTH 80.
    DATA assignmentreference TYPE string.

    DATA deleteString TYPE c LENGTH 4.
    DATA: lv_tstamp TYPE timestamp, lv_date TYPE d, lv_time TYPE t, lv_dst TYPE abap_bool.

    GET TIME STAMP FIELD DATA(lv_timestamp).

    GET TIME STAMP FIELD lv_tstamp.
    CONVERT TIME STAMP lv_tstamp TIME ZONE sy-zonlo INTO DATE lv_date TIME lv_time DAYLIGHT SAVING TIME lv_dst.

    deleteString = |{ lv_date+6(2) }| && |{ lv_time+0(2) }|.

*    IF deleteString = '1913'.
    IF deleteString = p_descr+7(4).
      DELETE FROM zpurchinvlines WHERE supplierinvoice IS NOT INITIAL.
      DELETE FROM zpurchinvproc WHERE supplierinvoice IS NOT INITIAL.
      COMMIT WORK.
    ENDIF.



    DATA: lt_purchinvlines     TYPE STANDARD TABLE OF zpurchinvlines,
          wa_purchinvlines     TYPE zpurchinvlines,
          lt_purchinvprocessed TYPE STANDARD TABLE OF zpurchinvproc,
          wa_purchinvprocessed TYPE zpurchinvproc.

*    GET TIME STAMP FIELD DATA(lv_timestamp).

*    DELETE FROM zpurchinvproc.
*    DELETE FROM zpurchinvlines.
*    COMMIT WORK.

    p_simul = abap_true.
    processfrom = sy-datum - 30.
    IF p_simul = abap_true.
      processfrom = sy-datum - 2000.
    ENDIF.


***************************************************** HEADER *****************************************
    SELECT FROM I_SupplierInvoiceAPI01 AS c
        LEFT JOIN i_supplier AS b ON b~supplier = c~InvoicingParty
        LEFT JOIN C_SupplierInvoiceDEX AS SDex ON SDex~SupplierInvoice = c~SupplierInvoice
***********************************
        LEFT JOIN I_BusPartAddress AS hdr1 ON c~BusinessPlace = hdr1~BusinessPartner
***********************************

        FIELDS
            b~Supplier , b~PostalCode , b~BPAddrCityName , b~BPAddrStreetName , b~TaxNumber3,
            b~Suppliername, b~region, c~ReverseDocument , c~ReverseDocumentFiscalYear,
            c~CompanyCode , c~PaymentTerms , c~CreatedByUser , c~CreationDate , c~InvoicingParty , c~InvoiceGrossAmount,
            c~DocumentCurrency , c~SupplierInvoiceIDByInvcgParty, c~FiscalYear, c~SupplierInvoice, c~SupplierInvoiceWthnFiscalYear,
            c~DocumentDate, c~PostingDate, b~TaxNumber3 AS Supp_Gst,
            SDex~ReverseDocument AS revDoc,
**************************************
            hdr1~AddressID
**************************************
        WHERE c~PostingDate >= @processfrom
*             and c~SupplierInvoice = '5105600287'
*             and c~CompanyCode = 'BBPL'
*             and c~FiscalYear = '2025'
            AND NOT EXISTS (
               SELECT supplierinvoice FROM zpurchinvproc
               WHERE c~supplierinvoice = zpurchinvproc~supplierinvoice AND
                 c~CompanyCode = zpurchinvproc~companycode AND
                 c~FiscalYear = zpurchinvproc~fiscalyearvalue
                 )
            INTO TABLE @DATA(ltheader).

********************************************************* LINE ITEM ***************************************
    LOOP AT ltheader INTO DATA(waheader).
*      lv_timestamp = cl_abap_tstmp=>add_to_short( tstmp = lv_timestamp secs = 11111 ).
      GET TIME STAMP FIELD lv_timestamp.

* Delete already processed sales line
      DELETE FROM zpurchinvlines
          WHERE zpurchinvlines~companycode = @waheader-CompanyCode AND
          zpurchinvlines~fiscalyearvalue = @waheader-FiscalYear AND
          zpurchinvlines~supplierinvoice = @waheader-SupplierInvoice.



      SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
**********************************************
          LEFT JOIN I_PurchaseOrderItemAPI01 AS li ON a~PurchaseOrder = li~PurchaseOrder AND a~PurchaseOrderItem = li~PurchaseOrderItem
*            LEFT JOIN zmaterial_table AS li4 ON li~Material = li4~mat
          LEFT JOIN i_deliverydocumentitem AS li2 ON li~PurchaseOrder = li2~ReferenceSDDocument AND li~PurchaseOrderItem = li2~ReferenceSDDocumentItem
          LEFT JOIN i_deliverydocument AS li3 ON li2~DeliveryDocument = li3~DeliveryDocument
          LEFT JOIN i_purchaseorderhistoryapi01 AS li5 ON li~PurchaseOrder = li5~PurchaseOrder AND li~PurchaseOrderItem = li5~PurchaseOrderItem
                    AND li5~PurchasingHistoryCategory = 'Q'
          LEFT JOIN i_purchaseorderapi01 AS li6 ON li~PurchaseOrder = li6~PurchaseOrder
          LEFT JOIN I_Supplier AS li13 ON li6~Supplier = li13~Supplier
          LEFT JOIN I_MaterialDocumentHeader_2 AS li14 ON a~ReferenceDocument = li14~MaterialDocument AND a~ReferenceDocumentFiscalYear = li14~MaterialDocumentYear
          LEFT JOIN I_BusinessPartner AS li7 ON li6~Supplier = li7~BusinessPartner
          LEFT JOIN I_BusinessPartnerLegalFormText AS li8 ON li7~LegalForm = li8~LegalForm
          LEFT JOIN i_purchaseorderitemtp_2 AS li9 ON li~PurchaseOrder = li9~PurchaseOrder AND li~PurchaseOrderItem = li9~PurchaseOrderItem
          LEFT JOIN I_Requestforquotation_Api01 AS li10 ON li9~SupplierQuotation = li10~RequestForQuotation
          LEFT JOIN I_SupplierQuotation_Api01 AS li11 ON li9~SupplierQuotation = li11~SupplierQuotation
          LEFT JOIN i_accountingdocumentjournal AS li12 ON li5~PurchasingHistoryDocument = li12~DocumentReferenceID
*    ********************************************
          FIELDS
              a~PurchaseOrderItem, a~SupplierInvoiceItem,
              a~PurchaseOrder, a~SupplierInvoiceItemAmount AS tax_amt, a~SupplierInvoiceItemAmount, a~taxcode,
              a~FreightSupplier , a~SupplierInvoice , a~FiscalYear , a~TaxJurisdiction, a~plant,
              a~PurchaseOrderItemMaterial AS material, a~QuantityInPurchaseOrderUnit, a~QtyInPurchaseOrderPriceUnit,
              a~PurchaseOrderQuantityUnit, PurchaseOrderPriceUnit, a~ReferenceDocument , a~ReferenceDocumentFiscalYear,
*    ***********************************************
              li~Plant AS plantcity, li~Plant AS plantpin, li3~DeliveryDocumentBySupplier, li5~DocumentDate,  "li4~trade_name,
              li8~LegalFormDescription, li9~SupplierQuotation, li10~RFQPublishingDate, li11~SupplierQuotation AS sq,
              li11~QuotationSubmissionDate, li5~PostingDate,  li12~DocumentReferenceID, li~NetPriceAmount,
              a~IsSubsequentDebitCredit, li6~Supplier, li13~SupplierName, li14~PostingDate AS MRNPostingDate
              ,li~PurchaseOrderItemText
*    **********************************************
          WHERE a~SupplierInvoice = @waheader-SupplierInvoice
                 AND a~FiscalYear = @waheader-FiscalYear
            AND a~SuplrInvcDeliveryCostCndnType = ''
          ORDER BY a~PurchaseOrderItem, a~SupplierInvoiceItem
            INTO TABLE @DATA(ltlines).

*       SORT ltlines BY PurchaseOrderItem SupplierInvoiceItem.
*       DELETE ADJACENT DUPLICATES FROM ltlines COMPARING ALL FIELDS.



************************Additional LOOP For "Mrnpostingdate"***************************
      LOOP AT ltlines INTO DATA(wa_new).
        CLEAR: wa_new-PostingDate.

        SELECT SINGLE    postingdate FROM I_PurchaseOrderItemAPI01 AS a
                LEFT JOIN i_purchaseorderhistoryapi01 AS b ON a~PurchaseOrder = b~PurchaseOrder AND a~PurchaseOrderItem = b~PurchaseOrderItem
            WHERE b~purchasinghistorycategory EQ 'Q' AND a~purchaseorder = @wa_new-PurchaseOrder AND a~purchaseorderitem = @wa_new-PurchaseOrderItem
            INTO @wa_new-PostingDate.

*    ***************************** FOR HSN CODE ****************************
        SELECT SINGLE FROM I_PurchaseOrderItemAPI01 AS a
              LEFT JOIN i_purchaseorderhistoryapi01 AS b ON a~PurchaseOrder = b~PurchaseOrder AND a~PurchaseOrderItem = b~PurchaseOrderItem AND b~GoodsMovementType EQ '101'
              LEFT JOIN i_accountingdocumentjournal AS c ON b~PurchasingHistoryDocument = c~DocumentReferenceID
            FIELDS c~documentreferenceid
                WHERE a~purchaseorder = @wa_new-PurchaseOrder AND a~purchaseorderitem = @wa_new-PurchaseOrderItem
                INTO @wa_new-documentreferenceid.

      ENDLOOP.
***************************************************************************************


*        SELECT FROM I_BillingDocItemPrcgElmntBasic FIELDS BillingDocument , BillingDocumentItem, ConditionRateValue, ConditionAmount, ConditionType
*        WHERE BillingDocument = @waheader-BillingDocument
*        INTO TABLE @DATA(it_price).
      IF ltlines IS NOT INITIAL.
        SELECT FROM I_Producttext AS a FIELDS
            a~ProductName, a~Product
        FOR ALL ENTRIES IN @ltlines
        WHERE a~Product = @ltlines-material AND a~Language = 'E'
            INTO TABLE @DATA(it_product).

        SELECT FROM I_PurchaseOrderItemAPI01 AS a
            LEFT JOIN I_PurchaseOrderAPI01 AS b ON a~PurchaseOrdeR = b~PurchaseOrder
            FIELDS a~BaseUnit , b~PurchaseOrderType , b~PurchasingGroup , b~PurchasingOrganization ,
            b~PurchaseOrderDate , a~PurchaseOrder , a~PurchaseOrderItem , a~ProfitCenter
        FOR ALL ENTRIES IN @ltlines
        WHERE a~PurchaseOrder = @ltlines-PurchaseOrder AND a~PurchaseOrderItem = @ltlines-PurchaseOrderItem
            INTO TABLE @DATA(it_po).

        SELECT FROM I_MaterialDocumentItem_2
            FIELDS MaterialDocument , PurchaseOrder , PurchaseOrderItem , QuantityInBaseUnit , PostingDate
        FOR ALL ENTRIES IN @ltlines
        WHERE MaterialDocument  = @ltlines-ReferenceDocument
            INTO TABLE @DATA(it_grn).

        SELECT FROM I_taxcodetext
            FIELDS TaxCode , TaxCodeName
        FOR ALL ENTRIES IN @ltlines
        WHERE Language = 'E' AND taxcode = @ltlines-TaxCode
            INTO TABLE @DATA(it_tax).


        SELECT FROM  i_purorditmpricingelementapi01 AS a LEFT JOIN I_PurchaseOrderAPI01 AS b ON
                     a~PricingDocument = b~PricingDocument
*                               and a~PricingDocument = b~pr
        FIELDS a~conditioncurrency , a~ConditionAmount , b~PurchaseOrder
        FOR ALL ENTRIES IN @ltlines
        WHERE b~PurchaseOrder = @ltLines-PurchaseOrder AND a~ConditionType IN ( 'ZDCP' , 'ZDCV' , 'ZCD1' , 'ZDCQ' )
        INTO TABLE @DATA(it_discount1).
      ENDIF.

      DATA lv_deliverycostamount TYPE I_SuplrInvcItemPurOrdRefAPI01-SupplierInvoiceItemAmount.
      DATA lv_signval TYPE i.

      LOOP AT ltlines INTO DATA(walines).
        wa_purchinvlines-client                     = sy-mandt.
        wa_purchinvlines-companycode                = waheader-CompanyCode.
        wa_purchinvlines-fiscalyearvalue            = waheader-FiscalYear.
        wa_purchinvlines-supplierbillno             = waheader-SupplierInvoiceIDByInvcgParty.
        wa_purchinvlines-supplierinvoice            = waheader-SupplierInvoice.
        wa_purchinvlines-supplierinvoiceitem        = walines-SupplierInvoiceItem.
        wa_purchinvlines-postingdate                = waheader-PostingDate.
********************************** Item Level Fields Added ****************************
        wa_purchinvlines-plantcity                  = walines-plantcity.
        wa_purchinvlines-plantpin                   = walines-plantpin.
        wa_purchinvlines-plantcode                  = walines-Plant.
        wa_purchinvlines-plant                      = walines-Plant.
*            wa_purchinvlines-product_trade_name = walines-trade_name.
        wa_purchinvlines-vendor_invoice_no          = walines-DeliveryDocumentBySupplier.
        wa_purchinvlines-vendor_invoice_date        = walines-DocumentDate.
        wa_purchinvlines-vendor_type                = walines-LegalFormDescription.
        wa_purchinvlines-rfqno                      = walines-SupplierQuotation.
        wa_purchinvlines-rfqno                      = walines-SupplierQuotation.
        wa_purchinvlines-rfqdate                    = walines-RFQPublishingDate.
        wa_purchinvlines-supplierquotation          = walines-sq.
        wa_purchinvlines-supplierquotationdate      = walines-QuotationSubmissionDate.
        wa_purchinvlines-mrnquantityinbaseunit      = walines-PostingDate.
        wa_purchinvlines-hsncode                    = walines-DocumentReferenceID.
        wa_purchinvlines-supp_gst                   = waheader-supp_gst.
        wa_purchinvlines-suppliercode               = walines-supplier.
        wa_purchinvlines-suppliercodename           = walines-SupplierName. "| { walines-Supplier } - { walines-SupplierName  } |.
        SELECT SINGLE FROM I_IN_BusinessPlaceTaxDetail AS a
            LEFT JOIN  I_Address_2  AS b ON a~AddressID = b~AddressID
            FIELDS
            a~BusinessPlaceDescription,
            a~IN_GSTIdentificationNumber,
            b~Street, b~PostalCode , b~CityName
        WHERE a~CompanyCode = @waheader-CompanyCode AND a~BusinessPlace = @walines-Plant
        INTO ( @wa_purchinvlines-plantname, @wa_purchinvlines-plantgst, @wa_purchinvlines-plantadr, @wa_purchinvlines-plantpin,
            @wa_purchinvlines-plantcity ).

        wa_purchinvlines-product                    = walines-material.
        IF walines-material <> ''.
          READ TABLE it_product INTO DATA(wa_product) WITH KEY product = walines-material.
          wa_purchinvlines-productname                = wa_product-ProductName.
        ELSE.
          wa_purchinvlines-productname                = walines-PurchaseOrderItemText.
        ENDIF.
        wa_purchinvlines-purchaseorder              = walines-PurchaseOrder.
        wa_purchinvlines-purchaseorderitem          = walines-PurchaseOrderItem.
        CONCATENATE walines-SupplierInvoice walines-FiscalYear INTO wa_purchinvlines-originalreferencedocument.

        READ TABLE it_po INTO DATA(wa_po) WITH KEY PurchaseOrder = walines-PurchaseOrder
                                                PurchaseOrderItem = walines-PurchaseOrderItem.

        wa_purchinvlines-baseunit                   = wa_po-BaseUnit.
        wa_purchinvlines-profitcenter               = wa_po-ProfitCenter.
        wa_purchinvlines-purchaseordertype          = wa_po-PurchaseOrderType.
        wa_purchinvlines-purchaseorderdate          = wa_po-PurchaseOrderDate.
        wa_purchinvlines-purchasingorganization     = wa_po-PurchasingOrganization.
        wa_purchinvlines-purchasinggroup            = wa_po-PurchasingGroup.
        wa_purchinvlines-basicrate                  = walines-NetPriceAmount.
        wa_purchinvlines-grnno                      = walines-ReferenceDocument.
        wa_purchinvlines-mrnquantityinbaseunit      = walines-QtyInPurchaseOrderPriceUnit.
        wa_purchinvlines-mrnpostingdate             = walines-mrnpostingdate.
*            READ TABLE it_grn INTO DATA(wa_grn) WITH KEY MaterialDocument = walines-ReferenceDocument.
*                wa_purchinvlines-mrnquantityinbaseunit     = wa_grn-QuantityInBaseUnit.
        READ TABLE it_tax INTO DATA(wa_tax) WITH KEY     TaxCode = walines-TaxCode.
        wa_purchinvlines-taxcodename                = wa_tax-TaxCodeName.
        IF waHeader-revdoc <> ''.
          wa_purchinvlines-isreversed = 'X'.
        ENDIF.
        CONCATENATE walines-PurchaseOrder walines-PurchaseOrderItem INTO assignmentreference.

        SELECT  TaxItemAcctgDocItemRef, IN_HSNOrSACCode FROM i_operationalacctgdocitem
            WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear AND TaxItemAcctgDocItemRef IS NOT INITIAL
            AND AccountingDocumentItemType <> 'T'
            AND FiscalYear = @walines-FiscalYear
            AND CompanyCode = @waheader-CompanyCode
            AND AccountingDocumentType = 'RE'
            AND AssignmentReference = @assignmentreference
            AND Product = @walines-material
            AND AccountingDocumentItemType IS NOT INITIAL

*        INTO  TABLE (  @DATA(lv_TaxItemAcctgDocItemRef), @DATA(lv_HSNCode) ).
        INTO  TABLE @DATA(it_taxitems).
        SORT it_taxitems  ASCENDING BY TaxItemAcctgDocItemRef.
        READ TABLE it_taxitems INTO DATA(wa_taxitems) INDEX 1.
        DATA lv_TaxItemAcctgDocItemRef TYPE i_operationalacctgdocitem-TaxItemAcctgDocItemRef.
        DATA lv_HSNCode TYPE i_operationalacctgdocitem-IN_HSNOrSACCode
        .
        IF wa_taxitems IS NOT INITIAL.

          lv_TaxItemAcctgDocItemRef = wa_taxitems-TaxItemAcctgDocItemRef .
          lv_HSNCode = wa_taxitems-IN_HSNOrSACCode .
        ENDIF.
        wa_purchinvlines-hsncode                    = lv_HSNCode.

        SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
            WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
                AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
                AND AccountingDocumentItemType = 'T'
                AND FiscalYear = @walines-FiscalYear
                AND CompanyCode = @waheader-CompanyCode
                AND TransactionTypeDetermination = 'JII'
        INTO  @wa_purchinvlines-igst.

*        SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
*    WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
*        AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
*        AND AccountingDocumentItemType = 'T'
*        AND FiscalYear = @walines-FiscalYear
*        AND CompanyCode = @waheader-CompanyCode
*        AND TransactionTypeDetermination = 'JII'
*INTO  @wa_purchinvlines-NDigst.

        IF wa_purchinvlines-igst IS INITIAL.
          SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
              WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
                  AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
                  AND AccountingDocumentItemType = 'T'
                  AND FiscalYear = @walines-FiscalYear
                  AND CompanyCode = @waheader-CompanyCode
                  AND TransactionTypeDetermination = 'JIC'
          INTO  @wa_purchinvlines-cgst.

          SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
              WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
                  AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
                  AND AccountingDocumentItemType = 'T'
                  AND FiscalYear = @walines-FiscalYear
                  AND CompanyCode = @waheader-CompanyCode
                  AND TransactionTypeDetermination = 'JIS'
          INTO  @wa_purchinvlines-sgst.
        ENDIF.

*        IF wa_purchinvlines-ndigst IS INITIAL.
*          SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
*              WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
*                  AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
*                  AND AccountingDocumentItemType = 'T'
*                  AND FiscalYear = @walines-FiscalYear
*                  AND CompanyCode = @waheader-CompanyCode
*                  AND TransactionTypeDetermination = 'JIC'
*          INTO  @wa_purchinvlines-ndcgst.
*
*          SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
*              WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
*                  AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
*                  AND AccountingDocumentItemType = 'T'
*                  AND FiscalYear = @walines-FiscalYear
*                  AND CompanyCode = @waheader-CompanyCode
*                  AND TransactionTypeDetermination = 'JIS'
*          INTO  @wa_purchinvlines-ndsgst.
*        ENDIF.




        SELECT  SINGLE AmountInCompanyCodeCurrency  FROM i_operationalacctgdocitem
            WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
                AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
                AND AccountingDocumentItemType = 'T'
                AND FiscalYear = @walines-FiscalYear
                AND CompanyCode = @waheader-CompanyCode
                AND TransactionTypeDetermination = 'JRI'
        INTO  @wa_purchinvlines-rcmigst .
*        wa_purchinvlines-rcmigst = wa_purchinvlines-rcmigst * -1 .
        IF wa_purchinvlines-rcmigst IS INITIAL.
          SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
              WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
                  AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
                  AND AccountingDocumentItemType = 'T'
                  AND FiscalYear = @walines-FiscalYear
                  AND CompanyCode = @waheader-CompanyCode
                  AND TransactionTypeDetermination = 'JRC'
          INTO  @wa_purchinvlines-rcmcgst.

          SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
              WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
                  AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
                  AND AccountingDocumentItemType = 'T'
                  AND FiscalYear = @walines-FiscalYear
                  AND CompanyCode = @waheader-CompanyCode
                  AND TransactionTypeDetermination = 'JRS'
          INTO  @wa_purchinvlines-rcmsgst.
*          wa_purchinvlines-rcmcgst *= -1 .

          SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
              WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
                  AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
                  AND AccountingDocumentItemType = 'T'
                  AND FiscalYear = @walines-FiscalYear
                  AND CompanyCode = @waheader-CompanyCode
                  AND TransactionTypeDetermination = 'JIM'
          INTO  @wa_purchinvlines-igst.
        ENDIF.

*        //For TransactionType
        SELECT FROM  i_purchaseorderhistoryapi01 AS a
        FIELDS a~PurchasingHistoryDocument , a~PurchasingHistoryCategory , a~PurchaseOrder, a~DebitCreditCode, a~ReferenceDocument
        WHERE a~PurchaseOrder = @walines-PurchaseOrder
        AND a~PurchasingHistoryDocument = @walines-SupplierInvoice
        AND a~PurchasingHistoryDocumentItem = @walines-SupplierInvoiceItem
        AND a~PurchasingHistoryCategory IN ( 'N' , 'Q' )
        INTO TABLE @DATA(it_transtype).

        lv_signval = 1.
        LOOP AT it_transtype INTO DATA(waTransType).
*               Transaction Type
          IF watranstype-PurchasingHistoryCategory = 'Q' AND wa_purchinvlines-purchaseordertype NE 'ZRET'.
            wa_purchinvlines-transactiontype = 'Invoice'.
            lv_signval = 1.

          ELSEIF watranstype-PurchasingHistoryCategory = 'Q' AND wa_purchinvlines-purchaseordertype = 'ZRET'.

            IF watranstype-PurchasingHistoryCategory = 'Q' AND watranstype-DebitCreditCode = 'H'.
              wa_purchinvlines-transactiontype = 'Debit Note'.
              lv_signval = -1.
            ELSEIF watranstype-PurchasingHistoryCategory = 'Q' AND watranstype-DebitCreditCode = 'S'.
              wa_purchinvlines-transactiontype = 'Credit Note'.
              lv_signval = 1.
            ENDIF.
          ELSE.
            IF watranstype-PurchasingHistoryCategory = 'N' AND watranstype-DebitCreditCode = 'H'.
              wa_purchinvlines-transactiontype = 'Debit Note'.
              lv_signval = -1.
            ELSEIF watranstype-PurchasingHistoryCategory = 'N' AND watranstype-DebitCreditCode = 'S'.
              wa_purchinvlines-transactiontype = 'Credit Note'.
              lv_signval = 1.
            ENDIF.
          ENDIF.
        ENDLOOP.

        """"""""""""""""""""""""""""""""""""""""""""""""for rate percent.
        wa_purchinvlines-rateigst   = 0.
        wa_purchinvlines-ratecgst   = 0.
        wa_purchinvlines-ratesgst   = 0.
        wa_purchinvlines-ratendigst = 0.
        wa_purchinvlines-ratendcgst = 0.
        wa_purchinvlines-ratendsgst = 0.
        IF walines-TaxCode = 'I0'.
          wa_purchinvlines-ratecgst   = 0.
          wa_purchinvlines-ratesgst   = 0.
        ELSEIF walines-TaxCode = 'I9'.
          wa_purchinvlines-rateigst   = 0.
        ELSEIF walines-TaxCode = 'I1'.
          wa_purchinvlines-ratecgst   = '2.5'.
          wa_purchinvlines-ratesgst   = '2.5'.
        ELSEIF walines-TaxCode = 'I5'.
          wa_purchinvlines-rateigst   = 5.
        ELSEIF walines-TaxCode = 'I2'.
          wa_purchinvlines-ratecgst   = 6.
          wa_purchinvlines-ratesgst   = 6.
        ELSEIF walines-TaxCode = 'I6'.
          wa_purchinvlines-rateigst   = 12.
        ELSEIF walines-TaxCode = 'I3'.
          wa_purchinvlines-ratecgst   = 9.
          wa_purchinvlines-ratesgst   = 9.
        ELSEIF walines-TaxCode = 'I7'.
          wa_purchinvlines-rateigst   = 18.
        ELSEIF walines-TaxCode = 'I4'.
          wa_purchinvlines-ratecgst   = 14.
          wa_purchinvlines-ratesgst   = 14.
        ELSEIF walines-TaxCode = 'I8'.
          wa_purchinvlines-rateigst   = 28.
        ELSEIF walines-TaxCode = 'F5'.
          wa_purchinvlines-ratecgst   = 9.
          wa_purchinvlines-ratesgst   = 9.
        ELSEIF walines-TaxCode = 'H5'.
          wa_purchinvlines-ratecgst   = 9.
          wa_purchinvlines-ratesgst   = 9.
*          wa_purchinvlines-rateigst   = 18.
        ELSEIF walines-TaxCode = 'H6'.
          wa_purchinvlines-ratecgst   = 9.
*                   ls_response-Ugstrate = '9'.
*                   wa_purchinvlines-CESSRate = '18'.
        ELSEIF walines-TaxCode = 'H4'.
          wa_purchinvlines-rateigst   = 18.
*                   ls_response-Ugstrate = '9'.
*                   ls_response-CESSRate = '18'.
        ELSEIF walines-TaxCode = 'H3'.
          wa_purchinvlines-ratecgst   = 9.
*                   ls_response-Ugstrate = '9'.
*                   LS_RESPONSE-CESSRate = '18'.
        ELSEIF walines-TaxCode = 'J3'.
          wa_purchinvlines-ratecgst   = 9.
*                   ls_response-Ugstrate = '9'.
*                   LS_RESPONSE-CESSRate = '18'.
        ELSEIF walines-TaxCode = 'G6'.
          wa_purchinvlines-rateigst   = 18.
*                   ls_response-Ugstrate = '9'.
*                   ls_response-CESSRate = '18'.
        ELSEIF walines-TaxCode = 'G7'.
          wa_purchinvlines-ratecgst   = 9.
          wa_purchinvlines-ratesgst   = 9.
*                   ls_response-CESSRate = '18'.
        ELSEIF walines-TaxCode = 'MA'.
          wa_purchinvlines-rateigst   = 5.
        ELSEIF walines-TaxCode = 'MB'.
          wa_purchinvlines-rateigst   = 12.
        ELSEIF walines-TaxCode = 'MC'.
          wa_purchinvlines-rateigst   = 18.
        ELSEIF walines-TaxCode = 'MD'.
          wa_purchinvlines-rateigst   = 28.
        ENDIF.


        SELECT SINGLE FROM I_JournalEntry
            FIELDS DocumentDate ,
                DocumentReferenceID ,
                IsReversed
        WHERE OriginalReferenceDocument = @walines-SupplierInvoice
        INTO (  @wa_purchinvlines-journaldocumentdate , @wa_purchinvlines-journaldocumentrefid, @wa_purchinvlines-isreversed ).

        wa_purchinvlines-pouom                      = walines-PurchaseOrderPriceUnit.
        wa_purchinvlines-poqty                      = walines-QuantityInPurchaseOrderUnit.
        wa_purchinvlines-netamount                  = walines-SupplierInvoiceItemAmount.
*        IF walines-IsSubsequentDebitCredit = 'X'.
*          wa_purchinvlines-netamount              =   walines-SupplierInvoiceItemAmount * -1.
*        ELSE.

*        ENDIF.
*            wa_purchinvlines-basicrate                  = round( val = wa_purchinvlines-netamount / wa_purchinvlines-poqty dec = 2 ).

        IF walines-TaxCode = 'N0'.
          wa_purchinvlines-ratendcgst   = 0.
          wa_purchinvlines-ratendsgst   = 0.
        ELSEIF walines-TaxCode = 'N9'.
          wa_purchinvlines-ratendigst   = 0.
        ELSEIF walines-TaxCode = 'N1'.
          wa_purchinvlines-ratendcgst   = '2.5'.
          wa_purchinvlines-ratendsgst   = '2.5'.
          wa_purchinvlines-ndcgst = wa_purchinvlines-netamount * '0.025' * lv_signval.
          wa_purchinvlines-ndsgst = wa_purchinvlines-netamount * '0.025' * lv_signval.
        ELSEIF walines-TaxCode = 'N5'.
          wa_purchinvlines-ratendigst   = 5.
          wa_purchinvlines-ndigst = wa_purchinvlines-netamount * '0.05' * lv_signval.
        ELSEIF walines-TaxCode = 'N2'.
          wa_purchinvlines-ratendcgst   = 6.
          wa_purchinvlines-ratendsgst   = 6.
          wa_purchinvlines-ndcgst = wa_purchinvlines-netamount * '0.06' * lv_signval.
          wa_purchinvlines-ndsgst = wa_purchinvlines-netamount * '0.06' * lv_signval.
        ELSEIF walines-TaxCode = 'N6'.
          wa_purchinvlines-ratendigst   = 12.
          wa_purchinvlines-ndigst = wa_purchinvlines-netamount * '0.12' * lv_signval.
        ELSEIF walines-TaxCode = 'N3'.
          wa_purchinvlines-ratendcgst   = 9.
          wa_purchinvlines-ratendsgst   = 9.
          wa_purchinvlines-ndcgst = wa_purchinvlines-netamount * '0.09' * lv_signval.
          wa_purchinvlines-ndsgst = wa_purchinvlines-netamount * '0.09' * lv_signval.
        ELSEIF walines-TaxCode = 'N7'.
          wa_purchinvlines-ratendigst   = 18.
          wa_purchinvlines-ndigst = wa_purchinvlines-netamount * '0.18' * lv_signval.
*          wa_purchinvlines-taxamount =
        ELSEIF walines-TaxCode = 'N4'.
          wa_purchinvlines-ratendcgst   = 14.
          wa_purchinvlines-ratendsgst   = 14.
          wa_purchinvlines-ndcgst = wa_purchinvlines-netamount * '0.14' * lv_signval.
          wa_purchinvlines-ndsgst = wa_purchinvlines-netamount * '0.14' * lv_signval.
        ELSEIF walines-TaxCode = 'N8'.
          wa_purchinvlines-ratendigst   = 28.
          wa_purchinvlines-ndigst = wa_purchinvlines-netamount * '0.28' * lv_signval.
        ENDIF.


        IF wa_purchinvlines-ndcgst IS NOT INITIAL OR wa_purchinvlines-ndigst IS NOT INITIAL OR wa_purchinvlines-ndsgst IS NOT INITIAL.
          wa_purchinvlines-cgst = 0.
          wa_purchinvlines-igst = 0.
          wa_purchinvlines-sgst = 0.
        ENDIF.

        wa_purchinvlines-taxamount                  = wa_purchinvlines-igst + wa_purchinvlines-sgst + wa_purchinvlines-ndigst +
                                                        wa_purchinvlines-ndsgst +  wa_purchinvlines-ndcgst + wa_purchinvlines-cgst.
        wa_purchinvlines-totalamount                = wa_purchinvlines-taxamount + wa_purchinvlines-netamount.

*        IF wa_purchinvlines-ratendcgst IS NOT INITIAL OR wa_purchinvlines-ratendigst IS NOT INITIAL .
*          wa_purchinvlines-totalamount = wa_purchinvlines-netamount + wa_purchinvlines-ndcgst + wa_purchinvlines-ndsgst + wa_purchinvlines-ndigst.
*        ENDIF.

        SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
        FIELDS
            a~PurchaseOrderItem, a~SupplierInvoiceItem,a~SuplrInvcDeliveryCostCndnType,
            a~PurchaseOrder, a~SupplierInvoiceItemAmount, a~taxcode,
            a~FreightSupplier
        WHERE a~SupplierInvoice = @waheader-SupplierInvoice
          AND a~FiscalYear = @waheader-FiscalYear
          AND a~PurchaseOrderItem = @walines-PurchaseOrderItem
          AND a~SuplrInvcDeliveryCostCndnType <> ''
          INTO TABLE @DATA(ltsublines).

        wa_purchinvlines-discount                   = 0.
        wa_purchinvlines-freight                    = 0.
        wa_purchinvlines-insurance                  = 0.
        wa_purchinvlines-ecs                        = 0.
        wa_purchinvlines-epf                        = 0.
        wa_purchinvlines-othercharges               = 0.
        wa_purchinvlines-packaging                  = 0.
        lv_deliverycostamount                       = 0.
        LOOP AT ltsublines INTO DATA(wasublines).


          IF wasublines-SuplrInvcDeliveryCostCndnType = 'ZFRV'.
*                       Freight
            wa_purchinvlines-freight += wasublines-SupplierInvoiceItemAmount.
            wa_purchinvlines-localfreightcharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'FQU1'.
*                       Freight
            wa_purchinvlines-freight += wasublines-SupplierInvoiceItemAmount.
            wa_purchinvlines-localfreightcharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'FVA1'.
*                       Freight
            wa_purchinvlines-freight += wasublines-SupplierInvoiceItemAmount.
            wa_purchinvlines-localfreightcharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZINP'.
*                       Insurance Value
            wa_purchinvlines-insurance11 += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZINV'.
*                       Insurance Value
            wa_purchinvlines-insurance11 += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZECS'.
*                       ECS
            wa_purchinvlines-ecs += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZEPF'.
*                       EPF
            wa_purchinvlines-epf += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZDCP'.
*                       Discount
*            IF walines-IsSubsequentDebitCredit = 'X'.
*              wa_purchinvlines-discount += walines-SupplierInvoiceItemAmount * -1.
*            ELSE.
            wa_purchinvlines-discount += wasublines-SupplierInvoiceItemAmount.
*            ENDIF.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZDCV'.
*                       Discount
*            IF walines-IsSubsequentDebitCredit = 'X'.
*              wa_purchinvlines-discount += walines-SupplierInvoiceItemAmount * -1.
*            ELSE.
            wa_purchinvlines-discount += wasublines-SupplierInvoiceItemAmount.
*            ENDIF.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZCD1'.
*                       Discount
*            IF walines-IsSubsequentDebitCredit = 'X'.
*              wa_purchinvlines-discount += walines-SupplierInvoiceItemAmount * -1.
*            ELSE.
            wa_purchinvlines-discount += wasublines-SupplierInvoiceItemAmount.
*            ENDIF.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZDCQ'.
*                       Discount
*            IF walines-IsSubsequentDebitCredit = 'X'.
*              wa_purchinvlines-discount += walines-SupplierInvoiceItemAmount * -1.
*            ELSE.
            wa_purchinvlines-discount += wasublines-SupplierInvoiceItemAmount.
*            ENDIF.

          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZOTH'.
*                       Other Charges
            wa_purchinvlines-othercharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZPKG'.
*                       Packaging & Forwarding Charges
            wa_purchinvlines-packaging += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZOFV'.
*                       Ocean Freight Charges
            wa_purchinvlines-oceanfreightcharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZFLV'.
*                       For-Land Charges
            wa_purchinvlines-forlandcharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'JCDB'.
*                       Custom Duty Charges
            wa_purchinvlines-customdutycharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'JSWC'.
*                       Social Welfare Charges
            wa_purchinvlines-socialwelfarecharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZCMP' OR wasublines-SuplrInvcDeliveryCostCndnType = 'ZCMQ'.
*                       Commercial Charges
            wa_purchinvlines-commissioncharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZIHV'.
*                       InLand Charges
            wa_purchinvlines-inlandcharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZCHA'.
*                       CHA Charges
            wa_purchinvlines-carrierhandcharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZDMV'.
*                       Demmurage Charges
            wa_purchinvlines-demmuragecharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZPFP'  .
*                       Packing Charges
            wa_purchinvlines-packagingcharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZPFV'  .
*                       Packing Charges
            wa_purchinvlines-packagingcharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZLDV'  .
*                       Load Charges
            wa_purchinvlines-loadingcharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZULV'  .
*                       UnLoad Charges
            wa_purchinvlines-unloadingcharges += wasublines-SupplierInvoiceItemAmount.
          ELSE.
            wa_purchinvlines-othercharges += wasublines-SupplierInvoiceItemAmount.

          ENDIF.

          IF wasublines-TaxCode IS NOT INITIAL.

            DATA lv_chrgrateigst TYPE p DECIMALS 2.
            DATA lv_chrgratecgst TYPE p DECIMALS 2.
            DATA lv_chrgratesgst TYPE p DECIMALS 2.
            DATA lv_chrgratendigst TYPE p DECIMALS 2.
            DATA lv_chrgratendcgst TYPE p DECIMALS 2.
            DATA lv_chrgratendsgst TYPE p DECIMALS 2.

            lv_chrgrateigst = 0.
            lv_chrgratecgst = 0.
            lv_chrgratesgst = 0.
            lv_chrgratendigst = 0.
            lv_chrgratendcgst = 0.
            lv_chrgratendsgst = 0.

            IF wasublines-TaxCode = 'I0'.
              lv_chrgratecgst   = 0.
              lv_chrgratesgst   = 0.
            ELSEIF wasublines-TaxCode = 'I9'.
              lv_chrgrateigst   = 0.
            ELSEIF wasublines-TaxCode = 'I1'.
              lv_chrgratecgst   = '2.5'.
              lv_chrgratesgst   = '2.5'.
            ELSEIF wasublines-TaxCode = 'I5'.
              lv_chrgrateigst   = 5.
            ELSEIF wasublines-TaxCode = 'I2'.
              lv_chrgratecgst   = 6.
              lv_chrgratesgst   = 6.
            ELSEIF wasublines-TaxCode = 'I6'.
              lv_chrgrateigst   = 12.
            ELSEIF wasublines-TaxCode = 'I3'.
              lv_chrgratecgst   = 9.
              lv_chrgratesgst   = 9.
            ELSEIF wasublines-TaxCode = 'I7'.
              lv_chrgrateigst   = 18.
            ELSEIF wasublines-TaxCode = 'I4'.
              lv_chrgratecgst   = 14.
              lv_chrgratesgst   = 14.
            ELSEIF wasublines-TaxCode = 'I8'.
              lv_chrgrateigst   = 28.
            ELSEIF wasublines-TaxCode = 'F5'.
              lv_chrgratecgst   = 9.
              lv_chrgratesgst   = 9.
            ELSEIF wasublines-TaxCode = 'H5'.
              lv_chrgratecgst   = 9.
              lv_chrgratesgst   = 9.
            ELSEIF wasublines-TaxCode = 'H6'.   "H6
              lv_chrgratecgst   = 9.
              lv_chrgratesgst   = 9.
            ELSEIF wasublines-TaxCode = 'H4'.
              lv_chrgrateigst   = 18.
            ELSEIF wasublines-TaxCode = 'H3'.   "H3
              lv_chrgratecgst   = 9.
              lv_chrgratesgst   = 9.
            ELSEIF wasublines-TaxCode = 'J3'.
              lv_chrgratecgst   = 9.
              lv_chrgratesgst   = 9.
            ELSEIF wasublines-TaxCode = 'G6'.
              lv_chrgrateigst   = 18.
            ELSEIF wasublines-TaxCode = 'G7'.
              lv_chrgratecgst   = 9.
              lv_chrgratesgst   = 9.
            ELSEIF wasublines-TaxCode = 'MA'.
              lv_chrgrateigst   = 5.
            ELSEIF wasublines-TaxCode = 'MB'.
              lv_chrgrateigst   = 12.
            ELSEIF wasublines-TaxCode = 'MC'.
              lv_chrgrateigst   = 18.
            ELSEIF wasublines-TaxCode = 'MD'.
              lv_chrgrateigst   = 28.
            ENDIF.

            IF wasublines-TaxCode = 'N0'.
              lv_chrgratendcgst   = 0.
              lv_chrgratendsgst   = 0.
            ELSEIF wasublines-TaxCode = 'N9'.
              lv_chrgratendigst   = 0.
            ELSEIF wasublines-TaxCode = 'N1'.
              lv_chrgratendcgst   = '2.5'.
              lv_chrgratendsgst   = '2.5'.
            ELSEIF wasublines-TaxCode = 'N5'.
              lv_chrgratendigst   = 5.
            ELSEIF wasublines-TaxCode = 'N2'.
              lv_chrgratendcgst   = 6.
              lv_chrgratendsgst   = 6.
            ELSEIF wasublines-TaxCode = 'N6'.
              lv_chrgratendigst   = 12.
            ELSEIF wasublines-TaxCode = 'N3'.
              lv_chrgratendcgst   = 9.
              lv_chrgratendsgst   = 9.
            ELSEIF wasublines-TaxCode = 'N7'.
              lv_chrgratendigst   = 18.
            ELSEIF wasublines-TaxCode = 'N4'.
              lv_chrgratendcgst   = 14.
              lv_chrgratendsgst   = 14.
            ELSEIF wasublines-TaxCode = 'N8'.
              lv_chrgratendigst   = 28.
            ENDIF.

            IF lv_chrgrateigst IS NOT INITIAL.
              wa_purchinvlines-igst +=   lv_signval * wasublines-SupplierInvoiceItemAmount *  lv_chrgrateigst / 100 .
              wa_purchinvlines-taxamount += lv_signval * wasublines-SupplierInvoiceItemAmount *  lv_chrgrateigst / 100 .
              lv_deliverycostamount += wasublines-SupplierInvoiceItemAmount.
            ENDIF.
            IF lv_chrgratecgst IS NOT INITIAL.
              wa_purchinvlines-cgst += lv_signval *  wasublines-SupplierInvoiceItemAmount *  lv_chrgratecgst  / 100 .
              wa_purchinvlines-taxamount += lv_signval *  wasublines-SupplierInvoiceItemAmount *  lv_chrgratecgst / 100 .
              lv_deliverycostamount += wasublines-SupplierInvoiceItemAmount.
            ENDIF.
            IF lv_chrgratesgst IS NOT INITIAL.
              wa_purchinvlines-sgst += lv_signval *  wasublines-SupplierInvoiceItemAmount *  lv_chrgratesgst / 100 .
              wa_purchinvlines-taxamount += lv_signval *  wasublines-SupplierInvoiceItemAmount *  lv_chrgratesgst / 100 .
            ENDIF.
            IF lv_chrgratendigst IS NOT INITIAL.
              wa_purchinvlines-ndigst += lv_signval * wasublines-SupplierInvoiceItemAmount *  lv_chrgratendigst / 100 .
              wa_purchinvlines-taxamount += lv_signval * wasublines-SupplierInvoiceItemAmount *  lv_chrgratendigst / 100 .
              lv_deliverycostamount += wasublines-SupplierInvoiceItemAmount.
            ENDIF.
            IF lv_chrgratendcgst IS NOT INITIAL.
              wa_purchinvlines-ndcgst += lv_signval * wasublines-SupplierInvoiceItemAmount *  lv_chrgratendcgst / 100 .
              wa_purchinvlines-taxamount += lv_signval * wasublines-SupplierInvoiceItemAmount *  lv_chrgratendcgst / 100 .
              lv_deliverycostamount += wasublines-SupplierInvoiceItemAmount.
            ENDIF.
            IF lv_chrgratendsgst IS NOT INITIAL.
              wa_purchinvlines-ndsgst += lv_signval * wasublines-SupplierInvoiceItemAmount *  lv_chrgratendsgst / 100 .
              wa_purchinvlines-taxamount += lv_signval * wasublines-SupplierInvoiceItemAmount *  lv_chrgratendsgst / 100 .
            ENDIF.
          ENDIF.
        ENDLOOP.


        SELECT FROM  i_purorditmpricingelementapi01 AS a
        INNER JOIN I_PurchaseOrderItemAPI01 AS b ON a~PurchaseOrder = b~PurchaseOrder
                   AND a~PurchaseOrderItem = b~PurchaseOrderItem
        FIELDS a~conditioncurrency , a~ConditionAmount , b~PurchaseOrder
        WHERE b~PurchaseOrder = @walines-PurchaseOrder
        AND b~PurchaseOrderItem = @walines-PurchaseOrderItem
        AND a~ConditionType IN ( 'ZDCP' , 'ZDCV' , 'ZCD1' , 'ZDCQ' )
        INTO TABLE @DATA(it_discount2).
        LOOP AT it_discount2 INTO DATA(waDiscount).
*               DIscount
          wa_purchinvlines-discount += waDiscount-ConditionAmount.
        ENDLOOP.

        wa_purchinvlines-DeliveryCost = wa_purchinvlines-freight +
                                      wa_purchinvlines-insurance11 + wa_purchinvlines-ecs +
                                      wa_purchinvlines-epf + wa_purchinvlines-othercharges +
                                      wa_purchinvlines-packaging + wa_purchinvlines-oceanfreightcharges +
                                      wa_purchinvlines-carrierhandcharges + wa_purchinvlines-commissioncharges +
                                      wa_purchinvlines-customdutycharges + wa_purchinvlines-demmuragecharges +
                                      wa_purchinvlines-forlandcharges + wa_purchinvlines-inlandcharges +
                                      wa_purchinvlines-loadingcharges + wa_purchinvlines-socialwelfarecharges +
                                      wa_purchinvlines-unloadingcharges +
                                      wa_purchinvlines-packagingcharges.

        wa_purchinvlines-totalamount = abs( wa_purchinvlines-taxamount ) + wa_purchinvlines-netamount + wa_purchinvlines-DeliveryCost +
                                       wa_purchinvlines-rcmcgst + wa_purchinvlines-rcmsgst + wa_purchinvlines-rcmigst .
        wa_purchinvlines-netamount += lv_deliverycostamount.

        wa_purchinvlines-discount *= lv_signval .
        wa_purchinvlines-DeliveryCost *= lv_signval.
        wa_purchinvlines-freight *= lv_signval.
        wa_purchinvlines-insurance11 *= lv_signval.
        wa_purchinvlines-ecs *= lv_signval.
        wa_purchinvlines-epf *= lv_signval.
        wa_purchinvlines-othercharges *= lv_signval.
        wa_purchinvlines-oceanfreightcharges *= lv_signval.
        wa_purchinvlines-packaging *= lv_signval.
        wa_purchinvlines-carrierhandcharges *= lv_signval.
        wa_purchinvlines-commissioncharges *= lv_signval.
        wa_purchinvlines-customdutycharges *= lv_signval.
        wa_purchinvlines-demmuragecharges *= lv_signval.
        wa_purchinvlines-forlandcharges *= lv_signval.
        wa_purchinvlines-inlandcharges *= lv_signval.
        wa_purchinvlines-socialwelfarecharges *= lv_signval.
        wa_purchinvlines-loadingcharges *= lv_signval.
        wa_purchinvlines-unloadingcharges *= lv_signval.
        wa_purchinvlines-packagingcharges *= lv_signval.
        wa_purchinvlines-totalamount *= lv_signval.
        wa_purchinvlines-netamount *= lv_signval.
        wa_purchinvlines-rcmcgst *= lv_signval.
        wa_purchinvlines-rcmsgst *= lv_signval.
        wa_purchinvlines-rcmigst *= lv_signval.

        wa_purchinvlines-invoicingpartycodename = | { waheader-Supplier } - { waheader-SupplierName } |.
*            //For Reverse Document
        wa_purchinvlines-referencedocumentno = waheader-revdoc .

        CLEAR : waTransType , it_transtype.


        APPEND wa_purchinvlines TO lt_purchinvlines.
*    ********************* Added on 08.02.2025
        MODIFY zpurchinvlines FROM @wa_purchinvlines.
        CLEAR : wa_purchinvlines.
        CLEAR : wa_po, wa_tax, lv_taxitemacctgdocitemref, it_discount2.
      ENDLOOP.

***** For Non Product Entries

      SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
**********************************************
          LEFT JOIN I_PurchaseOrderItemAPI01 AS li ON a~PurchaseOrder = li~PurchaseOrder AND a~PurchaseOrderItem = li~PurchaseOrderItem
*            LEFT JOIN zmaterial_table AS li4 ON li~Material = li4~mat
          LEFT JOIN i_deliverydocumentitem AS li2 ON li~PurchaseOrder = li2~ReferenceSDDocument AND li~PurchaseOrderItem = li2~ReferenceSDDocumentItem
          LEFT JOIN i_deliverydocument AS li3 ON li2~DeliveryDocument = li3~DeliveryDocument
          LEFT JOIN I_SupplierInvoiceAPI01 AS li5 ON a~SupplierInvoice = li5~SupplierInvoice AND a~FiscalYear = li5~FiscalYear
          LEFT JOIN i_purchaseorderapi01 AS li6 ON li~PurchaseOrder = li6~PurchaseOrder
          LEFT JOIN I_Supplier AS li13 ON li6~Supplier = li13~Supplier
          LEFT JOIN I_MaterialDocumentHeader_2 AS li14 ON a~ReferenceDocument = li14~MaterialDocument AND a~ReferenceDocumentFiscalYear = li14~MaterialDocumentYear
          LEFT JOIN I_BusinessPartner AS li7 ON li6~Supplier = li7~BusinessPartner
          LEFT JOIN I_BusinessPartnerLegalFormText AS li8 ON li7~LegalForm = li8~LegalForm
          LEFT JOIN i_purchaseorderitemtp_2 AS li9 ON li~PurchaseOrder = li9~PurchaseOrder
          LEFT JOIN I_Requestforquotation_Api01 AS li10 ON li9~SupplierQuotation = li10~RequestForQuotation
          LEFT JOIN I_SupplierQuotation_Api01 AS li11 ON li9~SupplierQuotation = li11~SupplierQuotation
*    ********************************************
          FIELDS
              a~PurchaseOrderItem, a~SupplierInvoiceItem,
              a~PurchaseOrder, a~SupplierInvoiceItemAmount AS tax_amt, a~SupplierInvoiceItemAmount, a~taxcode,
              a~FreightSupplier , a~SupplierInvoice , a~FiscalYear , a~TaxJurisdiction, a~plant,
              a~PurchaseOrderItemMaterial AS material, a~QuantityInPurchaseOrderUnit, a~QtyInPurchaseOrderPriceUnit,
              a~PurchaseOrderQuantityUnit, PurchaseOrderPriceUnit, a~ReferenceDocument , a~ReferenceDocumentFiscalYear,
*    ***********************************************
              li~Plant AS plantcity, li~Plant AS plantpin, li3~DeliveryDocumentBySupplier, li5~DocumentDate,  "li4~trade_name,
              li8~LegalFormDescription, li9~SupplierQuotation, li10~RFQPublishingDate, li11~SupplierQuotation AS sq,
              li11~QuotationSubmissionDate, li5~PostingDate, li~NetPriceAmount, a~IsSubsequentDebitCredit, li~br_ncm
              , li6~Supplier, li13~SupplierFullName, li14~PostingDate AS MRNPostingDate, li~PurchaseOrderItemText
*    **********************************************
          WHERE a~SupplierInvoice = @waheader-SupplierInvoice
            AND a~FiscalYear = @waheader-FiscalYear
            AND a~SuplrInvcDeliveryCostCndnType <> ''
          ORDER BY a~PurchaseOrderItem, a~SupplierInvoiceItem
            INTO TABLE @DATA(ltlinesNp).


      IF ltlinesNp IS NOT INITIAL.

        IF ltlines IS NOT INITIAL.
          SELECT FROM I_Producttext AS a FIELDS
              a~ProductName, a~Product
          FOR ALL ENTRIES IN @ltlines
          WHERE a~Product = @ltlines-material AND a~Language = 'E'
              INTO TABLE @DATA(it_productNp).
        ENDIF.

        IF ltlines IS NOT INITIAL.
          SELECT FROM I_PurchaseOrderItemAPI01 AS a
              LEFT JOIN I_PurchaseOrderAPI01 AS b ON a~PurchaseOrdeR = b~PurchaseOrder
              FIELDS a~BaseUnit , b~PurchaseOrderType , b~PurchasingGroup , b~PurchasingOrganization ,
              b~PurchaseOrderDate , a~PurchaseOrder , a~PurchaseOrderItem , a~ProfitCenter
          FOR ALL ENTRIES IN @ltlines
          WHERE a~PurchaseOrder = @ltlines-PurchaseOrder AND a~PurchaseOrderItem = @ltlines-PurchaseOrderItem
              INTO TABLE @DATA(it_ponp).
        ENDIF.

        IF ltlines IS NOT INITIAL.
          SELECT FROM I_MaterialDocumentItem_2
              FIELDS MaterialDocument , PurchaseOrder , PurchaseOrderItem , QuantityInBaseUnit , PostingDate
          FOR ALL ENTRIES IN @ltlines
          WHERE MaterialDocument  = @ltlines-ReferenceDocument
              INTO TABLE @DATA(it_grnnp).
        ENDIF.
        IF ltlines IS NOT INITIAL.
          SELECT FROM I_taxcodetext
              FIELDS TaxCode , TaxCodeName
          FOR ALL ENTRIES IN @ltlines
          WHERE Language = 'E' AND taxcode = @ltlines-TaxCode
              INTO TABLE @DATA(it_taxnp).
        ENDIF.
*
*        SELECT FROM  i_purorditmpricingelementapi01 AS a LEFT JOIN I_PurchaseOrderAPI01 AS b ON
*                     a~PricingDocument = b~PricingDocument
**                               and a~PricingDocument = b~pr
*        FIELDS a~conditioncurrency , a~ConditionAmount , b~PurchaseOrder
*        FOR ALL ENTRIES IN @ltlinesNp
*        WHERE b~PurchaseOrder = @ltLinesNp-PurchaseOrder AND a~ConditionType IN ( 'ZDCP' , 'ZDCV' , 'ZCD1' , 'ZDCQ' )
*        INTO TABLE @DATA(it_discount1Np).
        SELECT a~conditioncurrency,
               a~ConditionAmount,
               b~PurchaseOrder
          FROM i_purorditmpricingelementapi01 AS a
          INNER JOIN I_PurchaseOrderAPI01 AS b
            ON a~PricingDocument = b~PricingDocument
          WHERE b~PurchaseOrder IN ( SELECT PurchaseOrder
                                       FROM @ltlinesNp AS a )
            AND a~ConditionType IN ( 'ZDCP', 'ZDCV', 'ZCD1', 'ZDCQ' )
          INTO TABLE @DATA(it_discount1Np).

      ENDIF.

      SELECT SINGLE FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
        FIELDS
          a~PurchaseOrderItem, a~SupplierInvoiceItem
          WHERE a~SupplierInvoice = @waheader-SupplierInvoice
            AND a~FiscalYear = @waheader-FiscalYear
            AND a~SuplrInvcDeliveryCostCndnType = ''
        INTO @DATA(ltlinesNpCheck).
      IF ltlinesnpcheck IS INITIAL.
        LOOP AT ltlinesNp INTO DATA(walinesNp).
          wa_purchinvlines-client                     = sy-mandt.
          wa_purchinvlines-companycode                = waheader-CompanyCode.
          wa_purchinvlines-fiscalyearvalue            = waheader-FiscalYear.
          wa_purchinvlines-supplierbillno             = waheader-SupplierInvoiceIDByInvcgParty.
          wa_purchinvlines-supplierinvoice            = waheader-SupplierInvoice.
          wa_purchinvlines-supplierinvoiceitem        = walinesNp-SupplierInvoiceItem.
          wa_purchinvlines-postingdate                = walinesNp-PostingDate.
*    ********************************* Item Level Fields Added ****************************
          wa_purchinvlines-plantcity                  = walinesNp-plantcity.
          wa_purchinvlines-plantpin                   = walinesNp-plantpin.
*                wa_purchinvlines-product_trade_name = walines-trade_name.
          wa_purchinvlines-vendor_invoice_no          = walinesNp-DeliveryDocumentBySupplier.
          wa_purchinvlines-vendor_invoice_date        = walinesNp-DocumentDate.
          wa_purchinvlines-plant                      = walines-Plant.
          wa_purchinvlines-vendor_type                = walinesNp-LegalFormDescription.
          wa_purchinvlines-rfqno                      = walinesNp-SupplierQuotation.
          wa_purchinvlines-rfqno                      = walinesNp-SupplierQuotation.
          wa_purchinvlines-rfqdate                    = walinesNp-RFQPublishingDate.
          wa_purchinvlines-supplierquotation          = walinesNp-sq.
          wa_purchinvlines-supplierquotationdate      = walinesNp-QuotationSubmissionDate.
          wa_purchinvlines-mrnquantityinbaseunit      = walinesNp-PostingDate.
          wa_purchinvlines-hsncode                    = walinesNp-br_ncm.
          wa_purchinvlines-supp_gst                   = waheader-supp_gst.
          wa_purchinvlines-suppliercode               = walinesNp-Supplier.
          wa_purchinvlines-suppliercodename           = waLinesNp-SupplierFullName ."| { walinesNp-Supplier } - { waLinesNp-SupplierFullName  } |.
          SELECT SINGLE FROM I_IN_BusinessPlaceTaxDetail AS a
              LEFT JOIN  I_Address_2  AS b ON a~AddressID = b~AddressID
              FIELDS
              a~BusinessPlaceDescription,
              a~IN_GSTIdentificationNumber,
              b~Street, b~PostalCode , b~CityName
          WHERE a~CompanyCode = @waheader-CompanyCode AND a~BusinessPlace = @walinesNp-Plant
          INTO ( @wa_purchinvlines-plantname, @wa_purchinvlines-plantgst, @wa_purchinvlines-plantadr, @wa_purchinvlines-plantpin,
              @wa_purchinvlines-plantcity ).

          wa_purchinvlines-product                    = walinesNp-material.
          IF walinesNp-material <> ''.
            READ TABLE it_productNp INTO DATA(wa_productNp) WITH KEY product = walinesNp-material.
            wa_purchinvlines-productname            = wa_productNp-ProductName.
          ELSE.
            wa_purchinvlines-productname            = walinesNp-PurchaseOrderItemText.
          ENDIF.

          wa_purchinvlines-purchaseorder              = walinesNp-PurchaseOrder.
          wa_purchinvlines-purchaseorderitem          = walinesNp-PurchaseOrderItem.
          CONCATENATE walinesNp-SupplierInvoice walinesNp-FiscalYear INTO wa_purchinvlines-originalreferencedocument.

          READ TABLE it_ponp INTO DATA(wa_poNp) WITH KEY PurchaseOrder = walinesNp-PurchaseOrder
                                                  PurchaseOrderItem = walinesNp-PurchaseOrderItem.

          wa_purchinvlines-baseunit                   = wa_poNp-BaseUnit.
          wa_purchinvlines-profitcenter               = wa_poNp-ProfitCenter.
          wa_purchinvlines-purchaseordertype          = wa_poNp-PurchaseOrderType.
          wa_purchinvlines-purchaseorderdate          = wa_poNp-PurchaseOrderDate.
          wa_purchinvlines-purchasingorganization     = wa_poNp-PurchasingOrganization.
          wa_purchinvlines-purchasinggroup            = wa_poNp-PurchasingGroup.
          wa_purchinvlines-basicrate                  = 0. "walines-NetPriceAmount.
          wa_purchinvlines-grnno                      = walinesNp-ReferenceDocument.
          wa_purchinvlines-mrnpostingdate             = walinesNp-mrnpostingdate.
          wa_purchinvlines-mrnquantityinbaseunit      = 0. "walines-QtyInPurchaseOrderPriceUnit.
*                READ TABLE it_grn INTO DATA(wa_grn) WITH KEY MaterialDocument = walines-ReferenceDocument.
*                    wa_purchinvlines-mrnquantityinbaseunit     = wa_grn-QuantityInBaseUnit.
          READ TABLE it_taxnp INTO DATA(wa_taxNp) WITH KEY     TaxCode = walinesNp-TaxCode.
          wa_purchinvlines-taxcodename                = wa_taxNp-TaxCodeName.
*            if walinesNp-IsSubsequentDebitCredit = 'X'.
*                wa_purchinvlines-isreversed = 'X'.
*            ENDIF.
          CONCATENATE walinesNp-PurchaseOrder walinesNp-PurchaseOrderItem INTO assignmentreference.

          SELECT SINGLE TaxItemAcctgDocItemRef, IN_HSNOrSACCode FROM i_operationalacctgdocitem
              WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear AND TaxItemAcctgDocItemRef IS NOT INITIAL
              AND AccountingDocumentItemType <> 'T'
              AND FiscalYear = @walinesNp-FiscalYear
              AND CompanyCode = @waheader-CompanyCode
              AND AccountingDocumentType = 'RE'
              AND AssignmentReference = @assignmentreference
              AND Product = @walinesNp-material
          INTO  (  @DATA(lv_TaxItemAcctgDocItemRefNp), @DATA(lv_HSNCodeNp) ).
          wa_purchinvlines-hsncode                    = lv_HSNCodeNp.

          SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
              WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
                  AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
                  AND AccountingDocumentItemType = 'T'
                  AND FiscalYear = @walinesNp-FiscalYear
                  AND CompanyCode = @waheader-CompanyCode
                  AND TransactionTypeDetermination = 'JII'
          INTO  @wa_purchinvlines-igst.

          IF wa_purchinvlines-igst IS INITIAL.
            SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
                WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
                    AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
                    AND AccountingDocumentItemType = 'T'
                    AND FiscalYear = @walinesNp-FiscalYear
                    AND CompanyCode = @waheader-CompanyCode
                    AND TransactionTypeDetermination = 'JIC'
            INTO  @wa_purchinvlines-cgst.

            SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
                WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
                    AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
                    AND AccountingDocumentItemType = 'T'
                    AND FiscalYear = @walinesNp-FiscalYear
                    AND CompanyCode = @waheader-CompanyCode
                    AND TransactionTypeDetermination = 'JIS'
            INTO  @wa_purchinvlines-sgst.
          ENDIF.

          SELECT  SINGLE AmountInCompanyCodeCurrency  FROM i_operationalacctgdocitem
              WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
                  AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
                  AND AccountingDocumentItemType = 'T'
                  AND FiscalYear = @walinesNp-FiscalYear
                  AND CompanyCode = @waheader-CompanyCode
                  AND TransactionTypeDetermination = 'JRI'
          INTO  @wa_purchinvlines-rcmigst .
*            wa_purchinvlines-rcmigst = wa_purchinvlines-rcmigst * -1 .
          IF wa_purchinvlines-rcmigst IS INITIAL.
            SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
                WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
                    AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
                    AND AccountingDocumentItemType = 'T'
                    AND FiscalYear = @walinesNp-FiscalYear
                    AND CompanyCode = @waheader-CompanyCode
                    AND TransactionTypeDetermination = 'JRC'
            INTO  @wa_purchinvlines-rcmcgst.
*              wa_purchinvlines-rcmcgst *= -1 .

            SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
                WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
                    AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
                    AND AccountingDocumentItemType = 'T'
                    AND FiscalYear = @walinesNp-FiscalYear
                    AND CompanyCode = @waheader-CompanyCode
                    AND TransactionTypeDetermination = 'JRS'
            INTO  @wa_purchinvlines-rcmsgst.
*              wa_purchinvlines-rcmcgst *= -1 .
            SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
                WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
                    AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
                    AND AccountingDocumentItemType = 'T'
                    AND FiscalYear = @walinesNp-FiscalYear
                    AND CompanyCode = @waheader-CompanyCode
                    AND TransactionTypeDetermination = 'JIM'
            INTO  @wa_purchinvlines-igst.

          ENDIF.


          """"""""""""""""""""""""""""""""""""""""""""""""for rate percent.
          wa_purchinvlines-rateigst   = 0.
          wa_purchinvlines-ratecgst   = 0.
          wa_purchinvlines-ratesgst   = 0.
          wa_purchinvlines-ratendigst = 0.
          wa_purchinvlines-ratendcgst = 0.
          wa_purchinvlines-ratendsgst = 0.
          IF walinesNp-TaxCode = 'I0'.
            wa_purchinvlines-ratecgst   = 0.
            wa_purchinvlines-ratesgst   = 0.
          ELSEIF walinesNp-TaxCode = 'I9'.
            wa_purchinvlines-rateigst   = 0.
          ELSEIF walinesNp-TaxCode = 'I1'.
            wa_purchinvlines-ratecgst   = '2.5'.
            wa_purchinvlines-ratesgst   = '2.5'.
          ELSEIF walinesNp-TaxCode = 'I5'.
            wa_purchinvlines-rateigst   = 5.
          ELSEIF walinesNp-TaxCode = 'I2'.
            wa_purchinvlines-ratecgst   = 6.
            wa_purchinvlines-ratesgst   = 6.
          ELSEIF walinesNp-TaxCode = 'I6'.
            wa_purchinvlines-rateigst   = 12.
          ELSEIF walinesNp-TaxCode = 'I3'.
            wa_purchinvlines-ratecgst   = 9.
            wa_purchinvlines-ratesgst   = 9.
          ELSEIF walinesNp-TaxCode = 'I7'.
            wa_purchinvlines-rateigst   = 18.
          ELSEIF walinesNp-TaxCode = 'I4'.
            wa_purchinvlines-ratecgst   = 14.
            wa_purchinvlines-ratesgst   = 14.
          ELSEIF walinesNp-TaxCode = 'I8'.
            wa_purchinvlines-rateigst   = 28.
          ELSEIF walinesNp-TaxCode = 'F5'.
            wa_purchinvlines-ratecgst   = 9.
            wa_purchinvlines-ratesgst   = 9.
          ELSEIF walinesNp-TaxCode = 'H5'.
            wa_purchinvlines-ratecgst   = 9.
            wa_purchinvlines-ratesgst   = 9.
            wa_purchinvlines-rateigst   = 18.
          ELSEIF walinesNp-TaxCode = 'H6'.
            wa_purchinvlines-ratecgst   = 9.
*                       ls_response-Ugstrate = '9'.
*                       wa_purchinvlines-CESSRate = '18'.
          ELSEIF walinesNp-TaxCode = 'H4'.
            wa_purchinvlines-rateigst   = 18.
*                       ls_response-Ugstrate = '9'.
*                       ls_response-CESSRate = '18'.
          ELSEIF walinesNp-TaxCode = 'H3'.
            wa_purchinvlines-ratecgst   = 9.
*                       ls_response-Ugstrate = '9'.
*                       LS_RESPONSE-CESSRate = '18'.
          ELSEIF walinesNp-TaxCode = 'J3'.
            wa_purchinvlines-ratecgst   = 9.
*                       ls_response-Ugstrate = '9'.
*                       LS_RESPONSE-CESSRate = '18'.
          ELSEIF walinesNp-TaxCode = 'G6'.
            wa_purchinvlines-rateigst   = 18.
*                       ls_response-Ugstrate = '9'.
*                       ls_response-CESSRate = '18'.
          ELSEIF walinesNp-TaxCode = 'G7'.
            wa_purchinvlines-ratecgst   = 9.
            wa_purchinvlines-ratesgst   = 9.
*                       ls_response-CESSRate = '18'.
          ELSEIF walinesNp-TaxCode = 'MA'.
            wa_purchinvlines-rateigst   = 5.
          ELSEIF walinesNp-TaxCode = 'MB'.
            wa_purchinvlines-rateigst   = 12.
          ELSEIF walinesNp-TaxCode = 'MC'.
            wa_purchinvlines-rateigst   = 18.
          ELSEIF walinesNp-TaxCode = 'MD'.
            wa_purchinvlines-rateigst   = 28.
          ENDIF.


          SELECT SINGLE FROM I_JournalEntry
              FIELDS DocumentDate ,
                  DocumentReferenceID ,
                  IsReversed
          WHERE OriginalReferenceDocument = @walinesNp-SupplierInvoice
          INTO (  @wa_purchinvlines-journaldocumentdate , @wa_purchinvlines-journaldocumentrefid, @wa_purchinvlines-isreversed ).

          wa_purchinvlines-pouom                      = walinesNp-PurchaseOrderPriceUnit.
          wa_purchinvlines-poqty                      = walinesNp-QuantityInPurchaseOrderUnit.
          IF walinesNp-IsSubsequentDebitCredit = 'X'.
            wa_purchinvlines-netamount              =   0. "walinesNp-SupplierInvoiceItemAmount * -1.
          ELSE.
            wa_purchinvlines-netamount                  = 0. "walinesNp-SupplierInvoiceItemAmount.
          ENDIF.
*                wa_purchinvlines-basicrate                  = round( val = wa_purchinvlines-netamount / wa_purchinvlines-poqty dec = 2 ).


*           For Functional Currency
*            SELECT FROM I_OperationalAcctgDocItem AS a
*            FIELDS
*                a~FunctionalCurrency, a~TransactionCurrency
*                WHERE a~OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
*              AND a~TransactionCurrency = @walinesnp-SupplierInvoiceItemAmount
*            INTO @DATA(ltcurrencyINRNp).
*            ENDSELECT.
          IF walines-TaxCode = 'N0'.
            wa_purchinvlines-ratendcgst   = 0.
            wa_purchinvlines-ratendsgst   = 0.
          ELSEIF walines-TaxCode = 'N9'.
            wa_purchinvlines-ratendigst   = 0.
          ELSEIF walines-TaxCode = 'N1'.
            wa_purchinvlines-ratendcgst   = '2.5'.
            wa_purchinvlines-ratendsgst   = '2.5'.
            wa_purchinvlines-ndcgst = wa_purchinvlines-netamount * '0.025'.
            wa_purchinvlines-ndsgst = wa_purchinvlines-netamount * '0.025'.
          ELSEIF walines-TaxCode = 'N5'.
            wa_purchinvlines-ratendigst   = 5.
            wa_purchinvlines-ndigst = wa_purchinvlines-netamount * '0.05'.
          ELSEIF walines-TaxCode = 'N2'.
            wa_purchinvlines-ratendcgst   = 6.
            wa_purchinvlines-ratendsgst   = 6.
            wa_purchinvlines-ndcgst = wa_purchinvlines-netamount * '0.06'.
            wa_purchinvlines-ndsgst = wa_purchinvlines-netamount * '0.06'.
          ELSEIF walines-TaxCode = 'N6'.
            wa_purchinvlines-ratendigst   = 12.
            wa_purchinvlines-ndigst = wa_purchinvlines-netamount * '0.12'.
          ELSEIF walines-TaxCode = 'N3'.
            wa_purchinvlines-ratendcgst   = 9.
            wa_purchinvlines-ratendsgst   = 9.
            wa_purchinvlines-ndcgst = wa_purchinvlines-netamount * '0.09'.
            wa_purchinvlines-ndsgst = wa_purchinvlines-netamount * '0.09'.
          ELSEIF walines-TaxCode = 'N7'.
            wa_purchinvlines-ratendigst   = 18.
            wa_purchinvlines-ndigst = wa_purchinvlines-netamount * '0.18'.
          ELSEIF walines-TaxCode = 'N4'.
            wa_purchinvlines-ratendcgst   = 14.
            wa_purchinvlines-ratendsgst   = 14.
            wa_purchinvlines-ndcgst = wa_purchinvlines-netamount * '0.14'.
            wa_purchinvlines-ndsgst = wa_purchinvlines-netamount * '0.14'.
          ELSEIF walines-TaxCode = 'N8'.
            wa_purchinvlines-ratendigst   = 28.
            wa_purchinvlines-ndigst = wa_purchinvlines-netamount * '0.28'.
          ENDIF.

          IF wa_purchinvlines-ndcgst IS NOT INITIAL OR wa_purchinvlines-ndigst IS NOT INITIAL OR wa_purchinvlines-ndsgst IS NOT INITIAL.
            wa_purchinvlines-cgst = ''.
            wa_purchinvlines-igst = ''.
            wa_purchinvlines-sgst = ''.
          ENDIF.

          wa_purchinvlines-taxamount                  = wa_purchinvlines-igst + wa_purchinvlines-sgst + wa_purchinvlines-ndcgst +
                                                        wa_purchinvlines-cgst + wa_purchinvlines-ndigst + wa_purchinvlines-ndsgst.
          wa_purchinvlines-totalamount                = wa_purchinvlines-netamount.
*          IF wa_purchinvlines-ratendcgst IS NOT INITIAL OR wa_purchinvlines-ratendigst IS NOT INITIAL .
*            wa_purchinvlines-totalamount = wa_purchinvlines-netamount + wa_purchinvlines-ndcgst + wa_purchinvlines-ndsgst + wa_purchinvlines-ndigst.
*          ENDIF.


          SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
          FIELDS
              a~PurchaseOrderItem, a~SupplierInvoiceItem,a~SuplrInvcDeliveryCostCndnType,
              a~PurchaseOrder, a~SupplierInvoiceItemAmount, a~taxcode,
              a~FreightSupplier
          WHERE a~SupplierInvoice = @waheader-SupplierInvoice
            AND a~FiscalYear = @waheader-FiscalYear
            AND a~PurchaseOrderItem = @walinesNp-PurchaseOrderItem
            AND a~SuplrInvcDeliveryCostCndnType <> ''
            AND a~SupplierInvoiceItem = @walinesnp-SupplierInvoiceItem
            INTO TABLE @DATA(ltsublinesNp).

          wa_purchinvlines-discount                   = 0.
          wa_purchinvlines-freight                    = 0.
          wa_purchinvlines-insurance                  = 0.
          wa_purchinvlines-ecs                        = 0.
          wa_purchinvlines-epf                        = 0.
          wa_purchinvlines-othercharges               = 0.
          wa_purchinvlines-packaging                  = 0.
          lv_deliverycostamount                       = 0.
          LOOP AT ltsublinesNp INTO DATA(wasublinesNp).
            IF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZFRV'.
*                           Freight
              wa_purchinvlines-freight += wasublinesNp-SupplierInvoiceItemAmount.
              wa_purchinvlines-localfreightcharges += wasublinesNp-SupplierInvoiceItemAmount.
              IF wa_purchinvlines-ratendigst IS NOT INITIAL .
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-localfreightcharges *  wa_purchinvlines-ratendigst ) / 100 ).
              ELSEIF wa_purchinvlines-ratendcgst IS NOT INITIAL.
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-localfreightcharges *  wa_purchinvlines-ratendcgst ) / 100 ).
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-localfreightcharges *  wa_purchinvlines-ratendsgst ) / 100 ).
              ELSEIF wa_purchinvlines-rateigst IS NOT INITIAL.
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-localfreightcharges *  wa_purchinvlines-rateigst ) / 100 ).
              ELSEIF wa_purchinvlines-ratecgst IS NOT INITIAL.
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-localfreightcharges *  wa_purchinvlines-ratecgst ) / 100 ).
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-localfreightcharges *  wa_purchinvlines-ratesgst ) / 100 ).
              ENDIF.

              IF ( wa_purchinvlines-ratecgst + wa_purchinvlines-ratesgst + wa_purchinvlines-rateigst +
                   wa_purchinvlines-ratendigst + wa_purchinvlines-ratendcgst + wa_purchinvlines-ratendsgst ) NE 0.

                lv_deliverycostamount       +=  wa_purchinvlines-localfreightcharges.

              ENDIF.

            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'FQU1'.
*                           Freight
              wa_purchinvlines-freight += wasublinesNp-SupplierInvoiceItemAmount.
              wa_purchinvlines-localfreightcharges += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'FVA1'.
*                           Freight
              wa_purchinvlines-freight += wasublinesNp-SupplierInvoiceItemAmount.
              wa_purchinvlines-localfreightcharges += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZINP'.
*                           Insurance Value
              wa_purchinvlines-insurance11 += wasublinesNp-SupplierInvoiceItemAmount.

              IF wa_purchinvlines-ratendigst IS NOT INITIAL .
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-insurance11 *  wa_purchinvlines-ratendigst ) / 100 ).
              ELSEIF wa_purchinvlines-ratendcgst IS NOT INITIAL.
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-insurance11 *  wa_purchinvlines-ratendcgst ) / 100 ).
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-insurance11 *  wa_purchinvlines-ratendsgst ) / 100 ).
              ELSEIF wa_purchinvlines-rateigst IS NOT INITIAL.
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-insurance11 *  wa_purchinvlines-rateigst ) / 100 ).
              ELSEIF wa_purchinvlines-ratecgst IS NOT INITIAL.
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-insurance11 *  wa_purchinvlines-ratecgst ) / 100 ).
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-insurance11 *  wa_purchinvlines-ratesgst ) / 100 ).
              ENDIF.

              IF ( wa_purchinvlines-ratecgst + wa_purchinvlines-ratesgst + wa_purchinvlines-rateigst +
                   wa_purchinvlines-ratendigst + wa_purchinvlines-ratendcgst + wa_purchinvlines-ratendsgst ) NE 0.

                lv_deliverycostamount       +=  wa_purchinvlines-insurance11.

              ENDIF.

            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZINV'.
*                           Insurance Value
              wa_purchinvlines-insurance11 += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZECS'.
*                           ECS
              wa_purchinvlines-ecs += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZEPF'.
*                           EPF
              wa_purchinvlines-epf += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZDCP'.
*                           Discount
              IF walines-IsSubsequentDebitCredit = 'X'.
                wa_purchinvlines-discount += walinesNp-SupplierInvoiceItemAmount * -1.
              ELSE.
                wa_purchinvlines-discount += wasublinesNp-SupplierInvoiceItemAmount.
              ENDIF.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZDCV'.
*                           Discount
              IF walines-IsSubsequentDebitCredit = 'X'.
                wa_purchinvlines-discount += walinesNp-SupplierInvoiceItemAmount * -1.
              ELSE.
                wa_purchinvlines-discount += wasublinesNp-SupplierInvoiceItemAmount.
              ENDIF.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZCD1'.
*                           Discount
              IF walines-IsSubsequentDebitCredit = 'X'.
                wa_purchinvlines-discount += walinesNp-SupplierInvoiceItemAmount * -1.
              ELSE.
                wa_purchinvlines-discount += wasublinesNp-SupplierInvoiceItemAmount.
              ENDIF.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZDCQ'.
*                           Discount
              IF walines-IsSubsequentDebitCredit = 'X'.
                wa_purchinvlines-discount += walinesNp-SupplierInvoiceItemAmount * -1.
              ELSE.
                wa_purchinvlines-discount += wasublinesNp-SupplierInvoiceItemAmount.
              ENDIF.

            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZOTH'.
*                           Other Charges
              wa_purchinvlines-othercharges += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZPKG'.
*                           Packaging & Forwarding Charges
              wa_purchinvlines-packaging += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZOFV'.
*                           Ocean Freight Charges
              wa_purchinvlines-oceanfreightcharges += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZFLV'.
*                           For-Land Charges
              wa_purchinvlines-forlandcharges += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'JCDB'.
*                           Custom Duty Charges
              wa_purchinvlines-customdutycharges += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'JSWC'.
*                           Social Welfare Charges
              wa_purchinvlines-socialwelfarecharges += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZCMP' OR wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZCMQ' .
*                           Commercial Charges
              wa_purchinvlines-commissioncharges += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZIHV'.
*                           InLand Charges
              wa_purchinvlines-inlandcharges += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZCHA'.
*                           CHA Charges
              wa_purchinvlines-carrierhandcharges += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZDMV'.
*                           Demmurage Charges
              wa_purchinvlines-demmuragecharges += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZPFP'  .
*                           Packing Charges
              wa_purchinvlines-packagingcharges += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZPFV'  .
*                           Packing Charges
              wa_purchinvlines-packagingcharges += wasublinesNp-SupplierInvoiceItemAmount.

              IF wa_purchinvlines-ratendigst IS NOT INITIAL .
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-packagingcharges *  wa_purchinvlines-ratendigst ) / 100 ).
              ELSEIF wa_purchinvlines-ratendcgst IS NOT INITIAL.
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-packagingcharges *  wa_purchinvlines-ratendcgst ) / 100 ).
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-packagingcharges *  wa_purchinvlines-ratendsgst ) / 100 ).
              ELSEIF wa_purchinvlines-rateigst IS NOT INITIAL.
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-packagingcharges *  wa_purchinvlines-rateigst ) / 100 ).
              ELSEIF wa_purchinvlines-ratecgst IS NOT INITIAL.
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-packagingcharges *  wa_purchinvlines-ratecgst ) / 100 ).
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-packagingcharges *  wa_purchinvlines-ratesgst ) / 100 ).
              ENDIF.

              IF ( wa_purchinvlines-ratecgst + wa_purchinvlines-ratesgst + wa_purchinvlines-rateigst +
                   wa_purchinvlines-ratendigst + wa_purchinvlines-ratendcgst + wa_purchinvlines-ratendsgst ) NE 0.

                lv_deliverycostamount       +=  wa_purchinvlines-packagingcharges.

              ENDIF.

            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZLDV'  .
*                           Load Charges
              wa_purchinvlines-loadingcharges += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZULV'  .
*                           UnLoad Charges
              wa_purchinvlines-unloadingcharges += wasublinesNp-SupplierInvoiceItemAmount.
            ELSE.
              wa_purchinvlines-othercharges += wasublinesNp-SupplierInvoiceItemAmount.

              IF wa_purchinvlines-ratendigst IS NOT INITIAL .
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-othercharges *  wa_purchinvlines-ratendigst ) / 100 ).
              ELSEIF wa_purchinvlines-ratendcgst IS NOT INITIAL.
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-othercharges *  wa_purchinvlines-ratendcgst ) / 100 ).
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-othercharges *  wa_purchinvlines-ratendsgst ) / 100 ).
              ELSEIF wa_purchinvlines-rateigst IS NOT INITIAL.
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-othercharges *  wa_purchinvlines-rateigst ) / 100 ).
              ELSEIF wa_purchinvlines-ratecgst IS NOT INITIAL.
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-othercharges *  wa_purchinvlines-ratecgst ) / 100 ).
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-othercharges *  wa_purchinvlines-ratesgst ) / 100 ).
              ENDIF.

              IF ( wa_purchinvlines-ratecgst + wa_purchinvlines-ratesgst + wa_purchinvlines-rateigst +
                   wa_purchinvlines-ratendigst + wa_purchinvlines-ratendcgst + wa_purchinvlines-ratendsgst ) NE 0.

                lv_deliverycostamount       +=  wa_purchinvlines-othercharges.

              ENDIF.

            ENDIF.
*              clear ltcurrencyINRNp.
          ENDLOOP.

          SELECT FROM  i_purorditmpricingelementapi01 AS a
          INNER JOIN I_PurchaseOrderItemAPI01 AS b ON a~PurchaseOrder = b~PurchaseOrder
                     AND a~PurchaseOrderItem = b~PurchaseOrderItem
          FIELDS a~conditioncurrency , a~ConditionAmount , b~PurchaseOrder
          WHERE b~PurchaseOrder = @walinesNp-PurchaseOrder
          AND b~PurchaseOrderItem = @walinesNp-PurchaseOrderItem
          AND a~ConditionType IN ( 'ZDCP' , 'ZDCV' , 'ZCD1' , 'ZDCQ' )
          INTO TABLE @DATA(it_discount2Np).
          LOOP AT it_discount2Np INTO DATA(waDiscountNp).
*                   DIscount
            wa_purchinvlines-discount += waDiscountNp-ConditionAmount.
          ENDLOOP.

*               //For TransactionType
          SELECT FROM  i_purchaseorderhistoryapi01 AS a
          FIELDS a~PurchasingHistoryDocument , a~PurchasingHistoryCategory , a~PurchaseOrder, a~DebitCreditCode, a~ReferenceDocument
          WHERE a~PurchaseOrder = @walinesNp-PurchaseOrder
          AND a~PurchasingHistoryDocument = @walinesNp-SupplierInvoice
          AND a~PurchasingHistoryDocumentItem = @walinesNp-SupplierInvoiceItem
          AND a~PurchasingHistoryCategory IN ( 'N' , 'Q' )
          INTO TABLE @DATA(it_transtypeNp).
          LOOP AT it_transtypeNp INTO DATA(waTransTypeNp).
*                   Transaction Type
*            IF watranstypeNp-PurchasingHistoryCategory = 'Q'.
*              wa_purchinvlines-transactiontype = 'Invoice'.
*            ELSEIF watranstypeNp-PurchasingHistoryCategory = 'N' AND watranstypeNp-DebitCreditCode = 'H'.
*              wa_purchinvlines-transactiontype = 'Debit Note'.
*            ELSEIF watranstypeNp-PurchasingHistoryCategory = 'N' AND watranstypeNp-DebitCreditCode = 'S'.
*              wa_purchinvlines-transactiontype = 'Credit Note'.
*            ENDIF.
*          ENDLOOP.

            IF watranstype-PurchasingHistoryCategory = 'Q' AND wa_purchinvlines-purchaseordertype NE 'ZRET'.
              wa_purchinvlines-transactiontype = 'Invoice'.

            ELSEIF watranstype-PurchasingHistoryCategory = 'Q' AND wa_purchinvlines-purchaseordertype = 'ZRET'.

              IF watranstype-PurchasingHistoryCategory = 'Q' AND watranstype-DebitCreditCode = 'H'.
                wa_purchinvlines-transactiontype = 'Debit Note'.

              ELSEIF watranstype-PurchasingHistoryCategory = 'Q' AND watranstype-DebitCreditCode = 'S'.
                wa_purchinvlines-transactiontype = 'Credit Note'.
              ENDIF.

            ELSE.
              IF watranstype-PurchasingHistoryCategory = 'N' AND watranstype-DebitCreditCode = 'H'.
                wa_purchinvlines-transactiontype = 'Debit Note'.
              ELSEIF watranstype-PurchasingHistoryCategory = 'N' AND watranstype-DebitCreditCode = 'S'.
                wa_purchinvlines-transactiontype = 'Credit Note'.
              ENDIF.

            ENDIF.
          ENDLOOP.


          wa_purchinvlines-invoicingpartycodename = | { waheader-Supplier } - { waheader-SupplierName } |.
*           //For Reverse Document

          wa_purchinvlines-referencedocumentno = waheader-revdoc .
          wa_purchinvlines-DeliveryCost = wa_purchinvlines-freight +
                                        wa_purchinvlines-insurance11 + wa_purchinvlines-ecs +
                                        wa_purchinvlines-epf + wa_purchinvlines-othercharges +
                                        wa_purchinvlines-packaging + wa_purchinvlines-oceanfreightcharges +
                                        wa_purchinvlines-carrierhandcharges + wa_purchinvlines-commissioncharges +
                                        wa_purchinvlines-customdutycharges + wa_purchinvlines-demmuragecharges +
                                        wa_purchinvlines-forlandcharges + wa_purchinvlines-inlandcharges +
                                        wa_purchinvlines-loadingcharges + wa_purchinvlines-socialwelfarecharges +
                                        wa_purchinvlines-unloadingcharges +
                                        wa_purchinvlines-packagingcharges .

          wa_purchinvlines-totalamount    = wa_purchinvlines-taxamount + wa_purchinvlines-netamount + wa_purchinvlines-DeliveryCost +
                                       wa_purchinvlines-rcmcgst + wa_purchinvlines-rcmsgst
                                       + wa_purchinvlines-rcmigst .

          wa_purchinvlines-netamount += lv_deliverycostamount.

          CLEAR : waTransTypeNp ,  it_transtypeNp.


          APPEND wa_purchinvlines TO lt_purchinvlines.
*        ********************* Added on 08.02.2025
          MODIFY zpurchinvlines FROM @wa_purchinvlines.
          CLEAR : wa_purchinvlines.
          CLEAR : wa_poNp, wa_taxNp, lv_taxitemacctgdocitemrefNp, it_discount2Np.
        ENDLOOP.
      ENDIF.



*      INSERT zpurchinvlines FROM TABLE @lt_purchinvlines.


      wa_purchinvprocessed-client = sy-mandt.
      wa_purchinvprocessed-supplierinvoice = waheader-SupplierInvoice.
      wa_purchinvprocessed-companycode = waheader-CompanyCode.
      wa_purchinvprocessed-fiscalyearvalue = waheader-FiscalYear.
      wa_purchinvprocessed-supplierinvoicewthnfiscalyear = waheader-SupplierInvoiceWthnFiscalYear.
      wa_purchinvprocessed-creationdatetime = lv_timestamp.
************************************** Header Level Fields Added *******************************
      wa_purchinvlines-plantadr = waheader-AddressID.

      APPEND wa_purchinvprocessed TO lt_purchinvprocessed.
********************** Added on 08.02.2025
      MODIFY zpurchinvproc FROM @wa_purchinvprocessed.
*      INSERT zpurchinvproc FROM TABLE @lt_purchinvprocessed.
      COMMIT WORK.

      CLEAR :  wa_purchinvprocessed, lt_purchinvprocessed, lt_purchinvlines.
      CLEAR : ltlines, it_product, it_po, it_grn, it_tax, it_discount1. ", it_charges.

    ENDLOOP.



  ENDMETHOD.
ENDCLASS.
