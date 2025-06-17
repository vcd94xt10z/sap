class ZCL_DMS_UTILS definition
  public
  create public .

public section.

  types:
    BEGIN OF ly_dms_key
       , dokar  TYPE dokar
       , doknr  TYPE doknr
       , dokvr  TYPE dokvr
       , doktl  TYPE doktl_d
       , END OF ly_dms_key .
  types:
    BEGIN OF ly_detail
      , documentdata         TYPE bapi_doc_draw2
      , return               TYPE bapiret2
      , documentdescriptions TYPE tt_bapi_doc_drat
      , documentfiles        TYPE tt_bapi_doc_files2
      , characteristicvalues TYPE tt_bapi_characteristic_values
      , classallocations     TYPE tt_bapi_class_allocation
      , END OF ly_detail .

  class-methods LOAD_FILE
    importing
      value(IS_KEY) type LY_DMS_KEY
      value(ID_FILENAME) type STRING
      value(ED_CONTENT) type XSTRING .
  class-methods DELETE_FILE
    importing
      value(ID_FULLPATH) type STRING
      value(IS_KEY) type LY_DMS_KEY
    exporting
      value(ES_RETURN) type BAPIRET2 .
  class-methods CREATE_FILES
    exporting
      !ES_KEY type LY_DMS_KEY
      !ES_RETURN type BAPIRET2 .
  class-methods UPDATE_FILES
    importing
      value(IS_KEY) type LY_DMS_KEY
    exporting
      value(ES_RETURN) type BAPIRET2 .
  class-methods GET_DETAIL
    importing
      !IS_KEY type LY_DMS_KEY
    exporting
      !ES_DETAIL type LY_DETAIL .
protected section.
private section.
ENDCLASS.



