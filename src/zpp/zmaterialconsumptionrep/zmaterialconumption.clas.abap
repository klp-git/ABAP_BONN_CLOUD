CLASS zmaterialconumption DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA : it_table TYPE TABLE OF zrepmaterials,
           wa       TYPE zrepmaterials.


    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zmaterialconumption IMPLEMENTATION.



  METHOD if_oo_adt_classrun~main.


*    DATA lv_plant TYPE c LENGTH 4.
*    DATA lv_bukrs TYPE c LENGTH 4.
*    DATA lv_date TYPE datn.
*    SELECT FROM zmaterialdist FIELDS *
*    WHERE plantcode = @lv_plant AND bukrs = @lv_bukrs AND declarecdate = @lv_date
*    INTO TABLE @DATA(it) PRIVILEGED ACCESS.
*
*    LOOP AT it INTO DATA(wa).
*      wa-varianceposted = 0.
*      MODIFY zmaterialdist FROM @wa.
*      CLEAR wa.
*    ENDLOOP.


*   TRY.
*        " Insert data into the database table
*        INSERT zrepmaterials FROM TABLE @it_table.
*
*        " Check if the insert was successful
*        IF sy-subrc = 0.
*          out->write( |{ sy-dbcnt } records inserted successfully into zrepmaterials.| ).
*        ELSE.
*          out->write( |Error inserting records into zrepmaterials.| ).
*        ENDIF.
*
*      CATCH cx_sy_open_sql_db INTO DATA(lx_sql_error).
*        " Handle any SQL exceptions
*        out->write( |SQL Error: { lx_sql_error->get_text( ) }| ).
*    ENDTRY.

*    Select from I_MaterialDocumentItem_2 as a
*    FIELDS a~Material, sum( a~QuantityInEntryUnit ) as ttlqty , a~Plant,
*     a~StorageLocation,
*     a~QuantityInEntryUnit as quantity,
*     a~PostingDate,
*     a~GoodsMovementType as movementtype,
*     a~MaterialBaseUnit as um
*
*    group by a~Plant , a~Material , a~PostingDate, a~StorageLocation,a~QuantityInEntryUnit,a~GoodsMovementType,a~MaterialBaseUnit
*    into table @data(lineitems) PRIVILEGED ACCESS.
*
*    data wa_Table type  zrepmaterials.
*
*    LOOP AT lineitems into data(wa_lineitems).
*        wa_table-plant =  wa_lineitems-Plant.
*        wa_table-storagelocation =  wa_lineitems-StorageLocation.
*        wa_table-quantity  = wa_lineitems-quantity.
*        wa_table-rangedate = wa_lineitems-PostingDate.
*        data lvmaterial type c LENGTH 40.
*        lvmaterial = |{ wa_lineitems-Material ALPHA = OUT }|.
*        wa_table-material =  lvmaterial.
*        wa_table-um =  wa_lineitems-um.
*        wa_table-movementtype =  wa_lineitems-movementtype.
*
*        MODIFY zrepmaterials FROM @wa_table.
*
*        CLEAR: wa_lineitems, wa_table , lvmaterial.
*
*
*
*
*
*
*    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
