*
* Versão 0.1
*
REPORT ZCAD_CLIENTE_ECC.

CONSTANTS : C_UPDATE TYPE C VALUE 'M',
            C_INSERT TYPE C VALUE 'I'.

DATA: ls_address               TYPE bapiad1vl,
      ls_addressx              TYPE bapiad1vlx,
      "ls_bankdetail_st        TYPE cvis_ei_cvi_bankdetail,
      "ls_bankdetail           TYPE cvis_ei_bankdetail,
      ls_company_code_st       TYPE cmds_ei_company,
      ls_company_code          TYPE cmds_ei_cmd_company,
      ls_customer              TYPE cmds_ei_extern,
      ls_customers             TYPE cmds_ei_main,
      ls_master_data_correct   TYPE cmds_ei_main,
      ls_master_data_defective TYPE cmds_ei_main,
      ls_message_correct       TYPE cvis_message,
      ls_message_defective     TYPE cvis_message.

DATA: ls_functions_st  TYPE cmds_ei_functions,
      lt_functions_st  TYPE cmds_ei_functions_t,
      ls_sales_data_st TYPE cmds_ei_sales,
      lt_sales         TYPE cmds_ei_sales_t,
      ls_sales_data    TYPE cmds_ei_sales_data.

DATA: ls_smtp  TYPE cvis_ei_smtp_str.
DATA: ls_phone TYPE cvis_ei_phone_str.

SELECTION-SCREEN BEGIN OF BLOCK main WITH FRAME.
  PARAMETERS: p_bukrs TYPE bukrs.
  PARAMETERS: p_vkorg TYPE vkorg.
  PARAMETERS: p_vtweg TYPE vtweg.
  PARAMETERS: p_spart TYPE spart.
  PARAMETERS: p_ktokd TYPE ktokd.
  PARAMETERS: p_kunnr TYPE kunnr.
SELECTION-SCREEN END OF BLOCK main.

START-OF-SELECTION.
  CLEAR ls_customers.

  " Dados Gerais
  CLEAR ls_address.
  ls_address-title      = '0003'. " Tabela TSAD3
  ls_address-name       = 'Mercearia Paulista'.
  ls_address-city       = 'São Paulo'.
  ls_address-postl_cod1 = '04578-000'.
  ls_address-street     = 'Rua das mercearias'.
  ls_address-region     = 'SP'.
  ls_address-country    = 'BR'.
  ls_address-langu      = 'EN'.
  ls_address-taxjurcode = 'SP 5030'. " Domicílio fiscal
  ls_address-sort1      = 'MERCEARIA'.
  ls_address-sort2      = 'PAULISTA'.
  ls_address-time_zone  = 'UTC-3'.

  " Empresa
  CLEAR ls_company_code_st.
  ls_company_code_st-data_key-bukrs = p_bukrs.
  ls_company_code_st-data-akont     = '0000140000'. " Conta de reconciliação
  ls_company_code_st-data-zuawa     = '001'.
  ls_company_code_st-data-zwels     = 'AD'. " Formas de pagamento
  ls_company_code_st-data-zterm     = '0001'. " Condição de pagamento

  ls_customer-central_data-central-data-stcd1 = '23021782000140'. " CNPJ
  ls_customer-central_data-central-data-cfopc = '00'.
  ls_customer-central_data-central-data-ktokd = p_ktokd. " Grupo de contas
  ls_customer-central_data-address-postal-data  = ls_address.
  ls_customer-central_data-address-postal-datax = ls_addressx.

  ls_smtp-contact-data-e_mail = 'mercearia.paulista@teste.com'.
  APPEND ls_smtp TO ls_customer-central_data-address-communication-smtp-smtp.

  ls_phone-contact-data-telephone = '551132323333'.
  APPEND ls_phone TO ls_customer-central_data-address-communication-phone-phone.

  ls_phone-contact-data-telephone = '5511999998888'.
  ls_phone-contact-data-r_3_user = '3'.
  APPEND ls_phone TO ls_customer-central_data-address-communication-phone-phone.

  ls_company_code_st-task = c_insert.
  APPEND ls_company_code_st TO ls_company_code-company.

  " Área de vendas
  ls_customer-sales_data-current_state = 'X'.
  ls_sales_data_st-data_key-vkorg = p_vkorg.
  ls_sales_data_st-data_key-vtweg = p_vtweg.
  ls_sales_data_st-data_key-spart = p_spart.
  ls_sales_data-kalks = '1'.
  ls_sales_data-vsbed = '02'.
  ls_sales_data-waers = 'BRL'.
