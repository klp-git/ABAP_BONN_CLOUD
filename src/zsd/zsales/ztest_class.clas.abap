CLASS  ZTEST_cLASS DEFINITION
 PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
   INTERFACES if_oo_adt_classrun.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZTEST_CLASS IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

*    delete from zcratesdata where plant NE 'BN02'.
    delete from  zdt_rplcrnote where comp_code = 'BNPL' .

*    UPDATE zdt_rplcrnote set error_log = '' where error_log NE ''.
*    UPDATE zdt_rplcrnote set  glerror_log = '' where glerror_log NE ''.
  ENDMETHOD.
ENDCLASS.
