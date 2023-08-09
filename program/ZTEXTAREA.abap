*
* Autor Vinicius Cesar Dias
* Última atualização 09/08/2023 v0.1
*
REPORT ZTEXTAREA.

DATA: gd_debug    TYPE flag.
DATA: go_textarea TYPE REF TO zcl_textarea.

START-OF-SELECTION.
  go_textarea = new zcl_textarea( id_container = 'TEXTAREA1' ).

  CALL SCREEN 9000.

MODULE pbo_9000 OUTPUT.
  SET PF-STATUS 'S9000'.
  SET TITLEBAR 'T9000'.

  go_textarea->callme_in_pbo( ).
ENDMODULE.
MODULE pai_9000 INPUT.
  CASE sy-ucomm.
  WHEN 'LOAD'.
    PERFORM load.
  WHEN 'SAVE'.
    PERFORM save.
  WHEN 'LOAD1'.
    PERFORM load1.
  WHEN 'SAVE1'.
    PERFORM save1.
  WHEN 'BACK' OR 'UP' OR 'CANCEL'.
    LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
FORM load1.
  DATA: ls_header TYPE thead.

  CLEAR ls_header.
  ls_header-tdid     = 'Z001'.
  ls_header-tdname   = '1'.
  ls_header-tdobject = 'ZTX01'.
  ls_header-tdspras  = 'E'.

  IF gd_debug = 'X'.
    BREAK-POINT.
  ENDIF.

  go_textarea->load_text( is_header = ls_header ).
ENDFORM.
FORM save1.
  DATA: ls_header TYPE thead.

  CLEAR ls_header.
  ls_header-tdid     = 'Z001'.
  ls_header-tdname   = '1'.
  ls_header-tdobject = 'ZTX01'.
  ls_header-tdspras  = 'E'.

  IF gd_debug = 'X'.
    BREAK-POINT.
  ENDIF.

  go_textarea->save_text( is_header = ls_header ).
ENDFORM.
FORM load.
  DATA: lt_text TYPE STANDARD TABLE OF char255.

  IF gd_debug = 'X'.
    BREAK-POINT.
  ENDIF.

  APPEND 'Linha 1' TO lt_text.
  APPEND 'Linha 2' TO lt_text.
  APPEND 'Linha 3' TO lt_text.
  APPEND '' TO lt_text.
  APPEND 'Coluna 1 coluna 2 coluna 3 etc' TO lt_text.

  go_textarea->set_table_text( it_text = lt_text ).
ENDFORM.
FORM save.
  DATA: lt_text TYPE STANDARD TABLE OF char255.

  IF gd_debug = 'X'.
    BREAK-POINT.
  ENDIF.

  go_textarea->get_table_text(
    IMPORTING
      et_text = lt_text
  ).
ENDFORM.
