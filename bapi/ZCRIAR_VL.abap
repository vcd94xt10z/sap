REPORT ZCRIAR_VL.

SELECTION-SCREEN BEGIN OF BLOCK main WITH FRAME.
  PARAMETERS p_vbeln TYPE vbak-vbeln.
SELECTION-SCREEN END OF BLOCK main.

START-OF-SELECTION.
  DATA: ld_delivery          TYPE bapishpdelivnumb-deliv_numb.
  DATA: lt_sales_order_items TYPE STANDARD TABLE OF bapidlvreftosalesorder.
  DATA: ls_sales_order_items TYPE bapidlvreftosalesorder.
  DATA: lt_return            TYPE STANDARD TABLE OF bapiret2.
  DATA: ls_return            TYPE bapiret2.

  DATA: lt_vbap              TYPE STANDARD TABLE OF vbap.
  DATA: ls_vbap              TYPE vbap.
  DATA: ld_error             TYPE flag.

  SELECT *
    INTO TABLE lt_vbap
    FROM vbap
   WHERE vbeln = p_vbeln.

  LOOP AT lt_vbap INTO ls_vbap.
    CLEAR ls_sales_order_items.
    ls_sales_order_items-ref_doc    = ls_vbap-vbeln.
    ls_sales_order_items-ref_item   = ls_vbap-posnr.
    ls_sales_order_items-dlv_qty    = ls_vbap-kwmeng.
    ls_sales_order_items-sales_unit = ls_vbap-vrkme.
    APPEND ls_sales_order_items TO lt_sales_order_items.
  ENDLOOP.

  CALL FUNCTION 'BAPI_OUTB_DELIVERY_CREATE_SLS'
    IMPORTING
      delivery          = ld_delivery
    TABLES
      sales_order_items = lt_sales_order_items
      return            = lt_return.

  ld_error = ''.
  LOOP AT lt_return INTO ls_return WHERE type = 'E' OR type = 'A'.
    ld_error = 'X'.
    EXIT.
  ENDLOOP.

  IF ld_error = 'X'.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    CALL FUNCTION 'RSCRMBW_DISPLAY_BAPIRET2'
      TABLES
        it_return = lt_return.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    MESSAGE |Remessa criada { ld_delivery }| TYPE 'I'.
  ENDIF.
