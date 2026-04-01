class ZCL_DRC_UTILS definition
  public
  create public .

public section.

  types:
    BEGIN OF my_retEnvEvento_RE_IE
       , tpAmb       TYPE string
       , verAplic    TYPE string
       , cOrgao      TYPE string
       , cStat       TYPE string
       , xMotivo     TYPE string
       , chNFe       TYPE string
       , tpEvento    TYPE string
       , xEvento     TYPE string
       , nSeqEvento  TYPE string
       , CNPJDest    TYPE string
       , dhRegEvento TYPE string
       , nProt       TYPE string
       , END OF my_retEnvEvento_RE_IE .
  types:
    BEGIN OF my_retEnvEvento_RE
       , infEvento TYPE my_retEnvEvento_RE_IE
       , END OF my_retEnvEvento_RE .
  types:
    BEGIN OF my_retEnvEvento
       , idLote    TYPE string
       , tpAmb     TYPE string
       , verAplic  TYPE string
       , cOrgao    TYPE string
       , cStat     TYPE string
       , xMotivo   TYPE string
       , retEvento TYPE my_retEnvEvento_RE
       , END OF my_retEnvEvento .
  types:
    my_retEnvEvento_tab TYPE STANDARD TABLE OF my_retEnvEvento WITH DEFAULT KEY .
  types:
    BEGIN OF my_xml_stack
       , nodeindex      TYPE int4
       , path           TYPE string
       , tagname        TYPE string
       , level          TYPE int4
       , value          TYPE string
       , attributes     TYPE string
       , parent_tagname TYPE string
       , END OF my_xml_stack .
  types:
    my_xml_stack_tab TYPE STANDARD TABLE OF my_xml_stack WITH DEFAULT KEY .
  types:
    my_nfkey(44) TYPE c .
  types:
    mt_nfkey TYPE STANDARD TABLE OF my_nfkey WITH DEFAULT KEY .

  class-methods BUILD_PATH
    importing
      value(IO_NODE) type ref to IF_IXML_NODE
    returning
      value(RD_TEXT) type STRING .
  class-methods CONVERT_XSTRING_TO_STRING
    importing
      value(INXSTRING) type XSTRING
    returning
      value(OUTSTRING) type STRING .
  class-methods COUNT_OCC_PATH_STACK
    importing
      value(ID_PATH) type STRING
      value(IT_STACK) type MY_XML_STACK_TAB
    returning
      value(RD_VALUE) type INT4 .
  class-methods GET_ATTRIBUTE_BY_NAME
    importing
      value(IO_ATTR) type ref to IF_IXML_NAMED_NODE_MAP
      value(ID_NAME) type STRING
    returning
      value(RD_VALUE) type STRING .
  class-methods GET_CONCAT_ATTRIBUTES
    importing
      value(IO_ATTR) type ref to IF_IXML_NAMED_NODE_MAP
    returning
      value(RD_TEXT) type STRING .
  class-methods GET_XMLTAG_CONTENT
    importing
      value(ID_BEGIN_TAG) type ANY
      value(ID_END_TAG) type ANY
      value(ID_XML) type ANY
    exporting
      value(ED_CONTENT) type ANY .
  class-methods GET_XMLTAG_CONTENT2
    importing
      value(ID_PATH) type STRING
      value(ID_INDEX) type INT4
      value(ID_XML) type STRING
    exporting
      value(ED_CONTENT) type STRING .
  class-methods GET_XMLTAG_CONTENT3
    importing
      value(ID_OPEN_TAG) type ANY
      value(ID_CLOSE_TAG) type ANY
      value(ID_XML) type ANY
    exporting
      value(ED_CONTENT) type ANY .
  class-methods GET_XML_CONTENT
    importing
      value(ID_ACCESS_KEY) type ANY
      value(ID_TYPE) type CHAR3
    exporting
      value(ED_CONTENT) type STRING
      value(ED_XCONTENT) type XSTRING .
  class-methods GET_XML_STRING_BY_DOCUMENT
    importing
      value(IO_XML_DOC) type ref to IF_IXML_DOCUMENT
    exporting
      value(ED_STRING) type STRING .
  class-methods GET_XML_STRING_BY_NODE
    importing
      value(IO_NODE) type ref to IF_IXML_NODE
    exporting
      value(ED_STRING) type STRING .
  class-methods LOAD_NFITEM
    importing
      value(IT_NFKEY) type MT_NFKEY
    exporting
      value(ET_NFITEM) type ZXNFE_INNFEIT_TAB .
  class-methods GET_EVENT
    importing
      value(IS_EDOCUMENTFILE) type EDOCUMENTFILE
    exporting
      value(ES_DATA) type MY_RETENVEVENTO .
  class-methods GET_EVENTS
    importing
      value(ID_GUID) type EDOC_FILE_GUID
    exporting
      value(ET_DATA) type MY_RETENVEVENTO_TAB .
  class-methods PARSE_DATETIME
    importing
      value(ID_DATETIME) type ANY
    exporting
      value(ED_DATETIME_STRING) type ANY
      value(ED_TIMESTAMP) type TIMESTAMPL .
