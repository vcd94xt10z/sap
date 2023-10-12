* versão 0.1
class ZCL_TEXT_UTILS definition
  public
  create public .

public section.

  class-methods SPLIT_AT_SIZE
    importing
      value(ID_VALUE) type ANY
      value(ID_SIZE) type INT4
    exporting
      !ET_TABLE type ANY TABLE .
  class-methods TEXT_TO_MSG
    importing
      !ID_TEXT type ANY
    changing
      !CD_MSGV1 type ANY
      !CD_MSGV2 type ANY
      !CD_MSGV3 type ANY
      !CD_MSGV4 type ANY .
  class-methods LOAD_TEXT_OBJECT
    importing
      !IS_HEADER type THEAD
    exporting
      !ED_TEXT type ANY
      !ET_TEXT type STANDARD TABLE .
  class-methods SAVE_TEXT_OBJECT
    importing
      !IS_HEADER type THEAD
      !IT_TEXT type STANDARD TABLE
    returning
      value(RD_SUBRC) type INT4 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_TEXT_UTILS IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_TEXT_UTILS=>LOAD_TEXT_OBJECT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_HEADER                      TYPE        THEAD
* | [<---] ED_TEXT                        TYPE        ANY
* | [<---] ET_TEXT                        TYPE        STANDARD TABLE
* +--------------------------------------------------------------------------------------</SIGNATURE>
method LOAD_TEXT_OBJECT.
  DATA: lt_lines TYPE tline_tab
      , ls_lines LIKE LINE OF lt_lines.

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
  CLEAR ed_text.
  LOOP AT lt_lines INTO ls_lines.
    CONCATENATE ed_text ls_lines-tdline
           INTO ed_text RESPECTING BLANKS.
  ENDLOOP.

  CLEAR et_text.

  IF et_text IS SUPPLIED.
    SPLIT ed_text
       AT cl_abap_char_utilities=>newline
     INTO TABLE et_text.
  ENDIF.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_TEXT_UTILS=>SAVE_TEXT_OBJECT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_HEADER                      TYPE        THEAD
* | [--->] IT_TEXT                        TYPE        STANDARD TABLE
* | [<-()] RD_SUBRC                       TYPE        INT4
* +--------------------------------------------------------------------------------------</SIGNATURE>
method SAVE_TEXT_OBJECT.
  DATA: ld_text  TYPE string.
  DATA: lt_text2 TYPE STANDARD TABLE OF tline.
  DATA: ls_text2 LIKE LINE OF lt_text2.

  " convertendo para o formato correto
  LOOP AT it_text INTO ld_text.
    ls_text2-tdformat = '*'.
    ls_text2-tdline   = ld_text.
    APPEND ls_text2 TO lt_text2.
  ENDLOOP.

  " salvando textos
  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      header          = is_header
      savemode_direct = 'X'
    TABLES
      lines           = lt_text2
    EXCEPTIONS
      id       = 1
      language = 2
      name     = 3
      object   = 4
      others   = 5.

  rd_subrc = sy-subrc.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_TEXT_UTILS=>SPLIT_AT_SIZE
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_VALUE                       TYPE        ANY
* | [--->] ID_SIZE                        TYPE        INT4
* | [<---] ET_TABLE                       TYPE        ANY TABLE
* +--------------------------------------------------------------------------------------</SIGNATURE>
method SPLIT_AT_SIZE.
  DATA: ld_line   TYPE string.
  DATA: ld_strlen TYPE int4.

  DO.
    ld_strlen = strlen( id_value ).
    IF ld_strlen <= id_size.
      ld_line = id_value.
      INSERT ld_line INTO TABLE et_table.
      EXIT.
    ENDIF.

    ld_line = id_value(id_size).
    INSERT ld_line INTO TABLE et_table.
    id_value = id_value+id_size.
  ENDDO.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_TEXT_UTILS=>TEXT_TO_MSG
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_TEXT                        TYPE        ANY
* | [<-->] CD_MSGV1                       TYPE        ANY
* | [<-->] CD_MSGV2                       TYPE        ANY
* | [<-->] CD_MSGV3                       TYPE        ANY
* | [<-->] CD_MSGV4                       TYPE        ANY
* +--------------------------------------------------------------------------------------</SIGNATURE>
method TEXT_TO_MSG.
  DATA: lt_data TYPE STANDARD TABLE OF string.
  DATA: ld_data TYPE string.

  split_at_size(
    EXPORTING
      id_value = id_text
      id_size  = 50
    IMPORTING
      et_table = lt_data
  ).

  READ TABLE lt_data INTO ld_data INDEX 1.
  IF sy-subrc = 0.
    cd_msgv1 = ld_data.
  ENDIF.

  READ TABLE lt_data INTO ld_data INDEX 2.
  IF sy-subrc = 0.
    cd_msgv2 = ld_data.
  ENDIF.

  READ TABLE lt_data INTO ld_data INDEX 3.
  IF sy-subrc = 0.
    cd_msgv3 = ld_data.
  ENDIF.

  READ TABLE lt_data INTO ld_data INDEX 4.
  IF sy-subrc = 0.
    cd_msgv4 = ld_data.
  ENDIF.
endmethod.
ENDCLASS.
