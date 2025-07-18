CLASS zcl_rplcnglpost DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_apj_dt_exec_object .
  INTERFACES if_apj_rt_exec_object .


  INTERFACES if_oo_adt_classrun.

  CLASS-METHODS runJob
   IMPORTING paramcmno TYPE C.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_RPLCNGLPOST IMPLEMENTATION.


    METHOD if_apj_dt_exec_object~get_parameters.
        " Return the supported selection parameters here
        et_parameter_def = VALUE #(
          ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 80 param_text = 'Outgoing Credit Note'   lowercase_ind = abap_true changeable_ind = abap_true )
        ).

        " Return the default parameters values here
        et_parameter_val = VALUE #(
          ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'Outgoing Credit Note' )
        ).

    ENDMETHOD.


    METHOD if_apj_rt_exec_object~execute.
      DATA p_descr TYPE c LENGTH 80.

      " Getting the actual parameter values
      LOOP AT it_parameters INTO DATA(ls_parameter).
        CASE ls_parameter-selname.
          WHEN 'P_DESCR'. p_descr = ls_parameter-low.
        ENDCASE.
      ENDLOOP.
      runJob( p_descr ).
    ENDMETHOD.


    METHOD if_oo_adt_classrun~main .
        runJob( 'ABCD' ).
    ENDMETHOD.


    METHOD runJob.

      DATA plantno TYPE char05.
      DATA companycode TYPE c LENGTH 5.
      DATA cmno       TYPE  c LENGTH 10.
      DATA cmfyear    TYPE  c LENGTH 4.

      DATA gateentryno TYPE c LENGTH 20.
      DATA costcenter TYPE c LENGTH 10.
      DATA customercode TYPE c LENGTH 20.
      DATA glaccount TYPE c LENGTH 10.

****         SJ 02-04-25 start to Get GLs ************
      SELECT SINGLE FROM zintegration_tab WITH PRIVILEGED ACCESS
         FIELDS intgmodule,intgpath
         WHERE intgmodule = `ReplCN-GL`
         INTO  @DATA(wa_GL).

****         SJ 02-04-25 end to Get GLs ************

*        DATA lt_header TYPE TABLE FOR CREATE I_MaterialDocumentTP.
*        DATA lt_line TYPE TABLE FOR CREATE I_MaterialDocumentTP\_MaterialDocumentItem.
*        FIELD-SYMBOLS <ls_line> like line of lt_line.
*        DATA lt_target LIKE <ls_line>-%target.

      DATA localparamno TYPE c LENGTH 6.
      localparamno = paramcmno.
      IF localparamno = ''.
        SELECT FROM zdt_rplcrnote
       FIELDS comp_code, imfyear, imno, imdate, implant, location, imtype , imcramt, imdealercode
       WHERE glposted = ''
       INTO TABLE @DATA(ltcrdata).
      ELSE.
        SELECT FROM zdt_rplcrnote
         FIELDS comp_code, imfyear, imno, imdate, implant, location, imtype , imcramt, imdealercode
         WHERE glposted = '' AND imno = @localparamno
         INTO TABLE @ltcrdata.
      ENDIF.


      LOOP AT ltcrdata ASSIGNING FIELD-SYMBOL(<ls_crdata>).
        companycode = <ls_crdata>-comp_code.
        plantno = <ls_crdata>-implant.
        cmno    = <ls_crdata>-imno.
        cmfyear = <ls_crdata>-imfyear.
        customercode = ''.
        SELECT FROM I_BusinessPartner AS ibp
            FIELDS BusinessPartner
            WHERE ibp~BusinessPartnerIDByExtSystem = @<ls_crdata>-imdealercode
        INTO TABLE @DATA(lt_customer).
        IF lt_customer IS NOT INITIAL .
          LOOP AT lt_customer INTO DATA(wa_customer).
            customercode = wa_customer-BusinessPartner.
          ENDLOOP.
        ENDIF.
        IF customercode <> ''.
          SELECT FROM ztable_plant AS pt
              FIELDS pt~costcenter
              WHERE pt~comp_code = @companycode
              AND pt~plant_code = @plantno
          INTO TABLE @DATA(ltPlant).
          IF ltPlant IS NOT INITIAL.
            DATA: lt_je_deep TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
                  lv_cid     TYPE abp_behv_cid.

            LOOP AT ltPlant INTO DATA(waplant).
              costcenter = waplant-costcenter.
            ENDLOOP.



            TRY.
                lv_cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
              CATCH cx_uuid_error.
                ASSERT 1 = 0.
            ENDTRY.

            APPEND INITIAL LINE TO lt_je_deep ASSIGNING FIELD-SYMBOL(<je_deep>).
            <je_deep>-%cid = lv_cid.

            <je_deep>-%param = VALUE #(
            companycode = companycode
            businesstransactiontype = 'RFBU'
            accountingdocumenttype = 'DG'

            CreatedByUser = sy-uname
            documentdate = <ls_crdata>-imdate
            postingdate = <ls_crdata>-imdate
            accountingdocumentheadertext = <ls_crdata>-comp_code && <ls_crdata>-implant
                                            && <ls_crdata>-imfyear && <ls_crdata>-imtype
                                            && <ls_crdata>-imno

            _aritems = VALUE #(
                                ( glaccountlineitem = |001|
*                                          glaccount = '12213000'
                                    Customer = customercode
                                    BusinessPlace = <ls_crdata>-implant
                                  _currencyamount = VALUE #( (
                                                    currencyrole = '00'
                                                    journalentryitemamount = -1 * <ls_crdata>-imcramt
                                                    currency = 'INR' ) ) )
                               )

             _glitems = VALUE #(

                                    ( glaccountlineitem = |002|
                                  glaccount = wa_GL-intgpath
                                 CostCenter = costcenter
*                                            BusinessPlace = <ls_crdata>-implant
                                  _currencyamount = VALUE #( (
                                                    currencyrole = '00'
                                                    journalentryitemamount = <ls_crdata>-imcramt
                                                    currency = 'INR' ) ) )
                                )
            ).


            MODIFY ENTITIES OF i_journalentrytp PRIVILEGED
            ENTITY journalentry
            EXECUTE post FROM lt_je_deep
            FAILED DATA(ls_failed_deep)
            REPORTED DATA(ls_reported_deep)
            MAPPED DATA(ls_mapped_deep).
            DATA: lv_cust_result TYPE char256.



            IF ls_failed_deep IS NOT INITIAL.

              LOOP AT ls_reported_deep-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported_deep>).

                lv_cust_result = <ls_reported_deep>-%msg->if_message~get_text( ).

