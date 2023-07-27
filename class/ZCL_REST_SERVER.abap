class ZCL_REST_SERVER definition
  public
  final
  create public .

public section.

  interfaces IF_HTTP_EXTENSION .
protected section.
private section.
ENDCLASS.



CLASS ZCL_REST_SERVER IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_REST_SERVER->IF_HTTP_EXTENSION~HANDLE_REQUEST
* +-------------------------------------------------------------------------------------------------+
* | [--->] SERVER                         TYPE REF TO IF_HTTP_SERVER
* +--------------------------------------------------------------------------------------</SIGNATURE>
method IF_HTTP_EXTENSION~HANDLE_REQUEST.
*
* Autor Vinicius Cesar Dias
* https://github.com/vcd94xt10z
*
  DATA: ld_id            TYPE string.
  DATA: ld_path          TYPE string.
  DATA: lt_path          TYPE STANDARD TABLE OF string.
  DATA: ld_params        TYPE string.
  DATA: ld_remote_addr   TYPE string.
  DATA: ld_request_body  TYPE string.
  DATA: ld_method        TYPE string.
  DATA: lt_header        TYPE tihttpnvp.
  DATA: ls_header        LIKE LINE OF lt_header.
  DATA: ld_response_body TYPE string.

  " request
  ld_request_body = server->request->get_cdata( ).

  server->request->get_header_fields(
    CHANGING
      fields = lt_header
  ).

  READ TABLE lt_header INTO ls_header WITH KEY name = '~request_uri'.
  IF sy-subrc = 0.
    ld_path = ls_header-value.
  ENDIF.

  READ TABLE lt_header INTO ls_header WITH KEY name = '~remote_addr'.
  IF sy-subrc = 0.
    ld_remote_addr = ls_header-value.
  ENDIF.

  ld_method = server->request->get_method( ).

  " response
  SPLIT ld_path AT '?' INTO ld_path ld_params.
  SPLIT ld_path AT '/' INTO TABLE lt_path.

  IF ld_path = '/zapi/cliente' AND ld_method = 'POST'.
    server->response->set_status(
      EXPORTING
        code   = 201
        reason = 'OK'
    ).

    server->response->set_header_field(
      EXPORTING
        name  = 'Content-Type'
        value = 'plain/text'
    ).
  ELSEIF ld_path CS '/zapi/cliente' AND ld_method = 'GET'.
    READ TABLE lt_path INTO ld_id INDEX 4.

    server->response->set_status(
      EXPORTING
        code   = 200
        reason = 'OK'
    ).

    server->response->set_header_field(
      EXPORTING
        name  = 'Content-Type'
        value = 'application/json'
    ).

    ld_response_body = |\{id:1,nome:"José da Silva"\}|.
    server->response->set_cdata(
      EXPORTING
        data = ld_response_body
    ).
  ELSE.
    server->response->set_status(
      EXPORTING
        code   = 404
        reason = 'Page not Found'
    ).

    server->response->set_header_field(
      EXPORTING
        name  = 'Content-Type'
        value = 'plain/text'
    ).

    ld_response_body = 'Página não encontrada'.
    server->response->set_cdata(
      EXPORTING
        data = ld_response_body
    ).
  ENDIF.
endmethod.
ENDCLASS.