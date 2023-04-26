REPORT ZALV_BASICO.

* Programas exemplos do BCALV_GRID_01 até BCALV_GRID_11

START-OF-SELECTION.
  "PERFORM exemplo1.
  PERFORM exemplo2.

FORM exemplo1.
  DATA: lo_table   TYPE REF TO cl_salv_table.
  DATA: lo_columns TYPE REF TO cl_salv_columns_table.

  DATA: lt_result TYPE STANDARD TABLE OF stravelag.

  SELECT *
    INTO TABLE lt_result
    FROM stravelag.

  cl_salv_table=>factory(
  IMPORTING
    r_salv_table = lo_table
  CHANGING
    t_table = lt_result
  ).

  lo_columns = lo_table->get_columns( ).
  lo_columns->set_optimize( ).

  lo_table->display( ).
ENDFORM.
FORM exemplo2.
  DATA: ls_fieldcat TYPE slis_fieldcat_alv.
  DATA: lt_fieldcat TYPE STANDARD TABLE OF slis_fieldcat_alv.

  DATA: lt_message TYPE bapiret2_t.
  DATA: ls_message TYPE bapiret2.

  CLEAR lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TYPE'.
  ls_fieldcat-seltext_m = 'Tipo'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MESSAGE'.
  ls_fieldcat-seltext_m = 'Mensagem'.
  ls_fieldcat-outputlen = 60.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_message.
  ls_message-type    = 'E'.
  ls_message-message = 'Teste 1'.
  APPEND ls_message TO lt_message.

  CLEAR ls_message.
  ls_message-type    = 'S'.
  ls_message-message = 'Teste 2'.
  APPEND ls_message TO lt_message.

  CLEAR ls_message.
  ls_message-type    = 'W'.
  ls_message-message = 'Teste 3'.
  APPEND ls_message TO lt_message.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = sy-repid
      i_grid_title            = 'Mensagens'
      it_fieldcat             = lt_fieldcat
      i_save                  = 'X'
*     i_callback_top_of_page  = 'TOP-OF-PAGE'  "see FORM
*     i_callback_user_command = 'USER_COMMAND'
*     is_layout               = gd_layout
*     it_special_groups       = gd_tabgroup
*     it_events               = gt_xevents
*     is_variant              = z_template
    TABLES
      t_outtab                = lt_message
    EXCEPTIONS
      program_error           = 1
      others                  = 2.
ENDFORM.
