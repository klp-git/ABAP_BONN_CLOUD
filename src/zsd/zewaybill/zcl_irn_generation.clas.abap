CLASS zcl_irn_generation DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_transaction_details,   " mandatory
             supply_type     TYPE string,
             ecommerce_gstin TYPE string,
             reg_rev     TYPE string,
             tax_sch     TYPE string,
           END OF ty_transaction_details.

    TYPES: BEGIN OF ty_document_details,      " mandatory
             document_type   TYPE string,
             document_number TYPE string,
             document_date   TYPE string,
           END OF ty_document_details.

    TYPES: BEGIN OF ty_seller_details,          " mandatory
             gstin        TYPE string,
             legal_name   TYPE string,
             trade_name   TYPE string,
             address1     TYPE string,
             address2     TYPE string,
             location     TYPE string,
             pincode      TYPE string,
             state_code   TYPE string,
             state        TYPE string,
           END OF ty_seller_details.


    TYPES: BEGIN OF ty_buyer_details,           " mandatory
             gstin           TYPE string,
             legal_name      TYPE string,
             trade_name      TYPE string,
             address1        TYPE string,
             address2        TYPE string,
             location        TYPE string,
             pincode         TYPE string,
             place_of_supply TYPE string,
             state_code      TYPE string,
             state        TYPE string,
           END OF ty_buyer_details.


    TYPES:BEGIN OF ty_dispatch_details,
            name     TYPE string , "Vila",
            address1     TYPE string , "Vila",
            address2     TYPE string, "Vila",
            location     TYPE string, "Noida",
            pincode      TYPE string,                       " 201301,
            state_code   TYPE string,
            state        TYPE string,
          END OF ty_dispatch_details.


    TYPES: BEGIN OF ty_ship_details,
             gstin      TYPE string, "05AAAPG7885R002",
             legal_name TYPE string, ": "123",
             trade_name TYPE string, ": "232",
             address1   TYPE string, ": "1",
             address2   TYPE string, "",
             location   TYPE string, "221",
             pincode    TYPE string,                        ": 263001,
             state_code TYPE string,
             state      TYPE string,
           END OF ty_ship_details.

    TYPES: BEGIN OF ty_export_details,
             foreign_currency TYPE string, "inr",
             port_code        TYPE string, "12",
             country_code     TYPE string, ": "IN",
             refund_claim     TYPE string,  "N",
           END OF ty_export_details.




    TYPES: BEGIN OF ty_ewaybill_details,
             transporter_id              TYPE string, "05AAABB0639G1Z8",
             transporter_name            TYPE string, "Jay Trans",
             transportation_mode         TYPE string, "1",
             transportation_distance     TYPE int4, " 296,
             transporter_document_number TYPE string, "12301",
             transporter_document_date   TYPE string, "14/09/2023",
             vehicle_number              TYPE string,       "PQR1234",
             vehicle_type                TYPE string, "R"
           END OF ty_ewaybill_details.


    TYPES: BEGIN OF ty_value_details,                           " mandatory
             total_assessable_value      TYPE P length 13 decimals 2, ": 4,
             total_cgst_value            TYPE P length 13 decimals 2, "",
             total_sgst_value            TYPE P length 13 decimals 2, "0,
             total_igst_value            TYPE P length 13 decimals 2, "0.2,
             total_cess_value            TYPE P length 13 decimals 2, "0,
             total_cess_value_of_state   TYPE P length 13 decimals 2, "0,
             total_discount              TYPE P length 13 decimals 2, "0,
             total_other_charge          TYPE P length 13 decimals 2, "0,
             total_invoice_value         TYPE P length 13 decimals 2, "4.2,
             round_off_amount            TYPE P length 13 decimals 2, "0,
             tot_inv_val_additional_curr TYPE P length 13 decimals 2, "total_invoice_value_additional_currency:"0
           END OF ty_value_details.





    TYPES: BEGIN OF ty_item_list,
             item_serial_number         TYPE C length 3,
             product_description        TYPE string,
             is_service                 TYPE string,
             hsn_code                   TYPE string,
             bar_code                   TYPE string,
             quantity                   TYPE P length 13 decimals 2,
             unit                       TYPE string,
             unit_price                 TYPE P length 13 decimals 2,
             total_amount               TYPE P length 13 decimals 2,
             pre_tax_value              TYPE P length 13 decimals 2,
             discount                   TYPE P length 13 decimals 2,
             other_charge               TYPE P length 13 decimals 2,
             assessable_value           TYPE P length 13 decimals 2,
             gst_rate                   TYPE P length 13 decimals 2,
             igst_amount                TYPE P length 13 decimals 2,
             cgst_amount                TYPE P length 13 decimals 2,
             sgst_amount                TYPE P length 13 decimals 2,
             cess_rate                  TYPE P length 13 decimals 2,
             cess_amount                TYPE P length 13 decimals 2,
             cess_nonadvol_amount       TYPE P length 13 decimals 2,
             state_cess_rate            TYPE P length 13 decimals 2,
             state_cess_amount          TYPE P length 13 decimals 2,
             state_cess_nonadvol_amount TYPE P length 13 decimals 2,
             total_item_value           TYPE P length 13 decimals 2,
           END OF ty_item_list.

    CLASS-DATA : item_list TYPE TABLE OF ty_item_list.


    TYPES: BEGIN OF ty_body,
             version                     TYPE STRING,
             transaction_details         TYPE ty_transaction_details,
             document_details            TYPE ty_document_details,
             seller_details              TYPE ty_seller_details,
             buyer_details               TYPE ty_buyer_details,
             dispatch_details            TYPE ty_dispatch_details,
             ship_details                TYPE ty_ship_details,
             export_details              TYPE ty_export_details,
             ewaybill_details            TYPE ty_ewaybill_details,
             value_details               TYPE ty_value_details,
             item_list                   LIKE item_list,
           END OF ty_body.
    CLASS-METHODS :generated_irn IMPORTING
                                           companycode   TYPE ztable_irn-bukrs
                                           document      TYPE ztable_irn-billingdocno
                                 RETURNING VALUE(result) TYPE string.
    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_IRN_GENERATION IMPLEMENTATION.


  METHOD generated_irn.

    DATA : wa_final TYPE ty_body.
    DATA: it_itemlist TYPE TABLE OF ty_item_list,
          wa_itemlist TYPE ty_item_list.

    wa_final-version = '1.1'.


