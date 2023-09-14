REPORT ZBAPI_SALESORDER_CHANGE1.

DATA: ls_order_header_inx TYPE bapisdh1x.
DATA: lt_order_item_in    TYPE STANDARD TABLE OF bapisditm.
DATA: ls_order_item_in    TYPE bapisditm.
DATA: lt_order_item_inx   TYPE STANDARD TABLE OF bapisditmx.
DATA: ls_order_item_inx   TYPE bapisditmx.
DATA: lt_schedule_lines   TYPE STANDARD TABLE OF bapischdl.
DATA: ls_schedule_lines   TYPE bapischdl.
DATA: lt_schedule_linesx  TYPE STANDARD TABLE OF bapischdlx.
DATA: ls_schedule_linesx  TYPE bapischdlx.
DATA: lt_return           TYPE bapiret2_t.
DATA: ls_return           TYPE bapiret2.
DATA: ld_error            TYPE flag.

SELECTION-SCREEN BEGIN OF BLOCK main WITH FRAME.
  PARAMETERS p_vbeln TYPE vbak-vbeln.
SELECTION-SCREEN END OF BLOCK main.

START-OF-SELECTION.
  " header
  ls_order_header_inx-updateflag = 'U'.

  " items
  CLEAR ls_order_item_in.
  ls_order_item_in-itm_number = '000010'.
  APPEND ls_order_item_in TO lt_order_item_in.

  CLEAR ls_order_item_inx.
  ls_order_item_inx-itm_number = '000010'.
  ls_order_item_inx-updateflag = 'U'.
  APPEND ls_order_item_inx TO lt_order_item_inx.

  CLEAR ls_schedule_lines.
  ls_schedule_lines-itm_number = '000010'.
  ls_schedule_lines-sched_line = '0001'.
  ls_schedule_lines-req_qty    = 0.
  APPEND ls_schedule_lines TO lt_schedule_lines.

  CLEAR ls_schedule_linesx.
  ls_schedule_linesx-itm_number = '000010'.
  ls_schedule_linesx-sched_line = '0001'.
  ls_schedule_linesx-req_qty    = 'X'.
  ls_schedule_linesx-updateflag = 'U'.
  APPEND ls_schedule_linesx TO lt_schedule_linesx.

  CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
    EXPORTING
      salesdocument    = p_vbeln
      order_header_inx = ls_order_header_inx
    TABLES
      return           = lt_return
      order_item_in    = lt_order_item_in
      order_item_inx   = lt_order_item_inx
      schedule_lines   = lt_schedule_lines
      schedule_linesx  = lt_schedule_linesx.

  CALL FUNCTION 'RSCRMBW_DISPLAY_BAPIRET2'
    TABLES
      it_return = lt_return.

  LOOP AT lt_return INTO ls_return WHERE type = 'E' OR type = 'A'.
    ld_error = 'X'.
    EXIT.
  ENDLOOP.

  IF ld_error <> 'X'.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDIF.
