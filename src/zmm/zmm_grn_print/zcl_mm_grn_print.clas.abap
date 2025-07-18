CLASS zcl_mm_grn_print DEFINITION
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
      END OF struct."
    CLASS-METHODS :
      create_client
        IMPORTING url           TYPE string
        RETURNING VALUE(result) TYPE REF TO if_web_http_client
        RAISING   cx_static_check ,

      read_posts
        IMPORTING cleardoc        TYPE string
                  lv_fiscal type string
                  lv_company type string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'ZMM_GRN_PRINT/ZMM_GRN_PRINT'."'zpo/zpo_v2'."
*    CONSTANTS lc_template_name TYPE 'HDFC_CHECK/HDFC_MULTI_FINAL_CHECK'.
ENDCLASS.



CLASS ZCL_MM_GRN_PRINT IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts .

  TYPES: BEGIN OF ty_item,
         MATERIALDOCUMENT        TYPE I_MATERIALDOCUMENTITEM_2-MATERIALDOCUMENT,
         MATERIALDOCUMENTYEAR    TYPE I_MATERIALDOCUMENTITEM_2-MATERIALDOCUMENTYEAR,
         COMPANYCODE             TYPE I_MATERIALDOCUMENTITEM_2-COMPANYCODE,
         PURCHASEORDER           TYPE I_MATERIALDOCUMENTITEM_2-PURCHASEORDER,
         PURCHASEORDERITEM       TYPE I_MATERIALDOCUMENTITEM_2-PURCHASEORDERITEM,
         QUANTITYINENTRYUNIT     TYPE I_MATERIALDOCUMENTITEM_2-QUANTITYINENTRYUNIT,
         ENTRYUNIT               TYPE I_MATERIALDOCUMENTITEM_2-ENTRYUNIT,
         MATERIAL                TYPE I_MATERIALDOCUMENTITEM_2-MATERIAL,
