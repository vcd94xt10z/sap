REPORT ZBAPI_GOODSMVT_CREATE.

START-OF-SELECTION.
  "PERFORM test.
  PERFORM call_bapi.

FORM call_bapi.
  DATA: ls_goodsmvt_header TYPE bapi2017_gm_head_01.
  DATA: ls_goodsmvt_code   TYPE bapi2017_gm_code.
  DATA: lt_goodsmvt_item   TYPE STANDARD TABLE OF bapi2017_gm_item_create.
  DATA: ls_goodsmvt_item   TYPE bapi2017_gm_item_create.
  DATA: lt_return          TYPE STANDARD TABLE OF bapiret2.
  DATA: ls_return          TYPE bapiret2.

  DATA: ls_goodsmvt_headret TYPE bapi2017_gm_head_ret.
  DATA: ld_materialdocument TYPE mblnr.
  DATA: ld_matdocumentyear  TYPE mjahr.

  DATA: ld_error TYPE char1.

  CLEAR ls_goodsmvt_header.
  ls_goodsmvt_header-pstng_date          = sy-datum.
  ls_goodsmvt_header-doc_date            = sy-datum.
  ls_goodsmvt_header-ref_doc_no          = ``.
  ls_goodsmvt_header-bill_of_lading      = ``.
  ls_goodsmvt_header-gr_gi_slip_no       = ``.
  ls_goodsmvt_header-pr_uname            = sy-uname.
  ls_goodsmvt_header-header_txt          = `Test`.
  ls_goodsmvt_header-ver_gr_gi_slip      = ``.
  ls_goodsmvt_header-ver_gr_gi_slipx     = ``.
  ls_goodsmvt_header-ext_wms             = ``.
  ls_goodsmvt_header-ref_doc_no_long     = ``.
  ls_goodsmvt_header-bill_of_lading_long = ``.
  ls_goodsmvt_header-bar_code            = ``.

  " 01 => 501, 511
  " 03 => 262, 552, 992
  " 05 => 262, 501, 511
  " 06 => 262, 501, 511, 552, 992

  CLEAR ls_goodsmvt_code.
  ls_goodsmvt_code-gm_code = `01`.

  CLEAR lt_goodsmvt_item.

  CLEAR ls_goodsmvt_item.
  ls_goodsmvt_item-material  = ``.
  ls_goodsmvt_item-plant     = ``.
  ls_goodsmvt_item-stge_loc  = ``.
  ls_goodsmvt_item-move_type = `501`.
  ls_goodsmvt_item-entry_qnt = `2096`.
  ls_goodsmvt_item-entry_uom = `AF`.
  APPEND ls_goodsmvt_item TO lt_goodsmvt_item.

  CLEAR ls_goodsmvt_headret.
  CLEAR ld_materialdocument.
  CLEAR ld_matdocumentyear.
  CLEAR lt_return.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = ls_goodsmvt_header
      goodsmvt_code    = ls_goodsmvt_code
      testrun          = ' '
    IMPORTING
      goodsmvt_headret = ls_goodsmvt_headret
      materialdocument = ld_materialdocument
      matdocumentyear  = ld_matdocumentyear
    TABLES
      goodsmvt_item    = lt_goodsmvt_item
      return           = lt_return.

  ld_error = ``.
  LOOP AT lt_return INTO ls_return.
    IF ls_return-type = `E` OR ls_return-type = `X` OR ls_return-type = `A`.
      ld_error = `X`.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF ld_error <> `X`.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = `X`.

    "BREAK-POINT.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDIF.
ENDFORM.
FORM test.
  DATA: ls_goodsmvt_header TYPE bapi2017_gm_head_01.
  DATA: ls_goodsmvt_code   TYPE bapi2017_gm_code.
  DATA: lt_goodsmvt_item   TYPE STANDARD TABLE OF bapi2017_gm_item_create.
  DATA: ls_goodsmvt_item   TYPE bapi2017_gm_item_create.
  DATA: lt_return          TYPE STANDARD TABLE OF bapiret2.
  DATA: ls_return          TYPE bapiret2.

  DATA: ls_goodsmvt_headret TYPE bapi2017_gm_head_ret.
  DATA: ld_materialdocument TYPE mblnr.
  DATA: ld_matdocumentyear  TYPE mjahr.

  DATA: lt_t158g TYPE STANDARD TABLE OF t158g.
  DATA: ls_t158g TYPE t158g.
  DATA: lt_t156  TYPE STANDARD TABLE OF t156.
  DATA: ls_t156  TYPE t156.
  DATA: ld_error TYPE char1.
  DATA: lt_bwart TYPE STANDARD TABLE OF bwart.
  DATA: lt_message TYPE STANDARD TABLE OF string.
  DATA: ld_message TYPE string.

  SELECT *
    INTO TABLE lt_t158g
    FROM t158g.

  SELECT *
    INTO TABLE lt_t156
    FROM t156.

  CLEAR lt_bwart.
  CLEAR lt_message.

  LOOP AT lt_t158g INTO ls_t158g.
    LOOP AT lt_t156 INTO ls_t156.
      CLEAR ls_goodsmvt_header.
      ls_goodsmvt_header-pstng_date          = sy-datum.
      ls_goodsmvt_header-doc_date            = sy-datum.
      ls_goodsmvt_header-ref_doc_no          = ``.
      ls_goodsmvt_header-bill_of_lading      = ``.
      ls_goodsmvt_header-gr_gi_slip_no       = ``.
      ls_goodsmvt_header-pr_uname            = sy-uname.
      ls_goodsmvt_header-header_txt          = `Test`.
      ls_goodsmvt_header-ver_gr_gi_slip      = ``.
      ls_goodsmvt_header-ver_gr_gi_slipx     = ``.
      ls_goodsmvt_header-ext_wms             = ``.
      ls_goodsmvt_header-ref_doc_no_long     = ``.
      ls_goodsmvt_header-bill_of_lading_long = ``.
      ls_goodsmvt_header-bar_code            = ``.

      CLEAR ls_goodsmvt_code.
      ls_goodsmvt_code-gm_code = ls_t158g-gmcode.

      CLEAR lt_goodsmvt_item.

      CLEAR ls_goodsmvt_item.
      ls_goodsmvt_item-material  = ``.
      ls_goodsmvt_item-plant     = ``.
      ls_goodsmvt_item-stge_loc  = ``.
      "ls_goodsmvt_item-move_type = `101`.
      ls_goodsmvt_item-move_type = ls_t156-bwart.
      ls_goodsmvt_item-entry_qnt = `2096`.
      APPEND ls_goodsmvt_item TO lt_goodsmvt_item.

      CLEAR ls_goodsmvt_headret.
      CLEAR ld_materialdocument.
      CLEAR ld_matdocumentyear.
      CLEAR lt_return.

      CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
        EXPORTING
          goodsmvt_header  = ls_goodsmvt_header
          goodsmvt_code    = ls_goodsmvt_code
          testrun          = 'X'
        IMPORTING
          goodsmvt_headret = ls_goodsmvt_headret
          materialdocument = ld_materialdocument
          matdocumentyear  = ld_matdocumentyear
        TABLES
          goodsmvt_item    = lt_goodsmvt_item
          return           = lt_return.

      ld_error = ``.
      LOOP AT lt_return INTO ls_return.
        IF ls_return-type = `E` OR ls_return-type = `X` OR ls_return-type = `A`.
          ld_error = `X`.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF ld_error <> `X`.
        ld_message = |GM Code { ls_t158g-gmcode } / Movement Type = { ls_t156-bwart }|.
        APPEND ld_message TO lt_message.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  BREAK-POINT.
ENDFORM.