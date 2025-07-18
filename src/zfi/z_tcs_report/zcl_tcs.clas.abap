CLASS zcl_tcs DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_tcs IMPLEMENTATION.
  METHOD if_rap_query_provider~select.
    DATA: lt_response    TYPE TABLE OF zcdstcs,
          ls_response    LIKE LINE OF lt_response,
          lt_responseout LIKE lt_response,
          ls_responseout LIKE LINE OF lt_responseout.


    DATA(lv_top)           = io_request->get_paging( )->get_page_size( ).
    DATA(lv_skip)          = io_request->get_paging( )->get_offset( ).
    DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0
                                ELSE lv_top ).

    TRY.
        DATA(lt_clause)        = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lo_error).
        DATA(lv_msg) = lo_error->get_text( ).
    ENDTRY.

    DATA(lt_parameter)     = io_request->get_parameters( ).
    DATA(lt_fields)        = io_request->get_requested_elements( ).
    DATA(lt_sort)          = io_request->get_sort_elements( ).

    TRY.
        DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
        lv_msg = lo_error->get_text( ).
    ENDTRY.

    LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).

      IF ls_filter_cond-name = 'SALE_DATE'.
        DATA(lt_SALE_DATE) = ls_filter_cond-range[].

      ELSEIF ls_filter_cond-name = 'SALE_BILL_NO'.
        DATA(lt_Sale_Bill_No) = ls_filter_cond-range[].

      ELSEIF ls_filter_cond-name = 'ACCOUNT_CODE'.
        DATA(lt_ACCOUNT_CODE) = ls_filter_cond-range[].

      ELSEIF ls_filter_cond-name = 'PARTYNAME'.
        DATA(lt_PARTYNAME) = ls_filter_cond-range[].

      ELSEIF ls_filter_cond-name = 'PLANT_CODE'.
        DATA(lt_PlAnt) = ls_filter_cond-range[].

      ELSEIF ls_filter_cond-name = 'LOCATION'.
        DATA(lt_LOCATION) = ls_filter_cond-range[].

      ELSEIF ls_filter_cond-name = 'PAN_NO'.
        DATA(lt_PAN_NO) = ls_filter_cond-range[].
      ENDIF.

    ENDLOOP.

    IF lt_ACCOUNT_CODE IS NOT INITIAL.
      LOOP AT lt_ACCOUNT_CODE ASSIGNING FIELD-SYMBOL(<fs_account_code>).
        IF strlen( <fs_account_code>-low ) < 10.
          <fs_account_code>-low = |{ <fs_account_code>-low ALPHA = IN WIDTH = 10 }|.
        ENDIF.
      ENDLOOP.
    ENDIF.