*                         DATA(lv_result) = <ls_reported_deep>-%msg->if_message~get_text( ).
                ...
              ENDLOOP.

              UPDATE zdt_rplcrnote
                    SET glerror_log = @lv_cust_result
                  WHERE comp_code = @companycode AND implant = @plantno AND imfyear = @cmfyear
                      AND imtype =  @<ls_crdata>-imtype  AND imno = @cmno AND imdealercode = @<ls_crdata>-imdealercode .
              CLEAR : lv_cust_result.
            ELSE.

              COMMIT ENTITIES BEGIN
              RESPONSE OF i_journalentrytp
              FAILED DATA(lt_commit_failed)
              REPORTED DATA(lt_commit_reported).

              COMMIT ENTITIES END.

              IF lt_commit_failed IS INITIAL.
                DATA: jeno TYPE char72.
                DATA : acctdoc TYPE c LENGTH 30.
                jeno = <ls_crdata>-comp_code && <ls_crdata>-implant
                        && <ls_crdata>-imfyear && <ls_crdata>-imtype
                        && <ls_crdata>-imno .

                SELECT FROM I_JournalEntry AS ij
                FIELDS AccountingDocument, AccountingDocumentType
                WHERE ij~AccountingDocumentHeaderText = @jeno
*                            and ij~CompanyCode = @companycode and ij~FiscalYear = @cmfyear
*                            and ij~PostingDate = @<ls_crdata>-imdate
                INTO TABLE @DATA(ltJE).
                IF ltje IS NOT INITIAL.
                  LOOP AT ltje INTO DATA(wa_ltje).
                    acctdoc = wa_ltje-AccountingDocument.
                  ENDLOOP.
                ENDIF.

                UPDATE zdt_rplcrnote
                    SET glposted = '1',
                     glerror_log = ``,
                     dealercrdoc = @acctdoc
                    WHERE comp_code = @companycode AND implant = @plantno AND imfyear = @cmfyear
                    AND imtype =  @<ls_crdata>-imtype  AND imno = @cmno AND imdealercode = @<ls_crdata>-imdealercode.

              ENDIF.
              CLEAR : lt_commit_failed, lt_commit_reported.
            ENDIF.
            CLEAR : lt_je_deep.
            CLEAR : ltplant.
          ENDIF.
        ELSE .
          DATA strError TYPE c LENGTH 40 .
          strError = <ls_crdata>-imdealercode && ` Customer doesnot exist.`.
          UPDATE zdt_rplcrnote
            SET glerror_log =  @strError
          WHERE comp_code = @companycode AND implant = @plantno AND imfyear = @cmfyear
              AND imtype =  @<ls_crdata>-imtype  AND imno = @cmno AND imdealercode = @<ls_crdata>-imdealercode .

        ENDIF.

      ENDLOOP.

    ENDMETHOD.
ENDCLASS.
