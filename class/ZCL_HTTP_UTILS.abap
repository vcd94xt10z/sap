class ZCL_HTTP_UTILS definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF MY_RESPONSE_LINE
       , line TYPE char255
       , END OF MY_RESPONSE_LINE .
  types:
    MY_RESPONSE_LINE_TAB TYPE STANDARD TABLE OF MY_RESPONSE_LINE .
  types:
    BEGIN OF my_property_file
       , name    TYPE string
       , mime    TYPE string
       , content TYPE xstring
       , path    TYPE string
       , END OF my_property_file .
  types:
    my_property_file_tab TYPE STANDARD TABLE OF my_property_file .
  types:
    my_property_file_tab2 TYPE HASHED TABLE OF my_property_file WITH UNIQUE KEY name .
  types:
    BEGIN OF MY_REQUEST
       , url     TYPE string
       , method  TYPE string
       , header  TYPE tihttpnvp
       , data    TYPE tihttpnvp
       , body    TYPE string
       , xbody   TYPE xstring
       , file    TYPE my_property_file_tab2
       , END OF MY_REQUEST .
  types:
    BEGIN OF MY_RESPONSE
       , status_code   TYPE INT4
       , status_reason TYPE string
       , body          TYPE string
       , body_tab      TYPE tchar255
       , xbody         TYPE xstring
       , header        TYPE tihttpnvp
       , begin_date    TYPE dats
       , begin_time    TYPE tims
       , end_date      TYPE dats
       , end_time      TYPE tims
       , END OF MY_RESPONSE.

  methods CONSTRUCTOR .
  class-methods REQUEST
    importing
      value(IS_REQUEST) type MY_REQUEST
    returning
      value(RS_RESPONSE) type MY_RESPONSE .
  class-methods REQUEST_TEST .
protected section.
private section.
ENDCLASS.



CLASS ZCL_HTTP_UTILS IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_HTTP_UTILS->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
method CONSTRUCTOR.
*
* Autor Vinicius Cesar Dias
* https://github.com/vcd94xt10z
* Ultima atualização: 28/07/2023
*
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_HTTP_UTILS=>REQUEST
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_REQUEST                     TYPE        MY_REQUEST
* | [<-()] RS_RESPONSE                    TYPE        MY_RESPONSE
* +--------------------------------------------------------------------------------------</SIGNATURE>
method REQUEST.
*
* Autor Vinicius Cesar Dias
* https://github.com/vcd94xt10z
*
  DATA: ld_url              TYPE string.
  DATA: lo_part             TYPE REF TO if_http_entity.
  DATA: ls_data             LIKE LINE OF is_request-data.
  DATA: ld_data             TYPE string.
  DATA: ls_file             LIKE LINE OF is_request-file.
  DATA: ld_string           TYPE string.
  DATA: ls_header           LIKE LINE OF is_request-header.
  DATA: ld_length           TYPE i.
  DATA: lo_http_client      TYPE REF TO if_http_client.
  DATA: ld_status_code      TYPE c.
  DATA: ld_status_text      TYPE c.
  DATA: ld_len_xstring      TYPE i.
  DATA: ld_status_reason    TYPE string.
  DATA: ls_response_headers LIKE LINE OF is_request-header.

  " inicialização
  CLEAR: rs_response.

  " limpando cache
  cl_http_server=>server_cache_invalidate( id = |{ is_request-url }*| type = 0 scope = 0 ).

   " criando o objeto para realizar a conexão
  ld_url = is_request-url.
  call method cl_http_client=>create_by_url
    exporting
      url                = ld_url
    importing
      client             = lo_http_client
    exceptions
      argument_not_found = 1
      plugin_not_active  = 2
      internal_error     = 3
      others             = 4.

  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  IF lo_http_client IS NOT BOUND.
    RETURN.
  ENDIF.

  IF is_request-method = ''.
    is_request-method = 'GET'.
  ENDIF.

  call method lo_http_client->request->set_method(
    is_request-method
  ).

  lo_http_client->request->set_version(
    if_http_request=>co_protocol_version_1_0
  ).

  IF lines( is_request-data ) > 0.
    READ TABLE is_request-header INTO ls_header WITH KEY name = 'Content-Type'.
    IF sy-subrc <> 0.
      CLEAR rs_response.
      rs_response-status_code   = '400'.
      rs_response-status_reason = 'Ao usar campos de formulário, o Content-Type deve ser definido'.
      EXIT.
    ENDIF.
  ENDIF.