**************************    transaction details

    SELECT SINGLE FROM i_billingdocument AS a
        FIELDS a~TransactionCurrency, a~DistributionChannel, a~Country, a~AccountingExchangeRate
        WHERE a~BillingDocument = @document AND a~CompanyCode = @companycode
        INTO @DATA(lv_trans_details) PRIVILEGED ACCESS.

    IF lv_trans_details-DistributionChannel NE 'EX'.
      wa_final-transaction_details-supply_type = 'B2B'.
    ELSE.
      wa_final-transaction_details-supply_type = 'EXPWOP'.
    ENDIF.
    wa_final-transaction_details-reg_rev = 'N'.
    wa_final-transaction_details-tax_sch = 'GST'.

********************************Export Details

    IF wa_final-transaction_details-supply_type = 'EXPWOP'.

      wa_final-export_details-country_code = lv_trans_details-Country.
      wa_final-export_details-foreign_currency = lv_trans_details-TransactionCurrency .
      wa_final-export_details-refund_claim = 'N'.
      wa_final-export_details-port_code = 'INAJM6'.

********************************Ship Details

      SELECT SINGLE FROM I_BillingDocumentItem AS a
      INNER JOIN i_billingdocitempartner AS b ON a~BillingDocument = b~BillingDocument
      INNER JOIN i_customer AS c ON  c~customer = b~customer
      FIELDS c~taxnumber3, c~CustomerFullName, c~CustomerName, c~CityName, c~PostalCode, c~Country, c~Region
       WHERE a~billingdocument = @document AND b~PartnerFunction = 'WE'
      INTO @DATA(lv_shipDetails) PRIVILEGED ACCESS.


      wa_final-ship_details-gstin = 'URP'.
      wa_final-ship_details-legal_name = lv_shipDetails-customername.
      wa_final-ship_details-trade_name = lv_shipDetails-customername.
      wa_final-ship_details-address1 = lv_shipDetails-customerfullname.
      wa_final-ship_details-address2 = ''.
      IF lv_shipDetails-Country = 'IN'.
        wa_final-ship_details-location   = lv_shipDetails-cityname .
        wa_final-ship_details-pincode   = lv_shipDetails-postalcode  .
      ELSE.

        SELECT SINGLE FROM I_CountryText
            FIELDS CountryShortName
            WHERE Country = @lv_shipDetails-Country
            INTO @DATA(ShipCountry).
        wa_final-ship_details-location   = ShipCountry .
        wa_final-ship_details-pincode   = '999999'  .
      ENDIF.



      SELECT SINGLE FROM zstatecodemaster
      FIELDS Statecodenum
      WHERE StateCode = @lv_shipDetails-Region
      INTO @DATA(lv_statecode1).

      wa_final-ship_details-state_code  = lv_statecode1.


    ELSE.

