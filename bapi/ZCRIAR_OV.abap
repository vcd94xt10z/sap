REPORT ZCRIAR_OV.

DATA: ld_vbeln                TYPE vbak-vbeln.
DATA: ld_kunnr                TYPE kunnr.
DATA: ld_lifnr                TYPE lifnr.
DATA: ld_langu                TYPE sy-langu.

DATA: ls_order_header_in      TYPE bapisdhd1.
DATA: ls_order_header_inx     TYPE bapisdhd1x.
DATA: lt_order_items_in       TYPE STANDARD TABLE OF bapisditm.
DATA: ls_order_items_in       TYPE bapisditm.
DATA: lt_order_items_inx      TYPE STANDARD TABLE OF bapisditmx.
DATA: ls_order_items_inx      TYPE bapisditmx.
DATA: lt_order_schedules_in   TYPE STANDARD TABLE OF bapischdl.
DATA: ls_order_schedules_in   TYPE bapischdl.
DATA: lt_order_schedules_inx  TYPE STANDARD TABLE OF bapischdlx.
DATA: ls_order_schedules_inx  TYPE bapischdlx.
DATA: lt_order_conditions_in  TYPE STANDARD TABLE OF bapicond.
data: ls_order_conditions_in  type bapicond.
DATA: lt_order_conditions_inx TYPE STANDARD TABLE OF bapicondx.
DATA: ls_order_conditions_inx TYPE bapicondx.
DATA: lt_order_partners       TYPE STANDARD TABLE OF bapiparnr.
DATA: ls_order_partners       TYPE bapiparnr.
DATA: lt_partneraddresses     TYPE STANDARD TABLE OF bapiaddr1.
DATA: ls_partneraddresses     TYPE bapiaddr1.
DATA: lt_order_text           TYPE STANDARD TABLE OF bapisdtext.
DATA: ls_order_text           TYPE bapisdtext.
DATA: lt_return               TYPE bapiret2_t.
DATA: ls_return               TYPE bapiret2.
DATA: ld_error                TYPE flag.