protected section.
private section.
ENDCLASS.



CLASS ZCL_DRC_UTILS IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_DRC_UTILS=>BUILD_PATH
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_NODE                        TYPE REF TO IF_IXML_NODE
* | [<-()] RD_TEXT                        TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method BUILD_PATH.
  DATA: ld_text   TYPE string.
  DATA: lt_text   TYPE STANDARD TABLE OF string.
  DATA: lt_text2  LIKE lt_text.
  DATA: lo_parent TYPE REF TO if_ixml_node.
  DATA: ld_length TYPE int4.
  DATA: ld_index  TYPE int4.

  IF io_node IS NOT BOUND.
    RETURN.
  ENDIF.

  CLEAR lt_text.
  APPEND io_node->get_name( ) TO lt_text.

  lo_parent = io_node.
  DO.
    lo_parent = lo_parent->get_parent( ).
    IF lo_parent IS NOT BOUND.
      EXIT.
    ENDIF.

    APPEND lo_parent->get_name( ) TO lt_text.
  ENDDO.

  ld_length = lines( lt_text ).
  ld_index  = ld_length.
  DO ld_length TIMES.
    READ TABLE lt_text INTO ld_text INDEX ld_index.
    APPEND ld_text TO lt_text2.
    ld_index = ld_index - 1.
  ENDDO.
  CLEAR lt_text.

  CONCATENATE LINES OF lt_text2
         INTO rd_text SEPARATED BY '>'.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_DRC_UTILS=>CONVERT_XSTRING_TO_STRING
* +-------------------------------------------------------------------------------------------------+
* | [--->] INXSTRING                      TYPE        XSTRING
* | [<-()] OUTSTRING                      TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method CONVERT_XSTRING_TO_STRING.
  DATA: CONVERTER TYPE REF TO CL_ABAP_CONV_IN_CE.
  DATA: LV_XSTRING TYPE XSTRING.

  LV_XSTRING = INXSTRING.

*  -- Convert
  CALL METHOD CL_ABAP_CONV_IN_CE=>CREATE
    EXPORTING INPUT = LV_XSTRING
              ENCODING = 'UTF-8'
              REPLACEMENT = '?'
              IGNORE_CERR = ABAP_TRUE
    RECEIVING CONV = CONVERTER.

  TRY.
   CALL METHOD CONVERTER->READ
    IMPORTING
       DATA = OUTSTRING.
  CATCH CX_SY_CONVERSION_CODEPAGE.     "#EC NO_HANDLER
*  -- Should ignore errors in code conversions
  CATCH CX_SY_CODEPAGE_CONVERTER_INIT. "#EC NO_HANDLER
*  -- Should ignore errors in code conversions
  CATCH CX_PARAMETER_INVALID_TYPE.     "#EC NO_HANDLER
  CATCH CX_PARAMETER_INVALID_RANGE.    "#EC NO_HANDLER
  ENDTRY.