********************************Ship Details

      SELECT SINGLE FROM I_BillingDocumentPartner AS a
         FIELDS a~Customer
            WHERE a~BillingDocument = @document
            AND a~PartnerFunction = 'RE' INTO @DATA(buyer) PRIVILEGED ACCESS.


      SELECT SINGLE FROM I_BillingDocItemPartner AS a
      FIELDS a~Customer
         WHERE a~BillingDocument = @document
         AND a~PartnerFunction = 'WE' INTO @DATA(Shipper) PRIVILEGED ACCESS.

      IF buyer IS NOT INITIAL AND Shipper IS NOT INITIAL AND buyer NE Shipper.

        SELECT SINGLE FROM i_customer AS c
        FIELDS c~taxnumber3, c~CustomerFullName, c~CustomerName, c~CityName, c~PostalCode, c~Country, c~Region
         WHERE c~Customer = @Shipper
        INTO @lv_shipDetails PRIVILEGED ACCESS.


        wa_final-ship_details-gstin = lv_shipDetails-TaxNumber3.
        wa_final-ship_details-legal_name = lv_shipDetails-customername.
        wa_final-ship_details-trade_name = lv_shipDetails-customername.
        wa_final-ship_details-address1 = lv_shipDetails-customerfullname.
        wa_final-ship_details-address2 = ''.
        IF lv_shipDetails-Country = 'IN'.
          wa_final-ship_details-location   = lv_shipDetails-cityname .
          wa_final-ship_details-pincode   = lv_shipDetails-postalcode  .
        ELSE.

          SELECT SINGLE FROM I_CountryText
              FIELDS CountryShortName
              WHERE Country = @lv_shipDetails-Country
              INTO @ShipCountry.
          wa_final-ship_details-location   = ShipCountry .
          wa_final-ship_details-pincode   = '999999'  .
        ENDIF.

        SELECT SINGLE FROM zstatecodemaster
        FIELDS Statecodenum
        WHERE StateCode = @lv_shipDetails-Region
        INTO @lv_statecode1.

        wa_final-ship_details-state_code  = lv_statecode1.

      ENDIF.
    ENDIF.


********************************document details


    SELECT SINGLE FROM i_billingdocument AS a
    INNER JOIN I_BillingDocumentItem AS b ON a~BillingDocument = b~BillingDocument
    FIELDS a~BillingDocument,
    a~BillingDocumentType,
    a~BillingDocumentDate,
    b~Plant,a~CompanyCode, a~DocumentReferenceID
    WHERE a~BillingDocument = @document
*    AND b~BillingDocumentType NOT IN ( 'S1','S2' )
    INTO @DATA(lv_document_details) PRIVILEGED ACCESS.

    IF lv_document_details-BillingDocumentType = 'F2' OR lv_document_details-BillingDocumentType = 'JSTO' OR lv_document_details-BillingDocumentType = 'JSP'.
      wa_final-document_details-document_type = 'INV'.
    ELSEIF lv_document_details-BillingDocumentType = 'G2' OR lv_document_details-BillingDocumentType = 'CBRE'.
      wa_final-document_details-document_type = 'CRN'.
    ELSEIF lv_document_details-BillingDocumentType = 'L2'.
      wa_final-document_details-document_type = 'DBN'.
    ENDIF.
    SHIFT lv_document_details-BillingDocument LEFT DELETING LEADING '0'.
    wa_final-document_details-document_number = lv_document_details-DocumentReferenceID.
    wa_final-document_details-document_date = lv_document_details-BillingDocumentDate+6(2) && '/' && lv_document_details-BillingDocumentDate+4(2) && '/' && lv_document_details-BillingDocumentDate(4).

***************************************seller detials

    SELECT SINGLE FROM ztable_plant
    FIELDS gstin_no, city, address1, address2, pin, state_code1,plant_name1, state_name
    WHERE plant_code = @lv_document_details-plant AND comp_code = @lv_document_details-CompanyCode INTO @DATA(sellerplantaddress) PRIVILEGED ACCESS.

    wa_final-seller_details-gstin    =  sellerplantaddress-gstin_no.
    wa_final-seller_details-legal_name  =  sellerplantaddress-plant_name1.
    wa_final-seller_details-trade_name =  sellerplantaddress-plant_name1.
    wa_final-seller_details-address1    =  sellerplantaddress-address1.
    wa_final-seller_details-address2    =  sellerplantaddress-address2 .
    wa_final-seller_details-location      =  sellerplantaddress-address2 .
    IF sellerplantaddress-city IS NOT INITIAL.
      wa_final-seller_details-location      =  sellerplantaddress-city .
    ENDIF.
    wa_final-seller_details-state_code     =  sellerplantaddress-state_code1.
    wa_final-seller_details-pincode      =  sellerplantaddress-pin.
    wa_final-seller_details-state      =  sellerplantaddress-state_name.


