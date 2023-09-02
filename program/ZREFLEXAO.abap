*
* Ultima atualização 07/08/2023 v0.1
* Classes de refrexão encontradas na SE24 (CL_ABAP_*DESCR)
* CL_ABAP_CLASSDESCR
* CL_ABAP_COMPLEXDESCR
* CL_ABAP_DATADESCR
* CL_ABAP_ELEMDESCR
* CL_ABAP_ENUMDESCR
* CL_ABAP_INTFDESCR
* CL_ABAP_OBJECTDESCR
* CL_ABAP_REFDESCR
* CL_ABAP_STRUCTDESCR
* CL_ABAP_TABLEDESCR
* CL_ABAP_TYPEDESCR
*
REPORT ZREFLEXAO NO STANDARD PAGE HEADING.

SELECTION-SCREEN BEGIN OF BLOCK main WITH FRAME.
  PARAMETERS: p_name TYPE string OBLIGATORY.

  PARAMETERS: p_eleme RADIOBUTTON GROUP g1 DEFAULT 'X'. " Elemento de dados
  PARAMETERS: p_struc RADIOBUTTON GROUP g1. " Estrutura
  PARAMETERS: p_table RADIOBUTTON GROUP g1. " Tabela interna
  PARAMETERS: p_class RADIOBUTTON GROUP g1. " Classe
  PARAMETERS: p_inter RADIOBUTTON GROUP g1. " Interfaces
SELECTION-SCREEN END OF BLOCK main.

START-OF-SELECTION.
  DATA: lr_data       TYPE REF TO data.
  DATA: lo_type       TYPE REF TO cl_abap_typedescr.
  data: lo_table      TYPE REF TO cl_abap_tabledescr.
  DATA: lo_struc      TYPE REF TO cl_abap_structdescr.
  DATA: lt_comp       TYPE abap_compdescr_tab.
  DATA: ls_comp       LIKE LINE OF lt_comp.
  DATA: lo_object     TYPE REF TO cl_abap_objectdescr.
  DATA: ls_methods    TYPE abap_methdescr.
  DATA: ls_attributes TYPE abap_attrdescr.

  FIELD-SYMBOLS: <ld_data> TYPE any.

  BREAK-POINT.

  IF NOT ( p_class = 'X' OR p_inter = 'X' ).
    CREATE DATA lr_data TYPE (p_name).
    ASSIGN lr_data->* TO <ld_data>.
  ENDIF.

  IF p_eleme = 'X'.
     lo_type = cl_abap_typedescr=>describe_by_data( <ld_data> ).
     WRITE: /(15)'absolute_name: ', lo_type->absolute_name.
     WRITE: /(15)'kind: ', lo_type->kind.
     WRITE: /(15)'decimals: ', lo_type->decimals.
     WRITE: /(15)'length: ', lo_type->length.
     WRITE: /(15)'type_kind: ', lo_type->type_kind.
  ENDIF.

  IF p_struc = 'X'.
    lo_struc ?= cl_abap_structdescr=>describe_by_data( p_data = <ld_data> ).
    lt_comp  = lo_struc->components[].

    WRITE: /(15)'absolute_name: ', lo_struc->absolute_name.
    WRITE: /(15)'kind: ', lo_struc->kind.
    WRITE: /(15)'decimals: ', lo_struc->decimals.
    WRITE: /(15)'length: ', lo_struc->length.
    WRITE: /(15)'type_kind: ', lo_struc->type_kind.
    SKIP.

    WRITE: 'Campos'.
    WRITE sy-uline.
    NEW-LINE.
    LOOP AT lt_comp INTO ls_comp.
      WRITE: 'name: ', ls_comp-name.
      WRITE: 'type_kind: ', ls_comp-type_kind.
      WRITE: 'length: ', ls_comp-length.
      WRITE: 'decimals: ', ls_comp-decimals.
      NEW-LINE.
    ENDLOOP.
  ENDIF.

  IF p_table = 'X'.
    lo_table ?= cl_abap_tabledescr=>describe_by_data( <ld_data> ).
    lo_struc ?= lo_table->get_table_line_type( ).
    lt_comp   = lo_struc->components[].

    WRITE: /(15)'absolute_name: ', lo_table->absolute_name.
    WRITE: /(15)'kind: ', lo_table->kind.
    WRITE: /(15)'decimals: ', lo_table->decimals.
    WRITE: /(15)'length: ', lo_table->length.
    WRITE: /(15)'type_kind: ', lo_table->type_kind.
    SKIP.

    WRITE: 'Campos'.
    WRITE sy-uline.
    LOOP AT lt_comp INTO ls_comp.
      WRITE: 'name: ', ls_comp-name.
      WRITE: 'type_kind: ', ls_comp-type_kind.
      WRITE: 'length: ', ls_comp-length.
      WRITE: 'decimals: ', ls_comp-decimals.
      NEW-LINE.
    ENDLOOP.
  ENDIF.

  IF p_class = 'X'.
    lo_object ?= cl_abap_objectdescr=>describe_by_name( p_name ).

    WRITE: 'Métodos'.
    WRITE sy-uline.
    NEW-LINE.
    LOOP AT lo_object->methods INTO ls_methods.
      WRITE: / ls_methods-name.
    ENDLOOP.
    SKIP.

    WRITE: 'Atributos'.
    WRITE sy-uline.
    NEW-LINE.
    LOOP AT lo_object->attributes INTO ls_attributes.
      WRITE: / ls_attributes-name.
    ENDLOOP.
  ENDIF.

  IF p_inter = 'X'.
    lo_object ?= cl_abap_intfdescr=>describe_by_name( p_name ).

    WRITE: 'Métodos'.
    WRITE sy-uline.
    NEW-LINE.
    LOOP AT lo_object->methods INTO ls_methods.
      WRITE: / ls_methods-name.
    ENDLOOP.
    SKIP.

    WRITE: 'Atributos'.
    WRITE sy-uline.
    NEW-LINE.
    LOOP AT lo_object->attributes INTO ls_attributes.
      WRITE: / ls_attributes-name.
    ENDLOOP.
  ENDIF.

  BREAK-POINT.