*  -- Get rid of the <?xml encoding=??? > tag.
  DATA: DEFIDX TYPE SY-FDPOS,
        CLSTAGIDX TYPE SY-FDPOS.

  DEFIDX = -1. CLSTAGIDX = 10000.
  IF OUTSTRING CS '<?xml'.                   "#EC NOTEXT
    DEFIDX = SY-FDPOS.
    IF OUTSTRING CS '>'.
      CLSTAGIDX = SY-FDPOS + 1.
      IF CLSTAGIDX > DEFIDX.
        OUTSTRING = OUTSTRING+CLSTAGIDX.
      ENDIF.
    ENDIF.
  ENDIF.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_DRC_UTILS=>COUNT_OCC_PATH_STACK
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_PATH                        TYPE        STRING
* | [--->] IT_STACK                       TYPE        MY_XML_STACK_TAB
* | [<-()] RD_VALUE                       TYPE        INT4
* +--------------------------------------------------------------------------------------</SIGNATURE>
method COUNT_OCC_PATH_STACK.
  rd_value = 0.

  LOOP AT it_stack INTO DATA(ls_stack).
    IF ls_stack-path = id_path.
      rd_value = rd_value + 1.
    ENDIF.
  ENDLOOP.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_DRC_UTILS=>GET_ATTRIBUTE_BY_NAME
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_ATTR                        TYPE REF TO IF_IXML_NAMED_NODE_MAP
* | [--->] ID_NAME                        TYPE        STRING
* | [<-()] RD_VALUE                       TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_ATTRIBUTE_BY_NAME.
  DATA: ld_length TYPE int4.
  DATA: lo_node   TYPE REF TO if_ixml_node.
  DATA: ld_name   TYPE string.
  DATA: ld_value  TYPE string.

  CLEAR rd_value.

  IF io_attr IS NOT BOUND.
    RETURN.
  ENDIF.

  ld_length = io_attr->get_length( ).

  DO ld_length TIMES.
    lo_node = io_attr->get_item( index = sy-index ).
    IF lo_node IS NOT BOUND.
      EXIT.
    ENDIF.
    ld_name  = lo_node->get_name( ).
    ld_value = lo_node->get_value( ).

    IF id_name = ld_name.
      rd_value = ld_value.
      RETURN.
    ENDIF.
  ENDDO.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_DRC_UTILS=>GET_CONCAT_ATTRIBUTES
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_ATTR                        TYPE REF TO IF_IXML_NAMED_NODE_MAP
* | [<-()] RD_TEXT                        TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_CONCAT_ATTRIBUTES.
  DATA: ld_length TYPE int4.
  DATA: lo_node   TYPE REF TO if_ixml_node.
  DATA: ld_name   TYPE string.
  DATA: ld_value  TYPE string.
  DATA: ld_line   TYPE string.
  DATA: lt_line   TYPE STANDARD TABLE OF string.

  IF io_attr IS NOT BOUND.
    RETURN.
  ENDIF.

  ld_length = io_attr->get_length( ).

  DO ld_length TIMES.
    lo_node  = io_attr->get_item( index = sy-index ).
    IF lo_node IS NOT BOUND.
      EXIT.
    ENDIF.
    ld_name  = lo_node->get_name( ).
    ld_value = lo_node->get_value( ).
    ld_line  = |{ ld_name }={ ld_value }|.
    APPEND ld_line TO lt_line.
  ENDDO.

  CONCATENATE LINES OF lt_line INTO rd_text SEPARATED BY ','.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_DRC_UTILS=>GET_EVENT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_EDOCUMENTFILE               TYPE        EDOCUMENTFILE
