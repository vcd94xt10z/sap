REPORT ZTESTE.

START-OF-SELECTION.
  PERFORM criar_ordem.
  "PERFORM modificar_ordem.

FORM criar_ordem.
  DATA: ld_vbeln               TYPE vbeln.
  DATA: ls_order_header_in     TYPE bapisdhd1.
  DATA: ls_order_header_inx    TYPE bapisdhd1x.
  DATA: lt_order_items_in      TYPE STANDARD TABLE OF bapisditm.
  DATA: ls_order_items_in      TYPE bapisditm.
  DATA: lt_order_items_inx     TYPE STANDARD TABLE OF bapisditmx.
  DATA: ls_order_items_inx     TYPE bapisditmx.
  DATA: lt_order_partners      TYPE STANDARD TABLE OF bapiparnr.
  DATA: ls_order_partners      TYPE bapiparnr.
  DATA: lt_bapiret2            TYPE bapiret2_t.

  DATA: lt_order_schedules_in   TYPE STANDARD TABLE OF bapischdl.
  DATA: ls_order_schedules_in   TYPE bapischdl.
  DATA: lt_order_schedules_inx  TYPE STANDARD TABLE OF bapischdlx.
  DATA: ls_order_schedules_inx  TYPE bapischdlx.
  DATA: lt_order_conditions_in  TYPE STANDARD TABLE OF bapicond.
  DATA: ls_order_conditions_in  TYPE bapicond.
  DATA: lt_order_conditions_inx TYPE STANDARD TABLE OF bapicondx.
  DATA: ls_order_conditions_inx TYPE bapicondx.
  DATA: lt_order_text           TYPE STANDARD TABLE OF bapisdtext.
  DATA: ls_order_text           TYPE bapisdtext.

  " cabeçalho
  CLEAR ls_order_header_in.
  ls_order_header_in-doc_type   = 'ORB'.  " Tipo de Ordem (AUART)
  ls_order_header_in-sales_org  = '7000'. " Org. Vendas (VKORG)
  ls_order_header_in-distr_chan = '10'.   " Canal de Distribuição (VTWEG)
  ls_order_header_in-division   = '00'.   " Distribuição
  ls_order_header_in-pmnttrms   = '0001'. " Condição de Pagamento (ZTERM)
  ls_order_header_in-currency   = 'BRL'.
  ls_order_header_in-purch_no_c = 'via BAPI'.
  ls_order_header_in-purch_date = sy-datum.
  ls_order_header_in-incoterms1 = 'CIF'.
  ls_order_header_in-incoterms2 = 'São Paulo'.
  ls_order_header_in-price_date = sy-datum.
  ls_order_header_in-price_list = '02'.

  ls_order_header_inx-doc_type   = 'X'.
  ls_order_header_inx-sales_org  = 'X'.
  ls_order_header_inx-distr_chan = 'X'.
  ls_order_header_inx-division   = 'X'.
  ls_order_header_inx-pmnttrms   = 'X'.
  ls_order_header_inx-currency   = 'X'.
  ls_order_header_inx-purch_no_c = 'X'.
  ls_order_header_inx-purch_date = 'X'.
  ls_order_header_inx-incoterms1 = 'X'.
  ls_order_header_inx-incoterms2 = 'X'.
  ls_order_header_inx-price_list = 'X'.
  ls_order_header_inx-price_date = 'X'.

  ls_order_header_inx-updateflag = 'I'.

  " parceiros
  CLEAR ls_order_partners.
  ls_order_partners-partn_role = 'AG'.        " Emissor da Ordem
  ls_order_partners-partn_numb = 'BR-S50A00'. " Código do cliente
  APPEND ls_order_partners TO lt_order_partners.

  CLEAR ls_order_partners.
  ls_order_partners-partn_role = 'WE'.        " Recebedor da Mercadoria
  ls_order_partners-partn_numb = 'BR-S50A00'. " Código do cliente
  APPEND ls_order_partners TO lt_order_partners.

  " itens
  CLEAR ls_order_items_in.
  ls_order_items_in-itm_number = '000010'.
  ls_order_items_in-material   = 'BR-AS100'.
  ls_order_items_in-plant      = '7000'.
  ls_order_items_in-target_qty = 2.

  CLEAR ls_order_items_inx.
  ls_order_items_inx-itm_number = '000010'.
  ls_order_items_inx-material   = 'X'.
  ls_order_items_inx-plant      = 'X'.
  ls_order_items_inx-target_qty = 'X'.
  ls_order_items_inx-updateflag = 'I'.

  APPEND ls_order_items_in  TO lt_order_items_in.
  APPEND ls_order_items_inx TO lt_order_items_inx.

  " divisão de remessa
  CLEAR ls_order_schedules_in.
  ls_order_schedules_in-itm_number = '000010'.
  ls_order_schedules_in-sched_line = '0001'.
  ls_order_schedules_in-req_qty    = 2.
  APPEND ls_order_schedules_in TO lt_order_schedules_in.

  CLEAR ls_order_schedules_inx.
  ls_order_schedules_inx-itm_number  = '000010'.
  ls_order_schedules_inx-sched_line  = '0001'.
  ls_order_schedules_inx-req_qty     = 'X'.
  ls_order_schedules_inx-updateflag  = 'I'.
  APPEND ls_order_schedules_inx TO lt_order_schedules_inx.

  " condições
  CLEAR ls_order_conditions_in.
  ls_order_conditions_in-itm_number = '000010'.
  ls_order_conditions_in-cond_st_no = '001'.
  ls_order_conditions_in-cond_count = '01'.
  ls_order_conditions_in-cond_type  = 'ZPB0'.
  ls_order_conditions_in-cond_value = `123.59`.
  ls_order_conditions_in-currency   = 'BRL'.
  APPEND ls_order_conditions_in TO lt_order_conditions_in.

  CLEAR ls_order_conditions_inx.
  ls_order_conditions_inx-itm_number = '000010'.
  ls_order_conditions_inx-cond_st_no = '001'.
  ls_order_conditions_inx-cond_count = '01'.
  ls_order_conditions_inx-cond_type  = 'X'.
  ls_order_conditions_inx-cond_value = 'X'.
  ls_order_conditions_inx-currency   = 'X'.
  ls_order_conditions_inx-updateflag = 'I'.
  APPEND ls_order_conditions_inx TO lt_order_conditions_inx.

  " textos
  CLEAR ls_order_text.
  ls_order_text-langu      = 'PT'.
  ls_order_text-langu_iso  = 'PT'.
  ls_order_text-format_col = '*'.

  " Texto cabeçalho de formulário
  ls_order_text-text_id    = '0001'.
  ls_order_text-text_line  = 'Linha 1'.
  APPEND ls_order_text TO lt_order_text.

  ls_order_text-text_line  = 'Linha 2'.
  APPEND ls_order_text TO lt_order_text.

  " Nota de cabeçalho 1
  ls_order_text-text_id    = '0002'.
  ls_order_text-text_line  = 'Linha A'.
  APPEND ls_order_text TO lt_order_text.

  ls_order_text-text_line  = 'Linha B'.
  APPEND ls_order_text TO lt_order_text.

  CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
    EXPORTING
      order_header_in      = ls_order_header_in
      order_header_inx     = ls_order_header_inx
     "logic_switch         =
    IMPORTING
      salesdocument        = ld_vbeln
    TABLES
      return               = lt_bapiret2
      order_items_in       = lt_order_items_in
      order_items_inx      = lt_order_items_inx
      order_partners       = lt_order_partners
      order_schedules_in   = lt_order_schedules_in
      order_schedules_inx  = lt_order_schedules_inx
      order_conditions_in  = lt_order_conditions_in
      order_conditions_inx = lt_order_conditions_inx
      order_text           = lt_order_text.

  READ TABLE lt_bapiret2 TRANSPORTING NO FIELDS WITH KEY type = 'E'.
  IF sy-subrc = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    cl_rmsl_message=>display( lt_bapiret2 ).
    EXIT.
  ENDIF.

  IF lines( lt_bapiret2 ) > 0.
    "cl_rmsl_message=>display( lt_bapiret2 ).
  ENDIF.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.

  MESSAGE |Ordem criada com sucesso { ld_vbeln }| TYPE 'I'.
