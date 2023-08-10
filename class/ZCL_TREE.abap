class ZCL_TREE definition
  public
  create public .

*"* public components of class ZCL_TREE
*"* do not include other source files here!!!
public section.

  data MO_CONTAINER type ref to CL_GUI_CUSTOM_CONTAINER .
  data MO_TREE type ref to CL_SIMPLE_TREE_MODEL .
  data MD_CONTAINER_NAME type CHAR50 .
  data MT_DATA type TREEMSUNOT .

  methods HANDLE_NODE_DOUBLE_CLICK
    for event NODE_DOUBLE_CLICK of CL_SIMPLE_TREE_MODEL
    importing
      !NODE_KEY .
  methods CONSTRUCTOR
    importing
      !ID_CONTAINER_NAME type STRING .
  methods CALLME_IN_PBO .
  methods SET_DATA
    importing
      !IT_DATA type TREEMSUNOT .
  methods GET_DATA
    returning
      value(RT_DATA) type TREEMSUNOT .
  methods COPY_DATA_TO_NODES .
protected section.
*"* protected components of class ZCL_TREE
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_TREE
*"* do not include other source files here!!!

  data MD_COPY_DATA_TO_NODES type CHAR1 .
ENDCLASS.



CLASS ZCL_TREE IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_TREE->CALLME_IN_PBO
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
method CALLME_IN_PBO.
  DATA: event  TYPE cntl_simple_event,
        events TYPE cntl_simple_events.

  data: lt_event type cntl_simple_events,
        ls_event  type cntl_simple_event.

  IF me->mo_tree IS BOUND.
    me->COPY_DATA_TO_NODES( ).
    RETURN.
  ENDIF.

  CREATE OBJECT me->mo_tree
    EXPORTING
      NODE_SELECTION_MODE = cl_simple_tree_model=>node_sel_mode_single
    EXCEPTIONS
      illegal_node_selection_mode = 1.

  CREATE OBJECT me->mo_container
    EXPORTING
      CONTAINER_NAME = me->md_container_name.

  CALL METHOD me->mo_tree->create_tree_control
    EXPORTING
      PARENT = me->mo_container.

  me->COPY_DATA_TO_NODES( ).

  " eventos
  ls_event-eventid = cl_simple_tree_model=>eventid_node_double_click.
  append ls_event to lt_event.

  " registro dos eventos
  CALL METHOD me->mo_tree->set_registered_events
    EXPORTING
      events                    = lt_event
    EXCEPTIONS
      illegal_event_combination = 1
      unknown_event             = 2.

  " handlers
  SET HANDLER me->handle_node_double_click FOR me->mo_tree.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_TREE->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_CONTAINER_NAME              TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method CONSTRUCTOR.
*
* Autor Vinicius
* Última atualização 10/08/2023 v0.1
* https://github.com/vcd94xt10z
*
  me->md_container_name = id_container_name.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_TREE->COPY_DATA_TO_NODES
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
method COPY_DATA_TO_NODES.
  DATA: ls_node LIKE LINE OF me->mt_data.

  IF me->mo_tree IS NOT BOUND.
    RETURN.
  ENDIF.

  IF me->md_copy_data_to_nodes <> 'X'.
    RETURN.
  ENDIF.
  me->md_copy_data_to_nodes = ''.

  me->mo_tree->delete_all_nodes( ).

  LOOP AT me->mt_data INTO ls_node.
    me->mo_tree->add_node(
      EXPORTING
        node_key          = ls_node-node_key
        relative_node_key = ls_node-relatkey
        relationship      = ls_node-relatship
        isfolder          = ls_node-isfolder
        text              = ls_node-text
      EXCEPTIONS
        NODE_KEY_EXISTS         = 1
        ILLEGAL_RELATIONSHIP    = 2
        RELATIVE_NODE_NOT_FOUND = 3
        NODE_KEY_EMPTY          = 4
    ).
  ENDLOOP.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_TREE->GET_DATA
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RT_DATA                        TYPE        TREEMSUNOT
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_DATA.
  RT_DATA = me->mt_data.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_TREE->HANDLE_NODE_DOUBLE_CLICK
* +-------------------------------------------------------------------------------------------------+
* | [--->] NODE_KEY                       LIKE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method HANDLE_NODE_DOUBLE_CLICK.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_TREE->SET_DATA
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_DATA                        TYPE        TREEMSUNOT
* +--------------------------------------------------------------------------------------</SIGNATURE>
method SET_DATA.
  me->mt_data = it_data.
  me->md_copy_data_to_nodes = 'X'.
endmethod.
ENDCLASS.
