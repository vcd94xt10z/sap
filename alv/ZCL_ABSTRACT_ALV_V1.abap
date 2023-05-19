class ZCL_ABSTRACT_ALV_V1 definition
  public
  abstract
  create public .

*"* public components of class ZCL_ABSTRACT_ALV_V1
*"* do not include other source files here!!!
public section.

  data MT_FIELDCAT type LVC_T_FCAT .
  data MS_LAYOUT type LVC_S_LAYO .
  data MD_CONTAINER_NAME type SCRFNAME .
  data MO_CUSTOM_CONTAINER type ref to CL_GUI_CUSTOM_CONTAINER .
  data MO_GRID type ref to CL_GUI_ALV_GRID .
  data MT_DROPDOWN type LVC_T_DROP .
  data MD_TABLENAME type STRING .
  data MD_DISPLAYED type INT1 .
  data MT_DATA type ref to DATA .
  data MT_EXCLUDE_TOOLBAR type UI_FUNCTIONS .
  data MS_VARIANT type DISVARIANT .
  data MT_F4 type LVC_T_F4 .

  methods HANDLE_ENTER
  abstract
    for event DATA_CHANGED of CL_GUI_ALV_GRID
    importing
      !ER_DATA_CHANGED
      !E_ONF4
      !E_ONF4_BEFORE
      !E_ONF4_AFTER
      !E_UCOMM .
  methods HANDLE_DOUBLE_CLICK
  abstract
    for event DOUBLE_CLICK of CL_GUI_ALV_GRID
    importing
      !E_ROW
      !E_COLUMN
      !ES_ROW_NO .
  methods HANDLE_HOTSPOT_CLICK
  abstract
    for event HOTSPOT_CLICK of CL_GUI_ALV_GRID
    importing
      !E_ROW_ID
      !E_COLUMN_ID
      !ES_ROW_NO .
  methods HANDLE_DATA_CHANGED_FINISHED
  abstract
    for event DATA_CHANGED_FINISHED of CL_GUI_ALV_GRID
    importing
      !E_MODIFIED
      !ET_GOOD_CELLS .
  methods HANDLE_DATA_CHANGED
  abstract
    for event DATA_CHANGED of CL_GUI_ALV_GRID
    importing
      !ER_DATA_CHANGED
      !E_ONF4
      !E_ONF4_BEFORE
      !E_ONF4_AFTER
      !E_UCOMM .
  methods HANDLE_USER_COMMAND
    for event USER_COMMAND of CL_GUI_ALV_GRID
    importing
      !E_UCOMM .
  methods HANDLE_TOOLBAR
    for event TOOLBAR of CL_GUI_ALV_GRID
    importing
      !E_OBJECT
      !E_INTERACTIVE .
  methods HANDLE_MENU_BUTTON
    for event MENU_BUTTON of CL_GUI_ALV_GRID
    importing
      !E_OBJECT
      !E_UCOMM .
  methods HANDLE_F1
    for event ONF1 of CL_GUI_ALV_GRID
    importing
      !E_FIELDNAME
      !ES_ROW_NO
      !ER_EVENT_DATA .
  methods HANDLE_F4
    for event ONF4 of CL_GUI_ALV_GRID
    importing
      !E_FIELDNAME
      !E_FIELDVALUE
      !ES_ROW_NO
      !ER_EVENT_DATA
      !ET_BAD_CELLS
      !E_DISPLAY .
  methods CLEAN .
  methods REFRESH .
  methods FILL_FIELDCAT .
  methods FILL_DROPDOWN .
  methods FILL_LAYOUT .
  methods CALLME_IN_PBO
    raising
      ZCX_EXCEPTION .
  methods CONSTRUCTOR
    importing
      !ID_CONTAINER_NAME type SCRFNAME
      !ID_TABLENAME type STRING optional .
  methods CALL_PAI_PARENT_SCREEN
    importing
      !ID_FCODE type SYUCOMM default 'REFRESH' .
  methods GET_SELECTED_ROW
    returning
      value(RD_INDEX) type INT4 .
  methods SET_SELECTED_ROW
    importing
      !ID_INDEX type INT4 .
  methods SET_SELECTED_CELL
    importing
      value(ID_COL) type INT4
      value(ID_ROW) type INT4
      value(ID_FIELDNAME) type LVC_FNAME .
  methods GET_SELECTED_STRUCTURE
    exporting
      value(ES_STRUCTURE) type ANY .
  methods GET_SELECTED_TABLE
    exporting
      value(ET_TABLE) type STANDARD TABLE .
  methods GET_SELECTED_ROWS
    changing
      value(CT_INDEX) type ANY TABLE .
  methods REMOVE_SELECTED_ROWS .
  methods INSERT_EMPTY_ROWS
    importing
      value(ID_ROWS) type INT4 default 1 .
  methods SELECT_FIRST_CELL_LAST_ROW
    importing
      value(ID_FIELDNAME) type ANY .
  methods GET_TABLE_SIZE
    returning
      value(RD_RESULT) type INT4 .
  methods GET_PROGNAME
    returning
      value(RD_PROGNAME) type STRING .
