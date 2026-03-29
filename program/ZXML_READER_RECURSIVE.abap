REPORT ZXML_READER_RECURSIVE.

DATA: gd_xml_string TYPE string.

SELECTION-SCREEN BEGIN OF BLOCK main WITH FRAME.
  PARAMETERS p_file TYPE localfile.
SELECTION-SCREEN END OF BLOCK main.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CLEAR p_file.
  CALL FUNCTION 'F4_FILENAME'
    IMPORTING
      file_name = p_file.

START-OF-SELECTION.
  PERFORM load_xml.
  PERFORM read_xml.

FORM load_xml.
  TYPES: BEGIN OF ly_line
       , line(262143) TYPE c
       , END OF ly_line.

  DATA: ld_line TYPE ly_line.
  DATA: lt_line TYPE STANDARD TABLE OF ly_line.

  FIELD-SYMBOLS: <ld_line> TYPE ly_line.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                      = CONV string( p_file )
    TABLES
      data_tab                      = lt_line
   EXCEPTIONS
     FILE_OPEN_ERROR               = 1
     FILE_READ_ERROR               = 2
     NO_BATCH                      = 3
     GUI_REFUSE_FILETRANSFER       = 4
     INVALID_TYPE                  = 5
     NO_AUTHORITY                  = 6
     UNKNOWN_ERROR                 = 7
     BAD_DATA_FORMAT               = 8
     HEADER_NOT_ALLOWED            = 9
     SEPARATOR_NOT_ALLOWED         = 10
     HEADER_TOO_LONG               = 11
     UNKNOWN_DP_ERROR              = 12
     ACCESS_DENIED                 = 13
     DP_OUT_OF_MEMORY              = 14
     DISK_FULL                     = 15
     DP_TIMEOUT                    = 16
     OTHERS                        = 17.

  CONCATENATE LINES OF lt_line
         INTO gd_xml_string.
ENDFORM.
FORM read_xml.
  DATA: lo_parent          TYPE REF TO if_ixml_node.
  DATA: lo_node            TYPE REF TO if_ixml_node.
  DATA: lo_node2           TYPE REF TO if_ixml_node.
  DATA: lo_attr            TYPE REF TO if_ixml_named_node_map.
  DATA: ld_name            TYPE string.
  DATA: ld_value           TYPE string.
  DATA: ld_type            TYPE int4.
  DATA: ld_type_name       TYPE string.
  DATA: ld_attr_size       TYPE int4.
  DATA: lo_iterator        TYPE REF TO if_ixml_node_iterator.
  DATA: lo_children        TYPE REF TO if_ixml_node_list.
  DATA: ld_name2           TYPE string.
  DATA: ld_value2          TYPE string.
  DATA: ld_children_length TYPE int4.
  DATA: lo_xml             TYPE REF TO cl_xml_document.
  DATA: ld_text            TYPE string.

  CREATE OBJECT lo_xml.
  lo_xml->parse_string( stream = CONV string( gd_xml_string ) ).
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

    CASE ld_type.
    WHEN if_ixml_node=>co_node_text.
      ld_type_name = 'text'.
    WHEN if_ixml_node=>co_node_element.
      ld_type_name = 'element'.
    ENDCASE.

    IF ld_type = if_ixml_node=>co_node_element.
      ld_text = |{ ld_name }({ ld_type_name }) Atributos = { ld_attr_size }, Filhos { ld_children_length }|.
      WRITE ld_text.

      IF ld_value <> ''.
        WRITE |, Valor = { ld_value }|.
      ENDIF.

      NEW-LINE.
    ENDIF.

    " verificando se tem filhos
    IF ld_children_length > 0.
      " entrando no primeiro tag filho
      lo_iterator = lo_children->create_iterator( ).
      IF lo_iterator IS BOUND.
        lo_node = lo_iterator->get_next( ).
      ENDIF.
    ELSE.
      IF ld_type = if_ixml_node=>co_node_text.
        lo_node = lo_node->get_next( ).
        IF lo_node IS NOT BOUND.
          lo_node = lo_parent->get_next( ).
        ENDIF.
      ELSE.
        lo_node = lo_node->get_next( ).
      ENDIF.
    ENDIF.
  ENDDO.
ENDFORM.
