REPORT ZBOPF.

START-OF-SELECTION.
  DATA: lo_api     TYPE REF TO zcl_bopf_so_api.
  DATA: lt_message TYPE bapiret2_t.

  DATA: ls_header  TYPE zbo_soheader_ds.
  DATA: lt_item    TYPE zbo_soitem_ds_tab.
  DATA: ls_item    TYPE zbo_soitem_ds.

  DATA: ls_header2 TYPE zbo_soheader_cb.
  DATA: lt_item2   TYPE zbo_soitem_ctt.

  lo_api = new zcl_bopf_so_api( ).

  "PERFORM create.
  "PERFORM read.
  PERFORM update.
  "PERFORM delete.

FORM create.
  CLEAR ls_header.
  ls_header-soid       = 0.
  ls_header-customerid = '1'.
  ls_header-status     = 'N'.

  CLEAR ls_item.
  ls_item-itemid    = 1.
  ls_item-matnr     = '70'.
  ls_item-maktx     = 'Pilha'.
  ls_item-quantity  = 2.
  ls_item-price_uni = `1.99`.
  APPEND ls_item TO lt_item.

  CLEAR ls_item.
  ls_item-itemid    = 2.
  ls_item-matnr     = '100'.
  ls_item-maktx     = 'Teclado'.
  ls_item-quantity  = 1.
  ls_item-price_uni = `100.52`.
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
      id_soid    = 44
    IMPORTING
      es_header  = ls_header2
      et_item    = lt_item2
      et_message = lt_message
  ).

  CALL FUNCTION 'RSCRMBW_DISPLAY_BAPIRET2'
    TABLES
      it_return = lt_message.
ENDFORM.
FORM update.
  CLEAR ls_header.
  ls_header-soid       = 44.
  ls_header-customerid = '90'.
  ls_header-status     = 'F'.

  CLEAR ls_item.
  ls_item-soid      = 44.
  ls_item-itemid    = 1.
  ls_item-matnr     = '70'.
  ls_item-maktx     = 'Pilha'.
  ls_item-quantity  = 2.
  ls_item-price_uni = `1.99`.
  APPEND ls_item TO lt_item.

  CLEAR ls_item.
  ls_item-soid      = 44.
  ls_item-itemid    = 2.
  ls_item-matnr     = '111'.
  ls_item-maktx     = 'Teclado 111'.
  ls_item-quantity  = 1.
  ls_item-price_uni = `1.11`.
  APPEND ls_item TO lt_item.

  CLEAR ls_item.
  ls_item-soid      = 44.
  ls_item-itemid    = 3.
  ls_item-matnr     = '300'.
  ls_item-maktx     = 'Celular'.
  ls_item-quantity  = 1.
  ls_item-price_uni = `2.13`.
  APPEND ls_item TO lt_item.

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
ENDFORM.