protected section.
*"* protected components of class ZCL_ABSTRACT_ALV_V1
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_ABSTRACT_ALV_V1
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_ABSTRACT_ALV_V1 IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ABSTRACT_ALV_V1->CALLME_IN_PBO
* +-------------------------------------------------------------------------------------------------+
* | [!CX!] ZCX_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD CALLME_IN_PBO.
  " Autor: Vinicius
  DATA: ld_fieldname TYPE string.
  FIELD-SYMBOLS: <lt_data> TYPE ANY TABLE.

  " já foi exibido?
  IF me->md_displayed = 1.
    me->refresh( ).
    RETURN.
  ENDIF.

  me->md_displayed = 1.
  me->fill_dropdown( ).
  me->fill_fieldcat( ).
  me->fill_layout( ).

  " [1/3] por objeto de referência
  IF me->mt_data IS BOUND.
    ASSIGN me->mt_data->* TO <lt_data>.
  ENDIF.

  " [2/3] assign com o nome da tabela
  IF <lt_data> IS NOT ASSIGNED.
    ASSIGN (me->md_tablename) TO <lt_data>.
  ENDIF.

  " [3/3] assign com o nome do programa + nome da tabela
  IF <lt_data> IS NOT ASSIGNED.
    CONCATENATE '(' sy-cprog ')' me->md_tablename INTO ld_fieldname.
    ASSIGN (ld_fieldname) TO <lt_data>.
  ENDIF.

  " sem sucesso em obter uma referência no field-symbol
  IF <lt_data> IS NOT ASSIGNED.
    RAISE EXCEPTION TYPE ZCX_EXCEPTION
      EXPORTING
        message = 'A referência da tabela de dados é nula!'.
  ELSE.
    GET REFERENCE OF <lt_data> INTO me->mt_data.
  ENDIF.

  IF LINES( me->mt_fieldcat ) <= 0.
    RAISE EXCEPTION TYPE ZCX_EXCEPTION
      EXPORTING
        message = 'O catalogo de campos do ALV esta vazio!'.
  ENDIF.

  " criando o container
  CREATE OBJECT me->mo_custom_container
    EXPORTING
      container_name = me->md_container_name.

  " criando a grid
  CREATE OBJECT me->mo_grid
    EXPORTING
      i_parent = me->mo_custom_container.

  " eventos do grid
  SET HANDLER me->handle_f1                    FOR me->mo_grid.
  SET HANDLER me->handle_f4                    FOR me->mo_grid.
  SET HANDLER me->handle_enter                 FOR me->mo_grid.
  SET HANDLER me->handle_toolbar               FOR me->mo_grid.
  SET HANDLER me->handle_user_command          FOR me->mo_grid.
  SET HANDLER me->handle_double_click          FOR me->mo_grid.
  SET HANDLER me->handle_hotspot_click         FOR me->mo_grid.
  SET HANDLER me->handle_menu_button           FOR me->mo_grid.
  SET HANDLER me->handle_data_changed_finished FOR me->mo_grid.

  " dropdown
  CALL METHOD me->mo_grid->set_drop_down_table
    EXPORTING
      it_drop_down = me->mt_dropdown.

  " inicializando para exibir a opção de salvar layout
  IF me->ms_variant-report IS INITIAL.
    me->ms_variant-report   = me->get_progname( ).
    me->ms_variant-handle   = '0001'.
    me->ms_variant-username = sy-uname.
  ENDIF.

  CALL METHOD me->mo_grid->set_table_for_first_display
    EXPORTING
      is_layout            = me->ms_layout
      it_toolbar_excluding = me->mt_exclude_toolbar
      i_save               = 'A'
      is_variant           = me->ms_variant
    CHANGING
      it_fieldcatalog = me->mt_fieldcat
      it_outtab       = <lt_data>.

  " registrando enter
  CALL METHOD me->mo_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  call method me->mo_grid->register_edit_event
      exporting
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  call method me->mo_grid->register_f4_for_fields
    EXPORTING
      it_f4 = me->mt_f4.
ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ABSTRACT_ALV_V1->CALL_PAI_PARENT_SCREEN
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_FCODE                       TYPE        SYUCOMM (default ='REFRESH')
* +--------------------------------------------------------------------------------------</SIGNATURE>
method CALL_PAI_PARENT_SCREEN.
  " Autor: Vinicius
  cl_gui_cfw=>set_new_ok_code(
      exporting
        new_code = ID_FCODE
    ).
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ABSTRACT_ALV_V1->CLEAN
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
method CLEAN.
  " Autor: Vinicius
  FIELD-SYMBOLS: <lt_data> TYPE ANY TABLE.

  IF me->mt_data IS NOT BOUND.
    RETURN.
  ENDIF.

  ASSIGN me->mt_data->* TO <lt_data>.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  CLEAR: <lt_data>.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ABSTRACT_ALV_V1->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_CONTAINER_NAME              TYPE        SCRFNAME
