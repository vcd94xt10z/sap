class ZCL_CSV_UTILS definition
  public
  final
  create public .

public section.

  class-methods CLASS_CONSTRUCTOR .
  class-methods ITAB_TO_CSV
    importing
      !ITAB type ANY TABLE
      !CSV_FILE type STRING
      value(DELIMITER) type CHAR1 optional
      value(SEPARATOR) type CHAR1 optional
      value(SERVER) type FLAG optional
      value(HEADER) type FLAG default 'X' .
  class-methods CSV_TO_ITAB
    importing
      !CSV_FILE type STRING
      value(DELIMITER) type CHAR1 optional
      value(SEPARATOR) type CHAR1 optional
      value(SERVER) type FLAG optional
      value(HEADER) type FLAG default 'X'
    exporting
      !ITAB type STANDARD TABLE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_CSV_UTILS IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_CSV_UTILS=>CLASS_CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
method CLASS_CONSTRUCTOR.
*
* Autor Vinicius Cesar Dias
* https://github.com/vcd94xt10z
* Ultima atualização 04/08/2023 v0.2
*
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_CSV_UTILS=>CSV_TO_ITAB
* +-------------------------------------------------------------------------------------------------+
* | [--->] CSV_FILE                       TYPE        STRING
* | [--->] DELIMITER                      TYPE        CHAR1(optional)
* | [--->] SEPARATOR                      TYPE        CHAR1(optional)
* | [--->] SERVER                         TYPE        FLAG(optional)
* | [--->] HEADER                         TYPE        FLAG (default ='X')
* | [<---] ITAB                           TYPE        STANDARD TABLE
* +--------------------------------------------------------------------------------------</SIGNATURE>
method CSV_TO_ITAB.
  TYPES ly_line(4096)    TYPE c.
  TYPES ly_line_tab      TYPE STANDARD TABLE OF ly_line.

  DATA: lo_csv_converter TYPE REF TO cl_rsda_csv_converter.
  DATA: lt_raw_data      TYPE ly_line_tab.
  DATA: ld_row           TYPE string.

  FIELD-SYMBOLS: <ls_itab> TYPE any.

  IF delimiter = ''.
    delimiter = cl_rsda_csv_converter=>c_default_delimiter.
  ENDIF.

  IF separator = ''.
    separator = cl_rsda_csv_converter=>c_default_separator.
  ENDIF.

  CALL METHOD cl_rsda_csv_converter=>create
    EXPORTING
      i_delimiter = delimiter
      i_separator = separator
    RECEIVING
      r_r_conv    = lo_csv_converter.

  IF server = 'X'.
    " lendo arquivo no servidor
    OPEN DATASET csv_file FOR INPUT IN BINARY MODE.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    DO.
      READ DATASET csv_file INTO ld_row.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
      APPEND ld_row TO lt_raw_data.
    ENDDO.
    CLOSE DATASET csv_file.
  ELSE.
    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename = csv_file
        filetype = 'ASC'
      TABLES
        data_tab = lt_raw_data.
  ENDIF.

  LOOP AT lt_raw_data INTO DATA(ls_csv_line).
    " tem cabeçalho? Se sim, ignora
    IF header = 'X' AND sy-tabix = 1.
      CONTINUE.
    ENDIF.

    APPEND INITIAL LINE TO itab ASSIGNING <ls_itab>.

    CALL METHOD lo_csv_converter->csv_to_structure
      EXPORTING
        i_data   = ls_csv_line
      IMPORTING
        e_s_data = <ls_itab>.
  ENDLOOP.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_CSV_UTILS=>ITAB_TO_CSV
* +-------------------------------------------------------------------------------------------------+
* | [--->] ITAB                           TYPE        ANY TABLE
* | [--->] CSV_FILE                       TYPE        STRING
* | [--->] DELIMITER                      TYPE        CHAR1(optional)
* | [--->] SEPARATOR                      TYPE        CHAR1(optional)
* | [--->] SERVER                         TYPE        FLAG(optional)
* | [--->] HEADER                         TYPE        FLAG (default ='X')
* +--------------------------------------------------------------------------------------</SIGNATURE>
method ITAB_TO_CSV.
  DATA: lt_csv       TYPE TABLE OF string.
  DATA: ld_row       TYPE string.
  DATA: lt_comp      TYPE abap_compdescr_tab.
  DATA: ld_value     TYPE string.
  DATA: lo_type      TYPE REF TO cl_abap_typedescr.
  data: lo_table     TYPE REF TO cl_abap_tabledescr.
  DATA: lo_struc     TYPE REF TO cl_abap_structdescr.
  DATA: ld_kind      TYPE string.
  DATA: ld_type_kind TYPE string.

  IF delimiter = ''.
    delimiter = cl_rsda_csv_converter=>c_default_delimiter.
  ENDIF.

  IF separator = ''.
    separator = cl_rsda_csv_converter=>c_default_separator.
  ENDIF.

  lo_table ?= cl_abap_tabledescr=>describe_by_data( itab ).
  lo_struc ?= lo_table->get_table_line_type( ).
  lt_comp   = lo_struc->components[].

  " cabeçalho
  IF header = 'X'.
    CLEAR ld_row.
    LOOP AT lt_comp INTO DATA(ls_comp).
      ld_value = |{ delimiter }{ ls_comp-name }{ delimiter }|.

      IF sy-tabix EQ 1.
        ld_row = ld_value.
      ELSE.
        CONDENSE ld_value.
        CONCATENATE ld_row ld_value INTO ld_row SEPARATED BY separator.
      ENDIF.
    ENDLOOP.
    APPEND ld_row TO lt_csv.
  ENDIF.

  " valores
  LOOP AT itab ASSIGNING FIELD-SYMBOL(<ls_itab>).
    DO.
      ASSIGN COMPONENT sy-index OF STRUCTURE <ls_itab> TO FIELD-SYMBOL(<ld_value>).
      IF sy-subrc NE 0.
        EXIT.
      ENDIF.

      lo_type      = cl_abap_typedescr=>describe_by_data( <ld_value> ).
      ld_kind      = lo_type->kind.
      ld_value     = <ld_value>.
      ld_type_kind = lo_type->type_kind.

      IF ld_type_kind = cl_abap_typedescr=>typekind_char   OR
         ld_type_kind = cl_abap_typedescr=>typekind_string OR
         ld_type_kind = cl_abap_typedescr=>typekind_clike  OR
         ld_type_kind = cl_abap_typedescr=>typekind_date   OR
         ld_type_kind = cl_abap_typedescr=>typekind_time
         .
        ld_value = |{ delimiter }{ <ld_value> }{ delimiter }|.
      ENDIF.

      IF sy-index EQ 1.
        ld_row = ld_value.
      ELSE.
        CONDENSE ld_value.
        CONCATENATE ld_row ld_value INTO ld_row SEPARATED BY separator.
      ENDIF.
    ENDDO.

    APPEND ld_row TO lt_csv.
  ENDLOOP.

  IF server = 'X'.
    " salvar no servidor
    OPEN DATASET csv_file FOR OUTPUT IN BINARY MODE.
    IF sy-subrc = 0.
      LOOP AT lt_csv INTO ld_row.
        CONCATENATE ld_row cl_abap_char_utilities=>newline
               INTO ld_row.
        TRANSFER ld_row TO csv_file.
      ENDLOOP.
      CLOSE DATASET csv_file.
    ENDIF.
  ELSE.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename                = csv_file
      TABLES
        data_tab                = lt_csv
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        OTHERS                  = 22.
  ENDIF.
endmethod.
ENDCLASS.