*******************************    buyer details

    SELECT SINGLE * FROM i_billingdocumentpartner AS a  INNER JOIN i_customer AS
            b ON ( a~customer = b~customer  ) WHERE a~billingdocument = @document
             AND a~partnerfunction = 'RE' INTO  @DATA(buyeradd) PRIVILEGED ACCESS.

    IF wa_final-transaction_details-supply_type = 'EXPWOP'.
      wa_final-buyer_details-gstin = 'URP'.
      wa_final-buyer_details-pincode   = '999999'  .
      wa_final-buyer_details-state_code  = '96'  .
      wa_final-buyer_details-place_of_supply = '96'.

      SELECT SINGLE FROM I_CountryText
          FIELDS CountryShortName
          WHERE Country = @buyeradd-b-Country
          INTO @DATA(Country).

      wa_final-buyer_details-location   = Country .
      wa_final-buyer_details-state  = Country .
    ELSE.
      wa_final-buyer_details-gstin = buyeradd-b-taxnumber3.
      wa_final-buyer_details-pincode   = buyeradd-b-postalcode  .

      SELECT SINGLE FROM zstatecodemaster
      FIELDS Statecodenum
      WHERE StateCode = @buyeradd-b-Region
      INTO @DATA(lv_statecode).

      wa_final-buyer_details-state_code  = lv_statecode  .
      wa_final-buyer_details-place_of_supply  = lv_statecode .
      wa_final-buyer_details-location   = buyeradd-b-cityname .


      SELECT SINGLE FROM I_RegionText
          FIELDS RegionName
          WHERE Country = @buyeradd-b-Country AND Region = @buyeradd-b-Region
          INTO @DATA(state).
      wa_final-buyer_details-state  = state .
    ENDIF.

    wa_final-buyer_details-legal_name = buyeradd-b-customername.
    wa_final-buyer_details-trade_name = buyeradd-b-customername.
    wa_final-buyer_details-address1 = buyeradd-b-customerfullname.
    wa_final-buyer_details-address2 = ''.




****************************    dispatch details


    wa_final-dispatch_details-name    =  sellerplantaddress-plant_name1.
    wa_final-dispatch_details-address1    =  sellerplantaddress-address1.
    wa_final-dispatch_details-address2    =  sellerplantaddress-address2.
    wa_final-dispatch_details-location      =  sellerplantaddress-address2 .
    IF sellerplantaddress-city IS NOT INITIAL.
      wa_final-dispatch_details-location      =  sellerplantaddress-city .
    ENDIF.
    wa_final-dispatch_details-state_code     =  sellerplantaddress-state_code1.
    wa_final-dispatch_details-state     =  sellerplantaddress-state_name.
    wa_final-dispatch_details-pincode      =  sellerplantaddress-pin.


    SELECT FROM I_BillingDocumentItem FIELDS BillingDocument, BillingDocumentItem, BillingDocumentItemText,
    Product, Plant, BillingQuantity, BillingQuantityUnit
    WHERE BillingDocument = @document AND CompanyCode = @companycode
    INTO TABLE @DATA(lt_item) PRIVILEGED ACCESS.

***************************ewaybill_details


*    SELECT SINGLE FROM zr_zirntp
*    FIELDS Transportername, Vehiclenum, Grdate, Grno, Transportergstin
*    WHERE Billingdocno = @document AND Bukrs = @companycode
*    INTO @DATA(Eway).

*    wa_final-ewaybill_details-vehicle_number = Eway-Vehiclenum .
*    wa_final-ewaybill_details-transporter_name = Eway-Transportername .
*    wa_final-ewaybill_details-transporter_document_date = Eway-Grdate+6(2) && '/' && Eway-Grdate+4(2) && '/' && Eway-Grdate(4) .
*    wa_final-ewaybill_details-transporter_document_number = Eway-Grno .
*    wa_final-ewaybill_details-transporter_id = Eway-Transportergstin .
*    wa_final-ewaybill_details-transportation_mode = '1'.
*    IF wa_final-seller_details-pincode NE wa_final-buyer_details-pincode.
*      wa_final-ewaybill_details-transportation_distance = 0.
*    ELSE.
*      wa_final-ewaybill_details-transportation_distance = 10.
*    ENDIF.
*    wa_final-ewaybill_details-vehicle_type = 'R'.


*************************export details

* To be done