* | [--->] ID_TABLENAME                   TYPE        STRING(optional)
* +--------------------------------------------------------------------------------------</SIGNATURE>
method CONSTRUCTOR.
  " Autor: Vinicius
  me->md_container_name = id_container_name.
  me->md_tablename      = id_tablename.

  " muito importante para não deixar global no SAP
  " não usar sy-repid que retorna o nome da classe alv
  me->ms_variant-report   = me->get_progname( ).
  me->ms_variant-handle   = '0001'.
  me->ms_variant-username = sy-uname.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ABSTRACT_ALV_V1->FILL_DROPDOWN
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
method FILL_DROPDOWN.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ABSTRACT_ALV_V1->FILL_FIELDCAT
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
method FILL_FIELDCAT.
  " Autor: Vinicius
  me->ms_layout-zebra      = 'X'.
  me->ms_layout-cwidth_opt = ''.
  me->ms_layout-no_colexpd = 'X'.
  me->ms_layout-no_toolbar = 'X'.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ABSTRACT_ALV_V1->FILL_LAYOUT
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
method FILL_LAYOUT.
  " opções padrão
  me->ms_layout-zebra      = 'X'.
  me->ms_layout-cwidth_opt = ''.
  me->ms_layout-no_colexpd = 'X'.
  me->ms_layout-no_toolbar = 'X'.
  me->ms_layout-no_rowins  = 'X'.

  DATA LS_EXCLUDE TYPE UI_FUNC.

  "Botão Export File
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_MB_EXPORT.
  APPEND LS_EXCLUDE TO ME->mt_exclude_toolbar.

  "Botão Gerar Grafico
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_GRAPH.
  APPEND LS_EXCLUDE TO ME->mt_exclude_toolbar.

  "Botão Documento do Usuario
  APPEND CL_GUI_ALV_GRID=>MC_FC_INFO TO ME->mt_exclude_toolbar.

  "Botão de Impressora
  APPEND CL_GUI_ALV_GRID=>MC_FC_PRINT TO ME->mt_exclude_toolbar.

  "Botão de SubTotal
  APPEND CL_GUI_ALV_GRID=>MC_FC_SUBTOT TO ME->mt_exclude_toolbar.

  "Menu Soma
  APPEND CL_GUI_ALV_GRID=>MC_MB_SUM TO ME->mt_exclude_toolbar.

  "Menu de visoes
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_MB_VIEW.
  APPEND LS_EXCLUDE TO ME->mt_exclude_toolbar.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ABSTRACT_ALV_V1->GET_PROGNAME
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RD_PROGNAME                    TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_PROGNAME.
  " Autor: Vinicius
  DATA: lt_callstack TYPE SYS_CALLST.
  DATA: ls_callstack LIKE LINE OF lt_callstack.

  CLEAR rd_progname.

  CALL FUNCTION 'SYSTEM_CALLSTACK'
    IMPORTING
      et_callstack = lt_callstack.

  LOOP AT lt_callstack INTO ls_callstack.
    IF NOT ( ls_callstack-progname CS 'ZCL_ABSTRACT_ALV_V1' ).
      rd_progname  = ls_callstack-progname.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF rd_progname IS INITIAL.
    rd_progname = sy-tcode.
  ENDIF.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ABSTRACT_ALV_V1->GET_SELECTED_ROW
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RD_INDEX                       TYPE        INT4
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_SELECTED_ROW.
  " Autor: Vinicius
  DATA: lt_index_rows	TYPE LVC_T_ROW
      , lt_row_no     TYPE LVC_T_ROID.

  FIELD-SYMBOLS: <ls_index_rows> LIKE LINE OF lt_index_rows.

  IF me->mo_grid IS NOT BOUND.
    RETURN.
  ENDIF.

  CLEAR: rd_index.

  me->mo_grid->get_selected_rows(
    IMPORTING
      ET_INDEX_ROWS	= lt_index_rows
      ET_ROW_NO	    = lt_row_no
  ).

  IF lines( lt_index_rows ) <= 0.
    rd_index = 0.
    RETURN.
  ENDIF.

  READ TABLE lt_index_rows ASSIGNING <ls_index_rows> INDEX 1.
  IF sy-subrc = 0.
    rd_index = <ls_index_rows>-index.
  ENDIF.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ABSTRACT_ALV_V1->GET_SELECTED_ROWS
