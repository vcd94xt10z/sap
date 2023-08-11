* Include top
DATA: gt_item             TYPE STANDARD TABLE OF tabela.
DATA: gs_item             TYPE tabela.

DATA: go_grid1            TYPE REF TO CL_GUI_ALV_GRID.
DATA: go_custom_container TYPE REF TO CL_GUI_CUSTOM_CONTAINER.

* Criar tela 9000

* PBO
MODULE pbo_9000 OUTPUT.
  SET PF-STATUS 'S9000'.
  SET TITLEBAR  'T9000'.

  CLEAR sy-ucomm.

  DATA: lt_fieldcat TYPE lvc_t_fcat.
  DATA: ls_fieldcat TYPE lvc_s_fcat.

  IF go_custom_container IS INITIAL.
    CLEAR lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'MANDT'.
    ls_fieldcat-scrtext_m = 'Mandante'.
    ls_fieldcat-no_out    = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'VBELN'.
    ls_fieldcat-scrtext_m = 'Ordem'.
    ls_fieldcat-no_out    = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'POSNR'.
    ls_fieldcat-scrtext_m = 'Item'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'MATNR'.
    ls_fieldcat-scrtext_m = 'Material'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'MAKTX'.
    ls_fieldcat-scrtext_m = 'Descrição'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'VRKME'.
    ls_fieldcat-scrtext_m = 'Un. Venda'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'UMREZ'.
    ls_fieldcat-scrtext_m = 'Qtd. Un. Venda'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'VALOR_UNI'.
    ls_fieldcat-scrtext_m = 'Valor Unitário'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'MENGE'.
    ls_fieldcat-scrtext_m = 'Quantidade'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'VALOR_TOT'.
    ls_fieldcat-scrtext_m = 'Valor Total'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'PESO_UNI'.
    ls_fieldcat-scrtext_m = 'Peso Unitário'.
    ls_fieldcat-no_out    = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'PESO_TOT'.
    ls_fieldcat-scrtext_m = 'Peso Total'.
    APPEND ls_fieldcat TO lt_fieldcat.

    LOOP AT lt_fieldcat ASSIGNING FIELD-SYMBOL(<ls_fieldcat>).
      <ls_fieldcat>-col_pos = sy-tabix.
      <ls_fieldcat>-scrtext_l = <ls_fieldcat>-scrtext_m.
      <ls_fieldcat>-scrtext_s = <ls_fieldcat>-scrtext_m.
      <ls_fieldcat>-coltext   = <ls_fieldcat>-scrtext_m.
    ENDLOOP.

    CREATE OBJECT go_custom_container
      EXPORTING
        container_name = 'ALV_1'.

    CREATE OBJECT go_grid1
      EXPORTING
        I_PARENT = go_custom_container.

    CALL METHOD go_grid1->set_table_for_first_display
      EXPORTING
        i_structure_name = 'ZFV_OVITEM'
      CHANGING
        it_outtab        = gt_item
        it_fieldcatalog = lt_fieldcat.

    go_grid1->refresh_table_display( ).
  ENDIF.
ENDMODULE.