FUNCTION ZFM_TEST_RFC.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(ID_PARAM1) TYPE  CHAR10
*"     VALUE(IS_SAIRPORT) TYPE  SAIRPORT
*"  EXPORTING
*"     VALUE(ED_PARAM1) TYPE  DATS
*"     VALUE(ES_SAIRPORT) TYPE  SAIRPORT
*"  TABLES
*"      IT_SAIRPORT STRUCTURE  SAIRPORT OPTIONAL
*"      ET_SAIRPORT STRUCTURE  SAIRPORT OPTIONAL
*"  CHANGING
*"     VALUE(CD_PARAM1) TYPE  INT4
*"     VALUE(CS_SAIRPORT) TYPE  SAIRPORT
*"  EXCEPTIONS
*"      ERRO1
*"----------------------------------------------------------------------
  ed_param1 = sy-datum.

  cd_param1 = 9.

  SELECT SINGLE *
    FROM sairport
    INTO es_sairport
   WHERE id = 'ACA'.

  SELECT SINGLE *
    FROM sairport
    INTO cs_sairport
   WHERE id = 'ACE'.

  SELECT *
    FROM sairport
    INTO TABLE et_sairport.
ENDFUNCTION.
