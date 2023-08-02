class ZCL_XML_UTILS definition
  public
  final
  create public .

public section.

  class-methods DATA_TO_XML
    importing
      !DATA type ANY
    returning
      value(XML) type STRING .
  class-methods XML_TO_DATA
    importing
      !XML type STRING
    changing
      !DATA type ANY .
  class-methods DATA_TO_XML_MANUAL
    importing
      !DATA type ANY
      value(TAGNAME) type STRING optional
    changing
      !XMLTAB type TABLE_OF_STRINGS optional
    returning
      value(XML) type STRING .
  class-methods XML_TO_DATA_MANUAL
    importing
      !XML type STRING
    changing
      !DATA type ANY .
protected section.
private section.
ENDCLASS.



CLASS ZCL_XML_UTILS IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_XML_UTILS=>DATA_TO_XML
* +-------------------------------------------------------------------------------------------------+
* | [--->] DATA                           TYPE        ANY
* | [<-()] XML                            TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method DATA_TO_XML.
*
* Autor Vinicius Cesar Dias
* https://github.com/vcd94xt10z
*
  DATA: lo_xml TYPE REF TO cl_xml_document.

  CREATE OBJECT lo_xml.

  " Carrega os dados da variável para o XML
  lo_xml->create_with_data(
    EXPORTING
      name       = 'DATA'
      dataobject = data
  ).

  " Escreve o XML na string
  lo_xml->render_2_string(
    EXPORTING
      pretty_print = 'X'
    IMPORTING
      stream       = xml
  ).
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_XML_UTILS=>DATA_TO_XML_MANUAL
* +-------------------------------------------------------------------------------------------------+
* | [--->] DATA                           TYPE        ANY
* | [--->] TAGNAME                        TYPE        STRING(optional)
* | [<-->] XMLTAB                         TYPE        TABLE_OF_STRINGS(optional)
* | [<-()] XML                            TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method DATA_TO_XML_MANUAL.
*
* Autor Vinicius Cesar Dias
* https://github.com/vcd94xt10z
*
  DATA: ld_root    TYPE flag.
  DATA: lo_type    TYPE REF TO cl_abap_typedescr.
  DATA: lt_comp    TYPE abap_compdescr_tab.
  DATA: ls_comp    LIKE LINE OF lt_comp.
  DATA: lo_data    TYPE REF TO data.
  DATA: lo_struc   TYPE REF TO cl_abap_structdescr.
  DATA: ld_value   TYPE string.
  DATA: ld_rowtype TYPE ttrowtype.
  DATA: ld_roottag TYPE string.

  FIELD-SYMBOLS: <ls_data>  TYPE any.
  FIELD-SYMBOLS: <lt_data>  TYPE STANDARD TABLE.
  FIELD-SYMBOLS: <ld_value> TYPE any.

  CLEAR xml.

  ld_roottag = 'data'.

  ld_root = ''.
  IF xmltab IS INITIAL.
    ld_root = 'X'.
  ENDIF.

  IF ld_root = 'X'.
    APPEND '<?xml version = "1.0"?>' TO xmltab.
    IF tagname <> ''.
      ld_roottag = tagname.
    ENDIF.
    APPEND |<{ ld_roottag }>| TO xmltab.
  ENDIF.

  lo_type = cl_abap_typedescr=>describe_by_data( data ).

  CASE lo_type->kind.
  WHEN cl_abap_typedescr=>kind_elem.   " elemento de dados
    IF tagname = ''.
      tagname = 'value'.
    ENDIF.
    APPEND |<{ tagname }>{ data }</{ tagname }>| TO xmltab.
  WHEN cl_abap_typedescr=>kind_struct. " estrutura
    " só cria o tag da estrutura, se ela estiver identificada
    IF tagname <> ''.
      APPEND |<{ tagname }>| TO xmltab.
    ENDIF.

    lo_struc ?= cl_abap_typedescr=>describe_by_data( p_data = data ).
    lt_comp   = lo_struc->components[].
    LOOP AT lt_comp INTO ls_comp.
      ASSIGN COMPONENT ls_comp-name OF STRUCTURE data TO <ld_value>.

      IF ls_comp-type_kind = cl_abap_typedescr=>typekind_struct1 OR
         ls_comp-type_kind = cl_abap_typedescr=>typekind_struct2 OR
         ls_comp-type_kind = cl_abap_typedescr=>typekind_table
         .
        data_to_xml_manual(
          EXPORTING
            data    = <ld_value>
            tagname = CONV #( ls_comp-name )
          CHANGING
            xmltab = xmltab
        ).
      ELSE.
        ld_value = <ld_value>.
        CONDENSE ld_value.
        APPEND |<{ ls_comp-name }>{ ld_value }</{ ls_comp-name }>|
            TO xmltab.
      ENDIF.
    ENDLOOP.

    " só cria o tag da estrutura, se ela estiver identificada
    IF tagname <> ''.
      APPEND |</{ tagname }>| TO xmltab.
    ENDIF.
  WHEN cl_abap_typedescr=>kind_table. " tabela interna
    IF tagname = ''.
      tagname = 'tab'.
    ENDIF.
    APPEND |<{ tagname }>| TO xmltab.

    GET REFERENCE OF data INTO lo_data.
    ASSIGN lo_data->* TO <lt_data>.

    LOOP AT <lt_data> ASSIGNING <ls_data>.
      lo_struc ?= cl_abap_typedescr=>describe_by_data( p_data = <ls_data> ).
      lt_comp   = lo_struc->components[].

      APPEND '<item>' TO xmltab.
      LOOP AT lt_comp INTO ls_comp.
        ASSIGN COMPONENT ls_comp-name OF STRUCTURE <ls_data> TO <ld_value>.

        IF ls_comp-type_kind = cl_abap_typedescr=>typekind_struct1 OR
           ls_comp-type_kind = cl_abap_typedescr=>typekind_struct2 OR
           ls_comp-type_kind = cl_abap_typedescr=>typekind_table
           .
          data_to_xml_manual(
            EXPORTING
              data    = <ld_value>
              tagname = CONV #( ls_comp-name )
            CHANGING
              xmltab = xmltab
          ).
        ELSE.
          ld_value = <ld_value>.
          CONDENSE ld_value.
          APPEND |<{ ls_comp-name }>{ ld_value }</{ ls_comp-name }>|
              TO xmltab.
        ENDIF.
      ENDLOOP.
      APPEND '</item>' TO xmltab.
    ENDLOOP.

    APPEND |</{ tagname }>| TO xmltab.
  ENDCASE.

  IF ld_root = 'X'.
    APPEND |</{ ld_roottag }>| TO xmltab.

    CONCATENATE LINES OF xmltab
           INTO xml
      SEPARATED
             BY cl_abap_char_utilities=>newline.
  ENDIF.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_XML_UTILS=>XML_TO_DATA