* | [<---] ES_DATA                        TYPE        MY_RETENVEVENTO
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_EVENT.
  DATA: ld_string_xml     TYPE string.
  DATA: ld_xml_inf_evento TYPE string.

  CLEAR es_data.

  IF is_edocumentfile IS INITIAL.
    RETURN.
  ENDIF.

  convert_xstring_to_string(
    EXPORTING
      inxstring = is_edocumentfile-file_raw
    RECEIVING
      outstring = ld_string_xml
  ).

  IF ld_string_xml = ''.
    RETURN.
  ENDIF.

  CLEAR es_data.
  get_xmltag_content( EXPORTING id_begin_tag = '<idLote>'   id_end_tag = '</idLote>'   id_xml = ld_string_xml IMPORTING ed_content = es_data-idlote ).
  get_xmltag_content( EXPORTING id_begin_tag = '<tpAmb>'    id_end_tag = '</tpAmb>'    id_xml = ld_string_xml IMPORTING ed_content = es_data-tpamb ).
  get_xmltag_content( EXPORTING id_begin_tag = '<verAplic>' id_end_tag = '</verAplic>' id_xml = ld_string_xml IMPORTING ed_content = es_data-veraplic ).
  get_xmltag_content( EXPORTING id_begin_tag = '<cOrgao>'   id_end_tag = '</cOrgao>'   id_xml = ld_string_xml IMPORTING ed_content = es_data-corgao ).
  get_xmltag_content( EXPORTING id_begin_tag = '<cStat>'    id_end_tag = '</cStat>'    id_xml = ld_string_xml IMPORTING ed_content = es_data-cstat ).
  get_xmltag_content( EXPORTING id_begin_tag = '<xMotivo>'  id_end_tag = '</xMotivo>'  id_xml = ld_string_xml IMPORTING ed_content = es_data-xmotivo ).

  CLEAR ld_xml_inf_evento.
  get_xmltag_content2(
    EXPORTING
      id_path    = '#document>nfeRecepcaoEventoNFResult>retEnvEvento>retEvento>infEvento'
      id_index   = 1
      id_xml     = ld_string_xml
    IMPORTING
      ed_content = ld_xml_inf_evento
  ).

  IF ld_xml_inf_evento <> ''.
    get_xmltag_content( EXPORTING id_begin_tag = '<tpAmb>'       id_end_tag = '</tpAmb>'       id_xml = ld_xml_inf_evento IMPORTING ed_content = es_data-retevento-infevento-tpamb ).
    get_xmltag_content( EXPORTING id_begin_tag = '<verAplic>'    id_end_tag = '</verAplic>'    id_xml = ld_xml_inf_evento IMPORTING ed_content = es_data-retevento-infevento-veraplic ).
    get_xmltag_content( EXPORTING id_begin_tag = '<cOrgao>'      id_end_tag = '</cOrgao>'      id_xml = ld_xml_inf_evento IMPORTING ed_content = es_data-retevento-infevento-corgao ).
    get_xmltag_content( EXPORTING id_begin_tag = '<cStat>'       id_end_tag = '</cStat>'       id_xml = ld_xml_inf_evento IMPORTING ed_content = es_data-retevento-infevento-cstat ).
    get_xmltag_content( EXPORTING id_begin_tag = '<xMotivo>'     id_end_tag = '</xMotivo>'     id_xml = ld_xml_inf_evento IMPORTING ed_content = es_data-retevento-infevento-xmotivo ).
    get_xmltag_content( EXPORTING id_begin_tag = '<chNFe>'       id_end_tag = '</chNFe>'       id_xml = ld_xml_inf_evento IMPORTING ed_content = es_data-retevento-infevento-chnfe ).
    get_xmltag_content( EXPORTING id_begin_tag = '<tpEvento>'    id_end_tag = '</tpEvento>'    id_xml = ld_xml_inf_evento IMPORTING ed_content = es_data-retevento-infevento-tpevento ).
    get_xmltag_content( EXPORTING id_begin_tag = '<xEvento>'     id_end_tag = '</xEvento>'     id_xml = ld_xml_inf_evento IMPORTING ed_content = es_data-retevento-infevento-xevento ).
    get_xmltag_content( EXPORTING id_begin_tag = '<nSeqEvento>'  id_end_tag = '</nSeqEvento>'  id_xml = ld_xml_inf_evento IMPORTING ed_content = es_data-retevento-infevento-nseqevento ).
    get_xmltag_content( EXPORTING id_begin_tag = '<CNPJDest>'    id_end_tag = '</CNPJDest>'    id_xml = ld_xml_inf_evento IMPORTING ed_content = es_data-retevento-infevento-cnpjdest ).
    get_xmltag_content( EXPORTING id_begin_tag = '<dhRegEvento>' id_end_tag = '</dhRegEvento>' id_xml = ld_xml_inf_evento IMPORTING ed_content = es_data-retevento-infevento-dhregevento ).
    get_xmltag_content( EXPORTING id_begin_tag = '<nProt>'       id_end_tag = '</nProt>'       id_xml = ld_xml_inf_evento IMPORTING ed_content = es_data-retevento-infevento-nprot ).

    parse_datetime(
      EXPORTING
        id_datetime        = es_data-retevento-infevento-dhregevento
      IMPORTING
        ed_datetime_string = es_data-retevento-infevento-dhregevento
    ).
  ENDIF.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_DRC_UTILS=>GET_EVENTS
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_GUID                        TYPE        EDOC_FILE_GUID
* | [<---] ET_DATA                        TYPE        MY_RETENVEVENTO_TAB
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_EVENTS.
  DATA: lt_file TYPE STANDARD TABLE OF edocumentfile.
  DATA: ls_file TYPE edocumentfile.
  DATA: ls_data LIKE LINE OF et_data.

  CLEAR et_data.

  SELECT *
    INTO TABLE lt_file
    FROM edocumentfile
   WHERE edoc_guid = id_guid
     AND file_type = 'RECEVT_XML'
    ORDER BY create_date DESCENDING
             create_time DESCENDING.

  LOOP AT lt_file INTO ls_file.
    get_event(
      EXPORTING
        is_edocumentfile = ls_file
      IMPORTING
        es_data          = ls_data
    ).

    APPEND ls_data TO et_data.
  ENDLOOP.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_DRC_UTILS=>GET_XMLTAG_CONTENT
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_BEGIN_TAG                   TYPE        ANY
* | [--->] ID_END_TAG                     TYPE        ANY
* | [--->] ID_XML                         TYPE        ANY
* | [<---] ED_CONTENT                     TYPE        ANY
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_XMLTAG_CONTENT.
  DATA: ld_index1 TYPE int4.
  DATA: ld_index2 TYPE int4.
  DATA: ld_size   TYPE int4.

  CLEAR ld_index1.
  CLEAR ld_index2.
  CLEAR ed_content.

  " posição do tag de abertura
  SEARCH id_xml FOR id_begin_tag.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.
  ld_index1 = sy-fdpos.

  " posição do tag de fechamento
  SEARCH id_xml FOR id_end_tag.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.
  ld_index2 = sy-fdpos.

  " pulando o tamanho do tag de abertura para
  " descobrir o início do conteúdo
  ld_index1 = ld_index1 + strlen( id_begin_tag ).

  " calculando o tamanho do conteúdo
  ld_size = ld_index2 - ld_index1.

  " pegando somente o conteúdo do tag
  ed_content = id_xml+ld_index1(ld_size).
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_DRC_UTILS=>GET_XMLTAG_CONTENT2
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_PATH                        TYPE        STRING
* | [--->] ID_INDEX                       TYPE        INT4
* | [--->] ID_XML                         TYPE        STRING
* | [<---] ED_CONTENT                     TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_XMLTAG_CONTENT2.
  DATA: lo_parent          TYPE REF TO if_ixml_node.
  DATA: lo_node            TYPE REF TO if_ixml_node.
  "DATA: lo_node2           TYPE REF TO if_ixml_node.
  DATA: lo_attr            TYPE REF TO if_ixml_named_node_map.
  DATA: ld_parent_name     TYPE string.
  DATA: ld_name            TYPE string.
  DATA: ld_value           TYPE string.
  DATA: ld_type            TYPE int4.
  DATA: ld_type_name       TYPE string.
  DATA: ld_attr_size       TYPE int4.
  DATA: ld_attr_value      TYPE string.
  DATA: lo_iterator        TYPE REF TO if_ixml_node_iterator.
  DATA: lo_children        TYPE REF TO if_ixml_node_list.
  "DATA: ld_name2           TYPE string.
  "DATA: ld_value2          TYPE string.
  DATA: ld_children_length TYPE int4.
  DATA: lo_xml             TYPE REF TO cl_xml_document.
  DATA: ld_text            TYPE string.

  DATA: lt_stack           TYPE my_xml_stack_tab.
  DATA: ls_stack           TYPE my_xml_stack.
  DATA: ld_level           TYPE int4.
  DATA: ld_times           TYPE int4.

  CREATE OBJECT lo_xml.
  lo_xml->parse_string( stream = CONV string( id_xml ) ).
  lo_node = lo_xml->get_first_node( ).

  DO.
    IF lo_node IS NOT BOUND.
      EXIT.
    ENDIF.

    lo_parent   = lo_node->get_parent( ).
    ld_name     = lo_node->get_name( ).
    ld_value    = lo_node->get_value( ).
    ld_type     = lo_node->get_type( ).
    lo_attr     = lo_node->get_attributes( ).
    lo_children = lo_node->get_children( ).

    ld_parent_name = lo_parent->get_name( ).

    ld_type_name = ''.
    CASE ld_type.
    WHEN if_ixml_node=>co_node_text.
      ld_type_name = 'text'.
    WHEN if_ixml_node=>co_node_element.
      ld_type_name = 'element'.
    ENDCASE.

    ld_attr_size = 0.
    IF lo_attr IS BOUND.
      ld_attr_size = lo_attr->get_length( ).
    ENDIF.

    ld_children_length = 0.
    IF lo_children IS BOUND.
      ld_children_length = lo_children->get_length( ).
    ENDIF.

    ld_value = ''.
    IF ld_children_length = 1 AND lo_node->get_first_child( )->get_type( ) = if_ixml_node=>co_node_text
      AND lo_node->get_first_child( )->get_children( )->get_length( ) = 0.
      ld_value = lo_node->get_first_child( )->get_value( ).
    ENDIF.

    " stack
    CLEAR ls_stack.
    ls_stack-nodeindex      = sy-index.
    ls_stack-path           = build_path( io_node = lo_node ).
    ls_stack-tagname        = ld_name.
    ls_stack-value          = ld_value.
    ls_stack-level          = ld_level.
    ls_stack-attributes     = get_concat_attributes( io_attr = lo_attr ).
    ls_stack-parent_tagname = ld_parent_name.
    APPEND ls_stack TO lt_stack.

    " verificando se chegou no tag com os atributos procurados
    IF ls_stack-path = id_path.
      ld_times = count_occ_path_stack( id_path = id_path it_stack = lt_stack ).
      IF ld_times = id_index.
        CALL METHOD get_xml_string_by_node
          EXPORTING
            io_node   = lo_node
          IMPORTING
            ed_string = ed_content.
        RETURN.
      ENDIF.
    ENDIF.

    " verificando se tem filhos
    IF ld_children_length > 0.
      " entrando no primeiro tag filho
      lo_iterator = lo_children->create_iterator( ).
      IF lo_iterator IS BOUND.
        lo_node = lo_iterator->get_next( ).
        ld_level = ld_level + 1.
      ENDIF.
    ELSE.
      IF ld_type = if_ixml_node=>co_node_text.
        lo_node = lo_node->get_next( ).
        IF lo_node IS NOT BOUND.
          lo_node = lo_parent->get_next( ).
          ld_level = ld_level - 1.
        ENDIF.
      ELSE.
        lo_node = lo_node->get_next( ).
      ENDIF.
    ENDIF.
  ENDDO.
ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_DRC_UTILS=>GET_XMLTAG_CONTENT3
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_OPEN_TAG                    TYPE        ANY
* | [--->] ID_CLOSE_TAG                   TYPE        ANY
* | [--->] ID_XML                         TYPE        ANY
* | [<---] ED_CONTENT                     TYPE        ANY
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_XMLTAG_CONTENT3.
  DATA: ld_index1 TYPE int4.
  DATA: ld_index2 TYPE int4.
  DATA: ld_size   TYPE int4.

  CLEAR ld_index1.
  CLEAR ld_index2.
  CLEAR ed_content.