*************Pricing DATA


    SELECT FROM I_BillingDocumentItem AS item
       LEFT JOIN I_ProductDescription AS pd ON item~Product = pd~Product AND pd~LanguageISOCode = 'EN'
       LEFT JOIN i_productplantbasic AS c ON item~Product = c~Product AND item~Plant = c~Plant
       FIELDS item~BillingDocument, item~BillingDocumentItem
       , item~Plant, item~ProfitCenter, item~Product, item~BillingQuantity, item~BaseUnit, item~BillingQuantityUnit, item~NetAmount,
            item~TaxAmount, item~TransactionCurrency, item~CancelledBillingDocument, item~BillingQuantityinBaseUnit,
            pd~ProductDescription,
            c~consumptiontaxctrlcode, item~CompanyCode
       WHERE item~BillingDocument = @document AND consumptiontaxctrlcode IS NOT INITIAL AND item~salesdocumentitemcategory NE 'CB99'
          INTO TABLE @DATA(ltlines).

    SELECT FROM I_BillingDocItemPrcgElmntBasic FIELDS BillingDocument , BillingDocumentItem, ConditionRateValue, ConditionAmount, ConditionType,
      transactioncurrency AS d_transactioncurrency
      WHERE BillingDocument = @document
      INTO TABLE @DATA(it_price).

    DATA(count) = 1.

    LOOP AT ltlines INTO DATA(wa_lines).
      wa_itemlist-item_serial_number = |{ count WIDTH = 3 ALIGN = RIGHT PAD = '0' }|.
      wa_itemlist-product_description  = wa_lines-ProductDescription.
      wa_itemlist-hsn_code = wa_lines-consumptiontaxctrlcode.

      SELECT SINGLE FROM zgstuom
      FIELDS gstuom
      WHERE uom = @wa_lines-BillingQuantityUnit "and bukrs = @wa_lines-CompanyCode
      INTO @DATA(uom).

      IF uom IS INITIAL.
        wa_itemlist-unit = wa_lines-BillingQuantityUnit.
      ELSE.
        wa_itemlist-unit = uom.
      ENDIF.


*        wa_itemlist-unit = .
      wa_itemlist-quantity = wa_lines-BillingQuantity.


      READ TABLE it_price INTO DATA(wa_price1) WITH KEY BillingDocument = wa_lines-BillingDocument
                                                      BillingDocumentItem = wa_lines-BillingDocumentItem
                                                      ConditionType = 'JOIG'.
      IF wa_price1 IS NOT INITIAL.
        wa_itemlist-igst_amount                    = ( wa_price1-ConditionAmount ) * lv_trans_details-AccountingExchangeRate.
        wa_itemlist-gst_rate                       = wa_price1-ConditionRateValue.
        CLEAR wa_price1.

      ELSE.

        READ TABLE it_price INTO DATA(wa_price2) WITH KEY BillingDocument = wa_lines-BillingDocument
                                                         BillingDocumentItem = wa_lines-BillingDocumentItem
                                                         ConditionType = 'JOSG'.
        wa_itemlist-sgst_amount                    = ( wa_price2-ConditionAmount ) * lv_trans_details-AccountingExchangeRate.

        READ TABLE it_price INTO DATA(wa_price3) WITH KEY BillingDocument = wa_lines-BillingDocument
                                                        BillingDocumentItem = wa_lines-BillingDocumentItem
                                                        ConditionType = 'JOCG'.
        wa_itemlist-cgst_amount                    = ( wa_price3-ConditionAmount ) * lv_trans_details-AccountingExchangeRate.

        wa_itemlist-gst_rate                       = wa_price3-ConditionRateValue + wa_price2-ConditionRateValue.
        CLEAR : wa_price2,wa_price3.
      ENDIF.

         SELECT SUM( conditionamount )    FROM i_billingdocumentitemprcgelmnt
        WHERE   conditiontype IN ( 'JTC1', 'ZTCS' )
        AND billingdocument = @wa_lines-billingdocument AND billingdocumentitem = @wa_lines-billingdocumentitem
         INTO @DATA(tcs) .

      IF tcs IS NOT INITIAL .
        DATA(tcsamt) = tcs .
      ENDIF.

      SELECT SUM( conditionamount )    FROM i_billingdocumentitemprcgelmnt
         WHERE   conditiontype IN ( 'ZDIS', 'ZDIV', 'ZDPT', 'ZDQT','Z100' )
         AND billingdocument = @wa_lines-billingdocument AND billingdocumentitem = @wa_lines-billingdocumentitem
          INTO @DATA(discount) .

      IF discount < 0.
        wa_itemlist-discount                     =      discount * -1 * lv_trans_details-AccountingExchangeRate.
      ELSE.
        wa_itemlist-discount                     =      discount * lv_trans_details-AccountingExchangeRate.
      ENDIF.

      SELECT SUM( conditionamount )    FROM i_billingdocumentitemprcgelmnt
        WHERE   conditiontype IN ( 'YBHD', 'ZFRT','ZINS', 'FIN1','ZPCK' )
        AND billingdocument = @wa_lines-billingdocument AND billingdocumentitem = @wa_lines-billingdocumentitem
         INTO @DATA(OtherCharges) .


      SELECT   FROM i_billingdocumentitemprcgelmnt AS a
      FIELDS  SUM( a~ConditionRateAmount ) AS UnitPrice, SUM( a~ConditionAmount ) AS TotAmt
       WHERE   conditiontype IN ( 'ZEXF', 'ZBNP', 'ZPR0', 'PPR0','ZSTO' )
       AND billingdocument = @wa_lines-billingdocument AND billingdocumentitem = @wa_lines-billingdocumentitem
        INTO @DATA(unitprice) .

      wa_itemList-unit_price = ( unitprice-unitprice ) * lv_trans_details-AccountingExchangeRate.
      wa_itemlist-other_charge = tcsamt.
      wa_itemlist-total_amount = ( unitprice-TotAmt + OtherCharges ) * lv_trans_details-AccountingExchangeRate.
      wa_itemlist-assessable_value =  wa_itemlist-total_amount - wa_itemlist-discount.





      IF wa_itemlist-cgst_amount IS INITIAL.
        wa_itemlist-cgst_amount = '0'.
      ENDIF.
      IF wa_itemlist-sgst_amount IS INITIAL.
        wa_itemlist-sgst_amount = '0'.
      ENDIF.
      IF wa_itemlist-igst_amount IS INITIAL.
        wa_itemlist-igst_amount = '0'.
      ENDIF.
      IF wa_itemlist-other_charge IS INITIAL.
        wa_itemlist-other_charge = '0'.
      ENDIF.
      IF wa_itemlist-cess_nonadvol_amount IS INITIAL.
        wa_itemlist-cess_nonadvol_amount = '0'.
      ENDIF.

      READ TABLE it_price INTO DATA(wa_price4) WITH KEY BillingDocument = wa_lines-BillingDocument
                                                        BillingDocumentItem = wa_lines-BillingDocumentItem
                                                        ConditionType = 'DRD1'.
      wa_final-value_details-round_off_amount       += ( wa_price4-ConditionAmount ) * lv_trans_details-AccountingExchangeRate.


      wa_final-value_details-total_assessable_value   +=    wa_itemlist-assessable_value.
      wa_final-value_details-total_sgst_value += wa_itemlist-sgst_amount .
      wa_final-value_details-total_cgst_value += wa_itemlist-cgst_amount .
      wa_final-value_details-total_igst_value += wa_itemlist-igst_amount .
      wa_final-value_details-total_invoice_value      += wa_itemlist-assessable_value + ( wa_price4-ConditionAmount * lv_trans_details-AccountingExchangeRate )  +
                                         wa_itemlist-igst_amount + wa_itemlist-cgst_amount +
                                         wa_itemlist-sgst_amount + wa_itemlist-other_charge.




      wa_itemlist-is_service = 'N'.
      wa_itemlist-total_item_value = ( wa_itemlist-assessable_value * (  1 + ( wa_itemlist-gst_rate / 100 ) + wa_itemlist-cess_nonadvol_amount ) )  + wa_itemlist-other_charge.

      APPEND wa_itemlist TO it_itemlist.
      count = count + 1.
      CLEAR :  wa_itemlist ,tcsamt,discount, OtherCharges.
    ENDLOOP.

    wa_final-item_list = it_itemlist.

    DATA:json TYPE REF TO if_xco_cp_json_data.

    xco_cp_json=>data->from_abap(
      EXPORTING
        ia_abap      = wa_final
      RECEIVING
        ro_json_data = json   ).
    json->to_string(
      RECEIVING
        rv_string =   DATA(lv_string) ).

