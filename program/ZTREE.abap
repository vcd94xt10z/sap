*
* Autor Vinicius Cesar Dias
* Última atualização 10/08/2023 v0.1
*
REPORT ZTREE.

INCLUDE ztree_class.

DATA: gd_debug TYPE flag.
DATA: go_tree  TYPE REF TO zcl_tree.
DATA: gt_node  TYPE treemsunot.
DATA: gs_node  TYPE treemsuno.

START-OF-SELECTION.
  go_tree = new zcl_tree( id_container_name = 'TREE1' ).

  CLEAR gs_node.
  gs_node-node_key = '1'.
  "gs_node-relatkey = ''.
  gs_node-text = 'Presidente'.
  APPEND gs_node TO gt_node.

  CLEAR gs_node.
  gs_node-node_key = '2'.
  gs_node-relatkey = '1'.
  gs_node-text = 'Diretor 1'.
  APPEND gs_node TO gt_node.

  CLEAR gs_node.
  gs_node-node_key = '3'.
  gs_node-relatkey = '1'.
  gs_node-text = 'Diretor 2'.
  APPEND gs_node TO gt_node.

  CLEAR gs_node.
  gs_node-node_key = '4'.
  gs_node-relatkey = '2'.
  gs_node-text = 'Gerente 1'.
  APPEND gs_node TO gt_node.

  CLEAR gs_node.
  gs_node-node_key = '5'.
  gs_node-relatkey = '4'.
  gs_node-text = 'Funcionário 1'.
  APPEND gs_node TO gt_node.

  CLEAR gs_node.
  gs_node-node_key = '6'.
  gs_node-relatkey = '4'.
  gs_node-text = 'Funcionário 2'.
  APPEND gs_node TO gt_node.

  CLEAR gs_node.
  gs_node-node_key = '7'.
  gs_node-relatkey = '4'.
  gs_node-text = 'Funcionário 3'.
  APPEND gs_node TO gt_node.

  CALL SCREEN 9000.

MODULE pbo_9000 OUTPUT.
  SET PF-STATUS 'S9000'.
  SET TITLEBAR 'T9000'.

  go_tree->callme_in_pbo( ).
ENDMODULE.
MODULE pai_9000 INPUT.
  CASE sy-ucomm.
  WHEN 'LOAD'.
    PERFORM load.
  WHEN 'CLEAN'.
    PERFORM clean.
  WHEN 'SAVE'.
    PERFORM save.
  WHEN 'SEL'.
    PERFORM selected.
  WHEN 'OPEN'.
    PERFORM open.
  WHEN 'CLOSE'.
    PERFORM close.
  WHEN 'BACK' OR 'UP' OR 'CANCEL'.
    LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
FORM load.
  IF gd_debug = 'X'.
    BREAK-POINT.
  ENDIF.

  go_tree->set_data( it_data = gt_node ).
ENDFORM.
FORM clean.
  DATA: lt_node TYPE treemsunot.

  IF gd_debug = 'X'.
    BREAK-POINT.
  ENDIF.

  go_tree->set_data( it_data = lt_node ).
ENDFORM.
FORM selected.
  DATA: ld_node TYPE tm_nodekey.

  IF gd_debug = 'X'.
    BREAK-POINT.
  ENDIF.

  CLEAR ld_node.

  go_tree->mo_tree->get_selected_node(
    IMPORTING
      node_key                   = ld_node          " Key of Selected Node
    EXCEPTIONS
      control_not_existing       = 1                " Tree Control Does Not Exist
      control_dead               = 2                " Tree Control Has Already Been Destroyed
      cntl_system_error          = 3                " "
      failed                     = 4                " General Error
      single_node_selection_only = 5                " Only Allowed with Single Node Selection
      others                     = 6
  ).

  IF sy-subrc = 0 AND ld_node IS NOT INITIAL.
    MESSAGE |Você selecionou o nó { ld_node }| TYPE 'S'.
  ENDIF.
ENDFORM.
FORM close.
  go_tree->mo_tree->collapse_all_nodes( ).
ENDFORM.
FORM open.
  DATA: lt_node TYPE treemnotab.
  DATA: ld_node LIKE LINE OF lt_node.

  IF gd_debug = 'X'.
    BREAK-POINT.
  ENDIF.

  go_tree->mo_tree->expand_node(
    EXPORTING
      node_key            = '1'
      expand_subtree      = 'X'
    EXCEPTIONS
      node_not_found      = 1                " Node does not exist
      others              = 2
  ).
ENDFORM.
FORM save.
  DATA: lt_node TYPE treemsunot.

  IF gd_debug = 'X'.
    BREAK-POINT.
  ENDIF.

  lt_node = go_tree->get_data( ).
ENDFORM.