*  id_open_tag  = |<det nItem="1">|.
*  id_close_tag = '</det>'.
*  id_xml       = |<root>| &&
*                 |<cliente><id>1</id><nome>Teste</nome></cliente>| &&
*                 |<det nItem="1"><cod>111</cod><desc>Teclado</desc></det>| &&
*                 |<det nItem="2"><cod>222</cod><desc>Teclado</desc></det>| &&
*                 |<det nItem="3"><cod>444</cod><desc>Teclado</desc></det>| &&
*                 |<totais>| &&
*                 |<ipi>123.23</ipi>| &&
*                 |</totais>| &&
*                 |</root>|.

  " posição do tag de abertura
  SEARCH id_xml FOR id_open_tag.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.
  ld_index1 = sy-fdpos.

  " removendo conteúdo antes do tag de abertura
  id_xml = id_xml+ld_index1.

  " posição do tag de fechamento
  SEARCH id_xml FOR id_close_tag.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.
  ld_index2 = sy-fdpos.

  "
  ld_index2 = ld_index2 + strlen( id_close_tag ).

  " removendo conteúdo após o tag de fechamento
  ed_content = id_xml(ld_index2).
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_DRC_UTILS=>GET_XML_CONTENT
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_ACCESS_KEY                  TYPE        ANY
* | [--->] ID_TYPE                        TYPE        CHAR3
* | [<---] ED_CONTENT                     TYPE        STRING
* | [<---] ED_XCONTENT                    TYPE        XSTRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_XML_CONTENT.
  DATA: ls_result       TYPE edoc_br_entities.
  DATA: lo_xml_retriver TYPE REF TO cl_edoc_br_entity_retrieve.

  CLEAR ed_content.
  CLEAR ed_xcontent.

  lo_xml_retriver = new cl_edoc_br_entity_retrieve( ).

  CLEAR ls_result.
  lo_xml_retriver->if_edoc_br_entity_retrieve~retrieve_all_entities_by_ackey(
    EXPORTING
      iv_access_key = id_access_key
    RECEIVING
      result        = ls_result
  ).

  IF id_type = 'CTE'.
    " se a classe do CTE não tiver o método get_xml, crie um método Z
    " dentro da classe standard CL_EDOC_BR_CTE_ENTITY para obter o XML
    ls_result-cte->get_xml(
      RECEIVING
        rv_xml = ed_xcontent
    ).
  ELSE.
    ls_result-nfe->get_xml(
      RECEIVING
        rv_xml = ed_xcontent
    ).
  ENDIF.

  zcl_drc_utils=>convert_xstring_to_string(
    EXPORTING
      inxstring = ed_xcontent
    RECEIVING
      outstring = ed_content
  ).
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_DRC_UTILS=>GET_XML_STRING_BY_DOCUMENT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_XML_DOC                     TYPE REF TO IF_IXML_DOCUMENT
* | [<---] ED_STRING                      TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_XML_STRING_BY_DOCUMENT.
  DATA: lo_ixml         TYPE REF TO if_ixml,
      lo_streamfactory  TYPE REF TO if_ixml_stream_factory,
      lo_ostream        TYPE REF TO if_ixml_ostream,
      lo_renderer       TYPE REF TO if_ixml_renderer,
      lv_xml_string     TYPE string,
      lv_check          TYPE i.

  lo_ixml = cl_ixml=>create( ).
  lo_streamfactory = lo_ixml->create_stream_factory( ).

  " Connect string variable to the output stream
  lo_ostream = lo_streamfactory->create_ostream_cstring( string = lv_xml_string ).

  " Optional: Enable pretty print (indentation)
  lo_ostream->set_pretty_print( abap_true ).

  " Create the renderer and link the document and output stream
  lo_renderer = lo_ixml->create_renderer(
    ostream  = lo_ostream
    document = io_xml_doc
  ).

  " Render the document
  lv_check = lo_renderer->render( ).

  ed_string = lv_xml_string.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_DRC_UTILS=>GET_XML_STRING_BY_NODE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_NODE                        TYPE REF TO IF_IXML_NODE