START-OF-SELECTION.
  ld_langu = 'E'.
  ld_kunnr = 'BR-S50A05'.
  ld_lifnr = 'TRANS00-01'.

  " cabeçalho
  CLEAR ls_order_header_in.
  ls_order_header_in-doc_type   = 'ORB'.    " AUART
  ls_order_header_in-sales_org  = '7000'.   " VKORG
  ls_order_header_in-distr_chan = '10'.     " VTWEG
  ls_order_header_in-division   = '00'.     " SPART
  ls_order_header_in-sales_grp  = ''.       "
  ls_order_header_in-sales_off  = ''.       "
  ls_order_header_in-price_grp  = '01'.     "
  ls_order_header_in-price_list = '90'.     " Internet
  ls_order_header_in-cust_group = ''.       " KDGRP
  ls_order_header_in-sales_dist = ''.       " BZIRK
  ls_order_header_in-incoterms1 = 'CIF'.    " INCO1
  ls_order_header_in-incoterms2 = 'SEDEX'.  " INCO2
  ls_order_header_in-pmnttrms   = '0001'.   " DZTERM
  ls_order_header_in-dlv_block  = ''.       " LIFSK
  ls_order_header_in-bill_block = ''.       " FAKSK
  ls_order_header_in-ord_reason = ''.       " AUGRU
  ls_order_header_in-price_date = sy-datum. " PRSDT
  ls_order_header_in-purch_date = sy-datum. " PRSDT
  ls_order_header_in-purch_no_c = 'Pedido teste'. " BSTKD
  ls_order_header_in-purch_no_s = ''.       " BSTKD_E
  ls_order_header_in-doc_date   = sy-datum. " AUDAT
  ls_order_header_in-currency   = 'BRL'.    " WAERK
  ls_order_header_in-curr_iso   = 'BRL'.    " WAERS_ISO

  CLEAR ls_order_header_inx.
  ls_order_header_inx-updateflag = 'I'.
  ls_order_header_inx-doc_type   = 'X'.
  ls_order_header_inx-sales_org  = 'X'.
  ls_order_header_inx-distr_chan = 'X'.
  ls_order_header_inx-division   = 'X'.
  ls_order_header_inx-price_grp  = 'X'.
  ls_order_header_inx-price_list = 'X'.
  ls_order_header_inx-incoterms1 = 'X'.
  ls_order_header_inx-incoterms2 = 'X'.
  ls_order_header_inx-pmnttrms   = 'X'.
  ls_order_header_inx-price_date = 'X'.
  ls_order_header_inx-purch_date = 'X'.
  ls_order_header_inx-purch_no_c = 'X'.
  ls_order_header_inx-doc_date   = 'X'.
  ls_order_header_inx-currency   = 'X'.

  " itens
  CLEAR ls_order_items_in.
  ls_order_items_in-itm_number = '000010'.
  ls_order_items_in-material   = 'BR-AS100'.
  ls_order_items_in-plant      = '7000'.
  ls_order_items_in-store_loc  = ''.
  ls_order_items_in-target_qty = 2.
  APPEND ls_order_items_in TO lt_order_items_in.

  CLEAR ls_order_items_inx.
  ls_order_items_inx-itm_number = '000010'.
  ls_order_items_inx-material   = 'X'.
  ls_order_items_inx-plant      = 'X'.
  ls_order_items_inx-store_loc  = 'X'.
  ls_order_items_inx-target_qty = 'X'.
  APPEND ls_order_items_inx TO lt_order_items_inx.

  CLEAR ls_order_items_in.
  ls_order_items_in-itm_number = '000020'.
  ls_order_items_in-material   = 'BR-AS200'.
  ls_order_items_in-plant      = '7000'.
  ls_order_items_in-store_loc  = ''.
  ls_order_items_in-target_qty = 1.
  APPEND ls_order_items_in TO lt_order_items_in.

  CLEAR ls_order_items_inx.
  ls_order_items_inx-itm_number = '000020'.
  ls_order_items_inx-material   = 'X'.
  ls_order_items_inx-plant      = 'X'.
  ls_order_items_inx-store_loc  = 'X'.
  ls_order_items_inx-target_qty = 'X'.
  APPEND ls_order_items_inx TO lt_order_items_inx.

  " divisão de remessa
  CLEAR ls_order_schedules_in.
  ls_order_schedules_in-itm_number = '000010'.
  ls_order_schedules_in-sched_line = '0001'.
  ls_order_schedules_in-req_qty    = 2.
  APPEND ls_order_schedules_in TO lt_order_schedules_in.

  CLEAR ls_order_schedules_inx.
  ls_order_schedules_inx-itm_number = '000010'.
  ls_order_schedules_inx-sched_line = '0001'.
  ls_order_schedules_inx-req_qty    = 'X'.
  ls_order_schedules_inx-updateflag = 'U'.
  APPEND ls_order_schedules_inx TO lt_order_schedules_inx.

  CLEAR ls_order_schedules_in.
  ls_order_schedules_in-itm_number = '000020'.
  ls_order_schedules_in-sched_line = '0001'.
  ls_order_schedules_in-req_qty    = 1.
  APPEND ls_order_schedules_in TO lt_order_schedules_in.

  CLEAR ls_order_schedules_inx.
  ls_order_schedules_inx-itm_number = '000020'.
  ls_order_schedules_inx-sched_line = '0001'.
  ls_order_schedules_inx-req_qty    = 'X'.
  ls_order_schedules_inx-updateflag = 'U'.
  APPEND ls_order_schedules_inx TO lt_order_schedules_inx.

  " condições
  CLEAR ls_order_conditions_in.
  ls_order_conditions_in-itm_number = '000010'.
  ls_order_conditions_in-cond_st_no = '001'.
  ls_order_conditions_in-cond_type  = 'ZPB0'.
  ls_order_conditions_in-cond_value = `123.45`.
  ls_order_conditions_in-condvalue  = `123.45`.
  ls_order_conditions_in-currency   = 'BRL'.
  ls_order_conditions_in-curr_iso   = 'BRL'.
  APPEND ls_order_conditions_in TO lt_order_conditions_in.

  CLEAR ls_order_conditions_inx.
  ls_order_conditions_inx-itm_number = '000010'.
  ls_order_conditions_inx-cond_st_no = '001'.
  ls_order_conditions_inx-cond_type  = 'X'.
  ls_order_conditions_inx-cond_value = 'X'.
  ls_order_conditions_inx-currency   = 'X'.
  ls_order_conditions_inx-updateflag = 'I'.
  APPEND ls_order_conditions_inx TO lt_order_conditions_inx.

  CLEAR ls_order_conditions_in.
  ls_order_conditions_in-itm_number = '000020'.
  ls_order_conditions_in-cond_st_no = '001'.
  ls_order_conditions_in-cond_type  = 'ZPB0'.
  ls_order_conditions_in-cond_value = `300.64`.
  ls_order_conditions_in-condvalue  = `300.64`.
  ls_order_conditions_in-currency   = 'BRL'.
  ls_order_conditions_in-curr_iso   = 'BRL'.
  APPEND ls_order_conditions_in TO lt_order_conditions_in.

  CLEAR ls_order_conditions_inx.
  ls_order_conditions_inx-itm_number = '000020'.
  ls_order_conditions_inx-cond_st_no = '001'.
  ls_order_conditions_inx-cond_type  = 'X'.
  ls_order_conditions_inx-cond_value = 'X'.
  ls_order_conditions_inx-currency   = 'X'.
  ls_order_conditions_inx-updateflag = 'I'.
  APPEND ls_order_conditions_inx TO lt_order_conditions_inx.

  " parceiros
  CLEAR ls_order_partners.
  ls_order_partners-partn_role = 'AG'. " Emissor da ordem
  ls_order_partners-partn_numb = ld_kunnr.
  APPEND ls_order_partners TO lt_order_partners.

  CLEAR ls_order_partners.
  ls_order_partners-partn_role = 'WE'. " Recebedor da mercadoria
  ls_order_partners-partn_numb = ld_kunnr.
  APPEND ls_order_partners TO lt_order_partners.

  CLEAR ls_order_partners.
  ls_order_partners-partn_role = 'RE'. " Recebedor da fatura
  ls_order_partners-partn_numb = ld_kunnr.
  APPEND ls_order_partners TO lt_order_partners.

  CLEAR ls_order_partners.
  ls_order_partners-partn_role = 'RG'. " Pagador
  ls_order_partners-partn_numb = ld_kunnr.
  APPEND ls_order_partners TO lt_order_partners.

  CLEAR ls_order_partners.
  ls_order_partners-partn_role = 'SP'. " Transportador
  ls_order_partners-partn_numb = ld_lifnr.
  APPEND ls_order_partners TO lt_order_partners.

  " textos
  CLEAR ls_order_text.
  ls_order_text-format_col = '*'.
  ls_order_text-itm_number = '000000'.
  ls_order_text-langu      = ld_langu.
  ls_order_text-langu_iso  = ld_langu.

  " texto 1
  ls_order_text-text_id    = '0001'.
  ls_order_text-text_line  = 'Linha 1 linha 1'.
  APPEND ls_order_text TO lt_order_text.

  ls_order_text-text_line  = 'Linha 2 linha 2'.
  APPEND ls_order_text TO lt_order_text.

  " texto 2
  ls_order_text-text_id    = '0002'.
  ls_order_text-text_line  = 'aaa'.
  APPEND ls_order_text TO lt_order_text.

  ls_order_text-text_line  = 'bbb'.
  APPEND ls_order_text TO lt_order_text.

  CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
    EXPORTING
      salesdocumentin      = ld_vbeln
      order_header_in      = ls_order_header_in
      order_header_inx     = ls_order_header_inx
    IMPORTING
      salesdocument        = ld_vbeln
    TABLES
      return               = lt_return
      order_items_in       = lt_order_items_in
      order_items_inx      = lt_order_items_inx
      order_partners       = lt_order_partners
      order_schedules_in   = lt_order_schedules_in
      order_schedules_inx  = lt_order_schedules_inx
      order_conditions_in  = lt_order_conditions_in
      order_conditions_inx = lt_order_conditions_inx
      order_text           = lt_order_text
      partneraddresses     = lt_partneraddresses.

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

    MESSAGE |Ordem criada { ld_vbeln }| TYPE 'I'.
  ENDIF.
