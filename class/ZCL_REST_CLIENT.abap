class ZCL_REST_CLIENT definition
  public
  final
  create public .

public section.

  interfaces IF_HTTP_EXTENSION .
protected section.
private section.
ENDCLASS.



CLASS ZCL_REST_CLIENT IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_REST_CLIENT->IF_HTTP_EXTENSION~HANDLE_REQUEST
* +-------------------------------------------------------------------------------------------------+
* | [--->] SERVER                         TYPE REF TO IF_HTTP_SERVER
* +--------------------------------------------------------------------------------------</SIGNATURE>
method IF_HTTP_EXTENSION~HANDLE_REQUEST.
*
* Autor Vinicius Cesar Dias
* https://github.com/vcd94xt10z
*
  DATA: ld_uri           TYPE string.
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
    ld_uri = ls_header-value.
  ENDIF.

  READ TABLE lt_header INTO ls_header WITH KEY name = '~remote_addr'.
  IF sy-subrc = 0.
    ld_remote_addr = ls_header-value.
  ENDIF.

  ld_method = server->request->get_method( ).

  " response
  ld_response_body = |\{id:1,nome:"teste"\}|.

  server->response->set_status(
    EXPORTING
      code   = 201
      reason = 'OK'
  ).

  server->response->set_header_field(
    EXPORTING
      name  = 'Content-Type'
      value = 'application/json'
  ).

  server->response->set_cdata(
    EXPORTING
      data = ld_response_body
  ).
endmethod.
ENDCLASS.