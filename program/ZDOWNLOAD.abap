REPORT ZDOWNLOAD.

START-OF-SELECTION.
  BREAK-POINT.
  "PERFORM download_from_tab_txt.
  "PERFORM download_from_tab_bin.
  "PERFORM download_file_txt.
  PERFORM download_file_bin.

FORM download_from_tab_txt.
  DATA: lt_line   TYPE STANDARD TABLE OF char100.
  DATA: ld_target TYPE string.

  ld_target = 'C:\Users\diasv\OneDrive\Desktop\pasta1\arquivo.txt'.

  CLEAR lt_line.
  APPEND 'Linha 1' TO lt_line.
  APPEND 'Linha 2' TO lt_line.
  APPEND 'Linha 3' TO lt_line.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                        = ld_target
      filetype                        = 'ASC' " ASC = Texto, BIN = Binário
    TABLES
      data_tab                        = lt_line
    EXCEPTIONS
      file_write_error                = 1
      no_batch                        = 2
      gui_refuse_filetransfer         = 3
      invalid_type                    = 4
      no_authority                    = 5
      unknown_error                   = 6
      header_not_allowed              = 7
      separator_not_allowed           = 8
      filesize_not_allowed            = 9
      header_too_long                 = 10
      dp_error_create                 = 11
      dp_error_send                   = 12
      dp_error_write                  = 13
      unknown_dp_error                = 14
      access_denied                   = 15
      dp_out_of_memory                = 16
      disk_full                       = 17
      dp_timeout                      = 18
      file_not_found                  = 19
      dataprovider_exception          = 20
      control_flush_error             = 21
      others                          = 22.

  IF sy-subrc = 0.
    MESSAGE 'Arquivo salvo' TYPE 'S'.
  ELSE.
    MESSAGE |Erro ao salvar arquivo [{ sy-subrc }]| TYPE 'E'.
  ENDIF.
ENDFORM.
FORM download_from_tab_bin.
  DATA: ld_content TYPE xstring.
  DATA: lt_content TYPE solix_tab.

  DATA: ld_source TYPE string.
  DATA: ld_target TYPE string.

  ld_source = '/tmp/regex.pdf'.
  ld_target = 'C:\Users\diasv\OneDrive\Desktop\pasta1\arquivo2.pdf'.

  " lendo arquivo do servidor
  OPEN DATASET ld_source FOR INPUT IN BINARY MODE.
  READ DATASET ld_source INTO ld_content.
  CLOSE DATASET ld_source.

  " convertendo em tabela SOLIX
  lt_content = cl_bcs_convert=>xstring_to_solix( EXPORTING iv_xstring = ld_content ).

  " copiando o arquivo para o PC do usuário
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                        = ld_target
      filetype                        = 'BIN' " ASC = Texto, BIN = Binário
      bin_filesize                    = xstrlen( ld_content )
    TABLES
      data_tab                        = lt_content
    EXCEPTIONS
      file_write_error                = 1
      no_batch                        = 2
      gui_refuse_filetransfer         = 3
      invalid_type                    = 4
      no_authority                    = 5
      unknown_error                   = 6
      header_not_allowed              = 7
      separator_not_allowed           = 8
      filesize_not_allowed            = 9
      header_too_long                 = 10
      dp_error_create                 = 11
      dp_error_send                   = 12
      dp_error_write                  = 13
      unknown_dp_error                = 14
      access_denied                   = 15
      dp_out_of_memory                = 16
      disk_full                       = 17
      dp_timeout                      = 18
      file_not_found                  = 19
      dataprovider_exception          = 20
      control_flush_error             = 21
      others                          = 22.

  IF sy-subrc = 0.
    MESSAGE 'Arquivo salvo' TYPE 'S'.
  ELSE.
    MESSAGE |Erro ao salvar arquivo [{ sy-subrc }]| TYPE 'E'.
  ENDIF.
ENDFORM.
FORM download_file_txt.
  DATA: ld_source TYPE sapb-sappfad.
  DATA: ld_target TYPE sapb-sappfad.

  ld_source = '/tmp/arquivo.txt'.
  ld_target = 'C:\Users\diasv\OneDrive\Desktop\pasta1\arquivo2.txt'.

  CALL FUNCTION 'ARCHIVFILE_SERVER_TO_CLIENT'
    EXPORTING
      path             = ld_source
      targetpath       = ld_target
    EXCEPTIONS
      error_file       = 1
      no_authorization = 2
      others           = 3.

  IF sy-subrc = 0.
    MESSAGE 'Arquivo salvo' TYPE 'S'.
  ELSE.
    MESSAGE |Erro ao salvar arquivo [{ sy-subrc }]| TYPE 'E'.
  ENDIF.
ENDFORM.
FORM download_file_bin.
  DATA: ld_source TYPE sapb-sappfad.
  DATA: ld_target TYPE sapb-sappfad.

  ld_source = '/tmp/regex.pdf'.
  ld_target = 'C:\Users\diasv\OneDrive\Desktop\pasta1\arquivo.pdf'.

  CALL FUNCTION 'ARCHIVFILE_SERVER_TO_CLIENT'
    EXPORTING
      path             = ld_source
      targetpath       = ld_target
    EXCEPTIONS
      error_file       = 1
      no_authorization = 2
      others           = 3.

  IF sy-subrc = 0.
    MESSAGE 'Arquivo salvo' TYPE 'S'.
  ELSE.
    MESSAGE |Erro ao salvar arquivo [{ sy-subrc }]| TYPE 'E'.
  ENDIF.
ENDFORM.
