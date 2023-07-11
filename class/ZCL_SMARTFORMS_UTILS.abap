class ZCL_SMARTFORMS_UTILS definition
  public
  final
  create public .

public section.

  class-methods CLASS_CONSTRUCTOR .
  class-methods PRINT
    importing
      value(ID_LABEL) type TDSFNAME
      value(IS_DATA) type ANY optional .
  class-methods PREVIEW
    importing
      value(ID_LABEL) type TDSFNAME
      value(IS_DATA) type ANY optional .
  class-methods EXPORT_TO_SERVER
    importing
      value(ID_LABEL) type TDSFNAME
      value(IS_DATA) type ANY optional
      value(ID_FILENAME) type STRING .
  class-methods EXPORT_TO_CLIENT
    importing
      value(ID_LABEL) type TDSFNAME
      value(IS_DATA) type ANY optional
      value(ID_FILENAME) type STRING .
protected section.
private section.

  class-methods EXPORT_TO_PDF
    importing
      value(ID_FILENAME) type STRING
      value(IS_JOB_OUTPUT_INFO) type SSFCRESCL
      value(ID_OUTPUT) type STRING
    exporting
      value(ET_LINES) type TLINET
      value(ED_XSTRING) type XSTRING
      value(ED_LENGTH) type I .
  class-methods PRINT_OR_PREVIEW
    importing
      value(ID_LABEL) type TDSFNAME
      value(IS_DATA) type ANY optional
      value(ID_MODE) type CHAR10 optional
      value(ID_NO_DIALOG) type CHAR1 optional
      value(ID_TDNEWID) type CHAR1 default 'X'
      value(ID_TDIMMED) type CHAR1 default 'X'
      value(ID_TDDEST) type RSPOPNAME optional
      value(ID_PREVIEW) type CHAR1 optional
    exporting
      value(ES_JOB_OUTPUT_INFO) type SSFCRESCL .
ENDCLASS.