CLASS ZCL_DMS_UTILS IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_DMS_UTILS=>CREATE_FILES
* +-------------------------------------------------------------------------------------------------+
* | [<---] ES_KEY                         TYPE        LY_DMS_KEY
* | [<---] ES_RETURN                      TYPE        BAPIRET2
* +--------------------------------------------------------------------------------------</SIGNATURE>
method CREATE_FILES.
  DATA: ld_is_gui       TYPE char1.
  DATA: ls_documentdata TYPE bapi_doc_draw2.
  DATA: ld_pf_ftp_dest  TYPE rfcdest.
  DATA: ld_pf_http_dest TYPE rfcdest.

  CLEAR es_return.

  CALL FUNCTION 'GUI_IS_AVAILABLE'
    IMPORTING
      return = ld_is_gui.

  IF ld_is_gui NE abap_true.
    ld_pf_ftp_dest  = 'SAPFTPA'.
    ld_pf_http_dest = 'SAPHTTPA'.
  ENDIF.

  CALL FUNCTION 'BAPI_DOCUMENT_CREATE2'
    EXPORTING
      documentdata               = ls_documentdata
      pf_ftp_dest                = ld_pf_ftp_dest
      pf_http_dest               = ld_pf_http_dest
      defaultclass               = CONV cvflag( ld_is_gui )
    IMPORTING
      documenttype               = es_key-dokar
      documentnumber             = es_key-doknr
      documentpart               = es_key-doktl
      documentversion            = es_key-dokvr
      return                     = es_return.

  IF es_return-type CA 'AEX'.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
    WAIT UP TO 2 SECONDS.
  ENDIF.

  " Tabela FILECMCUST REJECT_EMPTY_PATH = OFF para funcionar carregando o arquivo do servidor
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_DMS_UTILS=>DELETE_FILE
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_FULLPATH                    TYPE        STRING
* | [--->] IS_KEY                         TYPE        LY_DMS_KEY
* | [<---] ES_RETURN                      TYPE        BAPIRET2
* +--------------------------------------------------------------------------------------</SIGNATURE>
method DELETE_FILE.
  DATA: ls_detail       TYPE ly_detail.
  DATA: ls_document     TYPE bapi_doc_draw2.
  DATA: ls_documentx    TYPE bapi_doc_drawx2.
  DATA: lt_doc_files    TYPE STANDARD TABLE OF bapi_doc_files2.

  DATA: ld_folder       TYPE string.
  DATA: ld_filename     TYPE string.
  DATA: ld_filename2    TYPE string.
  DATA: ld_fileext      TYPE string.

  DATA: ld_is_gui       TYPE char1.
  DATA: ld_pf_ftp_dest  TYPE rfcdest.
  DATA: ld_pf_http_dest TYPE rfcdest.

  FIELD-SYMBOLS: <ls_documentfiles> TYPE bapi_doc_files2.

  CLEAR es_return.

  " separando diretório e nome do arquivo
  TRY.
    cl_bcs_utilities=>split_path(
      EXPORTING
        iv_path = CONV #( id_fullpath )
      IMPORTING
        ev_path = ld_folder
        ev_name = ld_filename
    ).
  CATCH cx_bcs.
    SPLIT id_fullpath AT '/' INTO TABLE DATA(lt_files).
    ld_filename = VALUE #( lt_files[ lines( lt_files ) ] OPTIONAL ).
  ENDTRY.

  " separando nome do arquivo da extensão
  cl_bcs_utilities=>split_name(
    EXPORTING
      iv_name      = ld_filename
    IMPORTING
      ev_name      = ld_filename2
      ev_extension = ld_fileext
  ).

  " obtendo detalhes
  get_detail(
    EXPORTING
      is_key    = is_key
    IMPORTING
      es_detail = ls_detail
  ).

  " Deixando somente o arquivo selecionado
  DELETE ls_detail-documentfiles WHERE docfile NE ld_filename.

  READ TABLE ls_detail-documentfiles ASSIGNING <ls_documentfiles> INDEX 1.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  " marcando o arquivo como deletado
  <ls_documentfiles>-deletevalue = abap_true.

  " setando flag de atualização na BAPI
  LOOP AT CAST cl_abap_structdescr(
      cl_abap_typedescr=>describe_by_data_ref( REF #( ls_document ) ) )->get_components( )
    INTO DATA(ls_compx).

    ASSIGN COMPONENT ls_compx-name OF STRUCTURE ls_document TO FIELD-SYMBOL(<fs_value>).
    ASSIGN COMPONENT ls_compx-name OF STRUCTURE ls_documentx TO FIELD-SYMBOL(<fs_valuex>).
    CHECK <fs_value> IS ASSIGNED AND <fs_valuex> IS ASSIGNED.
    CHECK <fs_value> IS NOT INITIAL.
    <fs_valuex> = abap_true.
  ENDLOOP.

  CALL FUNCTION 'GUI_IS_AVAILABLE'
    IMPORTING
      return = ld_is_gui.

  IF ld_is_gui NE abap_true.
    ld_pf_ftp_dest  = 'SAPFTPA'.
    ld_pf_http_dest = 'SAPHTTPA'.
  ENDIF.

  CALL FUNCTION 'BAPI_DOCUMENT_CHANGE2'
    EXPORTING
      documenttype    = is_key-dokar
      documentnumber  = is_key-doknr
      documentpart    = is_key-doktl
      documentversion = is_key-dokvr
      pf_ftp_dest     = ld_pf_ftp_dest
      pf_http_dest    = ld_pf_http_dest
      documentdata    = ls_document
      documentdatax   = ls_documentx
    IMPORTING
      return          = es_return.

  IF es_return-type CA 'AEX'.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    RETURN.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
  ENDIF.

  CALL FUNCTION 'BAPI_DOCUMENT_DELETE_DIRECT'
    EXPORTING
      documenttype    = is_key-dokar
      documentnumber  = is_key-doknr
      documentpart    = is_key-doktl
      documentversion = is_key-dokvr
    IMPORTING
      return          = es_return.

  IF es_return-type CA 'AEX'.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
  ENDIF.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_DMS_UTILS=>GET_DETAIL
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_KEY                         TYPE        LY_DMS_KEY
* | [<---] ES_DETAIL                      TYPE        LY_DETAIL
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_DETAIL.
  CLEAR es_detail.

  CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
    EXPORTING
      documenttype         = is_key-dokar
      documentnumber       = is_key-doknr
      documentpart         = is_key-doktl
      documentversion      = is_key-dokvr
      getcomponents        = abap_true
      getdocdescriptions   = abap_true
      getdocfiles          = abap_true
      getclassification    = abap_true
    IMPORTING
      documentdata         = es_detail-documentdata
      return               = es_detail-return
    TABLES
      documentdescriptions = es_detail-documentdescriptions
      documentfiles        = es_detail-documentfiles
      characteristicvalues = es_detail-characteristicvalues
      classallocations     = es_detail-classallocations.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_DMS_UTILS=>LOAD_FILE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_KEY                         TYPE        LY_DMS_KEY
* | [--->] ID_FILENAME                    TYPE        STRING
* | [--->] ED_CONTENT                     TYPE        XSTRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method LOAD_FILE.
  DATA: ls_docfile     TYPE bapi_doc_files2.
  DATA: lt_access      TYPE TABLE OF scms_acinf.
  DATA: ls_access      TYPE scms_acinf.
  DATA: lt_bin         TYPE TABLE OF sdokcntbin.

  DATA: ls_detail TYPE ly_detail.
  DATA: ls_documentfiles LIKE LINE OF ls_detail-documentfiles.

  get_detail(
    EXPORTING
      is_key    = is_key
    IMPORTING
      es_detail = ls_detail
  ).

  " dentre os arquivos, excluindo os outros arquivos
  " e deixando somente o arquivo que interessa
  DELETE ls_detail-documentfiles WHERE description NE id_filename.

  IF lines( ls_detail-documentfiles ) = 0.
    RETURN.
  ENDIF.

  CLEAR ls_documentfiles.
  READ TABLE ls_detail-documentfiles INTO ls_documentfiles INDEX 1.

  CALL FUNCTION 'SCMS_DOC_READ'
    EXPORTING
      mandt       = sy-mandt
      stor_cat    = ls_documentfiles-storagecategory
      doc_id      = ls_documentfiles-file_id
    TABLES
      access_info = lt_access
      content_bin = lt_bin.

  CLEAR ls_access.
  READ TABLE lt_access INTO ls_access INDEX 1.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      input_length = ls_access-comp_size
      first_line   = 0
      last_line    = 0
    IMPORTING
      buffer       = ed_content
    TABLES
      binary_tab   = lt_bin.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_DMS_UTILS=>UPDATE_FILES
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_KEY                         TYPE        LY_DMS_KEY
* | [<---] ES_RETURN                      TYPE        BAPIRET2
* +--------------------------------------------------------------------------------------</SIGNATURE>
method UPDATE_FILES.
  DATA: ld_is_gui        TYPE char1.
  DATA: ls_detail        TYPE ly_detail.
  DATA: ld_pf_ftp_dest   TYPE rfcdest.
  DATA: ld_pf_http_dest  TYPE rfcdest.
  DATA: ls_documentdata  TYPE bapi_doc_draw2.
  DATA: ls_documentdatax TYPE bapi_doc_drawx2.

  CLEAR es_return.

  CALL FUNCTION 'GUI_IS_AVAILABLE'
    IMPORTING
      return = ld_is_gui.

  IF ld_is_gui NE abap_true.
    ld_pf_ftp_dest  = 'SAPFTPA'.
    ld_pf_http_dest = 'SAPHTTPA'.
  ENDIF.

  get_detail(
    EXPORTING
      is_key    = is_key
    IMPORTING
      es_detail = ls_detail
  ).

  CALL FUNCTION 'BAPI_DOCUMENT_CHANGE2'
    EXPORTING
      documenttype        = is_key-dokar
      documentnumber      = is_key-doknr
      documentpart        = is_key-doktl
      documentversion     = is_key-dokvr
      documentdata        = ls_documentdata
      documentdatax       = ls_documentdatax
      pf_ftp_dest         = ld_pf_ftp_dest
      pf_http_dest        = ld_pf_http_dest
    IMPORTING
      return               = es_return.

  IF es_return-type CA 'AEX'.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
    WAIT UP TO 2 SECONDS.
  ENDIF.

  " Function CVAPI_DOC_CHECKIN
endmethod.
ENDCLASS.