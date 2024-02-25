* Versão 0.1

*
* Para executar esse exemplo, siga os passos
* 1) Crie uma tela com o número 9001
* 2) Dentro da tela, no módulo PROCESS AFTER INPUT, use o módulo pai
* 3) Dentro da tela, no módulo PROCESS BEFORE OUTPUT, use o módulo pbo
* 4) Dentro da tela, insira um container que ocupa todo espaço disponível, coloque o nome CONTAINER
* 5) Crie um STATUS GUI S9001 e coloque as funções para do botão verde, amarelho e vermelho,
* respectivamente BACK, UP e CANCEL
* 6) Ative tudo e execute
*
REPORT ZALV_BASICO2.

DATA: go_grid       TYPE REF TO cl_gui_alv_grid.
DATA: go_ccontainer TYPE REF TO cl_gui_custom_container.
DATA: gt_spfli      TYPE TABLE OF spfli.
DATA: gs_layout     TYPE lvc_s_layo.
DATA: gs_variant    TYPE disvariant.
DATA: gt_fieldcat   TYPE lvc_t_fcat.
DATA: gs_fieldcat   TYPE lvc_s_fcat.

START-OF-SELECTION.
  SELECT *
    FROM spfli
    INTO TABLE gt_spfli.

  CALL SCREEN 9001.

MODULE pbo OUTPUT.
  SET PF-STATUS 'S9001'.

  IF go_ccontainer IS INITIAL.
    " cria o container
    CREATE OBJECT go_ccontainer
      EXPORTING
        container_name = 'CONTAINER'.

    " cria a GRID
    CREATE OBJECT go_grid
      EXPORTING
        i_parent = go_ccontainer.

    " configurando opções do layout do ALV
    CLEAR gs_layout.
    gs_layout-zebra      = 'X'.
    gs_layout-col_opt    = 'X'.
    gs_layout-sel_mode   = 'A'.
    gs_layout-no_toolbar = ''.

    " exibindo opção de salvar variante de ALV
    CLEAR gs_variant.
    gs_variant-report   = sy-repid.
    gs_variant-username = sy-uname.

    " configurando uma coluna
    CLEAR gs_fieldcat.
    gs_fieldcat-fieldname = 'CARRID'.
    gs_fieldcat-outputlen = 10.
    gs_fieldcat-coltext   = 'ID'.
    gs_fieldcat-just      = 'C'.
    APPEND gs_fieldcat TO gt_fieldcat.

    " exibe o ALV
    CALL METHOD go_grid->set_table_for_first_display
      EXPORTING
        i_structure_name = 'SPFLI'    " informe para exibir as colunas de uma tabela, não precisando do parâmetro it_fieldcatalog
        is_layout        = gs_layout
        is_variant       = gs_variant
        i_save           = 'X' " exibe a opção para salvar variante
      CHANGING
        "it_fieldcatalog  = gt_fieldcat " fielcat (só é necessário se não informar o parâmetro i_structure_name)
        it_outtab        = gt_spfli.
  ENDIF.
ENDMODULE.
MODULE pai INPUT.
  CALL METHOD cl_gui_cfw=>dispatch.

  CASE sy-ucomm.
  WHEN 'BACK' OR 'UP' OR 'CANCEL'.
    LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.
