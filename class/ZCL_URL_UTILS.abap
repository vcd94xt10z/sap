class ZCL_URL_UTILS definition
  public
  create public .

public section.

  types:
    BEGIN OF my_query
       , key   TYPE string
       , value TYPE string
       , END OF my_query .
  types:
    my_query_tab TYPE STANDARD TABLE OF my_query WITH DEFAULT KEY .
  types:
    BEGIN OF my_components
       , scheme   TYPE string
       , host     TYPE string
       , port     TYPE int4
       , path     TYPE string
       , query    TYPE my_query_tab
       , fragment TYPE string
       , END OF my_components .

  class-methods PARSE_URL
    importing
      value(ID_URL) type STRING
    returning
      value(RS_COMPONENTS) type MY_COMPONENTS .
  class-methods GET_SCHEME
    importing
      value(ID_URL) type STRING
    returning
      value(RD_SCHEME) type STRING .
  class-methods GET_HOST
    importing
      value(ID_URL) type STRING
    returning
      value(RD_HOST) type STRING .
  class-methods GET_PORT
    importing
      value(ID_URL) type STRING
    returning
      value(RD_PORT) type STRING .
  class-methods GET_PATH
    importing
      value(ID_URL) type STRING
    returning
      value(RD_PATH) type STRING .
  class-methods GET_QUERY
    importing
      value(ID_URL) type STRING
    returning
      value(RT_QUERY) type MY_QUERY_TAB .
  class-methods GET_FRAGMENT
    importing
      value(ID_URL) type STRING
    returning
      value(RD_FRAGMENT) type STRING .
  class-methods REMOVE_SCHEME
    changing
      value(CD_URL) type STRING .
protected section.
private section.
ENDCLASS.



