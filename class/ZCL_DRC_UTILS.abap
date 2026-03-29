class ZCL_DRC_UTILS definition
  public
  create public .

public section.

  class-methods GET_XMLTAG_CONTENT
    importing
      value(ID_BEGIN_TAG) type ANY
      value(ID_END_TAG) type ANY
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
  class-methods CONVERT_XSTRING_TO_STRING
    importing
      value(INXSTRING) type XSTRING
    returning
      value(OUTSTRING) type STRING .
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
ENDCLASS.
