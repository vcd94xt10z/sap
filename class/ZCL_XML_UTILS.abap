class ZCL_XML_UTILS definition
  public
  final
  create public .

public section.

  class-methods CLASS_CONSTRUCTOR .
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
      !DATA type ANY
      !ROOT type ref to IF_IXML_NODE optional .
protected section.
private section.
ENDCLASS.



CLASS ZCL_XML_UTILS IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_XML_UTILS=>CLASS_CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
method CLASS_CONSTRUCTOR.
*
* Autor Vinicius Cesar Dias
* https://github.com/vcd94xt10z
* Ultima atualização 02/08/2023
*
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_XML_UTILS=>DATA_TO_XML
* +-------------------------------------------------------------------------------------------------+
* | [--->] DATA                           TYPE        ANY
* | [<-()] XML                            TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method DATA_TO_XML.
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
    IF ld_root <> 'X'.
      APPEND |<{ tagname }>| TO xmltab.
    ENDIF.

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

    IF ld_root <> 'X'.
      APPEND |</{ tagname }>| TO xmltab.
    ENDIF.
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
* | [<-->] ROOT                           TYPE REF TO IF_IXML_NODE(optional)
* +--------------------------------------------------------------------------------------</SIGNATURE>
method XML_TO_DATA_MANUAL.
  DATA: lo_xml         TYPE REF TO cl_xml_document.
  DATA: lo_attr        TYPE REF TO if_ixml_named_node_map.
  DATA: lo_node        TYPE REF TO if_ixml_node.
  DATA: ld_name        TYPE string.
  DATA: ld_type        TYPE string.
  DATA: lo_next        TYPE REF TO if_ixml_node.
  DATA: lo_prev        TYPE REF TO if_ixml_node.
  DATA: lo_type        TYPE REF TO cl_abap_typedescr.
  DATA: lt_comp        TYPE abap_compdescr_tab.
  DATA: ls_comp        LIKE LINE OF lt_comp.
  DATA: lo_data        TYPE REF TO data.
  DATA: lo_struc       TYPE REF TO cl_abap_structdescr.
  DATA: lt_node        TYPE SWXMLNODES.
  DATA: ls_inode       TYPE SWXML_NITM.
  DATA: lo_node2       TYPE REF TO if_ixml_node.
  DATA: lo_node3       TYPE REF TO if_ixml_node.
  DATA: lo_node4       TYPE REF TO if_ixml_node.
  DATA: ld_depth       TYPE int4.
  DATA: ld_value       TYPE string.
  DATA: ld_length      TYPE int4.
  DATA: ld_height      TYPE int4.
  DATA: ld_rowtype     TYPE ttrowtype.
  DATA: lo_parent      TYPE REF TO if_ixml_node.
  DATA: lo_nodelist    TYPE REF TO if_ixml_node_list.
  DATA: lo_iterator    TYPE REF TO if_ixml_node_iterator.
  DATA: lo_iterator2   TYPE REF TO if_ixml_node_iterator.
  DATA: lo_iterator3   TYPE REF TO if_ixml_node_iterator.
  DATA: lo_children    TYPE REF TO if_ixml_node_list.
  DATA: ld_parent_name TYPE string.
  DATA: ld_childrenlen TYPE int4.

  FIELD-SYMBOLS: <ls_data>  TYPE any.
  FIELD-SYMBOLS: <lt_data>  TYPE STANDARD TABLE.
  FIELD-SYMBOLS: <ld_value> TYPE any.

  IF xml = ''.
    RETURN.
  ENDIF.

  IF root IS NOT BOUND.
    CREATE OBJECT lo_xml.

    lo_xml->parse_string( stream = xml ).

    root = lo_xml->get_first_node( ).
    IF root IS NOT BOUND.
      RETURN.
    ENDIF.
  ENDIF.

  lo_children = root->get_children( ).
  lo_iterator = lo_children->create_iterator( ).
  IF lo_iterator IS NOT BOUND.
    RETURN.
  ENDIF.

  lo_type = cl_abap_typedescr=>describe_by_data( data ).

  CASE lo_type->kind.
  WHEN cl_abap_typedescr=>kind_elem.   " elemento de dados

  WHEN cl_abap_typedescr=>kind_struct. " estrutura
    lo_struc ?= cl_abap_typedescr=>describe_by_data( p_data = data ).
    lt_comp   = lo_struc->components[].

    DO.
      lo_node = lo_iterator->get_next( ).

      " quando não houver mais nós, para de iterar
      IF lo_node IS NOT BOUND.
        EXIT.
      ENDIF.

      ld_name = lo_node->get_name( ).
      ASSIGN COMPONENT ld_name OF STRUCTURE data TO <ld_value>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      READ TABLE lt_comp INTO ls_comp WITH KEY name = ld_name.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF ls_comp-type_kind = cl_abap_typedescr=>typekind_struct1 OR
         ls_comp-type_kind = cl_abap_typedescr=>typekind_struct2 OR
         ls_comp-type_kind = cl_abap_typedescr=>typekind_table
         .
        xml_to_data_manual(
          EXPORTING
            xml  = xml
          CHANGING
            root = lo_node
            data = <ld_value>
        ).
      ELSE.
        <ld_value> = lo_node->get_value( ).
      ENDIF.
    ENDDO.
  WHEN cl_abap_typedescr=>kind_table. " tabela interna
    GET REFERENCE OF data INTO lo_data.
    ASSIGN lo_data->* TO <lt_data>.

    " iterando em cada linha da tabela
    DO.
      lo_node2 = lo_iterator->get_next( ).
      IF lo_node2 IS NOT BOUND.
        EXIT.
      ENDIF.
      IF lo_node2->get_type( ) = 16.
        CONTINUE.
      ENDIF.

      ld_name  = lo_node2->get_name( ).
      ld_value = lo_node2->get_value( ).

      IF ld_name = 'item'.
        APPEND INITIAL LINE TO <lt_data> ASSIGNING <ls_data>.

        xml_to_data_manual(
          EXPORTING
            xml  = xml
          CHANGING
            data = <ls_data>
            root = lo_node2
        ).
      ENDIF.
    ENDDO.
  ENDCASE.
endmethod.
ENDCLASS.
