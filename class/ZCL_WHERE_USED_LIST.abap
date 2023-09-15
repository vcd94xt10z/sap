class ZCL_WHERE_USED_LIST definition
  public
  create public .

public section.

  types:
    BEGIN OF my_object
       , type TYPE trobjtype
       , name TYPE sobj_name
       , END OF my_object .
  types:
    my_object_t TYPE STANDARD TABLE OF my_object WITH NON-UNIQUE KEY type name .

  class-methods WHERE_USED_LIST
    importing
      !ID_TYPE type TROBJTYPE
      !ID_NAME type SOBJ_NAME
    exporting
      !ET_OBJECT type MY_OBJECT_T .
  class-methods FIND_MAIN_PROGLIST
    importing
      !ID_TYPE type TROBJTYPE
      !ID_NAME type SOBJ_NAME
    changing
      !CT_OBJECT type MY_OBJECT_T .
protected section.
private section.
ENDCLASS.



CLASS ZCL_WHERE_USED_LIST IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_WHERE_USED_LIST=>FIND_MAIN_PROGLIST
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_TYPE                        TYPE        TROBJTYPE
* | [--->] ID_NAME                        TYPE        SOBJ_NAME
* | [<-->] CT_OBJECT                      TYPE        MY_OBJECT_T
* +--------------------------------------------------------------------------------------</SIGNATURE>
method FIND_MAIN_PROGLIST.
*
* Procura programas principais (ignorando includes) recursivamente
*
  DATA: lt_object LIKE ct_object.
  DATA: ls_object LIKE LINE OF ct_object.
  DATA: lt_trdir  TYPE STANDARD TABLE OF trdir.
  DATA: ls_trdir  TYPE trdir.

  where_used_list(
    EXPORTING
      id_type   = id_type
      id_name   = id_name
    IMPORTING
      et_object = lt_object
  ).

  DELETE lt_object WHERE type <> 'PROG'. " Programas e includes

  IF lines( lt_object ) = 0.
    RETURN.
  ENDIF.

  " obtendo somente os programas que não são includes
  SELECT *
    INTO TABLE lt_trdir
    FROM trdir
     FOR ALL ENTRIES IN lt_object
   WHERE name = lt_object-name.

  LOOP AT lt_trdir INTO ls_trdir.
    IF ls_trdir-subc = 'I'.
      find_main_proglist(
        EXPORTING
          id_type   = 'PROG'
          id_name   = ls_trdir-name
        CHANGING
          ct_object = ct_object
      ).
    ELSE.
      CLEAR ls_object.
      ls_object-type = 'PROG'.
      ls_object-name = ls_trdir-name.
      APPEND ls_object TO ct_object.
    ENDIF.
  ENDLOOP.

  SORT ct_object BY name ASCENDING.
  DELETE ADJACENT DUPLICATES FROM ct_object COMPARING name.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_WHERE_USED_LIST=>WHERE_USED_LIST
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_TYPE                        TYPE        TROBJTYPE
* | [--->] ID_NAME                        TYPE        SOBJ_NAME
* | [<---] ET_OBJECT                      TYPE        MY_OBJECT_T
* +--------------------------------------------------------------------------------------</SIGNATURE>
method WHERE_USED_LIST.
  DATA: lt_references TYPE crmost_except_type.
  DATA: ls_references LIKE LINE OF lt_references.
  DATA: ls_object     LIKE LINE OF et_object.

  CLEAR lt_references.

  CALL FUNCTION 'CRMOST_WHERE_USED_LIST'
    EXPORTING
      obj_type   = id_type
      obj_name   = id_name
    IMPORTING
      references = lt_references.

  LOOP AT lt_references INTO ls_references.
    CLEAR ls_object.
    ls_object-type = ls_references-obj_type.
    ls_object-name = ls_references-obj_name.
    APPEND ls_object TO et_object.
  ENDLOOP.
endmethod.
ENDCLASS.
