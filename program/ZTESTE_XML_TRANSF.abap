* Transação XSLT_TOOL
REPORT ZTESTE_XML_TRANSF.

DATA: ld_xml      TYPE string.
DATA: ls_ordem    TYPE ztest_ordem.
DATA: ls_item     TYPE ztest_item_s.
DATA: ls_cond     TYPE ztest_cond_s.
DATA: ls_cliente  TYPE ztest_cliente.
DATA: lt_sairport TYPE STANDARD TABLE OF sairport.

START-OF-SELECTION.
  BREAK-POINT.
  PERFORM dados.
  PERFORM conversoes.

FORM dados.
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
FORM conversoes.
  DATA: ld_string  TYPE string.
  DATA: ld_xstring TYPE xstring.

  " [Estrutura]

  " Estrutura => XML String
  CLEAR ld_string.
  CLEAR ld_xstring.
  CALL TRANSFORMATION ZTESTE1 SOURCE data = ls_cliente RESULT XML ld_xstring.
  PERFORM xstring_2_string USING ld_xstring CHANGING ld_string.

  " XML String => Estrutura
  CLEAR ls_cliente.
  CALL TRANSFORMATION ZTESTE1 SOURCE XML ld_string RESULT data = ls_cliente.

  " [Tabela interna]

  " Tabela interna => XML String
  CLEAR ld_string.
  CLEAR ld_xstring.
  CALL TRANSFORMATION ZTESTE2 SOURCE data = lt_sairport RESULT XML ld_xstring.
  PERFORM xstring_2_string USING ld_xstring CHANGING ld_string.

  " XML String => Tabela interna
  CLEAR lt_sairport.
  CALL TRANSFORMATION ZTESTE2 SOURCE XML ld_string RESULT data = lt_sairport.

  " [Estrutura profunda]

  " Estrutura => XML String
  CLEAR ld_string.
  CLEAR ld_xstring.
  CALL TRANSFORMATION ZTESTE3 SOURCE data = ls_ordem RESULT XML ld_xstring.
  PERFORM xstring_2_string USING ld_xstring CHANGING ld_string.

  " XML String => Estrutura
  CLEAR ls_ordem.
  CALL TRANSFORMATION ZTESTE3 SOURCE XML ld_string RESULT data = ls_ordem.
ENDFORM.
FORM xstring_2_string USING ud_xstring CHANGING cd_string.
  DATA: ld_length TYPE i.
  DATA: lt_binary TYPE STANDARD TABLE OF x255.

  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer        = ud_xstring
    IMPORTING
      output_length = ld_length
    TABLES
      binary_tab    = lt_binary.

  CALL FUNCTION 'SCMS_BINARY_TO_STRING'
    EXPORTING
      input_length = ld_length
    IMPORTING
      text_buffer  = cd_string
    TABLES
      binary_tab   = lt_binary
    EXCEPTIONS
      failed       = 1
      OTHERS       = 2.
endform.