ENDFORM.
FORM modificar_ordem.
  DATA: ld_vbeln           TYPE vbeln.

  DATA: ls_order_header_in  TYPE bapisdh1.
  DATA: ls_order_header_inx TYPE bapisdh1x.
  DATA: lt_order_item_in    TYPE STANDARD TABLE OF bapisditm.
  DATA: ls_order_item_in    TYPE bapisditm.
  DATA: lt_order_item_inx   TYPE STANDARD TABLE OF bapisditmx.
  DATA: ls_order_item_inx   TYPE bapisditmx.
  DATA: lt_schedule_lines   TYPE STANDARD TABLE OF bapischdl.
  DATA: ls_schedule_lines   TYPE bapischdl.
  DATA: lt_schedule_linesx  TYPE STANDARD TABLE OF bapischdlx.
  DATA: ls_schedule_linesx  TYPE bapischdlx.
  DATA: lt_order_text       TYPE STANDARD TABLE OF bapisdtext.
  DATA: ls_order_text       TYPE bapisdtext.
  DATA: lt_conditions_in    TYPE STANDARD TABLE OF bapicond.
  DATA: ls_conditions_in    TYPE bapicond.
  DATA: lt_conditions_inx   TYPE STANDARD TABLE OF bapicondx.
  DATA: ls_conditions_inx   TYPE bapicondx.
  DATA: lt_bapiret2         TYPE bapiret2_t.

  ld_vbeln = '15457'.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = ld_vbeln
    IMPORTING
      output = ld_vbeln.

  " cabeçalho
  ls_order_header_in-purch_no_c  = 'via BAPI (editado)'.
  ls_order_header_inx-purch_no_c = 'X'.
  ls_order_header_inx-updateflag = 'U'.

  " itens
  CLEAR ls_order_item_in.
  ls_order_item_in-itm_number = '000010'.
  ls_order_item_in-target_qty = 4.

  CLEAR ls_order_item_inx.
  ls_order_item_inx-itm_number = '000010'.
  ls_order_item_inx-target_qty = 'X'.
  ls_order_item_inx-updateflag = 'U'.

  APPEND ls_order_item_in TO lt_order_item_in.
  APPEND ls_order_item_inx TO lt_order_item_inx.

  " divisão de remessa
  CLEAR ls_schedule_lines.
  ls_schedule_lines-itm_number = '000010'.
  ls_schedule_lines-sched_line = '0001'.
  ls_schedule_lines-req_qty    = 4.
  APPEND ls_schedule_lines TO lt_schedule_lines.

  CLEAR ls_schedule_linesx.
  ls_schedule_linesx-itm_number  = '000010'.
  ls_schedule_linesx-sched_line  = '0001'.
  ls_schedule_linesx-req_qty     = 'X'.
  ls_schedule_linesx-updateflag  = 'U'.
  APPEND ls_schedule_linesx TO lt_schedule_linesx.

  " condições
  CLEAR ls_conditions_in.
  ls_conditions_in-itm_number = '000010'.
  ls_conditions_in-cond_st_no = '001'.
  ls_conditions_in-cond_count = '01'.
  ls_conditions_in-cond_type  = 'ZPB0'.
  ls_conditions_in-cond_value = `299.01`.
  ls_conditions_in-currency   = 'BRL'.
  APPEND ls_conditions_in TO lt_conditions_in.

  CLEAR ls_conditions_inx.
  ls_conditions_inx-itm_number = '000010'.
  ls_conditions_inx-cond_st_no = '001'.
  ls_conditions_inx-cond_count = '01'.
  ls_conditions_inx-cond_type  = 'X'.
  ls_conditions_inx-cond_value = 'X'.
  ls_conditions_inx-currency   = 'X'.
  ls_conditions_inx-updateflag = 'U'.
  APPEND ls_conditions_inx TO lt_conditions_inx.

  DATA: ls_logic_switch TYPE bapisdls.

  ls_logic_switch-pricing = 'C'.

  CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
    EXPORTING
      salesdocument    = ld_vbeln
      order_header_in  = ls_order_header_in
      order_header_inx = ls_order_header_inx
      logic_switch     = ls_logic_switch
    TABLES
      return           = lt_bapiret2
      order_item_in    = lt_order_item_in
      order_item_inx   = lt_order_item_inx
      schedule_lines   = lt_schedule_lines
      schedule_linesx  = lt_schedule_linesx
      order_text       = lt_order_text
      conditions_in    = lt_conditions_in
      conditions_inx   = lt_conditions_inx.

  READ TABLE lt_bapiret2 TRANSPORTING NO FIELDS WITH KEY type = 'E'.
  IF sy-subrc = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    cl_rmsl_message=>display( lt_bapiret2 ).
    EXIT.
  ENDIF.

  IF lines( lt_bapiret2 ) > 0.
    "cl_rmsl_message=>display( lt_bapiret2 ).
  ENDIF.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.

  MESSAGE |Ordem modificada com sucesso { ld_vbeln }| TYPE 'I'.
ENDFORM.
