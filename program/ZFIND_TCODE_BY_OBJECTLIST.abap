*
* Procura uma transação a partir de uma lista de objetos
*
REPORT ZFIND_TCODE_BY_OBJECTLIST.

TYPES: BEGIN OF ly_data
     , type    TYPE trobjtype
     , name    TYPE sobj_name
     , program TYPE program_id
     , tcode   TYPE tcode
     , END OF ly_data.

DATA: gt_data TYPE STANDARD TABLE OF ly_data.
DATA: gs_data TYPE ly_data.

SELECTION-SCREEN BEGIN OF BLOCK main WITH FRAME.
  PARAMETER: p_file TYPE aq_filename.
SELECTION-SCREEN END OF BLOCK main.

START-OF-SELECTION.
  PERFORM read_file.
  PERFORM process.
  PERFORM show.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  DATA: ld_rc          TYPE syst_subrc.
  DATA: lt_file_table  TYPE filetable.
  DATA: ls_file_table  TYPE file_table.
  DATA: ld_file_filter TYPE string VALUE 'Arquivos TXT (*.txt*)|*.txt*'.

  CLEAR lt_file_table.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = 'Selecione o arquivo'
      file_filter             = ld_file_filter
      initial_directory       = '%UserProfile%\Desktop'
      multiselection          = ' '
    CHANGING
      file_table              = lt_file_table
      rc                      = ld_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF sy-subrc = 0.
    READ TABLE lt_file_table INTO ls_file_table INDEX 1.
    IF sy-subrc = 0.
      p_file = ls_file_table-filename.
    ENDIF.
  ENDIF.

FORM show.
  DATA: lo_table   TYPE REF TO cl_salv_table.
  DATA: lo_columns TYPE REF TO cl_salv_columns_table.

  cl_salv_table=>factory(
  IMPORTING
    r_salv_table = lo_table
  CHANGING
    t_table = gt_data
  ).

  lo_columns = lo_table->get_columns( ).
  lo_columns->set_optimize( ).

  lo_table->display( ).
ENDFORM.
FORM process.
  DATA: lt_data   LIKE gt_data.
  DATA: lt_tstc   TYPE STANDARD TABLE OF tstc.
  DATA: ls_tstc   TYPE tstc.
  DATA: lt_object TYPE zcl_where_used_list=>my_object_t.
  DATA: ls_object TYPE zcl_where_used_list=>my_object.

  CLEAR lt_data.

  LOOP AT gt_data INTO gs_data.
    CLEAR lt_object.

    zcl_where_used_list=>find_main_proglist(
      EXPORTING
        id_type   = gs_data-type
        id_name   = gs_data-name
      CHANGING
        ct_object = lt_object
    ).

    " verificando quais desses programas tem transação apontando
    CLEAR lt_tstc.

    IF LINES( lt_object ) > 0.
      SELECT *
        FROM tstc
        INTO TABLE lt_tstc
         FOR ALL ENTRIES IN lt_object
       WHERE pgmna = lt_object-name.

      LOOP AT lt_tstc INTO ls_tstc.
        gs_data-program = ls_tstc-pgmna.
        gs_data-tcode   = ls_tstc-tcode.
        APPEND gs_data TO lt_data.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  CLEAR gt_data.
  gt_data = lt_data.
  CLEAR lt_data.
ENDFORM.
FORM read_file.
  DATA: lt_line TYPE STANDARD TABLE OF string.
  DATA: ld_line TYPE string.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                      = CONV string( p_file )
      filetype                      = 'ASC'
    TABLES
      data_tab                      = lt_line
    EXCEPTIONS
      FILE_OPEN_ERROR               = 1
      FILE_READ_ERROR               = 2
      NO_BATCH                      = 3
      GUI_REFUSE_FILETRANSFER       = 4
      INVALID_TYPE                  = 5
      NO_AUTHORITY                  = 6
      UNKNOWN_ERROR                 = 7
      BAD_DATA_FORMAT               = 8
      HEADER_NOT_ALLOWED            = 9
      SEPARATOR_NOT_ALLOWED         = 10
      HEADER_TOO_LONG               = 11
      UNKNOWN_DP_ERROR              = 12
      ACCESS_DENIED                 = 13
      DP_OUT_OF_MEMORY              = 14
      DISK_FULL                     = 15
      DP_TIMEOUT                    = 16
      OTHERS                        = 17.

  LOOP AT lt_line INTO ld_line.
    SPLIT ld_line AT cl_abap_char_utilities=>horizontal_tab
     INTO gs_data-type gs_data-name.
    APPEND gs_data TO gt_data.
  ENDLOOP.
ENDFORM.
