REPORT ZBOPF.

START-OF-SELECTION.
  DATA: lo_api     TYPE REF TO zcl_bopf_so_api.
  DATA: lt_message TYPE bapiret2_t.

  DATA: lt_header  TYPE zbo_soheader_ctt.
  DATA: ls_header  TYPE zbo_soheader_cb.
  DATA: lt_item    TYPE zbo_soitem_ctt.
  DATA: ls_item    TYPE zbo_soitem_cs.

  lo_api = new zcl_bopf_so_api( ).

  BREAK-POINT.
  PERFORM create.
  PERFORM read.
  PERFORM update.
  PERFORM delete.

FORM create.
  CLEAR ls_header.
  ls_header-soid       = 0.
  ls_header-customerid = '1'.
  ls_header-status     = 'N'.

  CLEAR ls_item.
  ls_item-itemid    = 1.
  ls_item-matnr     = '100'.
  ls_item-maktx     = 'Pilha'.
  ls_item-quantity  = 1.
  ls_item-price_uni = `1.00`.
  APPEND ls_item TO lt_item.

  CLEAR ls_item.
  ls_item-itemid    = 2.
  ls_item-matnr     = '200'.
  ls_item-maktx     = 'Teclado'.
  ls_item-quantity  = 2.
  ls_item-price_uni = `2.00`.
  APPEND ls_item TO lt_item.

  lo_api->create(
    EXPORTING
      is_header  = ls_header
      it_item    = lt_item
    IMPORTING
      et_message = lt_message
  ).

  CALL FUNCTION 'RSCRMBW_DISPLAY_BAPIRET2'
    TABLES
      it_return = lt_message.
ENDFORM.
FORM read.
  lo_api->read_single(
    EXPORTING
      id_soid    = 1
    IMPORTING
      es_header  = ls_header
      et_item    = lt_item
      et_message = lt_message
  ).

  CALL FUNCTION 'RSCRMBW_DISPLAY_BAPIRET2'
    TABLES
      it_return = lt_message.

  lo_api->read_all(
    IMPORTING
      et_header  = lt_header
      et_message = lt_message
  ).
ENDFORM.
FORM update.
  CLEAR ls_header.
  ls_header-soid       = 1.
  ls_header-customerid = '90'.
  ls_header-status     = 'F'.

  CLEAR ls_item.
  ls_item-soid      = ls_header-soid.
  ls_item-itemid    = 1.
  ls_item-matnr     = '100'.
  ls_item-maktx     = 'Pilha MODIFICADO'.
  ls_item-quantity  = 11.
  ls_item-price_uni = `11`.
  APPEND ls_item TO lt_item.

  CLEAR ls_item.
  ls_item-soid      = ls_header-soid.
  ls_item-itemid    = 2.
  ls_item-matnr     = '200'.
  ls_item-maktx     = 'Teclado MODIFICADO'.
  ls_item-quantity  = 22.
  ls_item-price_uni = `22`.
  APPEND ls_item TO lt_item.

*  CLEAR ls_item.
*  ls_item-soid      = ls_header-soid.
*  ls_item-itemid    = 3.
*  ls_item-matnr     = '300'.
*  ls_item-maktx     = 'Celular CRIADO'.
*  ls_item-quantity  = 3.
*  ls_item-price_uni = `3`.
*  APPEND ls_item TO lt_item.

  lo_api->update(
    EXPORTING
      is_header  = ls_header
      it_item    = lt_item
    IMPORTING
      et_message = lt_message
  ).

  CALL FUNCTION 'RSCRMBW_DISPLAY_BAPIRET2'
    TABLES
      it_return = lt_message.
ENDFORM.
FORM delete.
  lo_api->delete(
    EXPORTING
      id_soid    = 1
    IMPORTING
      et_message = lt_message
  ).

  CALL FUNCTION 'RSCRMBW_DISPLAY_BAPIRET2'
    TABLES
      it_return = lt_message.
ENDFORM.
