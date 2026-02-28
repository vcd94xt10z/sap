* Versão 0.2
REPORT ZALV_BASICO.

* Programas exemplos do BCALV_GRID_01 até BCALV_GRID_11

START-OF-SELECTION.
  PERFORM exemplo1.
  "PERFORM exemplo2.

FORM exemplo1.
  DATA: lo_table           TYPE REF TO cl_salv_table.
  DATA: lo_sorts           TYPE REF TO cl_salv_sorts.
  DATA: lo_column          TYPE REF TO cl_salv_column.
  DATA: lo_columns         TYPE REF TO cl_salv_columns_table.
  DATA: lo_display         TYPE REF TO cl_salv_display_settings.
  DATA: lo_functions       TYPE REF TO cl_salv_functions_list.
  DATA: ls_layout_key      TYPE salv_s_layout_key.
  DATA: lt_column_hide     TYPE STANDARD TABLE OF lvc_fname.
  DATA: lt_column_agreg    TYPE STANDARD TABLE OF lvc_fname.
  DATA: lt_column_sortup   TYPE STANDARD TABLE OF lvc_fname.
  DATA: ld_column_name     TYPE lvc_fname.
  DATA: lo_aggregations    TYPE REF TO cl_salv_aggregations.
  DATA: lo_layout_settings TYPE REF TO cl_salv_layout.

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

  " otimizando largura das colunas
  lo_columns = lo_table->get_columns( ).
  lo_columns->set_optimize( ).

  " exibindo barra de ferramentas (barra de botões acima do ALV)
  lo_functions = lo_table->get_functions( ).
  lo_functions->set_all( ).

  " efeito zebra (alternar cor de fundo das linhas)
  lo_display = lo_table->get_display_settings( ).
  lo_display->set_striped_pattern( cl_salv_display_settings=>true ).

  " habilitar opções de layout (salvar, carregar etc)
  lo_layout_settings = lo_table->get_layout( ).
  ls_layout_key-report = sy-repid.
  lo_layout_settings->set_key( ls_layout_key ).
  lo_layout_settings->set_save_restriction( if_salv_c_layout=>restrict_none ).
  lo_layout_settings->set_initial_layout( value = 'DEFAULT' ). " nome do layout ALV

  " alterando propriedades de uma coluna (nome, alinhamento etc.)
  lo_column = lo_columns->get_column( 'NAME' ).
  lo_column->set_long_text( 'NAME' ).
  lo_column->set_alignment( IF_SALV_C_ALIGNMENT=>CENTERED ).
  "lo_column->set_visible( if_salv_c_bool_sap=>false ).

  CLEAR lt_column_hide.
  APPEND 'TEST01' TO lt_column_hide.
  APPEND 'SUM01'  TO lt_column_hide.
  
  LOOP AT lt_column_hide INTO ld_column_name.
    lo_column = lo_columns->get_column( ld_column_name ).
    lo_column->set_visible( if_salv_c_bool_sap=>false ).
  ENDLOOP.

  CLEAR lt_column_agreg.
  APPEND 'TOT01' TO lt_column_agreg.
  APPEND 'TOT02' TO lt_column_agreg.

  lo_aggregations = lo_table->get_aggregations( ).
  LOOP AT lt_column_agreg INTO ld_column_name.
    TRY.
      CALL METHOD lo_aggregations->add_aggregation
        EXPORTING
          columnname  = ld_column_name
          aggregation = if_salv_c_aggregation=>total.
      CATCH cx_salv_not_found.
      CATCH cx_salv_data_error.
      CATCH cx_salv_existing.
    ENDTRY.
  ENDLOOP.

  CLEAR lt_column_sortup.
  APPEND 'MATNR' TO lt_column_sortup.
  APPEND 'MAKTX' TO lt_column_sortup.
  
  lo_sorts = lo_table->get_sorts( ).
  LOOP AT lt_column_sortup INTO ld_column_name.
    TRY.
      CALL METHOD lo_sorts->add_sort
        EXPORTING
          columnname = ld_column_name
          sequence   = if_salv_c_sort=>sort_up.
    CATCH cx_salv_not_found.
    CATCH cx_salv_existing.
    CATCH cx_salv_data_error.
    ENDTRY.
  ENDLOOP.

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