* | [<---] ED_STRING                      TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_XML_STRING_BY_NODE.
  DATA: lo_ixml      TYPE REF TO if_ixml,
        lo_temp_doc  TYPE REF TO if_ixml_document,
        lo_temp_node TYPE REF TO if_ixml_node,
        lo_ostream   TYPE REF TO if_ixml_ostream,
        lo_renderer  TYPE REF TO if_ixml_renderer,
        lv_xstring   TYPE xstring.

  CLEAR ed_string.
  IF io_node IS INITIAL.
    RETURN.
  ENDIF.

  lo_ixml = cl_ixml=>create( ).

  " 1. Criar um documento temporário vazio
  lo_temp_doc = lo_ixml->create_document( ).

  " 2. Clonar o nó atual para dentro deste novo documento
  " O parâmetro 'deep = abap_true' garante que os filhos e valores venham junto
  lo_temp_node = io_node->clone( ).
  lo_temp_doc->append_child( lo_temp_node ).

  " 3. Criar o stream usando XSTRING (que funcionou para você anteriormente)
  lo_ostream = lo_ixml->create_stream_factory( )->create_ostream_xstring( string = lv_xstring ).

  " Opcional: Se não quiser o cabeçalho <?xml...?> no retorno, use:
  " lo_ostream->set_declaration( abap_false ).

  lo_ostream->set_pretty_print( abap_true ).

  " 4. Renderizar o documento temporário (que agora só contém o seu nó)
  lo_renderer = lo_ixml->create_renderer( ostream  = lo_ostream
                                          document = lo_temp_doc ).
  lo_renderer->render( ).

  " 5. Converter de binário para texto
  IF lv_xstring IS NOT INITIAL.
    DATA(lo_conv) = cl_abap_conv_in_ce=>create( input = lv_xstring ).
    lo_conv->read( IMPORTING data = ed_string ).
  ENDIF.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_DRC_UTILS=>LOAD_NFITEM
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_NFKEY                       TYPE        MT_NFKEY
* | [<---] ET_NFITEM                      TYPE        ZXNFE_INNFEIT_TAB
* +--------------------------------------------------------------------------------------</SIGNATURE>
method LOAD_NFITEM.
  DATA: ld_nfkey       LIKE LINE OF it_nfkey.
  DATA: ld_xml_string  TYPE string.
  DATA: ld_xml_xstring TYPE xstring.
  DATA: ld_xml_item    TYPE string.
  DATA: ls_nfitem      LIKE LINE OF et_nfitem.
  DATA: ld_edoc_guid   TYPE edobrincoming-edoc_guid.

  SORT it_nfkey BY table_line ASCENDING.
  DELETE ADJACENT DUPLICATES FROM it_nfkey COMPARING ALL FIELDS.

  IF lines( it_nfkey ) <= 0.
    RETURN.
  ENDIF.

  LOOP AT it_nfkey INTO ld_nfkey.
    zcl_drc_utils=>get_xml_content(
      EXPORTING
        id_access_key = ld_nfkey
        id_type       = 'NFE'
      IMPORTING
        ed_content    = ld_xml_string
        ed_xcontent   = ld_xml_xstring
    ).

    DO.
      CLEAR ld_xml_item.
