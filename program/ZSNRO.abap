*
* Autor Vinicius Cesar Dias
* Última atualização 10/08/2023 v0.1
*
* Transação SNRO
* Informe o objeto e clique em Criar
* Informe o texto curto e longo
* Informe o domínio para puxar o tamanho
* Porcentagem de aviso quando o número estiver acabando, coloque 10%
* Clique em Editar intervalo
* Modificar intervalos
* Informe 01, 1 e 9999999999
* Salve
*
REPORT ZSNRO.

DATA: ld_number TYPE int4.

SELECTION-SCREEN BEGIN OF BLOCK main WITH FRAME.
  PARAMETERS: p_object TYPE nrobj DEFAULT 'ZCLI01'.
SELECTION-SCREEN END OF BLOCK main.

START-OF-SELECTION.
  CLEAR ld_number.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = '01'
      object                  = p_object
    IMPORTING
      NUMBER                  = ld_number
    EXCEPTIONS
      INTERVAL_NOT_FOUND      = 1
      NUMBER_RANGE_NOT_INTERN = 2
      OBJECT_NOT_FOUND        = 3
      QUANTITY_IS_0           = 4
      QUANTITY_IS_NOT_1       = 5
      INTERVAL_OVERFLOW       = 6
      BUFFER_OVERFLOW         = 7
      OTHERS                  = 8.

    IF sy-subrc = 0.
      MESSAGE |Número gerado: { ld_number }| TYPE 'S'.
    ELSE.
      MESSAGE |Erro em gerar número ( { sy-subrc } )| TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.