CLASS ZCL_URL_UTILS IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_URL_UTILS=>GET_FRAGMENT
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_URL                         TYPE        STRING
* | [<-()] RD_FRAGMENT                    TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_FRAGMENT.
  DATA: ld_index1  TYPE int4.

  CLEAR rd_fragment.

  " http://www.example.com:80/path/to/myfile.html?key1=value1&key2=value2#SomewhereInTheDocument

  " procurando próxima ?
  ld_index1 = find( val = id_url sub = '#' ).
  IF ld_index1 = -1.
    RETURN.
  ENDIF.

  ld_index1 = ld_index1 + 1.

  " removendo tudo que tem antes do ?
  rd_fragment = id_url+ld_index1.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_URL_UTILS=>GET_HOST
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_URL                         TYPE        STRING
* | [<-()] RD_HOST                        TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_HOST.
  DATA: ld_index1 TYPE int4.
  DATA: ld_index2 TYPE int4.

  " http://www.example.com:80/path/to/myfile.html?key1=value1&key2=value2#SomewhereInTheDocument

  CLEAR rd_host.

  IF id_url = ''.
    RETURN.
  ENDIF.

  " removendo schema
  remove_scheme( CHANGING cd_url = id_url ).

  " procurando próxima :
  ld_index1 = find( val = id_url sub = ':' ).

  " procurando próxima /
  ld_index2 = find( val = id_url sub = '/' ).

  " não tem :
  IF ld_index1 = -1.
    rd_host = id_url(ld_index2).
    RETURN.
  ENDIF.

  " tem :
  rd_host = id_url(ld_index1).
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_URL_UTILS=>GET_PATH
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_URL                         TYPE        STRING
* | [<-()] RD_PATH                        TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_PATH.
  DATA: ld_index1 TYPE int4.
  DATA: ld_index2 TYPE int4.
  DATA: ld_index3 TYPE int4.

  CLEAR rd_path.

  " http://www.example.com:80/path/to/myfile.html?key1=value1&key2=value2#SomewhereInTheDocument

  remove_scheme( CHANGING cd_url = id_url ).

  " procurando próxima /
  ld_index1 = find( val = id_url sub = '/' ).
  IF ld_index1 = -1.
    RETURN.
  ENDIF.

  " removendo tudo que tem antes do path
  id_url = id_url+ld_index1.

  " procurando próxima ?
  ld_index2 = find( val = id_url sub = '?' ).
  IF ld_index2 <> -1.
    rd_path = id_url(ld_index2).
    RETURN.
  ENDIF.

  " procurando próxima #
  ld_index3 = find( val = id_url sub = '#' ).
  IF ld_index3 <> -1.
    rd_path = id_url(ld_index3).
    RETURN.
  ENDIF.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_URL_UTILS=>GET_PORT
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_URL                         TYPE        STRING
* | [<-()] RD_PORT                        TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_PORT.
  DATA: ld_index1 TYPE int4.
  DATA: ld_index2 TYPE int4.
  DATA: ld_diff   TYPE int4.

  " http://www.example.com:80/path/to/myfile.html?key1=value1&key2=value2#SomewhereInTheDocument

  CLEAR rd_port.

  IF id_url = ''.
    RETURN.
  ENDIF.

  " removendo schema
  remove_scheme( CHANGING cd_url = id_url ).

  " procurando próxima :
  ld_index1 = find( val = id_url sub = ':' ).

  " procurando próxima /
  ld_index2 = find( val = id_url sub = '/' ).

  " se não tem :, não tem porta
  IF ld_index1 = -1.
    RETURN.
  ENDIF.

  " se não tem /, conta a string inteira
  IF ld_index2 = -1.
    ld_index2 = strlen( id_url ).
  ENDIF.

  " pulando o próprio :
  ld_index1 = ld_index1 + 1.

  ld_diff = ld_index2 - ld_index1.

  rd_port = id_url+ld_index1(ld_diff).
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_URL_UTILS=>GET_QUERY
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_URL                         TYPE        STRING
* | [<-()] RT_QUERY                       TYPE        MY_QUERY_TAB
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_QUERY.
  DATA: ld_index1  TYPE int4.
  DATA: ld_index2  TYPE int4.
  DATA: lt_string1 TYPE STANDARD TABLE OF string.
  DATA: lt_string2 TYPE STANDARD TABLE OF string.
  DATA: ld_string  TYPE string.
  DATA: ls_query   TYPE my_query.

  CLEAR rt_query.

  " http://www.example.com:80/path/to/myfile.html?key1=value1&key2=value2#SomewhereInTheDocument

  " procurando próxima ?
  ld_index1 = find( val = id_url sub = '?' ).
  IF ld_index1 = -1.
    RETURN.
  ENDIF.

  ld_index1 = ld_index1 + 1.

  " removendo tudo que tem antes do ?
  id_url = id_url+ld_index1.

  " procurando próxima #
  ld_index2 = find( val = id_url sub = '#' ).
  IF ld_index2 <> -1.
    id_url = id_url(ld_index2).
  ENDIF.

  CLEAR lt_string1.
  SPLIT id_url AT '&' INTO TABLE lt_string1.
  LOOP AT lt_string1 INTO ld_string.
    CLEAR lt_string2.
    SPLIT ld_string AT '=' INTO TABLE lt_string2.
    IF lines( lt_string2 ) >= 2.
      CLEAR ls_query.
      ls_query-key   = lt_string2[ 1 ].
      ls_query-value = lt_string2[ 2 ].
      APPEND ls_query TO rt_query.
    ENDIF.
  ENDLOOP.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_URL_UTILS=>GET_SCHEME
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_URL                         TYPE        STRING
* | [<-()] RD_SCHEME                      TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_SCHEME.
  DATA: lt_string TYPE STANDARD TABLE OF string.

  " http://www.example.com:80/path/to/myfile.html?key1=value1&key2=value2#SomewhereInTheDocument

  CLEAR rd_scheme.

  IF id_url = ''.
    RETURN.
  ENDIF.

  CLEAR lt_string.
  SPLIT id_url AT '://' INTO TABLE lt_string.
  IF lines( lt_string ) <= 0.
    RETURN.
  ENDIF.

  rd_scheme = lt_string[ 1 ].
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_URL_UTILS=>PARSE_URL
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_URL                         TYPE        STRING
* | [<-()] RS_COMPONENTS                  TYPE        MY_COMPONENTS
* +--------------------------------------------------------------------------------------</SIGNATURE>
method PARSE_URL.
  " http://www.example.com:80/path/to/myfile.html?key1=value1&key2=value2#SomewhereInTheDocument

  IF id_url = ''.
    id_url = 'http://www.example.com:80/path/to/myfile.html?key1=value1&key2=value2#SomewhereInTheDocument'.
  ENDIF.

  CLEAR rs_components.
  rs_components-scheme   = get_scheme( id_url = id_url ).
  rs_components-host     = get_host( id_url = id_url  ).
  rs_components-port     = get_port( id_url = id_url ).
  rs_components-path     = get_path( id_url = id_url ).
  rs_components-query    = get_query( id_url = id_url ).
  rs_components-fragment = get_fragment( id_url = id_url ).
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_URL_UTILS=>REMOVE_SCHEME
* +-------------------------------------------------------------------------------------------------+
* | [<-->] CD_URL                         TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method REMOVE_SCHEME.
  DATA: ld_scheme TYPE string.

  ld_scheme = get_scheme( EXPORTING id_url = cd_url ).
  IF ld_scheme <> ''.
    ld_scheme = |{ ld_scheme }://|.
    REPLACE FIRST OCCURRENCE OF ld_scheme IN cd_url WITH ''.
  ENDIF.
endmethod.
ENDCLASS.
