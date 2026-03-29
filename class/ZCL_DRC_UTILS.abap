class ZCL_DRC_UTILS definition
  public
  create public .

public section.

  class-methods CONVERT_XSTRING_TO_STRING
    importing
      value(INXSTRING) type XSTRING
    returning
      value(OUTSTRING) type STRING .
  class-methods GET_XMLTAG_CONTENT
    importing
      value(ID_BEGIN_TAG) type ANY
      value(ID_END_TAG) type ANY
      value(ID_XML) type ANY
    exporting
      value(ED_CONTENT) type ANY .
  class-methods GET_XMLTAG_CONTENT2
    importing
      value(ID_TAG) type STRING
      value(ID_ATTR_NAME) type STRING
      value(ID_ATTR_VALUE) type STRING
      value(ID_XML) type STRING
    exporting
      value(ED_CONTENT) type STRING .
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
protected section.
private section.
ENDCLASS.



CLASS ZCL_DRC_UTILS IMPLEMENTATION.


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
* | [--->] ID_TAG                         TYPE        STRING
* | [--->] ID_ATTR_NAME                   TYPE        STRING
* | [--->] ID_ATTR_VALUE                  TYPE        STRING
* | [--->] ID_XML                         TYPE        STRING
* | [<---] ED_CONTENT                     TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_XMLTAG_CONTENT2.
  DATA: lo_node     TYPE REF TO if_ixml_node.
  DATA: lo_node2    TYPE REF TO if_ixml_node.
  DATA: lo_attr     TYPE REF TO if_ixml_named_node_map.
  DATA: ld_name     TYPE string.
  DATA: ld_value    TYPE string.
  DATA: lo_iterator TYPE REF TO if_ixml_node_iterator.
  DATA: lo_children TYPE REF TO if_ixml_node_list.
  DATA: ld_name2    TYPE string.
  DATA: ld_value2   TYPE string.
  DATA: lo_xml      TYPE REF TO cl_xml_document.
  "DATA: lo_xml2     TYPE REF TO if_ixml_document.

  CREATE OBJECT lo_xml.

  lo_xml->parse_string( stream = CONV string( id_xml ) ).
  lo_node = lo_xml->get_first_node( ).
  DO.
    IF lo_node IS NOT BOUND.
      EXIT.
    ENDIF.

    ld_name  = lo_node->get_name( ).
    ld_value = lo_node->get_value( ).
    lo_attr  = lo_node->get_attributes( ).

    lo_node2 = lo_attr->get_named_item( name = id_attr_name ).
    IF lo_node2 IS BOUND.
      ld_name2  = lo_node2->get_name( ).
      ld_value2 = lo_node2->get_value( ).

      IF ld_name = id_tag AND ld_name2 = id_attr_name AND ld_value2 = id_attr_value.
        "lo_xml2 = lo_node->get_owner_document( ).

        get_xml_string_by_node(
          EXPORTING
            io_node   = lo_node
          IMPORTING
            ed_string = ed_content
        ).
        RETURN.
      ENDIF.
    ENDIF.

    lo_children = lo_node->get_children( ).
    lo_iterator = lo_children->create_iterator( ).
    IF lo_iterator IS NOT BOUND.
      RETURN.
    ENDIF.

    lo_node = lo_node->get_next( ).
    IF lo_node IS NOT BOUND.
      lo_node = lo_iterator->get_next( ).
    ENDIF.
  ENDDO.
ENDMETHOD.


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
ENDCLASS.
