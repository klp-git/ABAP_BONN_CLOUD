CLASS zcl_accountstatement_http DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_http_service_extension.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_accountstatement_http IMPLEMENTATION.
  METHOD if_http_service_extension~handle_request.
    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).
    DATA(req_method) = request->get_method( ).

  CASE req_method.
      WHEN CONV string( if_web_http_client=>post ).

        DATA(pCompanyCode) = request->get_form_field( `pCompanyCode` ).
        DATA(pCust_Supp) = request->get_form_field( `pCust_Supp` ).
        DATA(pFromDate) = request->get_form_field( `pFromDate` ).
        DATA(pToDate) = request->get_form_field( `pToDate` ).

        IF pCompanyCode IS INITIAL OR
           pCust_Supp IS INITIAL OR
           pFromDate IS INITIAL OR
           pToDate IS INITIAL.

          response->set_status( i_code = 500 ).
          response->set_text( |Please submit valid request| ).

        ELSE.


          TRY.
              DATA(pdf_content) = zcl_accountstatement_xml=>read_posts(
*                pCompanyCode = 'BBPL'
*                pCust_Supp = '0011000001'
*                pFromDate = '20250101'
*                pToDate = '20250628'
                pCompanyCode = pCompanyCode
                pCust_Supp = pCust_Supp
                pFromDate = pFromDate
                pToDate = pToDate
                lc_template_name = 'ZUI_ACCOUNTSTMT/ZUI_ACCOUNTSTMT'
              ).

              response->set_text( pdf_content ).

            CATCH cx_static_check INTO DATA(lx_static).
              response->set_status( i_code = 500 ).
              response->set_text( lx_static->get_text( ) ).
              response->set_status( i_code = 500 ).

            CATCH cx_root INTO DATA(lx_root).
              response->set_text( lx_root->get_text( ) ).
          ENDTRY.
        ENDIF.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