*   DATA(lv_json) = /ui2/cl_json=>serialize( data = lv_string compress = abap_true pretty_name = /ui2/cl_json=>pretty_mode-low_case ).

*    REPLACE ALL OCCURRENCES OF REGEX '"([A-Z0-9_]+)"\s*:' IN lv_string WITH '"\L\1":'.


    REPLACE ALL OCCURRENCES OF '"VERSION"' IN lv_string WITH '"Version"'.
    REPLACE ALL OCCURRENCES OF '"TRANSACTION_DETAILS"' IN lv_string WITH '"TranDtls"'.
    REPLACE ALL OCCURRENCES OF '"SUPPLY_TYPE"' IN lv_string WITH '"SupTyp"'.
    REPLACE ALL OCCURRENCES OF '"TAX_SCH"' IN lv_string WITH '"TaxSch"'.
    REPLACE ALL OCCURRENCES OF '"REG_REV"' IN lv_string WITH '"RegRev"'.
    REPLACE ALL OCCURRENCES OF '"ECOMMERCE_GSTIN":""' IN lv_string WITH '"EcmGstin":null'.

    REPLACE ALL OCCURRENCES OF '"DOCUMENT_DETAILS"' IN lv_string WITH '"DocDtls"'.
    REPLACE ALL OCCURRENCES OF '"DOCUMENT_TYPE"' IN lv_string WITH '"Typ"'.
    REPLACE ALL OCCURRENCES OF '"DOCUMENT_NUMBER"' IN lv_string WITH '"No"'.
    REPLACE ALL OCCURRENCES OF '"DOCUMENT_DATE"' IN lv_string WITH '"Dt"'.

    REPLACE ALL OCCURRENCES OF '"SELLER_DETAILS"' IN lv_string WITH '"SellerDtls"'.
    REPLACE ALL OCCURRENCES OF '"GSTIN"' IN lv_string WITH '"Gstin"'.
    REPLACE ALL OCCURRENCES OF '"LEGAL_NAME"' IN lv_string WITH '"LglNm"'.
    REPLACE ALL OCCURRENCES OF '"TRADE_NAME"' IN lv_string WITH '"TrdNm"'.
    REPLACE ALL OCCURRENCES OF '"ADDRESS1"' IN lv_string WITH '"Addr1"'.
    REPLACE ALL OCCURRENCES OF '"ADDRESS2":"",' IN lv_string WITH ''.
    REPLACE ALL OCCURRENCES OF '"ADDRESS2"' IN lv_string WITH '"Addr2"'.
    REPLACE ALL OCCURRENCES OF '"LOCATION"' IN lv_string WITH '"Loc"'.
    REPLACE ALL OCCURRENCES OF '"PINCODE"' IN lv_string WITH '"Pin"'.
    REPLACE ALL OCCURRENCES OF '"STATE_CODE"' IN lv_string WITH '"Stcd"'.
    REPLACE ALL OCCURRENCES OF '"STATE"' IN lv_string WITH '"State"'.

    REPLACE ALL OCCURRENCES OF '"BUYER_DETAILS"' IN lv_string WITH '"BuyerDtls"'.
    REPLACE ALL OCCURRENCES OF '"PLACE_OF_SUPPLY"' IN lv_string WITH '"Pos"'.

    REPLACE ALL OCCURRENCES OF '"DISPATCH_DETAILS"' IN lv_string WITH '"DispDtls"'.
    REPLACE ALL OCCURRENCES OF '"NAME"' IN lv_string WITH '"Nm"'.

    REPLACE ALL OCCURRENCES OF '"SHIP_DETAILS"' IN lv_string WITH '"ShipDtls"'.



    IF wa_final-ship_details-legal_name = ''.
      REPLACE ALL OCCURRENCES OF '"ShipDtls":{"Gstin":"","LglNm":"","TrdNm":"","Addr1":"","Loc":"","Pin":"","Stcd":"","State":""}' IN lv_string WITH '"ShipDtls":null'.
    ENDIF.

    IF wa_final-transaction_details-supply_type = 'B2B'.
      REPLACE ALL OCCURRENCES OF '"EXPORT_DETAILS":{"FOREIGN_CURRENCY":"","PORT_CODE":"","COUNTRY_CODE":"","REFUND_CLAIM":""}' IN lv_string WITH '"ExpDtls":null'.

    ELSE.
      REPLACE ALL OCCURRENCES OF '"EXPORT_DETAILS"' IN lv_string WITH '"ExpDtls"'.
      REPLACE ALL OCCURRENCES OF '"COUNTRY_CODE"' IN lv_string WITH '"CntCode"'.
      REPLACE ALL OCCURRENCES OF '"FOREIGN_CURRENCY"' IN lv_string WITH '"ForCur"'.
      REPLACE ALL OCCURRENCES OF '"REFUND_CLAIM"' IN lv_string WITH '"RefClm"'.
      REPLACE ALL OCCURRENCES OF '"PORT_CODE"' IN lv_string WITH '"Port"'.
    ENDIF.



    REPLACE ALL OCCURRENCES OF '"EWAYBILL_DETAILS"' IN lv_string WITH '"EwbDtls"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTER_ID"' IN lv_string WITH '"TransId"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTER_NAME"' IN lv_string WITH '"TransName"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTATION_MODE"' IN lv_string WITH '"TransMode"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTATION_DISTANCE"' IN lv_string WITH '"Distance"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTER_DOCUMENT_NUMBER"' IN lv_string WITH '"TransDocNo"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTER_DOCUMENT_DATE"' IN lv_string WITH '"TransDocDt"'.
    REPLACE ALL OCCURRENCES OF '"VEHICLE_NUMBER"' IN lv_string WITH '"VehNo"'.
    REPLACE ALL OCCURRENCES OF '"VEHICLE_TYPE"' IN lv_string WITH '"VehType"'.

