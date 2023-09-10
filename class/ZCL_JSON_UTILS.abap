class ZCL_JSON_UTILS definition
  public
  create public .

public section.

  class-methods DATA_TO_JSON
    importing
      !IA_DATA type ANY
    returning
      value(RV_JSON) type STRING .
  class-methods JSON_TO_DATA
    importing
      !IV_JSON type STRING
    changing
      !CA_DATA type ANY .
protected section.
private section.
ENDCLASS.



CLASS ZCL_JSON_UTILS IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_JSON_UTILS=>DATA_TO_JSON
* +-------------------------------------------------------------------------------------------------+
* | [--->] IA_DATA                        TYPE        ANY
* | [<-()] RV_JSON                        TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method DATA_TO_JSON.
  " opção 1
  SELECT COUNT(*)
    FROM tmdir
   WHERE classname  = '/UI2/CL_JSON'
     AND methodname = 'SERIALIZE'.

  IF sy-subrc = 0.
    CALL METHOD ('/UI2/CL_JSON')=>('SERIALIZE')
      EXPORTING
        data   = ia_data
      RECEIVING
        r_json = rv_json.

    RETURN.
  ENDIF.

  " opção 2
  SELECT COUNT(*)
    FROM tmdir
   WHERE classname  = 'ZCL_UI2_JSON'
     AND methodname = 'SERIALIZE'.

  IF sy-subrc = 0.
    CALL METHOD ('ZCL_UI2_JSON')=>('SERIALIZE')
      EXPORTING
        data   = ia_data
      RECEIVING
        r_json = rv_json.

    RETURN.
  ENDIF.

  " opção 3
  rv_json = cl_fdt_json=>data_to_json( ia_data = ia_data ).
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_JSON_UTILS=>JSON_TO_DATA
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_JSON                        TYPE        STRING
* | [<-->] CA_DATA                        TYPE        ANY
* +--------------------------------------------------------------------------------------</SIGNATURE>
method JSON_TO_DATA.
  " opção 1
  SELECT COUNT(*)
    FROM tmdir
   WHERE classname = '/UI2/CL_JSON'
     AND methodname = 'DESERIALIZE'.

  IF sy-subrc = 0.
    CALL METHOD ('/UI2/CL_JSON')=>('DESERIALIZE')
      EXPORTING
        json = iv_json
      CHANGING
        data = ca_data.

    RETURN.
  ENDIF.

  " opção 2
  SELECT COUNT(*)
    FROM tmdir
   WHERE classname = 'ZCL_UI2_JSON'
     AND methodname = 'DESERIALIZE'.

  IF sy-subrc = 0.
    CALL METHOD ('ZCL_UI2_JSON')=>('DESERIALIZE')
      EXPORTING
        json = iv_json
      CHANGING
        data = ca_data.

    RETURN.
  ENDIF.

  " opção 3
  cl_fdt_json=>json_to_data(
    EXPORTING
      iv_json = iv_json
    CHANGING
      ca_data = ca_data
  ).
endmethod.
ENDCLASS.