*  CALL METHOD lo_http_client->request->if_http_entity~set_formfield_encoding
*    EXPORTING
*      formfield_encoding = cl_http_request=>if_http_entity~co_encoding_raw.

  LOOP AT is_request-header INTO ls_header.
    CALL METHOD lo_http_client->request->set_header_field
      EXPORTING
        NAME  = ls_header-name
        VALUE = ls_header-value.
  ENDLOOP.

  IF is_request-body IS NOT INITIAL.
    CALL METHOD lo_http_client->request->append_cdata
      EXPORTING
        data = is_request-body.
  ELSEIF is_request-xbody IS NOT INITIAL.
    CALL METHOD lo_http_client->request->append_data
      EXPORTING
        data = is_request-xbody.
  ELSE.
    " dados de formulário
    LOOP AT is_request-data INTO ls_data.
      lo_part = lo_http_client->request->if_http_entity~add_multipart( ).
      CONCATENATE 'form-data;name="' ls_data-name '"'
             INTO ld_string.

      CALL METHOD lo_part->set_header_field
        EXPORTING
          NAME  = 'content-disposition'
          VALUE = ld_string.

      CALL METHOD lo_part->append_cdata
        EXPORTING
          DATA = ls_data-value.
    ENDLOOP.

    " arquivos da requisição (upload)
    LOOP AT is_request-file INTO ls_file.
      lo_part = lo_http_client->request->if_http_entity~add_multipart( ).
      CONCATENATE 'form-data; name="content"; filename="' ls_file-name '";'
             INTO ld_string.

      CALL METHOD lo_part->set_header_field
        EXPORTING
          name  = 'content-disposition'
          value = ld_string.

      CALL METHOD lo_part->set_content_type
        EXPORTING
          content_type = ls_file-mime.

      IF ls_file-path IS NOT INITIAL.
        OPEN DATASET ls_file-path FOR INPUT IN BINARY MODE.
        READ DATASET ls_file-path INTO ls_file-content.
        CLOSE DATASET ls_file-path.
      ENDIF.

      ld_len_xstring = xstrlen( ls_file-content ).

      CALL METHOD lo_part->set_data
        EXPORTING
          data   = ls_file-content
          offset = 0
          length = ld_len_xstring.
    ENDLOOP.
  ENDIF.

  GET TIME.
  rs_response-begin_date = sy-datum.
  rs_response-begin_time = sy-uzeit.

  " envia a requisição
  call method lo_http_client->send
    exceptions
      http_communication_failure = 1
      http_invalid_state         = 2.

  " obtem a resposta
  call method lo_http_client->receive
    exceptions
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3.

  " lê o corpo da resposta
  call method lo_http_client->response->get_cdata
    receiving
      data = rs_response-body.

  " formato binário
  rs_response-xbody = lo_http_client->response->get_data( ).

  " cabeçalhos da resposta
  call method lo_http_client->response->get_header_fields
    CHANGING
      fields = rs_response-header.

  " fecha a conexão
  call method lo_http_client->close
    exceptions
      http_invalid_state = 1
      others             = 2.

  GET TIME.
  rs_response-end_date = sy-datum.
  rs_response-end_time = sy-uzeit.

  READ TABLE rs_response-header INTO ls_response_headers WITH KEY name = '~status_code'.
  IF sy-subrc = 0.
    rs_response-status_code = ls_response_headers-value.
  ENDIF.

  READ TABLE rs_response-header INTO ls_response_headers WITH KEY name = '~status_reason'.
  IF sy-subrc = 0.
    rs_response-status_reason = ls_response_headers-value.
  ENDIF.

  " convertendo o corpo da resposta para linhas também
  split rs_response-body
       at cl_abap_char_utilities=>newline
     into table rs_response-body_tab.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_HTTP_UTILS=>REQUEST_TEST
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
method REQUEST_TEST.
  TYPES: BEGIN OF ly_retorno
       , _id TYPE char100
       , END OF ly_retorno.

  DATA: ld_json     TYPE string.
  DATA: ls_data     TYPE ihttpnvp.
  DATA: ls_file     TYPE my_property_file.
  DATA: ls_header   TYPE ihttpnvp.
  DATA: ls_retorno  TYPE ly_retorno.
  DATA: ls_request  TYPE my_request.
  DATA: ls_response TYPE my_response.
  DATA: ls_sairport TYPE sairport.
  DATA: ld_base_url TYPE string.

  SELECT SINGLE *
    INTO ls_sairport
    FROM sairport.

  " Acesse https://crudcrud.com e troque o hash!
  ld_base_url = 'https://crudcrud.com/api/816939db0bb54b3e826fe9552bfdbb40/airport'.
  ld_json = cl_fdt_json=>data_to_json( ia_data = ls_sairport ).

  BREAK-POINT.

  " Requisição POST
  CLEAR ls_request.
  CLEAR ls_response.

  CLEAR ls_header.
  ls_header-name  = 'Content-Type'.
  ls_header-value = 'application/json'.
  APPEND ls_header TO ls_request-header.

  ls_request-url    = ld_base_url.
  ls_request-method = 'POST'.
  ls_request-body   = ld_json.
  ls_response = zcl_http_utils=>request( is_request = ls_request ).

  cl_fdt_json=>json_to_data(
    EXPORTING
      iv_json = ls_response-body
    CHANGING
      ca_data = ls_retorno
  ).

  " Requisição GET
  CLEAR ls_request.
  CLEAR ls_response.
  ls_request-url    = |{ ld_base_url }/{ ls_retorno-_id }|.
  ls_request-method = 'GET'.
  ls_response = zcl_http_utils=>request( is_request = ls_request ).

  " Requisição PUT
  CLEAR ls_request.
  CLEAR ls_response.

  CLEAR ls_header.
  ls_header-name  = 'Content-Type'.
  ls_header-value = 'application/json'.
  APPEND ls_header TO ls_request-header.

  ls_request-url    = |{ ld_base_url }/{ ls_retorno-_id }|.
  ls_request-method = 'PUT'.
  ls_request-body   = ld_json.
  ls_response = zcl_http_utils=>request( is_request = ls_request ).

  " Requisição DELETE
  CLEAR ls_request.
  CLEAR ls_response.
  ls_request-url    = |{ ld_base_url }/{ ls_retorno-_id }|.
  ls_request-method = 'DELETE'.
  ls_response = zcl_http_utils=>request( is_request = ls_request ).

  " Enviando dados via formulário
  CLEAR ls_request.
  CLEAR ls_response.

  CLEAR ls_data.
  ls_data-name = 'id'.
  ls_data-value = 4.
  APPEND ls_data TO ls_request-data.

  CLEAR ls_data.
  ls_data-name = 'nome'.
  ls_data-value = 'José da Silva'.
  APPEND ls_data TO ls_request-data.

  CLEAR ls_header.
  ls_header-name  = 'Content-Type'.
  ls_header-value = 'multipart/form-data'.
  APPEND ls_header TO ls_request-header.

  ls_request-url    = 'https://httpbin.org/anything'.
  ls_request-method = 'POST'.
  ls_response = zcl_http_utils=>request( is_request = ls_request ).

  " Enviando arquivo de texto
  CLEAR ls_request.
  CLEAR ls_response.
  ls_request-url    = 'https://httpbin.org/anything'.
  ls_request-method = 'POST'.

  CLEAR ls_file.
  ls_file-name    = 'Arquivo.txt'.
  ls_file-mime    = 'plain/text'.
  ls_file-path    = '/tmp/teste.txt'.
  INSERT ls_file INTO TABLE ls_request-file.

  ls_response = zcl_http_utils=>request( is_request = ls_request ).

  " Enviando arquivo binário
  CLEAR ls_request.
  CLEAR ls_response.
  ls_request-url    = 'https://httpbin.org/anything'.
  ls_request-method = 'POST'.

  CLEAR ls_file.
  ls_file-name    = 'Manual.pdf'.
  ls_file-mime    = 'application/pdf'.
  ls_file-path    = '/usr/share/cups/data/topsecret.pdf'.
  INSERT ls_file INTO TABLE ls_request-file.

  ls_response = zcl_http_utils=>request( is_request = ls_request ).
endmethod.
ENDCLASS.