* +-------------------------------------------------------------------------------------------------+
* | [<-->] CT_INDEX                       TYPE        ANY TABLE
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_SELECTED_ROWS.
  " Autor: Vinicius
  DATA: lt_index_rows	TYPE LVC_T_ROW
      , lt_row_no     TYPE LVC_T_ROID.

  FIELD-SYMBOLS: <ls_index_rows> LIKE LINE OF lt_index_rows.

  IF me->mo_grid IS NOT BOUND.
    RETURN.
  ENDIF.

  CLEAR: ct_index.

  me->mo_grid->get_selected_rows(
    IMPORTING
      ET_INDEX_ROWS	= lt_index_rows
      ET_ROW_NO	    = lt_row_no
  ).

  IF lines( lt_index_rows ) <= 0.
    RETURN.
  ENDIF.

  LOOP AT lt_index_rows ASSIGNING <ls_index_rows>.
    INSERT <ls_index_rows>-index INTO TABLE ct_index.
  ENDLOOP.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ABSTRACT_ALV_V1->GET_SELECTED_STRUCTURE
* +-------------------------------------------------------------------------------------------------+
* | [<---] ES_STRUCTURE                   TYPE        ANY
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_SELECTED_STRUCTURE.
  " Autor: Vinicius
  DATA: ld_row    TYPE int4.
  DATA: lo_struct TYPE REF TO data.

  FIELD-SYMBOLS: <lt_data> TYPE ANY TABLE.
  FIELD-SYMBOLS: <ls_data> TYPE ANY.

  " inicialização
  CLEAR: es_structure.

  IF me->mt_data IS NOT BOUND.
    RETURN.
  ENDIF.

  ASSIGN me->mt_data->* TO <lt_data>.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  CREATE DATA lo_struct LIKE LINE OF <lt_data>.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  ASSIGN lo_struct->* to <ls_data>.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  ld_row = me->get_selected_row( ).
  IF ld_row <= 0.
    return.
  ENDIF.

  LOOP AT <lt_data> ASSIGNING <ls_data>.
    IF sy-tabix = ld_row.
      es_structure = <ls_data>.
      exit.
    ENDIF.
  ENDLOOP.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ABSTRACT_ALV_V1->GET_SELECTED_TABLE
