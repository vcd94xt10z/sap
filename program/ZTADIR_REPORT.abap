REPORT ZTADIR_REPORT.

TYPES: BEGIN OF ly_tadir
     , pgmid      TYPE tadir-PGMID
     , object     TYPE tadir-object
     , obj_name   TYPE tadir-obj_name
     , devclass   TYPE tadir-devclass
     , created_on TYPE tadir-created_on

     , tcode      TYPE tstc-tcode
     , ttext      TYPE tstct-ttext
     , END OF ly_tadir.

TYPES: BEGIN OF ly_tcode
     , pgmna TYPE tstc-pgmna
     , tcode TYPE tstc-tcode
     , ttext TYPE tstct-ttext
     , END OF ly_tcode.

DATA: lt_tcode TYPE STANDARD TABLE OF ly_tcode.
DATA: ls_tcode TYPE ly_tcode.

DATA: lt_tadir  TYPE SORTED TABLE OF ly_tadir WITH NON-UNIQUE KEY obj_name.
DATA: ls_tadir  TYPE ly_tadir.

FIELD-SYMBOLS: <ls_tadir> TYPE ly_tadir.
FIELD-SYMBOLS: <ls_tcode> TYPE ly_tcode.

" objetos do cliente
SELECT pgmid object obj_name devclass created_on
  INTO CORRESPONDING FIELDS OF TABLE lt_tadir
  FROM tadir
 WHERE obj_name LIKE 'Z%'
    OR obj_name LIKE 'Y%'.

" transações do cliente
SELECT t1~tcode t1~pgmna t2~ttext
  FROM tstc  AS t1
  JOIN tstct AS t2 ON t1~tcode = t2~tcode AND t2~sprsl = 'P'
  INTO CORRESPONDING FIELDS OF TABLE lt_tcode
 WHERE t1~pgmna LIKE 'Z%'
    OR t1~pgmna LIKE 'Y%'.

SORT lt_tcode BY pgmna tcode ASCENDING.

LOOP AT lt_tcode ASSIGNING <ls_tcode>.
  UNASSIGN <ls_tadir>.
  READ TABLE lt_tadir ASSIGNING <ls_tadir> WITH TABLE KEY obj_name = <ls_tcode>-pgmna.
  IF <ls_tadir> IS ASSIGNED.
    IF <ls_tadir>-tcode = ''.
      <ls_tadir>-tcode = <ls_tcode>-tcode.
      <ls_tadir>-ttext = <ls_tcode>-ttext.
    ELSE.
      CLEAR ls_tadir.
      MOVE-CORRESPONDING <ls_tadir> TO ls_tadir.
      ls_tadir-tcode = <ls_tcode>-tcode.
      ls_tadir-ttext = <ls_tcode>-ttext.
      INSERT ls_tadir INTO TABLE lt_tadir.
    ENDIF.
  ENDIF.
ENDLOOP.

PERFORM show.

FORM show.
  DATA: lt_tadir2 TYPE STANDARD TABLE OF ly_tadir.

  DATA: lo_table   TYPE REF TO cl_salv_table.
  DATA: lo_columns TYPE REF TO cl_salv_columns_table.

  CLEAR lt_tadir2.
  INSERT LINES OF lt_tadir INTO TABLE lt_tadir2.

  cl_salv_table=>factory(
  IMPORTING
    r_salv_table = lo_table
  CHANGING
    t_table = lt_tadir2
  ).

  lo_columns = lo_table->get_columns( ).
  lo_columns->set_optimize( ).

  lo_table->display( ).
ENDFORM.
