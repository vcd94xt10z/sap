REPORT ZOBJETO_BLOQUEIO.

DATA: gd_bloqueado TYPE char1.
DATA: gd_gravar    TYPE char1.
DATA: gd_name      TYPE ztest_cliente-name.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
  PARAMETERS p_kunnr TYPE ztest_cliente-kunnr.
SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.
  PERFORM bloquear.
  IF gd_bloqueado <> 'X'.
    EXIT.
  ENDIF.

  PERFORM obter_nome.
  IF gd_gravar <> 'X'.
    EXIT.
  ENDIF.

  PERFORM gravar_nome.
  PERFORM liberar_bloqueio.

FORM liberar_bloqueio.
  CALL FUNCTION 'DEQUEUE_EZTESTCLI'
   EXPORTING
*     MODE_ZTEST_CLIENTE       = 'E'
*     MANDT                    = SY-MANDT
     KUNNR                    = p_kunnr
*     X_KUNNR                  = ' '
*     _SCOPE                   = '3'
*     _SYNCHRON                = ' '
*     _COLLECT                 = ' '
            .
ENDFORM.
FORM gravar_nome.
  UPDATE ztest_cliente
     SET name = gd_name
   WHERE kunnr = p_kunnr.

  IF sy-subrc = 0.
    MESSAGE 'Cliente atualizado' TYPE 'S'.
  ENDIF.
ENDFORM.
FORM obter_nome.
  DATA: lt_field TYPE STANDARD TABLE OF sval.
  DATA: ls_field TYPE sval.
  DATA: ld_rc    TYPE char1.

  CLEAR lt_field.

  SELECT SINGLE name
    INTO gd_name
    FROM ztest_cliente
   WHERE kunnr = p_kunnr.

  CLEAR ls_field.
  ls_field-tabname   = 'ZTEST_CLIENTE'.
  ls_field-fieldname = 'NAME'.
  ls_field-value     = gd_name.
  APPEND ls_field TO lt_field.

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
*     NO_VALUE_CHECK        = ' '
      popup_title           = 'Informe o nome'
*     START_COLUMN          = '5'
*     START_ROW             = '5'
    IMPORTING
      RETURNCODE            = ld_rc
    TABLES
      fields                = lt_field
    EXCEPTIONS
      ERROR_IN_FIELDS       = 1
      OTHERS                = 2.

  gd_gravar = ''.

  IF sy-subrc = 0 AND ld_rc = ''.
    gd_gravar = 'X'.
    READ TABLE lt_field INTO ls_field INDEX 1.
    IF sy-subrc = 0.
      gd_name = ls_field-value.
    ENDIF.
  ELSE.
    MESSAGE 'Atualização cancelada' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.
FORM bloquear.
  DATA: ls_varkey  TYPE vim_enqkey.

  gd_bloqueado = ''.

  ls_varkey = |{ p_kunnr }|.

*  call function 'ENQUEUE_E_TABLE'
*    exporting
*      tabname        = 'ZTEST_CLIENTE'
*      varkey         = ls_varkey
*    exceptions
*      foreign_lock   = 1
*      system_failure = 2
*      others         = 3.

  CALL FUNCTION 'ENQUEUE_EZTESTCLI'
   EXPORTING
*     MODE_ZTEST_CLIENTE       = 'E'
*     MANDT                    = SY-MANDT
     KUNNR                    = p_kunnr
*     X_KUNNR                  = ' '
*     _SCOPE                   = '2'
*     _WAIT                    = ' '
*     _COLLECT                 = ' '
   EXCEPTIONS
     FOREIGN_LOCK             = 1
     SYSTEM_FAILURE           = 2
     OTHERS                   = 3.

  IF sy-subrc = 0.
    gd_bloqueado = 'X'.
    MESSAGE 'Pode modificar' TYPE 'S'.
  ELSE.
    MESSAGE |O usuário { sy-msgv1 } já esta modificando o cliente { p_kunnr }|
       TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.
