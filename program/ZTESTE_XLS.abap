* Ultima atualização 03/08/2023 v0.1
REPORT ZTESTE_XLS.

DATA ld_file     TYPE string.
DATA lt_sairport TYPE STANDARD TABLE OF sairport.

START-OF-SELECTION.
  SELECT *
    INTO TABLE lt_sairport
    FROM sairport.

  "ld_file = 'C:\Windows\Temp\data.xls'.
  ld_file = '/tmp/data.xls'.

  BREAK-POINT.

  zcl_xls_utils=>itab_to_xls(
    EXPORTING
      itab     = lt_sairport
      xls_file = ld_file
      "server   = 'X'
    EXCEPTIONS
      others   = 1
  ).

  CLEAR lt_sairport.
  zcl_xls_utils=>xls_to_itab(
    EXPORTING
      xls_file = ld_file
      "server   = 'X'
    IMPORTING
      itab     = lt_sairport
    EXCEPTIONS
      others   = 1
  ).

  BREAK-POINT.
