* versão 0.3
class ZCL_TEXTAREA definition
  public
  create public .

*"* public components of class ZCL_TEXTAREA
*"* do not include other source files here!!!
public section.

  types:
    BEGIN OF my_text_s
       , line TYPE char255
       , END OF my_text_s .

  "types: my_text_t TYPE STANDARD TABLE OF char255 .
  types: my_text_t TYPE STANDARD TABLE OF zmkpcharmax_e.

  data MO_EDITOR type ref to CL_GUI_TEXTEDIT .
  data MO_CONTAINER type ref to CL_GUI_CUSTOM_CONTAINER .
  data MD_CONTAINER type CHAR255 .
  data MT_TEXT_TMP type MY_TEXT_T .

  methods CALLME_IN_PBO .
  methods CONSTRUCTOR
    importing
      !ID_CONTAINER type STRING .
  methods GET_TABLE_TEXT
    exporting
      !ET_TEXT type STANDARD TABLE .
  methods SET_TABLE_TEXT
    importing
      value(IT_TEXT) type STANDARD TABLE .
  methods CLEAN_TEXT .
  methods SAVE_TEXT
    importing
      value(IS_HEADER) type THEAD
    returning
      value(RD_SUBRC) type SYSUBRC .
  methods LOAD_TEXT
    importing
      value(IS_HEADER) type THEAD .
protected section.
*"* protected components of class ZCL_TEXTAREA
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_TEXTAREA
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_TEXTAREA IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_TEXTAREA->CALLME_IN_PBO
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD callme_in_pbo.
  IF me->mo_editor IS NOT BOUND.
    " container
    CREATE OBJECT me->mo_container
      EXPORTING
        container_name              = me->md_container
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    " editor
    CREATE OBJECT me->mo_editor
      EXPORTING
        parent                     = me->mo_container
        wordwrap_mode              = cl_gui_textedit=>wordwrap_at_windowborder " cl_gui_textedit=>wordwrap_at_fixed_position
        wordwrap_to_linebreak_mode = cl_gui_textedit=>false        " cl_gui_textedit=>true
      EXCEPTIONS
        OTHERS                     = 1.
  ENDIF.

  " se tiver texto temporário
  IF lines( me->mt_text_tmp ) > 0.
    CALL METHOD me->mo_editor->set_text_as_r3table
      EXPORTING
        table = me->mt_text_tmp.

    CLEAR me->mt_text_tmp.
  ENDIF.
ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_TEXTAREA->CLEAN_TEXT
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
method CLEAN_TEXT.
  DATA: lt_text TYPE STANDARD TABLE OF char1.

  IF me->mo_editor IS NOT BOUND.
    RETURN.
  ENDIF.

  CALL METHOD me->set_table_text
    EXPORTING
      it_text = lt_text.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_TEXTAREA->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_CONTAINER                   TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method CONSTRUCTOR.
*
* Autor Vinicius
* Última atualização 09/08/2023 v0.1
* https://github.com/vcd94xt10z
*
  me->md_container = id_container.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_TEXTAREA->GET_TABLE_TEXT
