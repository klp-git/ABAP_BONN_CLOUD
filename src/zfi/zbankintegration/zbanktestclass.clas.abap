CLASS zbanktestclass DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .


  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zbanktestclass IMPLEMENTATION.

    METHOD if_oo_adt_classrun~main.

      DATA(filename) = ''.
      IF filename IS NOT INITIAL.
        DELETE FROM zbankpayable where uploadfilename = @filename.
      ENDIF.
    ENDMETHOD.
ENDCLASS.
