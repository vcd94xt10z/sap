REPORT ZSTVARV.

DATA: ld_type_msg TYPE string.
DATA: lt_tz_r     TYPE RANGE OF sairport-time_zone.
DATA: lt_tvarvc   TYPE STANDARD TABLE OF tvarvc.
DATA: lt_sairport TYPE STANDARD TABLE OF sairport.

BREAK-POINT.

SELECT SINGLE low
  INTO ld_type_msg
  FROM tvarvc
 WHERE name = 'ZTESTE01_TYPE_MSG'.

SELECT sign opti AS option low high
  INTO CORRESPONDING FIELDS OF TABLE lt_tz_r
  FROM tvarvc
 WHERE name = 'ZSAIRPORT_TZ'.

SELECT *
  INTO TABLE lt_sairport
  FROM sairport
 WHERE time_zone IN lt_tz_r.

IF ld_type_msg = 'WRITE'.
  WRITE 'Olá mundo!'.
ELSE.
  MESSAGE 'Olá mundo!' TYPE 'S'.
ENDIF.

BREAK-POINT.
