REPORT ZABRE_PERIODO.

SELECTION-SCREEN BEGIN OF BLOCK main WITH FRAME.
  PARAMETERS p_year1  TYPE int4.
  PARAMETERS p_month1 TYPE int4.

  PARAMETERS p_year2  TYPE int4.
  PARAMETERS p_month2 TYPE int4.
SELECTION-SCREEN END OF BLOCK main.

START-OF-SELECTION.
  IF p_year1 > p_year2.
    MESSAGE 'Ano inicial é maior que o final' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  IF p_year2 = sy-datum(4) AND p_month2 > sy-datum+4(2).
    MESSAGE 'Mês final ultrapassa a data atual' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  DO.
    IF p_year1 = p_year2 AND p_month1 > p_month2.
      EXIT.
    ENDIF.

    " MMRV / MMPV
    SUBMIT rmmmperi
      WITH i_vbukr = '7000'
      WITH i_lfmon = p_month1
      WITH i_lfgja = p_year1
       AND RETURN.

    p_month1 = p_month1 + 1.
    IF p_month1 > 12.
      p_month1 = 1.
      p_year1 = p_year1 + 1.
    ENDIF.
  ENDDO.
