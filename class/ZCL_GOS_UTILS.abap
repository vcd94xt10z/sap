class ZCL_GOS_UTILS definition
  public
  create public .

public section.

  class-methods LOAD_FILE_FROM_SERVER_DISK
    importing
      value(ID_FULLPATH) type ANY
    exporting
      value(ED_CONTENT) type XSTRING
      value(ET_BAPICONTEN) type BAPIDOCCONTENTAB
      value(ED_FILESIZE) type INT4 .
  class-methods CREATE_FILE_GOS
    importing
      value(ID_FILENAME) type ANY optional
      value(ID_FULLPATH) type ANY
      value(ID_OBJECT_KEY) type ANY
      value(ID_FROM_SERVER) type FLAG default 'X'
      value(ID_CLASSNAME) type SBDST_CLASSNAME
      value(ID_CLASSTYPE) type SBDST_CLASSTYPE
    exporting
      !ES_BAPIRET2 type BAPIRET2 .
  class-methods LOAD_FILE_GOS
    importing
      value(ID_DOCUMENT) type ANY
      value(ID_CLASSNAME) type ANY .
protected section.
private section.
ENDCLASS.



CLASS ZCL_GOS_UTILS IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_GOS_UTILS2=>CREATE_FILE_GOS
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_FILENAME                    TYPE        ANY(optional)
* | [--->] ID_FULLPATH                    TYPE        ANY
* | [--->] ID_OBJECT_KEY                  TYPE        ANY
* | [--->] ID_FROM_SERVER                 TYPE        FLAG (default ='X')
* | [--->] ID_CLASSNAME                   TYPE        SBDST_CLASSNAME
* | [--->] ID_CLASSTYPE                   TYPE        SBDST_CLASSTYPE
* | [<---] ES_BAPIRET2                    TYPE        BAPIRET2
* +--------------------------------------------------------------------------------------</SIGNATURE>
method CREATE_FILE_GOS.
  DATA: lt_components     TYPE sbdst_components.
  DATA: ls_components     TYPE bapicompon.
  DATA: lt_content        TYPE sbdst_content.
  DATA: ls_content        TYPE bapiconten.
  DATA: lt_signature      TYPE sbdst_signature.
  DATA: ls_signature      TYPE bapisignat.

  DATA: ld_mime           TYPE w3conttype.
  DATA: ld_folder(4096)   TYPE c.
  DATA: ld_filename(1024) TYPE c.
  DATA: ld_filename2      TYPE string.
  DATA: ld_fileext        TYPE string.
  DATA: ld_filesize       TYPE int4.

  DATA: ld_object_key     TYPE sbdst_object_key.

  CLEAR es_bapiret2.

  " validações
  IF id_fullpath = ''.
    es_bapiret2-type    = 'E'.
    es_bapiret2-message = 'Caminho do arquivo vazio'.
    RETURN.
  ENDIF.

  IF id_object_key = ''.
    es_bapiret2-type    = 'E'.
    es_bapiret2-message = 'Chave do objeto vazio'.
    RETURN.
  ENDIF.

  " padronizando separador
  REPLACE ALL OCCURRENCES OF '\' IN id_fullpath WITH '/'.

  CALL FUNCTION 'TRINT_SPLIT_FILE_AND_PATH'
    EXPORTING
      full_name     = id_fullpath
    IMPORTING
      stripped_name = ld_filename
      file_path     = ld_folder
    EXCEPTIONS
      x_error       = 1
      others        = 2.

  " extrair nome e extensão
  cl_bcs_utilities=>split_name(
    EXPORTING
      iv_name      = ld_filename
    IMPORTING
      ev_name      = ld_filename2
      ev_extension = ld_fileext
  ).

  TRANSLATE ld_fileext TO UPPER CASE.

  " mime
  CALL FUNCTION 'SDOK_MIMETYPE_GET'
    EXPORTING
      extension = CONV char100( ld_fileext )
    IMPORTING
      mimetype  = ld_mime.

  IF ld_mime = ''.
    es_bapiret2-type    = 'E'.
    es_bapiret2-message = |MIME não identificado para a extensão { ld_fileext }|.
    RETURN.
  ENDIF.

  " conteúdo do arquivo
  IF id_from_server = 'X'.
    load_file_from_server_disk(
      EXPORTING
        id_fullpath   = id_fullpath
      IMPORTING
        et_bapiconten = lt_content
        ed_filesize   = ld_filesize
    ).
  ELSE.
    " carregar arquivo do PC do usuário ...
  ENDIF.

  IF ld_filesize = 0.
    es_bapiret2-type    = 'E'.
    es_bapiret2-message = |Arquivo { ld_filename } vazio|.
    RETURN.
  ENDIF.

  CLEAR ls_components.
  ls_components-doc_count  = '1'.
  ls_components-comp_count = '1'.
  ls_components-comp_id    = ''.
  ls_components-mimetype   = ld_mime.
  ls_components-comp_size  = ld_filesize.
  APPEND ls_components TO lt_components.

  CLEAR ls_signature.
  ls_signature-doc_count  = '1'.
  ls_signature-comp_count = '1'.
  ls_signature-prop_name  = 'DESCRIPTION'.
  ls_signature-prop_value = ld_filename.

  " nome alternativo
  IF id_filename IS SUPPLIED AND id_filename <> ''.
    ls_signature-prop_value = id_filename.
  ENDIF.

  APPEND ls_signature TO lt_signature.

  IF ld_mime = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'.
    CLEAR ls_signature.
    ls_signature-doc_count  = '1'.
    ls_signature-comp_count = '1'.
    ls_signature-prop_name  = 'BDS_DOCUMENTCLASS'.
    ls_signature-prop_value = ld_fileext.
    APPEND ls_signature TO lt_signature.
  ENDIF.

  IF ld_fileext = 'ZIP'.
    CLEAR ls_signature.
    ls_signature-doc_count  = '1'.
    ls_signature-comp_count = '1'.
    ls_signature-prop_name  = 'BDS_DOCUMENTCLASS'.
    ls_signature-prop_value = ld_fileext.
    APPEND ls_signature TO lt_signature.
  ENDIF.

  ld_object_key = id_object_key.

  cl_bds_document_set=>create_with_table(
    EXPORTING
      classname       = id_classname
      classtype       = id_classtype
      components      = lt_components
      content         = lt_content
      vscan_profile   = '/SCMS/KPRO_CREATE'
    CHANGING
      object_key      = ld_object_key
      signature       = lt_signature
    EXCEPTIONS
      internal_error  = 1
      error_kpro      = 2
      parameter_error = 3
      not_authorized  = 4
      not_allowed     = 5
      nothing_found   = 6
      others          = 7
  ).

  IF sy-subrc = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    es_bapiret2-type    = 'E'.
    es_bapiret2-message = |Erro ao criar arquivo { ld_filename } no GOS|.
  ENDIF.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_GOS_UTILS2=>LOAD_FILE_FROM_SERVER_DISK
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_FULLPATH                    TYPE        ANY
* | [<---] ED_CONTENT                     TYPE        XSTRING
* | [<---] ET_BAPICONTEN                  TYPE        BAPIDOCCONTENTAB
* | [<---] ED_FILESIZE                    TYPE        INT4
* +--------------------------------------------------------------------------------------</SIGNATURE>
method LOAD_FILE_FROM_SERVER_DISK.
  DATA: ld_line       TYPE xstring.
  DATA: ls_bapiconten TYPE bapiconten.

  CLEAR ed_content.
  CLEAR et_bapiconten.

  OPEN DATASET id_fullpath FOR INPUT IN BINARY MODE.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  DO.
    READ DATASET id_fullpath INTO ld_line MAXIMUM LENGTH 1022.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.

    IF et_bapiconten IS SUPPLIED.
      CLEAR ls_bapiconten.
      ls_bapiconten-line = ld_line.
      APPEND ls_bapiconten TO et_bapiconten.
    ENDIF.

    IF ed_content IS SUPPLIED.
      CONCATENATE ld_line ed_content
             INTO ed_content
               IN BYTE MODE.
    ENDIF.
  ENDDO.

  GET DATASET id_fullpath POSITION ed_filesize.

  CLOSE DATASET id_fullpath.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_GOS_UTILS2=>LOAD_FILE_GOS
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_DOCUMENT                    TYPE        ANY
* | [--->] ID_CLASSNAME                   TYPE        ANY
* +--------------------------------------------------------------------------------------</SIGNATURE>
method LOAD_FILE_GOS.
  DATA: ls_document_data  TYPE sofolenti1.
  DATA: lt_object_content TYPE STANDARD TABLE OF solisti1.
  DATA: lt_contents_hex   TYPE STANDARD TABLE OF solix.

  DATA: lt_srgbtbrel TYPE STANDARD TABLE OF srgbtbrel.
  DATA: ls_srgbtbrel TYPE srgbtbrel.

  " pode ser o número do pedido de compra, requisição de compra, qualquer documento que possa ter anexo no GOS


  " via SAPoffice (SOOD/SRGBTBREL)
  SELECT *
    INTO TABLE lt_srgbtbrel
    FROM srgbtbrel
   WHERE reltype  = 'ATTA'
     AND instid_a = id_document.

  IF sy-subrc = 0.
    LOOP AT lt_srgbtbrel INTO ls_srgbtbrel.
      CALL FUNCTION 'SO_DOCUMENT_READ_API1'
        EXPORTING
          document_id                = CONV so_entryid( ls_srgbtbrel-instid_b )
        IMPORTING
          document_data              = ls_document_data
        TABLES
          object_content             = lt_object_content
          contents_hex               = lt_contents_hex
        EXCEPTIONS
          document_id_not_exist      = 1
          operation_no_authorization = 2
          x_error                    = 3
          OTHERS                     = 4.
    ENDLOOP.

    RETURN.
  ENDIF.

  " via BDS (Business Document Service)
  DATA: ld_classname     TYPE bds_clsnam.
  DATA: ld_object_key    TYPE bds_typeid.

  DATA: lt_signature     TYPE STANDARD TABLE OF bapisignat.
  DATA: lt_components    TYPE STANDARD TABLE OF bapicompon.
  DATA: lt_content       TYPE STANDARD TABLE OF bapiconten.
  DATA: lt_ascii_content TYPE STANDARD TABLE OF bapiascont.

  ld_classname  = id_classname.
  ld_object_key = id_document.

  CALL FUNCTION 'BDS_BUSINESSDOCUMENT_GET_TAB'
    EXPORTING
      CLIENT                = sy-mandt
      classname             = ld_classname
      classtype             = 'BO'
      OBJECT_KEY            = ld_object_key
*     BINARY_FLAG           = 'X'
*     TEXT_AS_STREAM        = 'X'
    TABLES
      signature             = lt_signature
      components            = lt_components
      content               = lt_content
      ascii_content         = lt_ascii_content
    EXCEPTIONS
      NOTHING_FOUND         = 1
      PARAMETER_ERROR       = 2
      NOT_ALLOWED           = 3
      ERROR_KPRO            = 4
      INTERNAL_ERROR        = 5
      NOT_AUTHORIZED        = 6
      OTHERS                = 7.
endmethod.
ENDCLASS.