* +-------------------------------------------------------------------------------------------------+
* | [<---] ET_TEXT                        TYPE        STANDARD TABLE
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_TABLE_TEXT.
  IF me->mo_editor IS NOT BOUND.
    RETURN.
  ENDIF.

  CALL METHOD me->mo_editor->get_text_as_r3table
    IMPORTING
      table = et_text
    EXCEPTIONS
      OTHERS = 1.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_TEXTAREA->LOAD_TEXT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_HEADER                      TYPE        THEAD
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD load_text.
  DATA: lt_lines  TYPE tline_tab
      , ls_lines  LIKE LINE OF lt_lines.
  DATA: lt_text   TYPE my_text_t.
  DATA: ld_string TYPE string.

  me->clean_text( ).

  " carregando texto anterior (se existir)
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = is_header-tdid
      language                = is_header-tdspras
      name                    = is_header-tdname
      object                  = is_header-tdobject
    TABLES
      lines                   = lt_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7.

  " populando tabela de textos usada pelo componente
  CLEAR ld_string.
  LOOP AT lt_lines INTO ls_lines.
    CONCATENATE ld_string ls_lines-tdline
           INTO ld_string RESPECTING BLANKS.
  ENDLOOP.

  " devolvendo a linha e deixando o textarea fazer as quebras automaticamente
  CLEAR lt_text.
  APPEND ld_string TO lt_text.

  IF me->mo_editor IS NOT BOUND.
    " guardando texto para ser carregado depois
    me->mt_text_tmp = lt_text.
    RETURN.
  ENDIF.

  " setando texto de entrada
  CALL METHOD me->mo_editor->set_text_as_r3table
    EXPORTING
      table = lt_text.
ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_TEXTAREA->SAVE_TEXT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_HEADER                      TYPE        THEAD
* | [<-()] RD_SUBRC                       TYPE        SYSUBRC
* +--------------------------------------------------------------------------------------</SIGNATURE>
method SAVE_TEXT.
  DATA: lt_text  TYPE my_text_t.
  DATA: ls_text  LIKE LINE OF lt_text.
  DATA: lt_text2 TYPE STANDARD TABLE OF tline.
  DATA: ls_text2 LIKE LINE OF lt_text2.

  DATA: ld_buffer TYPE string.
  DATA: ld_string TYPE string.
  DATA: ld_index  TYPE int4.
  DATA: ld_size   TYPE int4.
  DATA: ld_char   TYPE char1.
  DATA: ld_line   TYPE string.

  IF me->mo_editor IS NOT BOUND.
    RETURN.
  ENDIF.

  " obtendo os textos
  CALL METHOD me->mo_editor->get_text_as_r3table
    IMPORTING
      table = lt_text
    EXCEPTIONS
      OTHERS = 1.

  " juntando linhas em uma única string
  CLEAR ld_string.
  LOOP AT lt_text INTO ld_line.
    IF ld_line = ''.
      " o componente textarea separa as linhas com uma linha em branco.
      " Para representar corretamente, é necessário inserir duas quebras de linha
      CONCATENATE ld_string
                  cl_abap_char_utilities=>newline
                  cl_abap_char_utilities=>newline
             INTO ld_string RESPECTING BLANKS.
    ELSE.
      CONCATENATE ld_string ld_line
             INTO ld_string RESPECTING BLANKS.
    ENDIF.
  ENDLOOP.
  CONDENSE ld_string.

  " quebrando string em padaços de texto
  ld_size = strlen( ld_string ).
  ld_buffer = ''.
  DO ld_size TIMES.
    ld_index = sy-index - 1.
    ld_char = ld_string+ld_index(1).
    CONCATENATE ld_buffer ld_char
           INTO ld_buffer RESPECTING BLANKS.

    IF strlen( ld_buffer ) = 132.
      CLEAR ls_text2.
      ls_text2-tdformat = '*'.
      ls_text2-tdline   = ld_buffer.
      APPEND ls_text2 TO lt_text2.
      CLEAR ld_buffer.
    ENDIF.
  ENDDO.

  " se sobrar algo no buffer no final, adiciona o resto
  IF ld_buffer <> ''.
    CLEAR ls_text2.
    ls_text2-tdformat = '*'.
    ls_text2-tdline   = ld_buffer.
    APPEND ls_text2 TO lt_text2.
    CLEAR ld_buffer.
  ENDIF.

  " salvando textos
  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      header          = is_header
      savemode_direct = 'X'
    TABLES
      lines           = lt_text2
    EXCEPTIONS
      id              = 1
      language        = 2
      name            = 3
      object          = 4
      others          = 5.

  rd_subrc = sy-subrc.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_TEXTAREA->SET_TABLE_TEXT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_TEXT                        TYPE        STANDARD TABLE
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD set_table_text.
  IF me->mo_editor IS NOT BOUND.
    INSERT LINES OF it_text INTO TABLE me->mt_text_tmp.
    RETURN.
  ENDIF.

  CALL METHOD me->mo_editor->set_text_as_r3table
    EXPORTING
      table  = it_text
    EXCEPTIONS
      OTHERS = 1.
ENDMETHOD.
ENDCLASS.