*      zcl_drc_utils=>get_xmltag_content2(
*        EXPORTING
*          id_path       = '#document>nfeProc>NFe>infNFe>det'
*          id_index      = sy-index
*          id_xml        = ld_xml_string
*        IMPORTING
*          ed_content    = ld_xml_item
*      ).
      zcl_drc_utils=>get_xmltag_content3(
        EXPORTING
          id_open_tag  = |<det nItem="{ sy-index }">|
          id_close_tag = '</det>'
          id_xml       = ld_xml_string
        IMPORTING
          ed_content   = ld_xml_item
      ).

      IF ld_xml_item = ''.
        EXIT.
      ENDIF.

      SELECT SINGLE edoc_guid
        INTO ld_edoc_guid
        FROM edobrincoming
       WHERE accesskey = ld_nfkey.

      CLEAR ls_nfitem.
      ls_nfitem-guid_header = ld_edoc_guid.
      ls_nfitem-nitem       = sy-index.

      zcl_drc_utils=>get_xmltag_content(
        EXPORTING
          id_begin_tag = '<cProd>'
          id_end_tag   = '</cProd>'
          id_xml       = ld_xml_item
        IMPORTING
          ed_content   = ls_nfitem-cprod
      ).

      zcl_drc_utils=>get_xmltag_content(
        EXPORTING
          id_begin_tag = '<cEAN>'
          id_end_tag   = '</cEAN>'
          id_xml       = ld_xml_item
        IMPORTING
          ed_content   = ls_nfitem-cean
      ).

      zcl_drc_utils=>get_xmltag_content(
        EXPORTING
          id_begin_tag = '<xProd>'
          id_end_tag   = '</xProd>'
          id_xml       = ld_xml_item
        IMPORTING
          ed_content   = ls_nfitem-xProd
      ).

      zcl_drc_utils=>get_xmltag_content(
        EXPORTING
          id_begin_tag = '<NCM>'
          id_end_tag   = '</NCM>'
          id_xml       = ld_xml_item
        IMPORTING
          ed_content   = ls_nfitem-NCM
      ).

