*
* Autor Vinicius Cesar Dias
* Última atualização 10/08/2023 v0.2
*
* Objeto de texto
*
* Procedimento para cadastro
* Transação SE75
* Opção: Text Objects and IDs > Change
* Clique em New
* Informe o Text object, exemplo ZNF01
* Editor application, exemplo TN
* Line width, exemplo 72
* Clique em OK
*
* Marque a linha e clique em Text IDs
* Informe o text ID, exemplo Z001 (Texto da nota fiscal)
* Clique em Salvar
*
REPORT ZOBJETO_TEXTO.
  DATA: ls_header TYPE thead.

  DATA: lt_text TYPE STANDARD TABLE OF tline.
  DATA: ls_text LIKE LINE OF lt_text.

  CLEAR ls_header.
  ls_header-tdobject = 'ZNF01'. " Objeto (exemplo: Nota Fiscal, Ordem de Venda, Ordem de Compra etc)
  ls_header-tdid     = 'Z001'.  " Id do texto (exemplo: Texto básico, texto de remessa, texto de fatura etc)
  ls_header-tdname   = '1'.     " Chave primária do objeto (exemplo: Número da nota fiscal, número da ordem etc)
  ls_header-tdspras  = 'E'.     " Idioma (P = Português, E = Inglês etc)

  BREAK-POINT.

  " lendo objeto de texto
  CLEAR lt_text.
  PERFORM read.

  " atualizando objeto de texto
  CLEAR ls_text.
  ls_text-tdformat = '*'.
  ls_text-tdline   = |{ sy-datum } { sy-uzeit }|.
  APPEND ls_text TO lt_text.
  PERFORM save.

  " lendo novamente para conferir
  CLEAR lt_text.
  PERFORM read.

  BREAK-POINT.

FORM read.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = ls_header-tdid
      language                = ls_header-tdspras
      name                    = ls_header-tdname
      object                  = ls_header-tdobject
    TABLES
      lines                   = lt_text
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7.
ENDFORM.
FORM save.
  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      header          = ls_header
      savemode_direct = 'X'
    TABLES
      lines           = lt_text
    EXCEPTIONS
      id       = 1
      language = 2
      name     = 3
      object   = 4
      others   = 5.
ENDFORM.
