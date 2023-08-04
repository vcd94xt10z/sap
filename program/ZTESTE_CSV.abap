* Ultima atualização 04/08/2023 v0.1
REPORT ZTESTE_CSV.

DATA: ld_file     TYPE string.
DATA: ld_server   TYPE flag.
DATA: ld_header   TYPE flag.
DATA: lt_sairport TYPE STANDARD TABLE OF sairport.

START-OF-SELECTION.
  BREAK-POINT.

  SELECT *
    INTO TABLE lt_sairport
    FROM sairport.

  ld_server = ''.
  ld_header = 'X'.

  IF ld_server = 'X'.
    ld_file = '/tmp/data.csv'.
  ELSE.
    ld_file = 'C:\Users\User\Desktop\CSV\data.csv'.
  ENDIF.

  zcl_csv_utils=>itab_to_csv(
    EXPORTING
      itab      = lt_sairport
      csv_file  = ld_file
      header    = ld_header
      server    = ld_server
      "delimiter = cl_rsda_csv_converter=>c_default_delimiter
      "separator = cl_rsda_csv_converter=>c_default_separator
  ).

  CLEAR lt_sairport.
  zcl_csv_utils=>csv_to_itab(
    EXPORTING
      csv_file  = ld_file
      header    = ld_header
      server    = ld_server
      "delimiter = cl_rsda_csv_converter=>c_default_delimiter
      "separator = cl_rsda_csv_converter=>c_default_separator
    IMPORTING
      itab      = lt_sairport
  ).

  BREAK-POINT.