**************************************************** CODE HERE
    SELECT FROM i_billingdocument AS a
    LEFT JOIN i_billingdocumentitem AS b ON a~BillingDocument = b~BillingDocument
    LEFT JOIN i_plant AS c ON b~Plant = c~Plant
    LEFT JOIN I_Customer AS d ON a~PayerParty = d~Customer
    FIELDS a~BillingDocument ,
           a~SalesOrganization,
           a~BillingDocumentType,
           a~BillingDocumentDate,
           a~DocumentReferenceID,
           a~PayerParty,
           c~Plant,
           c~PlantName,
           d~CustomerName,
           d~TaxNumber3
     WHERE a~BillingDocumentDate IN @lt_SALE_DATE
     AND a~DocumentReferenceID IN @lt_Sale_Bill_No
     AND c~Plant IN @lt_PlAnt
     AND c~PlantName IN @lt_LOCATION
     AND a~PayerParty IN @lt_ACCOUNT_CODE
     AND d~CustomerName IN @lt_PARTYNAME
     INTO TABLE @DATA(item).


    SORT item BY BillingDocument DocumentReferenceID.
    DELETE ADJACENT DUPLICATES FROM item COMPARING BillingDocument DocumentReferenceID.

    LOOP AT item INTO DATA(ls_item).
      ls_response-sale_date = ls_item-BillingDocumentDate.
      ls_response-Sale_Bill_No = ls_item-DocumentReferenceID.
      ls_response-Plant_code = ls_item-Plant.
      ls_response-location = ls_item-PlantName.
      ls_response-account_code = ls_item-PayerParty.
      ls_response-partyname = ls_item-CustomerName.
      IF strlen( ls_item-TaxNumber3 ) >= 5.
        DATA(lv_l) = strlen( ls_item-TaxNumber3 ) - 5.
        ls_response-Pan_No = ls_item-TaxNumber3+2(lv_l).
      ENDIF.
      ls_response-TCS_Code = '206C (1)'.

      SELECT FROM  I_BillingDocument AS a
      LEFT JOIN I_BillingDocumentItem AS b ON a~BillingDocument = b~BillingDocument
      LEFT JOIN I_BillingDocItemPrcgElmntBasic AS d ON a~BillingDocument = d~BillingDocument AND b~BillingDocumentItem = d~BillingDocumentItem
      LEFT JOIN i_product AS c ON b~Product = c~Product
       FIELDS
       SUM( d~ConditionBaseAmount ) AS ConditionBaseAmount,
       SUM( d~ConditionAmount ) AS ConditionAmount
       WHERE a~BillingDocument = @ls_item-BillingDocument
       AND ConditionType IN ( 'ZTCS','ZSCP' )
       INTO @DATA(pricingelement).

      SELECT SINGLE FROM  I_BillingDocument AS a
      LEFT JOIN I_BillingDocumentItem AS b ON a~BillingDocument = b~BillingDocument
      LEFT JOIN I_BillingDocItemPrcgElmntBasic AS d ON a~BillingDocument = d~BillingDocument AND b~BillingDocumentItem = d~BillingDocumentItem
      LEFT JOIN i_product AS c ON b~Product = c~Product
      FIELDS
      SUM( d~ConditionAmount )  AS ConditionBaseAmount
      WHERE a~BillingDocument = @ls_item-BillingDocument
      AND c~ProductType NE 'ZNVM'
      AND d~ConditionType IN ( 'ZPR1','JOCG','JOSG','JOIG' )
      INTO @DATA(breadcondition).

      ls_response-TCS_Base_Amount = pricingelement-conditionbaseamount.
      ls_response-TCS_Amount = pricingelement-conditionamount.
      ls_response-TCS_Deduction_Rate = 1.

      IF ls_item-SalesOrganization = 'BI00' OR ls_item-SalesOrganization = 'CA00' OR ls_item-SalesOrganization = 'BN00'.
        ls_response-TCS_Base_Amount = breadcondition.
      ENDIF.

      IF ls_item-BillingDocumentType = 'S1' OR ls_item-BillingDocumentType = 'CBRE'.
        ls_response-TCS_Deduction_Rate = (    ls_response-TCS_Deduction_Rate * -1 ).
        ls_response-TCS_Base_Amount = ( pricingelement-conditionbaseamount * -1 ).
        ls_response-TCS_Amount = ( pricingelement-conditionamount * -1 ).
      ENDIF.


      APPEND ls_response TO lt_response.
      CLEAR : ls_response,pricingelement,ls_item.
    ENDLOOP.


    DELETE lt_response WHERE TCS_Amount = 0.
****************************************************
    lv_max_rows = lv_skip + lv_top.
    IF lv_skip > 0.
      lv_skip = lv_skip + 1.
    ENDIF.

    CLEAR lt_responseout.
    LOOP AT lt_response ASSIGNING FIELD-SYMBOL(<lfs_out_line_item>) FROM lv_skip TO lv_max_rows.
      ls_responseout = <lfs_out_line_item>.
      APPEND ls_responseout TO lt_responseout.
    ENDLOOP.

    io_response->set_total_number_of_records( lines( lt_response ) ).
    io_response->set_data( lt_responseout ).

  ENDMETHOD.

ENDCLASS.
