class ZCL_TEXT_UTILS definition
  public
  create public .

public section.

  class-methods SPLIT_AT_SIZE
    importing
      value(ID_VALUE) type ANY
      value(ID_SIZE) type INT4
    exporting
      !ET_TABLE type ANY TABLE .
  class-methods TEXT_TO_MSG
    importing
      !ID_TEXT type ANY
    changing
      !CD_MSGV1 type ANY
      !CD_MSGV2 type ANY
      !CD_MSGV3 type ANY
      !CD_MSGV4 type ANY .
protected section.
private section.
ENDCLASS.



CLASS ZCL_TEXT_UTILS IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_TEXT_UTILS=>SPLIT_AT_SIZE
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_VALUE                       TYPE        ANY
* | [--->] ID_SIZE                        TYPE        INT4
* | [<---] ET_TABLE                       TYPE        ANY TABLE
* +--------------------------------------------------------------------------------------</SIGNATURE>
method SPLIT_AT_SIZE.
  DATA: ld_line   TYPE string.
  DATA: ld_strlen TYPE int4.

  DO.
    ld_strlen = strlen( id_value ).
    IF ld_strlen <= id_size.
      ld_line = id_value.
      INSERT ld_line INTO TABLE et_table.
      EXIT.
    ENDIF.

    ld_line = id_value(id_size).
    INSERT ld_line INTO TABLE et_table.
    id_value = id_value+id_size.
  ENDDO.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_TEXT_UTILS=>TEXT_TO_MSG
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_TEXT                        TYPE        ANY
* | [<-->] CD_MSGV1                       TYPE        ANY
* | [<-->] CD_MSGV2                       TYPE        ANY
* | [<-->] CD_MSGV3                       TYPE        ANY
* | [<-->] CD_MSGV4                       TYPE        ANY
* +--------------------------------------------------------------------------------------</SIGNATURE>
method TEXT_TO_MSG.
  DATA: lt_data TYPE STANDARD TABLE OF string.
  DATA: ld_data TYPE string.

  split_at_size(
    EXPORTING
      id_value = id_text
      id_size  = 50
    IMPORTING
      et_table = lt_data
  ).

  READ TABLE lt_data INTO ld_data INDEX 1.
  IF sy-subrc = 0.
    cd_msgv1 = ld_data.
  ENDIF.

  READ TABLE lt_data INTO ld_data INDEX 2.
  IF sy-subrc = 0.
    cd_msgv2 = ld_data.
  ENDIF.

  READ TABLE lt_data INTO ld_data INDEX 3.
  IF sy-subrc = 0.
    cd_msgv3 = ld_data.
  ENDIF.

  READ TABLE lt_data INTO ld_data INDEX 4.
  IF sy-subrc = 0.
    cd_msgv4 = ld_data.
  ENDIF.
endmethod.
ENDCLASS.