*         GOODSMOVEMENTTYPE         TYPE I_MaterialDocumentItem_2-GoodsMovementType,
         PURCHASEORDERITEMTEXT   TYPE I_PURCHASEORDERITEMAPI01-PURCHASEORDERITEMTEXT,
         NETPRICEAMOUNT          TYPE I_PURCHASEORDERITEMAPI01-NETPRICEAMOUNT,
         CONSUMPTIONTAXCTRLCODE  TYPE I_PRODUCTPLANTINTLTRD-CONSUMPTIONTAXCTRLCODE,
         GATEENTRYNO             TYPE zgateentryheader-gateentryno,
         GATEQTY                 TYPE zgateentrylines-gateqty,
       END OF ty_item.

  DATA: it_item TYPE TABLE OF ty_item,
      wa_item TYPE ty_item.

  SELECT SINGLE
  a~MATERIALDOCUMENT,
  a~MATERIALDOCUMENTYEAR,
  a~GoodsMovementType,
  a~companycode,
  a~plant,
  a~POSTINGDATE,
  a~Goodsmovementiscancelled,
  b~Plant_name1,   """""""""""""""""""""company Name
  b~ADDRESS1,   """""""""""""""plant add
  b~ADDRESS2,
  b~ADDRESS3,
  b~CITY,
  b~Pin,
  b~State_code2,
  b~state_name,
  b~state_code1,
  b~gstin_no,    """""""""""""""plant add
  a~PURCHASEORDER,     """"""""""""""it is used for supplier
  c~supplier,   """""""""""" this is supplier Code
  c~supplyingplant,
  d~SupplierFullName,
  d~SupplierName,  """"""""""""'supplier Name
  d~AddressID,
  d~TaxNumber3,
  e~street,
  e~streetprefixname1,
  e~streetprefixname2,
  e~POBoxPostalCode,
  e~region,              """"""" it is used for joining
  f~regionname,
  h~MATERIALDOCUMENTHEADERTEXT,
  g~INVOICENO,
  g~INVOICEDATE,
  g~vehicleno

  FROM I_MATERIALDOCUMENTITEM_2 WITH PRIVILEGED ACCESS as a
  LEFT JOIN ZTABLE_PLANT WITH PRIVILEGED ACCESS as b on a~plant = b~plant_code
  LEFT JOIN I_PURCHASEORDERAPI01 WITH PRIVILEGED ACCESS as c on a~PurchaseOrder = c~PurchaseOrder
  LEFT JOIN  i_supplier WITH PRIVILEGED ACCESS as d on c~Supplier = d~Supplier
  left JOIN I_ADDRESS_2 WITH PRIVILEGED ACCESS as e on d~AddressID = e~AddressID
  LEFT JOIN  I_regiontext WITH PRIVILEGED ACCESS as f on e~Region = f~Region AND f~Country = 'IN'
  LEFT JOIN  I_MATERIALDOCUMENTHEADER_2 WITH PRIVILEGED ACCESS as h on ( a~MaterialDocument = h~MaterialDocument AND a~MaterialDocumentYear = h~MaterialDocumentYear )
  LEFT JOIN ZGATEENTRYHEADER WITH PRIVILEGED ACCESS as g on h~MATERIALDOCUMENTHEADERTEXT = g~gateentryno

  WHERE a~MaterialDocument = @cleardoc AND a~MaterialDocumentYear = @lv_fiscal
  AND a~CompanyCode = @lv_company
  INTO @DATA(header).


IF header-supplier IS INITIAL.
DATA(lv_supplyingplant) = |CV{ header-supplyingplant }|.
  SELECT SINGLE
    d~supplier,
    d~SupplierFullName,
    d~AddressID
    from I_Supplier AS d
    WHERE d~Supplier = @lv_supplyingplant
    INTO ( @header-supplier, @header-SupplierFullName, @header-AddressID ).
ENDIF.
clear : lv_supplyingplant.

  data plant_add type string.
  CONCATENATE header-address1 header-address2 header-address3 header-city header-pin header-state_code2 header-state_name into plant_add SEPARATED BY space.
  """""""""""""""supplier name and code"""""""""""""
  DATA str2 type string.
  CONCATENATE header-Supplier header-SupplierName INTO str2 SEPARATED BY '-'.
  """"""""""""supplier add"""""""""""""""""""""""""""
  data str3 type string.
  CONCATENATE header-Street header-streetprefixname1 header-streetprefixname2 header-POBoxPostalCode INTO str3 SEPARATED BY space.
  """"""""""""""""""plant state and code""""""""""""""""""""""""""""
  data str7 type string.
  CONCATENATE header-state_name header-state_code1 INTO str7 SEPARATED BY '-'.

  data str9 type string.
  CONCATENATE header-RegionName header-Region INTO str9 SEPARATED BY ' - '.
  data str8 type string.
 """"""""""""""""""""""""""""""""""""""line item""""""""""""""""""""""

  SELECT
  a~MATERIALDOCUMENT,
  a~MATERIALDOCUMENTYEAR,
  a~companycode,
  a~PURCHASEORDER,
  a~PURCHASEORDERITEM,
  a~QUANTITYINENTRYUNIT,
  a~ENTRYUNIT,
  a~material,
  b~PURCHASEORDERITEMTEXT,
  b~NETPRICEAMOUNT,
  c~CONSUMPTIONTAXCTRLCODE,
  g~gateentryno
*  i~gateqty
  FROM I_MATERIALDOCUMENTITEM_2 WITH PRIVILEGED ACCESS as a
  LEFT JOIN I_PURCHASEORDERITEMAPI01 WITH PRIVILEGED ACCESS as b on a~PurchaseOrder = b~PurchaseOrder and a~PurchaseOrderItem = b~PurchaseOrderItem
  AND a~PurchaseOrderItem = b~PurchaseOrderItem
 LEFT JOIN I_PRODUCTPLANTINTLTRD WITH PRIVILEGED ACCESS as c on a~Material = c~Product  AND a~Plant = c~Plant
 LEFT JOIN  I_MATERIALDOCUMENTHEADER_2 WITH PRIVILEGED ACCESS as h on a~MaterialDocument = h~MaterialDocument
    AND a~MaterialDocumentYear = h~MaterialDocumentYear
  LEFT JOIN zgateentryheader WITH PRIVILEGED ACCESS as g on h~MATERIALDOCUMENTHEADERTEXT = g~gateentryno
*  left join I_MATERIALDOCUMENTITEM_2 WITH PRIVILEGED ACCESS  as i
*  LEFT JOIN zgateentrylines WITH PRIVILEGED ACCESS as i on h~MATERIALDOCUMENTHEADERTEXT = i~gateentryno and a~PurchaseOrder = i~documentno
*   and a~PurchaseOrderItem = i~documentitemno
  WHERE a~MaterialDocument = @cleardoc
  AND a~MaterialDocumentYear = @lv_fiscal
  AND a~CompanyCode = @lv_company
  AND (
        ( a~GoodsMovementType = '101' AND a~PurchaseOrder is not initial )
        OR a~GoodsMovementType = '305'
      )

  INTO TABLE @it_item.
  sort it_item by MaterialDocument MaterialDocumentYear PurchaseOrder PurchaseOrderItem gateentryno.

  LOOP AT it_item INTO wa_item.
   SELECT SINGLE gateqty
    FROM zgateentrylines
    WHERE gateentryno     = @wa_item-gateentryno
      AND documentno      = @wa_item-purchaseorder
      AND documentitemno  = @wa_item-purchaseorderitem
          INTO @wa_item-gateqty.
    MODIFY it_item FROM wa_item TRANSPORTING gateqty.
  ENDLOOP.

 if header-Goodsmovementiscancelled is NOT INITIAL  .
    str8 = 'Cancelled'.
 ENDIF.

  DATA(lv_xml) =
  |<Form>| &&
  |<Header>| &&
  |<Company_Name>{ header-plant_name1 }</Company_Name>| &&
  |<CompanyCode>{ header-CompanyCode }</CompanyCode>| &&
  |<Plant_Add>{ plant_add }</Plant_Add>| &&
  |<Pb_Tel>{ str7 }</Pb_Tel>| &&
  |<GSTIN_NO>{ header-gstin_no }</GSTIN_NO>| &&
  |<Supplier_Name>{ header-SupplierName }</Supplier_Name>| &&
  |<Supplier_Code>{ header-Supplier }</Supplier_Code>| &&
  |<Supplier_State_Code></Supplier_State_Code>| &&
  |<Supplier_State>{ str9 }</Supplier_State>| &&
  |<Supplier_Add>{ str3 }</Supplier_Add>| &&
  |<Supplier_GSTIN>{ header-TaxNumber3 }</Supplier_GSTIN>| &&
  |<GRN_NO>{ header-MaterialDocument }</GRN_NO>| &&
  |<GRN_Date>{ header-PostingDate }</GRN_Date>| &&
  |<Bill_No>{ header-invoiceno }</Bill_No>| &&
  |<Bill_Date>{ header-invoicedate }</Bill_Date>| &&
  |<Vehical_number>{ header-vehicleno }</Vehical_number>| &&
  |<Gate_entry>{ header-MaterialDocumentHeaderText }</Gate_entry>| &&
  |<Goods_Canceled>{ str8 }</Goods_Canceled>| &&
  |<Goods_Mov_type>{ header-GoodsMovementType }</Goods_Mov_type>| &&
  |</Header>| &&
  |<Line_Item>| .

 data str4 type string.
 data str5 type string.
 data str6 type string.
 data str10 type string.
 data str11 type string.


  LOOP AT it_item INTO DATA(wa_it_item).
   str10 = wa_it_item-PurchaseOrderItem.
   SHIFT str10 LEFT DELETING LEADING '0'.
 CONCATENATE wa_it_item-PurchaseOrder str10 INTO str4 SEPARATED BY '-'.

  str5 = wa_it_item-QUANTITYINENTRYUNIT * wa_it_item-NetPriceAmount.
*  CONCATENATE wa_it_item-Material wa_it_item-PurchaseOrderItemText INTO str6 SEPARATED BY '-'.

 str11 = wa_it_item-Material.
 SHIFT str11 LEFT DELETING LEADING '0'.

 SELECT SINGLE
 a~PRODUCT,
 a~PRODUCTNAME

 FROM I_PRODUCTTEXT WITH PRIVILEGED ACCESS as a
 WHERE a~Product = @wa_it_item-Material
 INTO @DATA(str12).

 if wa_it_item-PurchaseOrderItemText is INITIAL.
        wa_it_item-PurchaseOrderItemText = str12-ProductName.
 ENDIF.

CONCATENATE wa_it_item-PurchaseOrderItemText str11 INTO str6
  SEPARATED BY cl_abap_char_utilities=>newline.


   DATA(lv_xml_item) =
   |<Item>| &&
   |<Sr_No></Sr_No>| &&
   |<item>{ wa_it_item-material }</item>| &&
   |<Description_of_goods>{ wa_it_item-purchaseorderitemtext }</Description_of_goods>| &&
   |<material>{ str11 }</material>| &&
   |<HSN_SAG_NO>{ wa_it_item-ConsumptionTaxCtrlCode }</HSN_SAG_NO>| &&
   |<A_C_Posting></A_C_Posting>| &&
   |<Po_Indent_No>{ str4 }</Po_Indent_No>| &&
   |<Uom>{ wa_it_item-ENTRYUNIT }</Uom>| &&
   |<Qty>{ wa_it_item-QUANTITYINENTRYUNIT }</Qty>| &&
   |<gate_qty>{ wa_it_item-gateqty }</gate_qty>| &&
   |<Rate>{ wa_it_item-NetPriceAmount }</Rate>| &&
   |<Total>{ str5 }</Total>| &&
   |</Item>|.

 CONCATENATE lv_xml lv_xml_item INTO lv_xml.
  ENDLOOP.

 CONCATENATE lv_xml '</Line_Item>' '</Form>' INTO lv_xml.

 REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH 'and'.

  CALL METHOD zcl_ads_master=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).

  ENDMETHOD.
ENDCLASS.
