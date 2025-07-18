CLASS lhc_materialdist DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR materialdist RESULT result.

    METHODS createvariancedata FOR MODIFY
      IMPORTING keys FOR ACTION materialdist~createVarianceData RESULT result.
    METHODS calculateVariance FOR MODIFY
      IMPORTING keys FOR ACTION materialdist~calculateVariance RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR materialdist RESULT result.

    METHODS postVariance FOR MODIFY
      IMPORTING keys FOR ACTION materialdist~postVariance RESULT result.


ENDCLASS.

CLASS lhc_materialdist IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD createVarianceData.
    CONSTANTS mycid TYPE abp_behv_cid VALUE 'My%CID_matvariance' ##NO_TEXT.

    DATA prodorderdate TYPE datum.
    DATA prodordertodate TYPE datn.
    DATA plantno TYPE char05.
    DATA companycode TYPE char05.
    DATA productdesc TYPE char72.
    DATA productcode TYPE char72.
    DATA distlineno TYPE int2.
    DATA totalconsumedqty TYPE p DECIMALS 3.
    DATA stockqty TYPE p DECIMALS 3.
    DATA stockvarqty TYPE p DECIMALS 3.
    DATA calcvarqty TYPE p DECIMALS 3.
    DATA isconsumed TYPE int1.

    DATA create_matdist TYPE STRUCTURE FOR CREATE ZR_materialdist01TP.
    DATA create_matdisttab TYPE TABLE FOR CREATE ZR_materialdist01TP.
    DATA upd_matdisttab TYPE TABLE FOR UPDATE ZR_materialdist01TP.

    DATA create_matdistline TYPE STRUCTURE FOR CREATE ZR_matdistlines.
    DATA create_matdistlinetab TYPE TABLE FOR CREATE ZR_matdistlines.
    DATA upd_matdistlinetab TYPE TABLE FOR UPDATE ZR_matdistlines.


    LOOP AT keys INTO DATA(ls_key).
      TRY.
          plantno = ls_key-%param-PlantNo .
          prodorderdate = ls_key-%param-prodorderdate .
          prodordertodate = ls_key-%param-prodordertodate .

          IF plantno = ''.
            APPEND VALUE #( %cid     = ls_key-%cid ) TO failed-materialdist.
            APPEND VALUE #( %cid     = ls_key-%cid
                            %msg     = new_message_with_text(
                            severity = if_abap_behv_message=>severity-error
                            text     = 'Plant No. cannot be blank.' )
                          ) TO reported-materialdist.
            RETURN.
          ENDIF.
      ENDTRY.

      SELECT SINGLE FROM ztable_plant FIELDS comp_code
      WHERE plant_code = @plantno INTO @DATA(lv_companycode2).
      companycode = lv_companycode2.

      SELECT FROM zmaterialdist
      FIELDS bukrs, plantcode, varianceposted
      WHERE bukrs = @companycode AND plantcode = @plantno
      AND declaredate >= @prodorderdate AND declaredate <= @prodordertodate
      INTO TABLE @DATA(ltlines).

      IF ltlines IS INITIAL.
        "Insert Master record
        DATA lv_date_len TYPE i.
        DATA lv_cnt TYPE i.
        DATA lv_curr_date TYPE datn.
        lv_date_len = prodordertodate - prodorderdate.
        lv_curr_date = prodorderdate.
        lv_cnt = 1.

        WHILE lv_curr_date <= prodordertodate.

          create_matdist = VALUE #( %cid               = |{ ls_key-%cid }_{ lv_cnt } |
                                    Bukrs              = companycode
                                    plantcode          = plantno
                                    declarecdate       = |{ lv_curr_date }|
                                    declaredate        = lv_curr_date
                                    variancecalculated = 0
                                    varianceposted     = 0
                                    varianceclosed     = 0
                          ).
          APPEND create_matdist TO create_matdisttab.
          lv_curr_date = lv_curr_date + 1.
          lv_cnt += 1.
        ENDWHILE.

        MODIFY ENTITIES OF ZR_materialdist01TP IN LOCAL MODE
        ENTITY materialdist
        CREATE FIELDS ( bukrs plantcode declarecdate declaredate variancecalculated varianceposted varianceclosed )
        WITH create_matdisttab
        MAPPED   mapped
        FAILED   failed
        REPORTED reported.

        CLEAR : create_matdisttab, create_matdist.
      ELSE.
        "Check if further processed
        LOOP AT ltlines INTO DATA(walines).
          IF walines-varianceposted = 0.
            MODIFY ENTITY ZR_matdistlines
            DELETE FROM VALUE #( ( bukrs = companycode plantcode = plantno declarecdate = |{ prodorderdate }| ) ).
          ELSE.
            APPEND VALUE #( %cid = ls_key-%cid ) TO failed-materialdist.
            APPEND VALUE #( %cid = ls_key-%cid
                            %msg = new_message_with_text(
                            severity = if_abap_behv_message=>severity-error
                            text     = 'Variance already posted.' )
                        ) TO reported-materialdist.
            RETURN.
          ENDIF.
        ENDLOOP.
      ENDIF.

      distlineno = 0.
      "Loop for unique item declaration
      SELECT FROM zmaterialdecl AS md
      FIELDS DISTINCT md~productcode
      WHERE md~bukrs = @companycode AND md~plantcode = @plantno AND md~declaredate >= @prodorderdate
      AND md~declaredate <= @prodordertodate AND md~stockquantity <> 0
      INTO TABLE @DATA(ltItems).

      LOOP AT ltitems INTO DATA(waItem).
        totalconsumedqty = 0.
        stockqty = 0.
        stockvarqty = 0.
        isconsumed = 0.

        productdesc = ''.
        productcode = waitem-productcode.
        productcode = |{ productcode  WIDTH = 18 ALIGN = RIGHT  PAD = '0' }|.

        SELECT FROM I_ProductDescription AS pd
        FIELDS pd~Product, pd~ProductDescription
        WHERE ( pd~Product = @waitem-productcode OR pd~Product = @productcode ) AND pd~LanguageISOCode = 'EN'
        INTO TABLE @DATA(Itlines).

        DATA: ls_Itlines LIKE LINE OF Itlines.

        READ TABLE Itlines WITH KEY Product = productcode INTO ls_Itlines.
        IF sy-subrc = 0.
          productcode = ls_Itlines-Product.
          productdesc = ls_Itlines-ProductDescription.
        ELSE.
          READ TABLE Itlines WITH KEY Product = waitem-productcode INTO ls_Itlines.
          IF sy-subrc = 0.
            productcode = ls_Itlines-Product.
            productdesc = ls_Itlines-ProductDescription.
          ENDIF.
        ENDIF.

        SELECT FROM I_MfgOrderConfirmation AS mconf
        JOIN i_prodnordconfmatldocitemtp AS pdoc ON mconf~ManufacturingOrder = pdoc~OrderID AND mconf~MfgOrderConfirmationGroup = pdoc~ConfirmationGroup
        AND mconf~MfgOrderConfirmation = pdoc~ConfirmationCount
        FIELDS mconf~ManufacturingOrder, pdoc~StorageLocation, pdoc~Batch, mconf~ShiftDefinition, mconf~ShiftGrouping, mconf~MfgOrderConfirmationGroup,
        mconf~ManufacturingOrderSequence, mconf~PostingDate, pdoc~EntryUnit, SUM( pdoc~QuantityInEntryUnit ) AS qty
        WHERE mconf~Plant = @plantno AND mconf~PostingDate >= @prodorderdate AND mconf~PostingDate <= @prodordertodate
        AND pdoc~Material = @productcode AND mconf~IsReversal NE 'X' AND mconf~IsReversed NE 'X'
        GROUP BY mconf~ManufacturingOrder, pdoc~StorageLocation, pdoc~Batch, mconf~ShiftDefinition, mconf~ShiftGrouping,
        mconf~MfgOrderConfirmationGroup, mconf~ManufacturingOrderSequence, mconf~PostingDate, pdoc~EntryUnit
        INTO TABLE @DATA(ltmatlines).

        LOOP AT ltmatlines INTO DATA(wamatline).
          "Insert Shift wise consumption record
          distlineno = distlineno + 1.
          create_matdistline = VALUE #( %cid      = ls_key-%cid
                                        Bukrs = companycode
                                        plantcode = plantno
                                        declarecdate = wamatline-PostingDate "|{ prodorderdate }|
                                        shiftnumber = wamatline-ShiftDefinition
                                        distlineno = distlineno
                                        declaredate = wamatline-PostingDate   " prodorderdate
                                        productionorder = wamatline-ManufacturingOrder
                                        productionorderline = 1
                                        Orderconfirmationgroup = wamatline-MfgOrderConfirmationGroup
                                        Ordersequence = wamatline-ManufacturingOrderSequence
                                        storagelocation = wamatline-StorageLocation
                                        productcode = productcode
                                        batchno = wamatline-Batch
                                        productdesc = productdesc
                                        consumedqty = wamatline-qty
                                        varianceqty = 0
                                        varianceposted = 0
                                        Entryuom = wamatline-EntryUnit
                                        Shiftgroup = wamatline-ShiftGrouping
                                        Variancepostlinedate = wamatline-PostingDate
                      ).
          APPEND create_matdistline TO create_matdistlinetab.
          totalconsumedqty = totalconsumedqty + wamatline-qty.
          isconsumed = 1.

          MODIFY ENTITIES OF ZR_matdistlines
          ENTITY ZR_matdistlines
          CREATE FIELDS ( bukrs plantcode declarecdate shiftnumber Distlineno declaredate Productionorder Productionorderline
          Orderconfirmationgroup Ordersequence Storagelocation
          Productcode Batchno Productdesc Consumedqty Varianceqty Varianceposted Entryuom Shiftgroup Variancepostlinedate )
          WITH create_matdistlinetab.

          CLEAR : create_matdistline, create_matdistlinetab.
        ENDLOOP.

      ENDLOOP.

      APPEND VALUE #( %cid = ls_key-%cid
                      %msg = new_message_with_text(
                      severity = if_abap_behv_message=>severity-success
                      text     = 'Variance Data Created.' )
                      ) TO reported-materialdist.
      RETURN.

    ENDLOOP.

  ENDMETHOD.


  METHOD calculateVariance.
    CONSTANTS mycid TYPE abp_behv_cid VALUE 'My%CID_matvariance' ##NO_TEXT.

    DATA prodorderdate TYPE datum.
    DATA plantno TYPE char05.
    DATA companycode TYPE char05.
    DATA productdesc TYPE char72.
    DATA productcode TYPE char72.
    DATA distlineno TYPE int2.
    DATA totalconsumedqty TYPE p DECIMALS 3.
    DATA stockqty TYPE p DECIMALS 3.
    DATA stockvarqty TYPE p DECIMALS 3.
    DATA calcvarqty TYPE p DECIMALS 3.
    DATA isconsumed TYPE int1.

    DATA upd_matdisttab TYPE TABLE FOR UPDATE ZR_materialdist01TP.

    DATA upd_matdistlinetab TYPE TABLE FOR UPDATE ZR_matdistlines.


    READ ENTITIES OF ZR_materialdist01TP IN LOCAL MODE
    ENTITY materialdist
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(it_materialdist).

    LOOP AT it_materialdist INTO DATA(wadistline).
      companycode   = wadistline-Bukrs.
      plantno       = wadistline-Plantcode.
      prodorderdate = wadistline-declaredate.

      SELECT FROM zmatdistlines AS mdlines
      FIELDS DISTINCT mdlines~productionorder
      WHERE mdlines~bukrs = @companycode AND mdlines~plantcode = @plantno
      AND mdlines~declaredate = @prodorderdate
      AND mdlines~varianceqty <> 0 AND mdlines~varianceposted = 1
      INTO TABLE @DATA(ltcheck).

      IF ltcheck IS NOT INITIAL.
        APPEND VALUE #( %cid = mycid ) TO failed-materialdist.
        APPEND VALUE #( %cid = mycid
                        %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = 'Variance already posted.' )
                ) TO reported-materialdist.

        READ ENTITIES OF ZR_materialdist01TP IN LOCAL MODE
        ENTITY materialdist
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(it_materialdists).

        result = VALUE #( FOR matdistline IN it_materialdists
                ( %tky   = matdistline-%tky
                  %param = matdistline ) ).

        RETURN.
      ENDIF.

      upd_matdistlinetab = VALUE #( ( bukrs = companycode plantcode = plantno declarecdate = |{ prodorderdate }| varianceqty = 0 ) ).
      MODIFY ENTITY ZR_matdistlines
      UPDATE FIELDS ( varianceqty )
      WITH upd_matdistlinetab.
      CLEAR : upd_matdistlinetab.

      SELECT FROM zmaterialdecl AS md
      FIELDS DISTINCT md~productcode
      WHERE md~bukrs = @companycode AND md~plantcode = @plantno
      AND md~declaredate = @prodorderdate AND md~stockquantity <> 0
      INTO TABLE @DATA(ltItems).

      LOOP AT ltitems INTO DATA(waItem).
        productcode = waItem-productcode.
        productcode = |{ productcode  WIDTH = 18 ALIGN = RIGHT  PAD = '0' }|.

        SELECT FROM I_ProductDescription AS pd
        FIELDS pd~Product, pd~ProductDescription
        WHERE ( pd~Product = @waitem-productcode OR pd~Product = @productcode ) AND pd~LanguageISOCode = 'EN'
        INTO TABLE @DATA(Itlines).

        DATA: ls_Itlines LIKE LINE OF Itlines.

        READ TABLE Itlines WITH KEY Product = productcode INTO ls_Itlines.
        IF sy-subrc = 0.
          productcode = ls_Itlines-Product.
        ELSE.
          READ TABLE Itlines WITH KEY Product = waitem-productcode INTO ls_Itlines.
          IF sy-subrc = 0.
            productcode = ls_Itlines-Product.
          ENDIF.
        ENDIF.
        totalconsumedqty = 0.
        stockqty = 0.
        stockvarqty = 0.

        SELECT FROM zmaterialdecl AS md
        FIELDS md~productcode, md~batchno, SUM( md~stockquantity ) AS qty
        WHERE md~bukrs = @companycode AND md~plantcode = @plantno
        AND md~declaredate = @prodorderdate AND md~productcode = @waitem-productcode
        GROUP BY md~productcode, md~batchno
        INTO TABLE @DATA(ltStock).

        LOOP AT ltStock INTO DATA(waltStock).
          stockvarqty = 0.
          SELECT FROM zmatdistlines AS mdlines
          FIELDS SUM( mdlines~consumedqty ) AS consumedqty
          WHERE mdlines~Bukrs = @companycode AND mdlines~plantcode = @plantno AND mdlines~declaredate = @prodorderdate
          AND mdlines~productcode = @productcode "AND mdlines~batchno = @waltStock-batchno
          INTO TABLE @DATA(ltdlineStock).

          LOOP AT ltdlineStock INTO DATA(waltdlineStock).
            stockvarqty = waltStock-qty - waltdlineStock-consumedqty.
          ENDLOOP.
          IF stockvarqty <> 0.
            "Distribute variance
            SELECT FROM zmatdistlines AS mdlines
            FIELDS mdlines~shiftnumber, mdlines~declarecdate, mdlines~distlineno, mdlines~consumedqty
            WHERE mdlines~Bukrs = @companycode AND mdlines~plantcode = @plantno AND mdlines~declaredate = @prodorderdate
            AND mdlines~productcode = @productcode "AND mdlines~batchno = @waltStock-batchno
            INTO TABLE @DATA(ltdlineStockUpd).

            LOOP AT ltdlineStockUpd INTO DATA(waltdlineStockUpd).

              calcvarqty         = stockvarqty * waltdlineStockUpd-consumedqty / waltdlineStock-consumedqty.
              upd_matdistlinetab = VALUE #( ( bukrs = companycode plantcode = plantno declarecdate = waltdlineStockUpd-declarecdate
                                              shiftnumber = waltdlineStockUpd-shiftnumber distlineno = waltdlineStockUpd-distlineno varianceqty = calcvarqty ) ).
              MODIFY ENTITY ZR_matdistlines
              UPDATE FIELDS ( varianceqty )
              WITH upd_matdistlinetab.
              CLEAR : upd_matdistlinetab.
            ENDLOOP.

          ENDIF.
        ENDLOOP.
      ENDLOOP.

      upd_matdisttab = VALUE #( ( bukrs = companycode plantcode = plantno declarecdate = |{ prodorderdate }| Variancecalculated = 1 ) ).
      MODIFY ENTITIES OF ZR_materialdist01TP IN LOCAL MODE
      ENTITY materialdist
      UPDATE FIELDS ( Variancecalculated )
      WITH upd_matdisttab.
      CLEAR : upd_matdisttab.

    ENDLOOP.

    APPEND VALUE #( %cid     = mycid
                    %msg     = new_message_with_text(
                    severity = if_abap_behv_message=>severity-success
                    text     = 'Variance Calculated.' )
                    ) TO reported-materialdist.

    READ ENTITIES OF ZR_materialdist01TP IN LOCAL MODE
    ENTITY materialdist
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(it_materialdists2).

    result = VALUE #( FOR matdistline IN it_materialdists2
                    ( %tky   = matdistline-%tky
                      %param = matdistline ) ).

  ENDMETHOD.

  METHOD get_instance_features.