* +-------------------------------------------------------------------------------------------------+
* | [<---] ET_TABLE                       TYPE        STANDARD TABLE
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_SELECTED_TABLE.
  " Autor: Vinicius
  DATA: lt_index_rows	TYPE LVC_T_ROW
      , ls_index_rows LIKE LINE OF lt_index_rows
      , lt_row_no     TYPE LVC_T_ROID.

  DATA: lo_struct TYPE REF TO data.

  FIELD-SYMBOLS: <lt_data> TYPE STANDARD TABLE.
  FIELD-SYMBOLS: <ls_data> TYPE ANY.

  " inicialização
  IF me->mt_data IS NOT BOUND.
    RETURN.
  ENDIF.

  ASSIGN me->mt_data->* TO <lt_data>.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  CREATE DATA lo_struct LIKE LINE OF <lt_data>.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  ASSIGN lo_struct->* to <ls_data>.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  me->mo_grid->get_selected_rows(
    IMPORTING
      ET_INDEX_ROWS	= lt_index_rows
      ET_ROW_NO	    = lt_row_no
  ).

  IF lines( lt_index_rows ) <= 0.
    RETURN.
  ENDIF.

  LOOP AT lt_index_rows INTO ls_index_rows.
    READ TABLE <lt_data> INTO <ls_data> INDEX ls_index_rows-index.
    IF sy-subrc = 0.
      APPEND <ls_data> TO et_table.
    ENDIF.
  ENDLOOP.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ABSTRACT_ALV_V1->GET_TABLE_SIZE
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RD_RESULT                      TYPE        INT4
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_TABLE_SIZE.
" Autor: Vinicius
  FIELD-SYMBOLS: <lt_data> TYPE STANDARD TABLE.

  " inicialização
  IF me->mt_data IS NOT BOUND.
    RETURN.
  ENDIF.

  ASSIGN me->mt_data->* TO <lt_data>.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  rd_result = lines( <lt_data> ).
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ABSTRACT_ALV_V1->HANDLE_F1
* +-------------------------------------------------------------------------------------------------+
* | [--->] E_FIELDNAME                    LIKE
* | [--->] ES_ROW_NO                      LIKE
* | [--->] ER_EVENT_DATA                  LIKE
* +--------------------------------------------------------------------------------------</SIGNATURE>
method HANDLE_F1.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ABSTRACT_ALV_V1->HANDLE_F4
* +-------------------------------------------------------------------------------------------------+
* | [--->] E_FIELDNAME                    LIKE
* | [--->] E_FIELDVALUE                   LIKE
* | [--->] ES_ROW_NO                      LIKE
* | [--->] ER_EVENT_DATA                  LIKE
* | [--->] ET_BAD_CELLS                   LIKE
* | [--->] E_DISPLAY                      LIKE
* +--------------------------------------------------------------------------------------</SIGNATURE>
method HANDLE_F4.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ABSTRACT_ALV_V1->HANDLE_MENU_BUTTON
* +-------------------------------------------------------------------------------------------------+
* | [--->] E_OBJECT                       LIKE
* | [--->] E_UCOMM                        LIKE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method HANDLE_MENU_BUTTON.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ABSTRACT_ALV_V1->HANDLE_TOOLBAR
* +-------------------------------------------------------------------------------------------------+
* | [--->] E_OBJECT                       LIKE
* | [--->] E_INTERACTIVE                  LIKE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method HANDLE_TOOLBAR.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ABSTRACT_ALV_V1->HANDLE_USER_COMMAND
* +-------------------------------------------------------------------------------------------------+
* | [--->] E_UCOMM                        LIKE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method HANDLE_USER_COMMAND.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ABSTRACT_ALV_V1->INSERT_EMPTY_ROWS
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_ROWS                        TYPE        INT4 (default =1)
* +--------------------------------------------------------------------------------------</SIGNATURE>
method INSERT_EMPTY_ROWS.
*
* Autor Vinicius
* Desde 10/08/2017
*
  DATA: lo_struct TYPE REF TO data.

  FIELD-SYMBOLS: <lt_data> TYPE STANDARD TABLE.
  FIELD-SYMBOLS: <ls_data> TYPE ANY.

  " inicialização
  IF me->mt_data IS NOT BOUND.
    RETURN.
  ENDIF.

  ASSIGN me->mt_data->* TO <lt_data>.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  CREATE DATA lo_struct LIKE LINE OF <lt_data>.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  ASSIGN lo_struct->* to <ls_data>.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  DO id_rows TIMES.
    APPEND <ls_data> TO <lt_data>.
  ENDDO.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ABSTRACT_ALV_V1->REFRESH
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD refresh.
  " Autor: Vinicius

  " celulas selecionadas
  DATA: lt_cells TYPE lvc_t_ceno.

  " dados para refresh
  DATA: ls_stable TYPE lvc_s_stbl
      , ld_soft_refresh TYPE char01.

  " dados da celula selecionada
  DATA: ld_row    TYPE i
      , ld_value  TYPE c
      , ld_col    TYPE i
      , ls_row_id	TYPE lvc_s_row
      , ls_col_id	TYPE lvc_s_col
      , ls_row_no	TYPE lvc_s_roid.

  " dados da posição do scroll
  DATA: ls_row_no_4scroll TYPE lvc_s_roid " já esta declarado
      , ls_row_info	      TYPE lvc_s_row
      , ls_col_info	      TYPE lvc_s_col.

  " dados de linhas selecionadas
  DATA: lt_index_rows	TYPE lvc_t_row
      , lt_row_no	    TYPE lvc_t_roid.

  " limpando tudo antes de começar
  CLEAR: lt_cells
       , ls_stable
       , ld_soft_refresh
       , ld_row
       , ld_value
       , ld_col
       , ls_row_id
       , ls_col_id
       , ls_row_no
       , ls_row_no_4scroll
       , ls_row_info
       , ls_col_info
       , lt_index_rows
       , lt_row_no.

  " validação
  IF me->mo_grid IS NOT BOUND.
    RETURN.
  ENDIF.

  "----------------------------------------------------------
  " Parte 1/3 - Colhendo informações
  "----------------------------------------------------------

  " obtendo celulas selecionadas
  CALL METHOD me->mo_grid->get_selected_cells_id
    IMPORTING
      et_cells = lt_cells.

  " obtendo a posição do scroll
  CALL METHOD me->mo_grid->get_scroll_info_via_id(
    IMPORTING
      es_row_no	  = ls_row_no_4scroll
      es_row_info	= ls_row_info
      es_col_info	= ls_col_info
  ).

  " obtendo celula selecionada
  CALL METHOD me->mo_grid->get_current_cell(
    IMPORTING
      e_row     = ld_row
      e_value   = ld_value
      e_col	    = ld_col
      es_row_id	= ls_row_id
      es_col_id	= ls_col_id
      es_row_no	= ls_row_no
  ).

  " obtendo linhas selecionadas
  CALL METHOD me->mo_grid->get_selected_rows
    IMPORTING
      et_index_rows	= lt_index_rows
      et_row_no	    = lt_row_no.

  "----------------------------------------------------------
  " Parte 2/3 - Refresh na tabela
  "----------------------------------------------------------

  " forçando otimização de colunas
  CALL METHOD me->mo_grid->set_frontend_layout
    EXPORTING
      is_layout = me->ms_layout.

  " recarregando os dados
  ls_stable-row = 'X'.
  ls_stable-col = 'X'.

  CALL METHOD me->mo_grid->refresh_table_display
    EXPORTING
      is_stable      = ls_stable
      i_soft_refresh = ld_soft_refresh.

  "----------------------------------------------------------
  " Parte 3/3 - Restaurando o estado da grid antes do refresh
  "----------------------------------------------------------

  " restaurando linhas selecionadas
  CALL METHOD me->mo_grid->set_selected_rows
    EXPORTING
      it_index_rows	= lt_index_rows
      it_row_no	    = lt_row_no.

  " resturando scroll
  CALL METHOD me->mo_grid->set_scroll_info_via_id
    EXPORTING
      is_row_info = ls_row_info
      is_col_info = ls_col_info
      is_row_no   = ls_row_no_4scroll.

  " restaurando celula selecionada
