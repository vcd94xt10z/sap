*
* Autor Vinicius Cesar Dias
* Ultima atualização 08/08/2023 v0.1
* https://github.com/vcd94xt10z/sap
* Programa baseado na documentação da SAP
*
REPORT ZSUBROUTINE_POOL.

DATA tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.

tab = VALUE #(
  ( `PROGRAM subpool.`                        )
  ( `DATA spfli_tab TYPE TABLE OF spfli.`     )
  ( `LOAD-OF-PROGRAM.`                        )
  ( `  SELECT *` &
    `         FROM spfli` &
    `         INTO TABLE @spfli_tab.`         )
  ( `FORM teste.`                       )
  ( `MESSAGE 'TESTE' TYPE 'I'.`                       )
  ( `ENDFORM.`                                )
  ( `FORM loop_at_tab.`                       )
  ( `  DATA spfli_wa TYPE spfli.`             )
  ( `  LOOP AT spfli_tab INTO spfli_wa.`      )
  ( `    PERFORM evaluate_wa USING spfli_wa.` )
  ( `  ENDLOOP.`                              )
  ( `ENDFORM.`                                )
  ( `FORM evaluate_wa USING l_wa TYPE spfli.` )
  ( `  cl_demo_output=>write_data( l_wa ).`   )
  ( `ENDFORM.`                                ) ).

GENERATE SUBROUTINE POOL tab NAME DATA(prog)
         MESSAGE                  DATA(mess)
         SHORTDUMP-ID             DATA(sid).

IF sy-subrc = 0.
  "PERFORM ('LOOP_AT_TAB') IN PROGRAM (prog) IF FOUND.
  PERFORM ('TESTE') IN PROGRAM (prog) IF FOUND.
  "cl_demo_output=>display( ).
ELSEIF sy-subrc = 4.
  MESSAGE mess TYPE 'I'.
ELSEIF sy-subrc = 8.
  MESSAGE sid TYPE 'I'.
ENDIF.