*  ls_sales_data-bzirk = ''.
*  ls_sales_data-vkbur = ''.
*  ls_sales_data-vkgrp = ''.
*  ls_sales_data-klabc = ''.
*  ls_sales_data-konda = ''.

  "ls_sales_data-zterm = '0001'.
  "ls_sales_data-versg = '1'.
  "ls_sales_data-aufsd = '01'.
  "ls_sales_data-inco1 = 'FOB'.
  "ls_sales_data-inco2 = 'Correios'.
  ls_sales_data_st-data = ls_sales_data.

  " Funções do parceiro
  ls_functions_st-data_key-parvw = 'AG'.
  ls_functions_st-data-defpa     = 'X'.
  ls_functions_st-data-partner   = ls_customer-header-object_instance-kunnr.
  APPEND ls_functions_st TO lt_functions_st.

  CLEAR: ls_functions_st.
  ls_functions_st-data_key-parvw = 'RE'.
  ls_functions_st-data-defpa     = 'X'.
  ls_functions_st-data-partner   = ls_customer-header-object_instance-kunnr.
  APPEND ls_functions_st TO  lt_functions_st.

  CLEAR: ls_functions_st.
  ls_functions_st-data_key-parvw = 'RG'.
  ls_functions_st-data-defpa     = 'X'.
  ls_functions_st-data-partner   = ls_customer-header-object_instance-kunnr.
  APPEND ls_functions_st TO  lt_functions_st.

  CLEAR: ls_functions_st.
  ls_functions_st-data_key-parvw = 'WE'.
  ls_functions_st-data-defpa     = 'X'.
  ls_functions_st-data-partner   = ls_customer-header-object_instance-kunnr.
  APPEND ls_functions_st TO  lt_functions_st.

  CLEAR: ls_functions_st.
  ls_sales_data_st-functions-current_state = 'X'.
  ls_sales_data_st-functions-functions = lt_functions_st.
  APPEND ls_sales_data_st TO lt_sales.

  ls_customer-sales_data-sales              = lt_sales.
  ls_customer-header-object_instance-kunnr  = p_kunnr.
  ls_customer-header-object_task            = c_insert.
  ls_customer-company_data                  = ls_company_code.
  APPEND ls_customer TO ls_customers-customers.

  CLEAR ls_master_data_correct.
  CLEAR ls_message_correct.
  CLEAR ls_master_data_defective.
  CLEAR ls_message_defective.

  CALL METHOD cmd_ei_api=>maintain_bapi
    EXPORTING
      iv_test_run              = ''
      iv_collect_messages      = 'X'
      is_master_data           = ls_customers
    IMPORTING
      es_master_data_correct   = ls_master_data_correct
      es_message_correct       = ls_message_correct
      es_master_data_defective = ls_master_data_defective
      es_message_defective     = ls_message_defective.

  IF ls_message_defective-is_error IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    MESSAGE 'Cliente cadastrado' TYPE 'S'.

    SET PARAMETER ID 'KUN' FIELD p_kunnr.
    CALL TRANSACTION 'XD03'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    CALL FUNCTION 'RSCRMBW_DISPLAY_BAPIRET2'
      TABLES
        it_return = ls_message_defective-messages.
  ENDIF.
