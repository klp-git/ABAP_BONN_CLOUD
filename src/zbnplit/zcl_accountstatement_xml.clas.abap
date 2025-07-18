CLASS zcl_accountstatement_xml DEFINITION
   PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-DATA : access_token TYPE string .
    CLASS-DATA : xml_file TYPE string .
    TYPES :
      BEGIN OF struct,
        xdp_template TYPE string,
        xml_data     TYPE string,
        form_type    TYPE string,
        form_locale  TYPE string,
        tagged_pdf   TYPE string,
        embed_font   TYPE string,
      END OF struct.


    CLASS-METHODS :
      create_client
        IMPORTING url           TYPE string
        RETURNING VALUE(result) TYPE REF TO if_web_http_client
        RAISING   cx_static_check ,

      read_posts
        IMPORTING
                  pCompanyCode     TYPE string
                  pCust_Supp       TYPE string
                  pFromDate        TYPE string
                  pToDate          TYPE string
                  lc_template_name TYPE string
        RETURNING VALUE(result12)  TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.

ENDCLASS.



CLASS zcl_accountstatement_xml IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts .
    DATA(todaydate) = cl_abap_context_info=>get_system_date( ).
    todaydate = todaydate+6(2) && '/' &&
                    todaydate+4(2) && '/' &&
                    todaydate(4).
    DATA(FromDateTodate) = |Period From { pFromDate } Period To { pToDate }|.

    SELECT SINGLE
     a~address1,
     a~address2,
     a~city,
     a~STATE_Name,
     a~pin,
     a~country,
     a~GSTin_No,
     a~PAN_No,
     a~Cin_No,
     a~plant_name1
     FROM ztable_plant AS a
     WHERE a~comp_code = @pCompanyCode

     INTO  @DATA(Plant_address).

    IF Plant_address IS NOT INITIAL.
      DATA(lv_plant_address) = |{ Plant_address-address1 }, { Plant_address-address2 }, { Plant_address-city }, { Plant_address-state_name }-{ Plant_address-pin }|.
    ELSE.
      lv_plant_address = ' '.
    ENDIF.


    SELECT
        a~*

         FROM ZUI_AccountStatement( pcompanycode = @pcompanycode,
         pcust_supp = @pcust_supp, pfromdate = @pfromdate,
         ptodate = @ptodate, pisrevdoc = 'N'
         ) AS a
         WHERE a~partycode = @pcust_supp
         ORDER BY a~srno DESCENDING
         INTO TABLE @DATA(ACStmtData).



  IF ACStmtData IS NOT INITIAL.

  SELECT SINGLE a~* FROM @ACStmtData AS a WHERE a~AccountingDocumentType = 'OB'
    INTO @DATA(opbalrow) .

    SELECT SINGLE a~*
    from ZDIM_BusinessPartner as a
    where BusinessPartner = @pcust_supp
    into @Data(bprow).

    DATA(lv_xml) =
     |<form1>| &&
     |<plantname>{ Plant_address-plant_name1 }</plantname>| &&
     |<address1>{ lv_plant_address }</address1>| &&
     |<CINNO>{ Plant_address-cin_no }</CINNO>| &&
     |<GSTIN>{ Plant_address-gstin_no }</GSTIN>| &&
     |<PAN>{ Plant_address-pan_no }</PAN>| &&
     |<REPORTDATE>{ todaydate }</REPORTDATE>| &&
     |<FromDateTodate>{ FromDateTodate }</FromDateTodate>| &&
     |<LeftSide>| &&
     |<partyno>{ bprow-BusinessPartnerFullName }</partyno>| &&
     |<ccode>({ bprow-BusinessPartner })</ccode>| &&
     |<companyCode>{ pCompanyCode }</companyCode>| &&
     |<partyno2></partyno2>| &&
     |<partyno3></partyno3>| &&
     |<partyadd></partyadd>| &&
     |<partynumbername></partynumbername>| &&
     |<partyadd1></partyadd1>| &&
     |<PHNNO></PHNNO>| &&
     |<EMAIL></EMAIL>| &&
     |<Subform7/>| &&
     |</LeftSide>| &&
     |<RightSide>| &&
     |<openingdate>{ opbalrow-postingdate }</openingdate>| &&
     |<openingBal>{ opbalrow-runningbalance }</openingBal>| &&
     |<OpeningBalance>{ opbalrow-runningbalance }</OpeningBalance>| &&

     |<ToDate>{ pToDate }</ToDate>| &&
     |<Page>| &&
     |<HaderData>| &&
     |<RightSide>| &&
     |<StationNo></StationNo>| &&
     |</RightSide>| &&
     |</HaderData>| &&
     |</Page>| &&
     |</RightSide>| .



    LOOP AT ACStmtData INTO DATA(wa_final).

      lv_xml = lv_xml &&
         |<LopTab>| &&
         |<Row1>| &&
*         |<invoicedate>{ invdt }</invoicedate>| &&
         |<docdate>{ wa_final-postingdate+6(2) }.{ wa_final-postingdate+4(2) }.{ wa_final-postingdate+0(4) }</docdate>| &&
         |<JournalEntry>{  wa_final-AccountingDocument WIDTH = 10 ALIGN = RIGHT PAD = '0' }</JournalEntry>| &&
         |<naration>{ wa_final-documentitemtext  }</naration>| &&
         |<debitamt>{ wa_final-debitamountincmpcdcrcy }</debitamt>| &&
         |<creditamt>{ wa_final-creditamountincmpcdcrcy }</creditamt>| &&
         |<Balance>{ wa_final-runningbalance } { wa_final-Sign }</Balance>| &&
         |</Row1>| &&
         |</LopTab>|.

    ENDLOOP.

    SELECT SINGLE a~* FROM @ACStmtData AS a
    WHERE a~SRNO = 1
    INTO @DATA(closing).


    lv_xml = lv_xml &&
       |<Subform3>| &&
       |<Table3>| &&
       |<Row1>| &&
       |<closingbl>{ closing-runningbalance }</closingbl>| &&
       |</Row1>| &&
       |</Table3>| &&
       |</Subform3>| &&
       |</form1>| .



    REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH '&amp;' .
    "Please don't delete this line
*    REPLACE ALL OCCURRENCES OF ` ` IN lv_xml WITH `_` .
    CONDENSE lv_xml.

*      result12 = lv_xml.

    CALL METHOD zcl_ads_master=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).
  ELSE.
    result12   = 'No record found.'.
  ENDIF.


ENDMETHOD .
ENDCLASS.
