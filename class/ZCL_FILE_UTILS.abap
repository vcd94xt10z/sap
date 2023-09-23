* Versão 0.1
class ZCL_FILE_UTILS definition
  public
  create public .

public section.

  class-methods REQUEST_USER_FILE
    importing
      value(ID_DEFAULT_FILENAME) type STRING optional
      value(ID_DEFAULT_EXTENSION) type STRING optional
      value(ID_FILE_FILTER) type STRING optional
    returning
      value(RD_FILE) type STRING .
  class-methods LOAD_USER_TEXT_FILE
    importing
      !ID_FILE type STRING
    returning
      value(RD_CONTENT) type STRING .
  class-methods DOWNLOAD_USER_BIN_FILE
    importing
      !ID_FILE type ANY
      !ID_CONTENT type XSTRING
    returning
      value(RD_SUBRC) type INT4 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_FILE_UTILS IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_FILE_UTILS=>DOWNLOAD_USER_BIN_FILE
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_FILE                        TYPE        ANY
* | [--->] ID_CONTENT                     TYPE        XSTRING
* | [<-()] RD_SUBRC                       TYPE        INT4
* +--------------------------------------------------------------------------------------</SIGNATURE>
method DOWNLOAD_USER_BIN_FILE.
  DATA: lt_content TYPE solix_tab.

  " convertendo em tabela SOLIX
  lt_content = cl_bcs_convert=>xstring_to_solix( EXPORTING iv_xstring = id_content ).

  cl_gui_frontend_services=>gui_download(
    EXPORTING
      bin_filesize              = xstrlen( id_content )
      filename                  = id_file
      filetype                  = 'BIN'
    CHANGING
      data_tab                  = lt_content
    EXCEPTIONS
      file_write_error          = 1
      no_batch                  = 2
      gui_refuse_filetransfer   = 3
      invalid_type              = 4
      no_authority              = 5
      unknown_error             = 6
      header_not_allowed        = 7
      separator_not_allowed     = 8
      filesize_not_allowed      = 9
      header_too_long           = 10
      dp_error_create           = 11
      dp_error_send             = 12
      dp_error_write            = 13
      unknown_dp_error          = 14
      access_denied             = 15
      dp_out_of_memory          = 16
      disk_full                 = 17
      dp_timeout                = 18
      file_not_found            = 19
      dataprovider_exception    = 20
      control_flush_error       = 21
      not_supported_by_gui      = 22
      error_no_gui              = 23
      others                    = 24
  ).

  rd_subrc = sy-subrc.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_FILE_UTILS=>LOAD_USER_TEXT_FILE
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_FILE                        TYPE        STRING
* | [<-()] RD_CONTENT                     TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method LOAD_USER_TEXT_FILE.
  DATA: lt_content TYPE STANDARD TABLE OF string.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename = id_file
      filetype = 'ASC'
    TABLES
      data_tab = lt_content.

  IF lines( lt_content ) > 0.
    CONCATENATE LINES OF lt_content INTO rd_content SEPARATED BY cl_abap_char_utilities=>newline.
  ENDIF.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_FILE_UTILS=>REQUEST_USER_FILE
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_DEFAULT_FILENAME            TYPE        STRING(optional)
* | [--->] ID_DEFAULT_EXTENSION           TYPE        STRING(optional)
* | [--->] ID_FILE_FILTER                 TYPE        STRING(optional)
* | [<-()] RD_FILE                        TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method REQUEST_USER_FILE.
  DATA: ld_rc          TYPE int4,
        ld_user_action TYPE int4.

  DATA: lt_file TYPE TABLE OF file_table,
        ls_file TYPE file_table.

  CLEAR: lt_file.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = 'Escolha o arquivo...'
      default_filename        = id_default_filename
      default_extension       = id_default_extension "  '*.xml'
      file_filter             = id_file_filter       "  'XML (*.xml) '
      multiselection          = space
    CHANGING
      file_table              = lt_file
      rc                      = ld_rc
      user_action             = ld_user_action
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF sy-subrc EQ 0.
    READ TABLE lt_file INTO ls_file INDEX 1.
    IF sy-subrc = 0.
      MOVE ls_file TO rd_file.
    ENDIF.
  ENDIF.
endmethod.
ENDCLASS.