* +-------------------------------------------------------------------------------------------------+
* | [--->] XML                            TYPE        STRING
* | [<-->] DATA                           TYPE        ANY
* +--------------------------------------------------------------------------------------</SIGNATURE>
method XML_TO_DATA.
*
* Autor Vinicius Cesar Dias
* https://github.com/vcd94xt10z
*
  DATA: lo_xml TYPE REF TO cl_xml_document.

  CREATE OBJECT lo_xml.

  " Lê o XML a partir da String
  lo_xml->parse_string( stream = xml ).
  IF lo_xml IS NOT BOUND.
    RETURN.
  ENDIF.

  " Transfere os valores do XML para uma variável
  lo_xml->get_data(
    CHANGING
      dataobject = data
  ).

  lo_xml->free( ).
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_XML_UTILS=>XML_TO_DATA_MANUAL
* +-------------------------------------------------------------------------------------------------+
* | [--->] XML                            TYPE        STRING
* | [<-->] DATA                           TYPE        ANY
* +--------------------------------------------------------------------------------------</SIGNATURE>
method XML_TO_DATA_MANUAL.
*
* Autor Vinicius Cesar Dias
* https://github.com/vcd94xt10z
*
  DATA: lo_xml         TYPE REF TO cl_xml_document.
  DATA: lo_attr        TYPE REF TO if_ixml_named_node_map.
  DATA: lo_node        TYPE REF TO if_ixml_node.
  DATA: ld_name        TYPE string.
  DATA: ld_type        TYPE string.
  DATA: lo_next        TYPE REF TO if_ixml_node.
  DATA: lo_prev        TYPE REF TO if_ixml_node.
  DATA: lo_node2       TYPE REF TO if_ixml_node.
  DATA: ld_depth       TYPE int4.
  DATA: ld_value       TYPE string.
  DATA: ld_height      TYPE int4.
  DATA: lo_parent      TYPE REF TO if_ixml_node.
  DATA: lo_iterator    TYPE REF TO if_ixml_node_iterator.
  DATA: lo_children    TYPE REF TO if_ixml_node_list.
  DATA: ld_parent_name TYPE string.
  DATA: ld_childrenlen TYPE int4.

  IF xml = ''.
    RETURN.
  ENDIF.

  CREATE OBJECT lo_xml.

  lo_xml->parse_string( stream = xml ).

  lo_node = lo_xml->get_first_node( ).
  IF lo_node IS NOT BOUND.
    RETURN.
  ENDIF.

  lo_iterator = lo_node->create_iterator( ).
  IF lo_iterator IS NOT BOUND.
    RETURN.
  ENDIF.

  "lo_node2 = lo_xml->find_node( name = 'FIELD3' ).
  lo_node2 = lo_xml->find_node( name = 'FIELD3/ID' ).
  IF lo_node2 IS BOUND.
    ld_value = lo_node2->get_value( ).
  ENDIF.

  DO.
    lo_node = lo_iterator->get_next( ).

    " quando não houver mais nós, para de iterar
    IF lo_node IS NOT BOUND.
      EXIT.
    ENDIF.

    " extraindo valores dos tags
    ld_name        = lo_node->get_name( ).
    lo_attr        = lo_node->get_attributes( ).
    ld_type        = lo_node->get_type( ).
    ld_value       = lo_node->get_value( ).
    lo_next        = lo_node->get_next( ).
    lo_prev        = lo_node->get_prev( ).
    ld_depth       = lo_node->get_depth( ).
    ld_height      = lo_node->get_height( ).
    lo_parent      = lo_node->get_parent( ).
    lo_children    = lo_node->get_children( ).
    ld_childrenlen = lo_children->get_length( ).

    " nós de valor não são avaliados pois o nó pai já consegue obter o valor
    IF ld_type = 16.
      CONTINUE.
    ENDIF.

    " sua lógica aqui...
    "lo_children->create_iterator( ).
  ENDDO.
endmethod.
ENDCLASS.
