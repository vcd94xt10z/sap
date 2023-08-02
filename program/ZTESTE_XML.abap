REPORT ZTESTE_XML.

DATA: ld_xml      TYPE string.
DATA: ls_ordem    TYPE ztest_ordem.
DATA: ls_item     TYPE ztest_item_s.
DATA: ls_cond     TYPE ztest_cond_s.
DATA: ls_cliente  TYPE ztest_cliente.
DATA: lt_sairport TYPE STANDARD TABLE OF sairport.

START-OF-SELECTION.
  BREAK-POINT.
  PERFORM fill.
  PERFORM automatica.
  PERFORM manual.

FORM fill.
  SELECT *
    INTO TABLE lt_sairport
    FROM sairport.

  ls_cliente-kunnr = 2.
  ls_cliente-nome  = 'José da Silva'.

  ls_ordem-cliente   = ls_cliente.
  ls_ordem-erdat     = sy-datum.
  ls_ordem-erzet     = sy-uzeit.
  ls_ordem-vbeln     = 123.
  ls_ordem-peso_tot  = '123.456'.
  ls_ordem-valor_tot = '198.32'.

  CLEAR ls_item.
  ls_item-posnr = 1.
  ls_item-matnr = '111'.
  ls_item-maktx = 'Pilha'.

  CLEAR ls_cond.
  ls_cond-posnr    = 1.
  ls_cond-kposn    = 1.
  ls_cond-tipo     = 'DESC'.
  ls_cond-montante = '10'.
  ls_cond-valor    = '10'.
  APPEND ls_cond TO ls_item-cond_tab.

  CLEAR ls_cond.
  ls_cond-posnr    = 1.
  ls_cond-kposn    = 2.
  ls_cond-tipo     = 'IPI'.
  ls_cond-montante = '15'.
  ls_cond-valor    = '15'.
  APPEND ls_cond TO ls_item-cond_tab.

  APPEND ls_item TO ls_ordem-item_tab.

  CLEAR ls_item.
  ls_item-posnr = 2.
  ls_item-matnr = '222'.
  ls_item-maktx = 'Teclado'.
  APPEND ls_item TO ls_ordem-item_tab.
ENDFORM.
FORM automatica.
  " estrutura simples
  CLEAR ld_xml.
  zcl_xml_utils=>data_to_xml(
    EXPORTING
      data = ls_cliente
    RECEIVING
      xml  = ld_xml
  ).

  CLEAR ls_cliente.
  zcl_xml_utils=>xml_to_data(
    EXPORTING
      xml  = ld_xml
    CHANGING
      data = ls_cliente
  ).

  " tabela interna
  CLEAR ld_xml.
  zcl_xml_utils=>data_to_xml(
    EXPORTING
      data = lt_sairport
    RECEIVING
      xml  = ld_xml
  ).

  CLEAR lt_sairport.
  zcl_xml_utils=>xml_to_data(
    EXPORTING
      xml  = ld_xml
    CHANGING
      data = lt_sairport
  ).

  " estrutura complexa
  CLEAR ld_xml.
  zcl_xml_utils=>data_to_xml(
    EXPORTING
      data = ls_ordem
    RECEIVING
      xml  = ld_xml
  ).

  CLEAR ls_ordem.
  zcl_xml_utils=>xml_to_data(
    EXPORTING
      xml  = ld_xml
    CHANGING
      data = ls_ordem
  ).
ENDFORM.
FORM manual.
  " estrutura simples
  CLEAR ld_xml.
  zcl_xml_utils=>data_to_xml_manual(
    EXPORTING
      data = ls_cliente
    RECEIVING
      xml  = ld_xml
  ).

  CLEAR ls_cliente.
  zcl_xml_utils=>xml_to_data_manual(
    EXPORTING
      xml  = ld_xml
    CHANGING
      data = ls_cliente
  ).

  " tabela interna
  CLEAR ld_xml.
  zcl_xml_utils=>data_to_xml_manual(
    EXPORTING
      data = lt_sairport
    RECEIVING
      xml  = ld_xml
  ).

  CLEAR lt_sairport.
  zcl_xml_utils=>xml_to_data_manual(
    EXPORTING
      xml  = ld_xml
    CHANGING
      data = lt_sairport
  ).

  " estrutura complexa
  CLEAR ld_xml.
  zcl_xml_utils=>data_to_xml_manual(
    EXPORTING
      data = ls_ordem
    RECEIVING
      xml  = ld_xml
  ).

  CLEAR ls_ordem.
  zcl_xml_utils=>xml_to_data_manual(
    EXPORTING
      xml  = ld_xml
    CHANGING
      data = ls_ordem
  ).
ENDFORM.