*    make ewb details null
    REPLACE ALL OCCURRENCES OF '"EwbDtls":{"TransId":"","TransName":"","TransMode":"","Distance":0,"TransDocNo":"","TransDocDt":"","VehNo":"","VehType":""}' IN lv_string WITH '"EwbDtls":null'.

    REPLACE ALL OCCURRENCES OF '"VALUE_DETAILS"' IN lv_string WITH '"ValDtls"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_ASSESSABLE_VALUE"' IN lv_string WITH '"AssVal"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_CGST_VALUE"' IN lv_string WITH '"CgstVal"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_SGST_VALUE"' IN lv_string WITH '"SgstVal"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_IGST_VALUE"' IN lv_string WITH '"IgstVal"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_CESS_VALUE"' IN lv_string WITH '"CesVal"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_INVOICE_VALUE"' IN lv_string WITH '"TotInvVal"'.

    REPLACE ALL OCCURRENCES OF '"ITEM_LIST"' IN lv_string WITH '"ItemList"'.
    REPLACE ALL OCCURRENCES OF '"ITEM_SERIAL_NUMBER"' IN lv_string WITH '"SlNo"'.
    REPLACE ALL OCCURRENCES OF '"PRODUCT_DESCRIPTION"' IN lv_string WITH '"PrdDesc"'.
    REPLACE ALL OCCURRENCES OF '"IS_SERVICE"' IN lv_string WITH '"IsServc"'.
    REPLACE ALL OCCURRENCES OF '"BAR_CODE":"",' IN lv_string WITH ''.
    REPLACE ALL OCCURRENCES OF '"HSN_CODE"' IN lv_string WITH '"HsnCd"'.
    REPLACE ALL OCCURRENCES OF '"BAR_CODE"' IN lv_string WITH '"Barcde"'.
    REPLACE ALL OCCURRENCES OF '"QUANTITY"' IN lv_string WITH '"Qty"'.
    REPLACE ALL OCCURRENCES OF '"UNIT"' IN lv_string WITH '"Unit"'.

    REPLACE ALL OCCURRENCES OF '"UNIT_PRICE"' IN lv_string WITH '"UnitPrice"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_AMOUNT"' IN lv_string WITH '"TotAmt"'.

    REPLACE ALL OCCURRENCES OF '"TOTAL_CESS_VALUE_OF_STATE"' IN lv_string WITH '"StCesVal"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_DISCOUNT"' IN lv_string WITH '"Discount"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_OTHER_CHARGE"' IN lv_string WITH '"OthChrg"'.
    REPLACE ALL OCCURRENCES OF '"ROUND_OFF_AMOUNT"' IN lv_string WITH '"RndOffAmt"'.
    REPLACE ALL OCCURRENCES OF '"TOT_INV_VAL_ADDITIONAL_CURR"' IN lv_string WITH '"TotInvValFc"'.
    REPLACE ALL OCCURRENCES OF '"PRE_TAX_VALUE"' IN lv_string WITH '"PreTaxVal"'.
    REPLACE ALL OCCURRENCES OF '"DISCOUNT"' IN lv_string WITH '"Discount"'.
    REPLACE ALL OCCURRENCES OF '"OTHER_CHARGE"' IN lv_string WITH '"OthChrg"'.
    REPLACE ALL OCCURRENCES OF '"ASSESSABLE_VALUE"' IN lv_string WITH '"AssAmt"'.
    REPLACE ALL OCCURRENCES OF '"GST_RATE"' IN lv_string WITH '"GstRt"'.
    REPLACE ALL OCCURRENCES OF '"IGST_AMOUNT"' IN lv_string WITH '"IgstAmt"'.
    REPLACE ALL OCCURRENCES OF '"CGST_AMOUNT"' IN lv_string WITH '"CgstAmt"'.
    REPLACE ALL OCCURRENCES OF '"SGST_AMOUNT"' IN lv_string WITH '"SgstAmt"'.
    REPLACE ALL OCCURRENCES OF '"CESS_RATE"' IN lv_string WITH '"CesRt"'.
    REPLACE ALL OCCURRENCES OF '"CESS_AMOUNT"' IN lv_string WITH '"CesAmt"'.
    REPLACE ALL OCCURRENCES OF '"CESS_NONADVOL_AMOUNT"' IN lv_string WITH '"CesNonAdvlAmt"'.
    REPLACE ALL OCCURRENCES OF '"STATE_CESS_AMOUNT"' IN lv_string WITH '"StateCesAmt"'.
    REPLACE ALL OCCURRENCES OF '"STATE_CESS_RATE"' IN lv_string WITH '"StateCesRt"'.
    REPLACE ALL OCCURRENCES OF '"STATE_CESS_NONADVOL_AMOUNT"' IN lv_string WITH '"StateCesNonAdvlAmt"'.
    REPLACE ALL OCCURRENCES OF '"TOTAL_ITEM_VALUE"' IN lv_string WITH '"TotItemVal"'.


    REPLACE ALL OCCURRENCES OF '"TransId":""' IN lv_string WITH '"TransId":null'.
    REPLACE ALL OCCURRENCES OF '"TransName":""' IN lv_string WITH '"TransName":null'.
    REPLACE ALL OCCURRENCES OF '"TransDocNo":""' IN lv_string WITH '"TransDocNo":null'.
    REPLACE ALL OCCURRENCES OF '"TransDocDt":"00/00/0000"' IN lv_string WITH '"TransDocDt":null'.
    REPLACE ALL OCCURRENCES OF '"VehNo":""' IN lv_string WITH '"VehNo":null'.




    result = lv_string.

  ENDMETHOD.


  METHOD IF_OO_ADT_CLASSRUN~MAIN.

  ENDMETHOD.
ENDCLASS.