*  CALL METHOD me->mo_grid->set_current_cell_via_id(
*    EXPORTING
*      IS_ROW_ID    = ls_row_id
*      IS_COLUMN_ID = ls_col_id
*      IS_ROW_NO    = ls_row_no
*  ).
ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ABSTRACT_ALV_V1->REMOVE_SELECTED_ROWS
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
method REMOVE_SELECTED_ROWS.
*
* Autor Vinicius
* Desde 10/08/2017
*
  DATA: lt_index TYPE STANDARD TABLE OF LVC_INDEX.
  DATA: ld_index TYPE int4.

  FIELD-SYMBOLS: <lt_data> TYPE STANDARD TABLE.

  " inicialização
  IF me->mt_data IS NOT BOUND.
    RETURN.
  ENDIF.

  ASSIGN me->mt_data->* TO <lt_data>.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  me->get_selected_rows(
    CHANGING
      CT_INDEX = lt_index
  ).

  IF lines( lt_index ) <= 0.
    RETURN.
  ENDIF.

  " deletando ao contrário para não ter problemas com o indice
  SORT lt_index BY table_line DESCENDING.

  LOOP AT lt_index INTO ld_index.
    DELETE <lt_data> INDEX ld_index.
  ENDLOOP.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ABSTRACT_ALV_V1->SELECT_FIRST_CELL_LAST_ROW
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_FIELDNAME                   TYPE        ANY
* +--------------------------------------------------------------------------------------</SIGNATURE>
method SELECT_FIRST_CELL_LAST_ROW.
*
* Autor Vinicius
* Desde 11/08/2017
*
  DATA: ld_total TYPE int4.

  DATA: lo_struct TYPE REF TO data.

  FIELD-SYMBOLS: <lt_data> TYPE STANDARD TABLE.
  FIELD-SYMBOLS: <ls_data> TYPE ANY.

  " inicialização
  IF me->mt_data IS NOT BOUND.
    RETURN.
  ENDIF.

  ASSIGN me->mt_data->* TO <lt_data>.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  ld_total = lines( <lt_data> ).

  me->set_selected_cell(
    EXPORTING
      id_col       = 1
      id_row       = ld_total
      id_fieldname = id_fieldname
  ).
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ABSTRACT_ALV_V1->SET_SELECTED_CELL
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_COL                         TYPE        INT4
* | [--->] ID_ROW                         TYPE        INT4
* | [--->] ID_FIELDNAME                   TYPE        LVC_FNAME
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD set_selected_cell.
  " Autor: Vinicius
  DATA: ls_row_id    TYPE lvc_s_row
      , ls_column_id TYPE lvc_s_col
      , ls_row_no    TYPE lvc_s_roid.

  DATA: lt_cells TYPE lvc_t_cell
      , ls_cells LIKE LINE OF lt_cells.

  DATA: lt_cells2 TYPE LVC_T_CENO
      , ls_cells2 LIKE LINE OF lt_cells2.

  CLEAR: lt_cells
       , ls_cells.

  CLEAR: lt_cells2
       , ls_cells2.

  CLEAR: ls_row_id
       , ls_column_id
       , ls_row_no.

  " set_selected_cells
  ls_cells-row_id-index	    = id_row.
  ls_cells-col_id-fieldname = id_fieldname.
  ls_cells-value  = ''.
  APPEND ls_cells TO lt_cells.
  CALL METHOD me->mo_grid->set_selected_cells
    EXPORTING
      it_cells = lt_cells.

  " set_selected_cells_id
  ls_cells2-ROW_ID = id_row.
  ls_cells2-SUB_ROW_ID = ''.
  ls_cells2-COL_ID = id_col.
  APPEND ls_cells2 TO lt_cells2.
  CALL METHOD me->mo_grid->set_selected_cells_id
    EXPORTING
      it_cells = lt_cells2.

  " set_current_cell_via_id
  ls_row_id-index        = id_row.
  ls_column_id-fieldname = id_fieldname.
  ls_row_no-row_id       = id_row.
  CALL METHOD me->mo_grid->set_current_cell_via_id(
    EXPORTING
      is_row_id    = ls_row_id
      is_column_id = ls_column_id
      is_row_no    = ls_row_no
  ).

  cl_gui_control=>set_focus( me->mo_grid ).
  CALL METHOD me->mo_grid->set_ready_for_input
    EXPORTING
      i_ready_for_input = 1.

  cl_gui_cfw=>flush( ).
ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ABSTRACT_ALV_V1->SET_SELECTED_ROW
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_INDEX                       TYPE        INT4
* +--------------------------------------------------------------------------------------</SIGNATURE>
method SET_SELECTED_ROW.
  " Autor: Vinicius
  DATA: lt_index_rows TYPE LVC_T_ROW
      , ls_index_rows TYPE LVC_S_ROW.

  IF me->mo_grid IS NOT BOUND.
    RETURN.
  ENDIF.

  ls_index_rows-index = id_index.
  APPEND ls_index_rows TO lt_index_rows.

  me->mo_grid->set_selected_rows(
    it_index_rows = lt_index_rows
  ).
endmethod.
ENDCLASS.