*    READ ENTITIES OF ZR_materialdist01TP IN LOCAL MODE
*      ENTITY materialdist
*      ALL FIELDS WITH CORRESPONDING #( keys )
*      RESULT DATA(materialdistlist).
*
*    result = VALUE #( FOR it_materialdist IN materialdistlist
*                        LET
*                          is_cancelled = COND #( WHEN it_materialdist-Varianceposted = 1
*                                                 THEN if_abap_behv=>fc-o-disabled
*                                                 ELSE if_abap_behv=>fc-o-enabled  )
*                        IN
*                            ( %tky                      = it_materialdist-%tky
*                              %action-calculateVariance = is_cancelled ) ).
*
*    result = VALUE #( FOR it_materialdist IN materialdistlist
*                        LET
*                          is_cancelled = COND #( WHEN it_materialdist-Varianceposted = 1
*                                                 THEN if_abap_behv=>fc-o-disabled
*                                                 ELSE if_abap_behv=>fc-o-enabled  )
*                        IN
*                            ( %tky                      = it_materialdist-%tky
*                              %action-postVariance = is_cancelled ) ).
  ENDMETHOD.

  METHOD postVariance.
    CONSTANTS mycid TYPE abp_behv_cid VALUE 'My%CID_matvarpost' ##NO_TEXT.

    DATA upd_matdisttab TYPE TABLE FOR UPDATE ZR_materialdist01TP.
    DATA prodorderdate TYPE datn.
    DATA lv_postvariancedate TYPE datn.
    DATA plantno TYPE char05.
    DATA companycode TYPE char05.
    DATA(wa_param) = keys[ 1 ]-%param.
    DATA lv_date TYPE c LENGTH 10.
    DATA lv_linedate TYPE c LENGTH 10.
    DATA lv_month TYPE c LENGTH 2.
    DATA lv_year TYPE c LENGTH 4.

    lv_month = wa_param-declarecdate+4(2).
    lv_year = wa_param-declarecdate+0(4).
    lv_date = |{ lv_year }{ lv_month }| && '%'.

    SELECT FROM ZR_materialdist01TP
    FIELDS bukrs, Plantcode, Declaredate, Varianceposted, Variancecalculated
    WHERE Bukrs = @wa_param-bukrs AND Plantcode = @wa_param-werks
    AND Declarecdate LIKE @lv_date AND Variancecalculated = 1 AND Varianceposted = 0
    INTO TABLE @DATA(it_materialdist) PRIVILEGED ACCESS.

    LOOP AT it_materialdist INTO DATA(wa_materialdist).

      companycode           = wa_materialdist-Bukrs.
      plantno               = wa_materialdist-Plantcode.
      prodorderdate         = wa_materialdist-declaredate.
      lv_postvariancedate   = keys[ 1 ]-%param-declarecdate.

      IF wa_materialdist-declaredate >= keys[ 1 ]-%param-declarecdate.
        prodorderdate       = keys[ 1 ]-%param-declarecdate .
      ENDIF.

      IF wa_materialdist-Varianceposted = 0 AND wa_materialdist-Variancecalculated = 1.
        upd_matdisttab = VALUE #( ( bukrs = companycode plantcode = plantno declarecdate = |{ prodorderdate }| Variancepostdate = lv_postvariancedate Varianceposted = 1 ) ).
        MODIFY ENTITIES OF ZR_materialdist01TP IN LOCAL MODE
        ENTITY materialdist
        UPDATE FIELDS ( Varianceposted  Variancepostdate )
        WITH upd_matdisttab.
        CLEAR : upd_matdisttab.

        DATA upd_matdistlinetab TYPE TABLE FOR UPDATE ZR_matdistlines.

        SELECT FROM ZR_matdistlinesTP
        FIELDS bukrs, Plantcode, Declarecdate, Shiftnumber, Distlineno
        WHERE Bukrs = @wa_materialdist-Bukrs AND Plantcode = @wa_materialdist-Plantcode
        AND Declarecdate = @prodorderdate AND Varianceposted = 0
        INTO TABLE @DATA(it_materialdistline) PRIVILEGED ACCESS.

        LOOP AT it_materialdistline INTO DATA(wa_materialdistline).

          upd_matdistlinetab = VALUE #( ( bukrs                 = wa_materialdistline-Bukrs
                                          Plantcode             = wa_materialdistline-Plantcode
                                          declarecdate          = wa_materialdistline-Declarecdate
                                          Shiftnumber           = wa_materialdistline-Shiftnumber
                                          Distlineno            = wa_materialdistline-Distlineno
                                          Variancepostlinedate  = lv_postvariancedate ) ).
          MODIFY ENTITY ZR_matdistlines
          UPDATE FIELDS ( Variancepostlinedate )
          WITH upd_matdistlinetab.
          CLEAR : upd_matdistlinetab.

          CLEAR: wa_materialdistline.
        ENDLOOP.
        CLEAR it_materialdistline.

      ELSE.
        APPEND VALUE #( %cid     = mycid ) TO failed-materialdist.
        APPEND VALUE #( %cid     = mycid
                        %msg     = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = 'Variance cannot be posted.' )
                    ) TO reported-materialdist.
        RETURN.
      ENDIF.

      CLEAR : wa_materialdist.
    ENDLOOP.

    APPEND VALUE #( %cid     = mycid
                    %msg     = new_message_with_text(
                    severity = if_abap_behv_message=>severity-success
                    text     = 'Variance Posting scheduled.' )
                    ) TO reported-materialdist.

    READ ENTITIES OF ZR_materialdist01TP IN LOCAL MODE
    ENTITY materialdist
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(it_materialdists).

    result = VALUE #( FOR matdistline IN it_materialdists
                    ( %param = matdistline ) ).
  ENDMETHOD.

ENDCLASS.
