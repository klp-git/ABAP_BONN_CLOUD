CLASS zcl_test1 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_test1 IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main..


  data: lv_bill type zbillinglines-billno.
  data: lv_fiscal type zbillinglines-fiscalyearvalue.
  data: lv_line type zbillinglines-lineitemno.
  data: lv_typebill type zbillinglines-billingtype.
  lv_typebill = '0000'.
      lv_bill = '0000000000'.
      lv_fiscal = '0000'.
      lv_line = '0000'.

*      delete from zbillinglines where billingtype = @lv_typebill." and fiscalyearvalue is INITIAL.
**      delete from zbillingproc
*    select distinct invoice as invoice from zbillinglines into table @data(lv_billinglines).
*
*    delete from zbillinglines.
*    delete from zbillingproc.




  ENDMETHOD.
ENDCLASS.