CLASS ZCL_SMARTFORMS_UTILS IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_SMARTFORMS_UTILS=>CLASS_CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
method CLASS_CONSTRUCTOR.
*
* Autor Vinicius Cesar Dias
* https://github.com/vcd94xt10z
* Ultima atualização: 11/07/2023
*
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_SMARTFORMS_UTILS=>EXPORT_TO_CLIENT
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_LABEL                       TYPE        TDSFNAME
* | [--->] IS_DATA                        TYPE        ANY(optional)
* | [--->] ID_FILENAME                    TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method EXPORT_TO_CLIENT.
*
* Autor Vinicius Cesar Dias
* https://github.com/vcd94xt10z
*
  DATA: ls_job_output_info TYPE ssfcrescl.

  CALL METHOD print_or_preview
    EXPORTING
      id_label = id_label
      is_data  = is_data
      id_mode  = 'GETOTF'
    IMPORTING
      es_job_output_info = ls_job_output_info.

  CALL METHOD export_to_pdf
    EXPORTING
      id_filename        = id_filename
      is_job_output_info = ls_job_output_info
      id_output          = 'GUI'.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_SMARTFORMS_UTILS=>EXPORT_TO_PDF
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_FILENAME                    TYPE        STRING
* | [--->] IS_JOB_OUTPUT_INFO             TYPE        SSFCRESCL
* | [--->] ID_OUTPUT                      TYPE        STRING
* | [<---] ET_LINES                       TYPE        TLINET
* | [<---] ED_XSTRING                     TYPE        XSTRING
* | [<---] ED_LENGTH                      TYPE        I
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD export_to_pdf.
*
* Autor Vinicius Cesar Dias
* https://github.com/vcd94xt10z
*
  DATA: lt_docs      TYPE STANDARD TABLE OF docs.
  DATA: ls_lines     LIKE LINE OF et_lines.
  DATA: ld_string    TYPE string.
  DATA: ld_xstring   TYPE xstring.
  DATA: lt_otfdata   TYPE TABLE OF itcoo.
  DATA: ld_pdf_data  TYPE xstring.
  DATA: ld_pdf_size  TYPE i.
  DATA: lt_lines_otf LIKE et_lines.

  CLEAR: ld_pdf_data.
  CLEAR: ld_pdf_size.

  lt_otfdata[] = is_job_output_info-otfdata[].

  " convertendo o conteúdo do smartforms para conteúdo de PDF
  CALL FUNCTION 'CONVERT_OTF_2_PDF'
    IMPORTING
      bin_filesize           = ld_pdf_size
    TABLES
      otf                    = lt_otfdata
      doctab_archive         = lt_docs
      lines                  = et_lines
    EXCEPTIONS
      err_conv_not_possible  = 1
      err_otf_mc_noendmarker = 2
      OTHERS                 = 3.

  IF ed_xstring IS SUPPLIED.
    CALL FUNCTION 'CONVERT_OTF'
      EXPORTING
        format                = 'PDF'
      IMPORTING
        bin_filesize          = ed_length
        bin_file              = ed_xstring
      TABLES
        otf                   = lt_otfdata
        lines                 = lt_lines_otf
      EXCEPTIONS
        err_max_linewidth     = 1
        err_format            = 2
        err_conv_not_possible = 3
        err_bad_otf           = 4
        OTHERS                = 5.
  ENDIF.

  IF id_output = 'SERVER_DISK'.
    OPEN DATASET id_filename FOR OUTPUT IN BINARY MODE.
    IF sy-subrc = 0.
      LOOP AT et_lines INTO ls_lines.
        TRANSFER ls_lines TO id_filename.
      ENDLOOP.
      CLOSE DATASET id_filename.
    ENDIF.

    RETURN.
  ENDIF.

  " salvando conteúdo do arquivo no disco do usuário
  IF id_output = 'GUI'.
    CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      bin_filesize = ld_pdf_size
      filename     = id_filename
      filetype     = 'BIN'
    TABLES
      data_tab     = et_lines
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
ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_SMARTFORMS_UTILS=>EXPORT_TO_SERVER
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_LABEL                       TYPE        TDSFNAME
* | [--->] IS_DATA                        TYPE        ANY(optional)
* | [--->] ID_FILENAME                    TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method EXPORT_TO_SERVER.
*
* Autor Vinicius Cesar Dias
* https://github.com/vcd94xt10z
*
  DATA: ls_job_output_info TYPE ssfcrescl.

  CALL METHOD print_or_preview
    EXPORTING
      id_label = id_label
      is_data  = is_data
      id_mode  = 'GETOTF'
    IMPORTING
      es_job_output_info = ls_job_output_info.

  CALL METHOD export_to_pdf
    EXPORTING
      id_filename        = id_filename
      is_job_output_info = ls_job_output_info
      id_output          = 'SERVER_DISK'.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_SMARTFORMS_UTILS=>PREVIEW
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_LABEL                       TYPE        TDSFNAME
* | [--->] IS_DATA                        TYPE        ANY(optional)
* +--------------------------------------------------------------------------------------</SIGNATURE>
method PREVIEW.
*
* Autor Vinicius Cesar Dias
* https://github.com/vcd94xt10z
*
  CALL METHOD print_or_preview
    EXPORTING
      id_label = id_label
      is_data  = is_data
      id_mode  = 'PREVIEW'.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_SMARTFORMS_UTILS=>PRINT
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_LABEL                       TYPE        TDSFNAME
* | [--->] IS_DATA                        TYPE        ANY(optional)
* +--------------------------------------------------------------------------------------</SIGNATURE>
method PRINT.
*
* Autor Vinicius Cesar Dias
* https://github.com/vcd94xt10z
*
  CALL METHOD print_or_preview
    EXPORTING
      id_label = id_label
      is_data  = is_data
      id_mode  = 'PRINT'.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_SMARTFORMS_UTILS=>PRINT_OR_PREVIEW
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_LABEL                       TYPE        TDSFNAME
* | [--->] IS_DATA                        TYPE        ANY(optional)
* | [--->] ID_MODE                        TYPE        CHAR10(optional)
* | [--->] ID_NO_DIALOG                   TYPE        CHAR1(optional)
* | [--->] ID_TDNEWID                     TYPE        CHAR1 (default ='X')
* | [--->] ID_TDIMMED                     TYPE        CHAR1 (default ='X')
* | [--->] ID_TDDEST                      TYPE        RSPOPNAME(optional)
* | [--->] ID_PREVIEW                     TYPE        CHAR1(optional)
* | [<---] ES_JOB_OUTPUT_INFO             TYPE        SSFCRESCL
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD PRINT_OR_PREVIEW.
*
* Autor Vinicius Cesar Dias
* https://github.com/vcd94xt10z
*
  DATA: ld_fm_name              TYPE rs38l_fnam.
  DATA: st_output_options       TYPE ssfcompop.
  DATA: st_control_parameters   TYPE ssfctrlop.
  DATA: ls_job_output_options   TYPE ssfcresop.
  DATA: ld_document_output_info TYPE ssfcrespd.

  FIELD-SYMBOLS: <ls_sfspoolid> TYPE rspoid.

  CLEAR: es_job_output_info
       , st_output_options
       , ls_job_output_options
       , st_control_parameters
       , ld_document_output_info.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = id_label
    IMPORTING
      fm_name            = ld_fm_name
    EXCEPTIONS
      no_form            = 2
      no_function_module = 3
      OTHERS             = 4.

  IF id_tddest IS INITIAL.
    id_tddest  = 'LP01'.
  ENDIF.

  " controles
  st_control_parameters-no_dialog = id_no_dialog. " não exibe o dialogo
  st_control_parameters-preview   = id_preview.   " pré visualização nunca
  st_control_parameters-device    = 'PRINTER'.    "
  st_control_parameters-getotf    = ' '.          " não retorna o código otf

  " opções
  st_output_options-tdnoprev  = ' '.        " sem preview sempre pois senão vai aparecer o código zpl
  st_output_options-tdnoprint = ' '.        " imprimir sempre
  st_output_options-tdnewid   = id_tdnewid. " cria nova ordem de spool
  st_output_options-tdimmed   = id_tdimmed. " saída imediata
  st_output_options-tdcopies  = 1.
  st_output_options-tddelete  = ' '.
  st_output_options-tdfinal   = ' '.
  st_output_options-tddest    = id_tddest.

  IF id_mode = 'PRINT'.
    " controles
    st_control_parameters-no_dialog = 'X'.       " não exibe o dialogo
    st_control_parameters-preview   = ' '.       " sem pré visualização
    st_control_parameters-device    = 'PRINTER'. " dispositivo
    st_control_parameters-getotf    = ' '.       " não retorna o código otf

    " opções
    st_output_options-tdnoprev  = 'X'. " sem preview
    st_output_options-tdnoprint = ' '. " imprime
  ENDIF.

  IF id_mode = 'PREVIEW'.
    " controles
    st_control_parameters-no_dialog = 'X'.       " não exibe o dialogo
    st_control_parameters-preview   = 'X'.       " com pré visualização
    st_control_parameters-device    = 'PRINTER'. " dispositivo
    st_control_parameters-getotf    = ' '.       " não retorna o código otf

    " opções
    st_output_options-tdnoprev  = 'X'. " sem preview
    st_output_options-tdnoprint = 'X'. " imprime
  ENDIF.

  IF id_mode = 'GETOTF'.
    " controles
    st_control_parameters-no_dialog = 'X'.       " não exibe o dialogo
    st_control_parameters-preview   = ' '.       " sem pré visualização
    st_control_parameters-device    = 'PRINTER'. " dispositivo
    st_control_parameters-getotf    = 'X'.       " não retorna o código otf

    " opções
    st_output_options-tdnoprev  = 'X'. " sem preview
    st_output_options-tdnoprint = 'X'. " imprime
  ENDIF.

  " executando smartform
  IF is_data IS NOT INITIAL.
    CALL FUNCTION ld_fm_name
      EXPORTING
        is_data              = is_data
        control_parameters   = st_control_parameters
        output_options       = st_output_options
        user_settings        = ' '
      IMPORTING
        document_output_info = ld_document_output_info
        job_output_info      = es_job_output_info
        job_output_options   = ls_job_output_options.
  ELSE.
    CALL FUNCTION ld_fm_name
      EXPORTING
        "is_data             = is_data
        control_parameters   = st_control_parameters
        output_options       = st_output_options
        user_settings        = ' '
      IMPORTING
        document_output_info = ld_document_output_info
        job_output_info      = es_job_output_info
        job_output_options   = ls_job_output_options.
  ENDIF.
ENDMETHOD.
ENDCLASS.