*
* Ultima atualização 04/08/2023 v0.1
*
* Resumo das definições
* Field Symbol: Aponta para uma variável que tem tipo concreto
* Data: Cria uma variável sem tipo definido e somente depois atribui o tipo
*
REPORT ZVARIAVEIS_GENERICAS.

DATA: lr_data TYPE REF TO data.

DATA: lt_sairport TYPE STANDARD TABLE OF sairport.

FIELD-SYMBOLS: <lt_data>  TYPE ANY TABLE.
FIELD-SYMBOLS: <ls_data>  TYPE ANY.
FIELD-SYMBOLS: <ld_field> TYPE ANY.

SELECTION-SCREEN BEGIN OF BLOCK main WITH FRAME.
  PARAMETERS p_table TYPE string.
SELECTION-SCREEN END OF BLOCK main.

START-OF-SELECTION.
  BREAK-POINT.

  CREATE DATA lr_data TYPE STANDARD TABLE OF (p_table).
  "GET REFERENCE OF lt_sairport INTO lr_data.

  ASSIGN lr_data->* TO <lt_data>.
  "ASSIGN lt_sairport TO <lt_data>. " variável normal
  "ASSIGN ('lt_sairport') TO <lt_data>. " variável normal (dinâmica)

  SELECT *
    INTO TABLE <lt_data>
    FROM (p_table).

  LOOP AT <lt_data> ASSIGNING <ls_data>.
    DO.
      ASSIGN COMPONENT sy-index OF STRUCTURE <ls_data> TO <ld_field>.
      IF sy-subrc = 0.
        WRITE <ld_field>.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.

    NEW-LINE.
  ENDLOOP.

  BREAK-POINT.