*      zcl_drc_utils=>get_xmltag_content(
*        EXPORTING
*          id_begin_tag = '<CEST>'
*          id_end_tag   = '</CEST>'
*          id_xml       = ld_xml_item
*        IMPORTING
*          ed_content   = ls_nfitem-CEST
*      ).

      zcl_drc_utils=>get_xmltag_content(
        EXPORTING
          id_begin_tag = '<CFOP>'
          id_end_tag   = '</CFOP>'
          id_xml       = ld_xml_item
        IMPORTING
          ed_content   = ls_nfitem-CFOP
      ).

      zcl_drc_utils=>get_xmltag_content(
        EXPORTING
          id_begin_tag = '<uCom>'
          id_end_tag   = '</uCom>'
          id_xml       = ld_xml_item
        IMPORTING
          ed_content   = ls_nfitem-uCom
      ).

      zcl_drc_utils=>get_xmltag_content(
        EXPORTING
          id_begin_tag = '<qCom>'
          id_end_tag   = '</qCom>'
          id_xml       = ld_xml_item
        IMPORTING
          ed_content   = ls_nfitem-qCom
      ).

*      zcl_drc_utils=>get_xmltag_content(
*        EXPORTING
*          id_begin_tag = '<vUnCom>'
*          id_end_tag   = '</vUnCom>'
*          id_xml       = ld_xml_item
*        IMPORTING
*          ed_content   = ls_nfitem-vUnCom
*      ).

      zcl_drc_utils=>get_xmltag_content(
        EXPORTING
          id_begin_tag = '<vProd>'
          id_end_tag   = '</vProd>'
          id_xml       = ld_xml_item
        IMPORTING
          ed_content   = ls_nfitem-vProd
      ).

*      zcl_drc_utils=>get_xmltag_content(
*        EXPORTING
*          id_begin_tag = '<cEANTrib>'
*          id_end_tag   = '</cEANTrib>'
*          id_xml       = ld_xml_item
*        IMPORTING
*          ed_content   = ls_nfitem-cEANTrib
*      ).
*
*      zcl_drc_utils=>get_xmltag_content(
*        EXPORTING
*          id_begin_tag = '<uTrib>'
*          id_end_tag   = '</uTrib>'
*          id_xml       = ld_xml_item
*        IMPORTING
*          ed_content   = ls_nfitem-uTrib
*      ).
*
*      zcl_drc_utils=>get_xmltag_content(
*        EXPORTING
*          id_begin_tag = '<qTrib>'
*          id_end_tag   = '</qTrib>'
*          id_xml       = ld_xml_item
*        IMPORTING
*          ed_content   = ls_nfitem-qTrib
*      ).

*      zcl_drc_utils=>get_xmltag_content(
*        EXPORTING
*          id_begin_tag = '<vUnTrib>'
*          id_end_tag   = '</vUnTrib>'
*          id_xml       = ld_xml_item
*        IMPORTING
*          ed_content   = ls_nfitem-vUnTrib
*      ).
*
*      zcl_drc_utils=>get_xmltag_content(
*        EXPORTING
*          id_begin_tag = '<indTot>'
*          id_end_tag   = '</indTot>'
*          id_xml       = ld_xml_item
*        IMPORTING
*          ed_content   = ls_nfitem-indTot
*      ).

      zcl_drc_utils=>get_xmltag_content(
        EXPORTING
          id_begin_tag = '<xPed>'
          id_end_tag   = '</xPed>'
          id_xml       = ld_xml_item
        IMPORTING
          ed_content   = ls_nfitem-ponumber
      ).

      zcl_drc_utils=>get_xmltag_content(
        EXPORTING
          id_begin_tag = '<nItemPed>'
          id_end_tag   = '</nItemPed>'
          id_xml       = ld_xml_item
        IMPORTING
          ed_content   = ls_nfitem-poitem
      ).

      APPEND ls_nfitem TO et_nfitem.
    ENDDO.
  ENDLOOP.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_DRC_UTILS=>PARSE_DATETIME
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_DATETIME                    TYPE        ANY
* | [<---] ED_DATETIME_STRING             TYPE        ANY
* | [<---] ED_TIMESTAMP                   TYPE        TIMESTAMPL
* +--------------------------------------------------------------------------------------</SIGNATURE>
method PARSE_DATETIME.
  DATA: ld_string TYPE string.

  CLEAR ed_timestamp.
  CLEAR ed_datetime_string.

  IF id_datetime = ''.
    RETURN.
  ENDIF.

  IF strlen( id_datetime ) < 19.
    RETURN.
  ENDIF.

  ld_string = id_datetime(19).
  REPLACE ALL OCCURRENCES OF REGEX '[^0-9]' IN ld_string WITH ''.
  IF ld_string = ''.
    RETURN.
  ENDIF.

  ed_datetime_string = ld_string.

  ed_timestamp = ed_datetime_string.
endmethod.
ENDCLASS.
