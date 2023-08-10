*
* Autor Vinicius Cesar Dias
* Última atualização 10/08/2023 v0.1
* https://github.com/vcd94xt10z
*
* Criar Classe e Objeto de Autorização
* Transação SU21
*
* Exibir verificação de autorização
* Transação SU53
*
* Dar autorização para um usuário
* Transação PFCG
*
REPORT ZAUTHORITY_CHECK.

CONSTANTS: lc_green TYPE char4 VALUE '@5B@'.
CONSTANTS: lc_red   TYPE char4 VALUE '@5C@'.

START-OF-SELECTION.
  AUTHORITY-CHECK OBJECT 'ZCLIENTE'
         ID 'ACTVT' FIELD '01'.

  CASE sy-subrc.
    WHEN 0.
      WRITE lc_green AS ICON.
      WRITE 'Você tem autorização'.
    WHEN 4.
      WRITE lc_red AS ICON.
      WRITE |Você não tem autorização|.
    WHEN 12.
      WRITE lc_red AS ICON.
      WRITE |Nenhuma autorização encontrada|.
    WHEN OTHERS.
      WRITE lc_red AS ICON.
      WRITE |Erro em verificar autorização ({ sy-subrc })|.
  ENDCASE.
