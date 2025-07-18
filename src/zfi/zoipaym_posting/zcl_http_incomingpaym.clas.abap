class ZCL_HTTP_INCOMINGPAYM definition
  public
  create public .

PUBLIC SECTION.

  INTERFACES if_http_service_extension .

  CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.
  CLASS-METHODS saveData
    IMPORTING
      VALUE(request) TYPE REF TO if_web_http_request
    RETURNING
      VALUE(message) TYPE string .

  CLASS-METHODS get_next_letter
    IMPORTING
      !iv_last_letter       TYPE c
    RETURNING
      VALUE(rv_next_letter) TYPE  string.


protected section.
private section.
ENDCLASS.



CLASS ZCL_HTTP_INCOMINGPAYM IMPLEMENTATION.


      METHOD getCID.
        TRY.
            cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
          CATCH cx_uuid_error.
            ASSERT 1 = 0.
        ENDTRY.
      ENDMETHOD.


  METHOD get_next_letter.
    CONSTANTS lc_letters TYPE string VALUE 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890qwertyuiopasdfghjklzxcvbnm'.
    DATA lv_index TYPE i.

    IF iv_last_letter IS INITIAL.
      rv_next_letter = 'A'.
      RETURN.
    ENDIF.

    FIND SUBSTRING iv_last_letter IN lc_letters MATCH OFFSET lv_index.

    IF sy-subrc = 0.
      lv_index = lv_index + 1.
      IF lv_index < strlen( lc_letters ).
        rv_next_letter = lc_letters+lv_index(1).
      ELSE.
        rv_next_letter = 'A'.
      ENDIF.
    ELSE.
      rv_next_letter = 'A'.
    ENDIF.
  ENDMETHOD.


      METHOD IF_HTTP_SERVICE_EXTENSION~HANDLE_REQUEST.

        CASE request->get_method(  ).
          WHEN CONV string( if_web_http_client=>post ).
           response->set_text( saveData( request ) ).

        ENDCASE.


      ENDMETHOD.


      METHOD saveData.

        DATA: lv_oipaym TYPE TABLE OF zr_oipayments,
              wa_oipaym TYPE zr_oipayments.

        TYPES: BEGIN OF ty_json_structure,
                 companycode   TYPE c LENGTH 4,
                 documentdate  TYPE c LENGTH 10,
                 postingdate  TYPE c LENGTH 10,
                 currencycode  TYPE c LENGTH 3,
                 bpartner      TYPE c LENGTH 10,
                 glamount      TYPE p LENGTH 16 DECIMALS 2,
                 businessplace TYPE c LENGTH 10,
                 sectioncode   TYPE c LENGTH 10,
                 gltext        TYPE c LENGTH 100,
                 glaccount     TYPE c LENGTH 10,
                 housebank     TYPE c LENGTH 10,
                 accountid     TYPE c LENGTH 10,
                 profitcenter  TYPE c LENGTH 10,
                 assignmentreference TYPE c LENGTH 18,
               END OF ty_json_structure.

        DATA tt_json_structure TYPE TABLE OF ty_json_structure WITH EMPTY KEY.

        TRY.

            xco_cp_json=>data->from_string( request->get_text( ) )->write_to( REF #( tt_json_structure ) ).

            LOOP AT tt_json_structure INTO DATA(wa).
   DATA special_gl_code TYPE zr_oipayments-SpecialGlCode.

          DATA(cid) = getcid( ).
          DATA(createdtime) = cl_abap_context_info=>get_system_time( ).
          DATA(bpPartner) = |{ wa-Bpartner ALPHA = IN }|.


*       check record arleady exists
          SELECT  FROM zr_oipayments
             FIELDS SpecialGlCode
             WHERE Companycode = @wa-Companycode
               AND Documentdate = @wa-Documentdate
               AND Bpartner = @bpPartner
               AND Createdtime = @Createdtime
               AND type = 'INCO'
               AND Isdeleted = '' AND Isposted = ''
             ORDER BY SpecialGlCode DESCENDING
               INTO TABLE @DATA(ls_special_gl_code).

          IF ls_special_gl_code IS INITIAL.
            special_gl_code = 'A'.
          ELSE.
            special_gl_code = get_next_letter( ls_special_gl_code[ 1 ]-SpecialGlCode ).
          ENDIF.
              MODIFY ENTITIES OF zr_oipayments
             ENTITY ZrOipayments
             CREATE FIELDS (
                  Companycode
                  Documentdate
                  Postingdate
                  Bpartner
                  Currencycode
                  Glamount
                  Type
                  Businessplace
                  Sectioncode
                  Gltext
                  Glaccount
                  Housebank
                  Accountid
                  Profitcenter
                  Createdtime
                  SpecialGlCode
                  AccountingDocumenttype
                  Assignmentreference )
             WITH VALUE #( (
                  %cid = cid
                  Companycode = wa-Companycode
                  Documentdate = wa-Documentdate
                  Postingdate = wa-postingdate
                  Bpartner =  bppartner
                  Currencycode = wa-Currencycode
                  Glamount = wa-Glamount
                  Type = 'INCO'
                  Businessplace = wa-Businessplace
                  Sectioncode = wa-Sectioncode
                  Gltext = wa-Gltext
                  Glaccount = wa-Glaccount
                  Housebank = wa-Housebank
                  Accountid = wa-Accountid
                  Profitcenter = wa-Profitcenter
                  Createdtime = createdtime
                  SpecialGlCode = special_gl_code
                  AccountingDocumenttype = 'DZ'
                  Assignmentreference = wa-Assignmentreference
                  ) )
              REPORTED DATA(ls_po_reported)
              FAILED   DATA(ls_po_failed)
              MAPPED   DATA(ls_po_mapped).

              COMMIT ENTITIES BEGIN
                 RESPONSE OF zr_oipayments
                 FAILED DATA(ls_save_failed)
                 REPORTED DATA(ls_save_reported).

              IF ls_po_failed IS NOT INITIAL OR ls_save_failed IS NOT INITIAL.
                message = 'Failed to save data'.
              ELSE.
                message = 'Data saved successfully'.
              ENDIF.

              COMMIT ENTITIES END.
            ENDLOOP.

          CATCH cx_root INTO DATA(lx_root).
            message = |General Error: { lx_root->get_text( ) }|.
        ENDTRY.


      ENDMETHOD.
ENDCLASS.
