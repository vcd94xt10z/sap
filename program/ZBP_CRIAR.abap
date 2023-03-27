*
* Autor Vinicius Cesar Dias
* Criado em 27/03/2023
* Report modificado, original em:
* https://blogs.sap.com/2022/10/13/create-business-partner-via-api-class-cl_md_bp_maintain/
*
REPORT ZBP_CRIAR.

SELECTION-SCREEN BEGIN OF BLOCK main WITH FRAME TITLE text-001.
  PARAMETERS p_pnome TYPE char30 DEFAULT 'Nome 1'.
  PARAMETERS p_unome TYPE char30 DEFAULT 'Nome 2'.
  PARAMETERS p_cpf   TYPE char11 DEFAULT '123456789'.
  PARAMETERS p_pernr TYPE PERSNO DEFAULT '0000001'.
SELECTION-SCREEN END OF BLOCK main.

SELECTION-SCREEN BEGIN OF BLOCK addr WITH FRAME TITLE text-002.
  PARAMETERS p_rua    TYPE char35 DEFAULT 'RUA TESTE'.
  PARAMETERS p_bairro TYPE char35 DEFAULT 'BAIRRO TESTE'.
  PARAMETERS p_cidade TYPE char35 DEFAULT 'SAO PAULO'.
  PARAMETERS p_uf     TYPE char2  DEFAULT 'SP'.
  PARAMETERS p_cep    TYPE char10 DEFAULT '99999-999'.
  PARAMETERS p_txjcd  TYPE txjcd  DEFAULT 'SP 123456'.
SELECTION-SCREEN END OF BLOCK addr.

SELECTION-SCREEN BEGIN OF BLOCK bank WITH FRAME TITLE text-003.
  PARAMETERS p_bankn TYPE bankn DEFAULT '1090364'.  " Nº conta bancária
  PARAMETERS p_banks TYPE banks DEFAULT 'BR'.       " Chave do país/região do banco
  PARAMETERS p_bankl TYPE bankl DEFAULT '23720320'. " Nº da agência bancária
SELECTION-SCREEN END OF BLOCK bank.

SELECTION-SCREEN BEGIN OF BLOCK options WITH FRAME TITLE text-004.
  PARAMETERS p_test  TYPE flag.
  PARAMETERS p_debug TYPE flag.
SELECTION-SCREEN END OF BLOCK options.

START-OF-SELECTION.
  CONSTANTS: c_task_insert   TYPE bus_ei_object_task VALUE 'I'.

  DATA:
    s_bp            TYPE cvis_ei_extern,
    t_bp            TYPE cvis_ei_extern_t,
    t_address       TYPE bus_ei_bupa_address_t,
    t_role          TYPE bus_ei_bupa_roles_t,
    t_ident_numbers TYPE bus_ei_bupa_identification_t,
    t_taxnumbers    TYPE bus_ei_bupa_taxnumber_t,
    t_return        TYPE bapiretm,
    v_bu_partner    TYPE bu_partner,
    v_error         TYPE abap_bool.

  IF p_debug = 'X'.
    BREAK-POINT.
  ENDIF.

*------------------------------------------------------------------------------
* Create GUID for new BP
*------------------------------------------------------------------------------
  TRY.
      DATA(v_guid) = cl_system_uuid=>if_system_uuid_static~create_uuid_c32( ).
    CATCH cx_uuid_error INTO DATA(r_uuid_exc).
      MESSAGE r_uuid_exc->get_text( ) TYPE 'E'.
  ENDTRY.

*------------------------------------------------------------------------------
* Header and common central data
*------------------------------------------------------------------------------
  s_bp-partner-header-object_task = c_task_insert. "'I' for new BP
  s_bp-partner-header-object_instance-bpartnerguid = v_guid.

  s_bp-partner-central_data-common-data-bp_control-category = '1'.    " Category: 1 for Person, 2 for Organization, 3 for Group
  s_bp-partner-central_data-common-data-bp_control-grouping = 'Z001'. " The grouping depends on the system settings

  s_bp-partner-central_data-common-data-bp_centraldata-searchterm1        = p_pnome.
  s_bp-partner-central_data-common-data-bp_person-firstname               = p_pnome.
  s_bp-partner-central_data-common-data-bp_person-lastname                = p_unome.
  s_bp-partner-central_data-common-data-bp_person-correspondlanguage      = 'P'.
  s_bp-partner-central_data-common-data-bp_person-correspondlanguageiso   = 'PT'.
  s_bp-partner-central_data-common-data-bp_centraldata-partnerlanguage    = 'P'.
  s_bp-partner-central_data-common-data-bp_centraldata-partnerlanguageiso = 'PT'.

* Mark as changed
  s_bp-partner-central_data-common-datax-bp_person-firstname             = abap_true.
  s_bp-partner-central_data-common-datax-bp_person-lastname              = abap_true.
  s_bp-partner-central_data-common-datax-bp_person-correspondlanguage    = abap_true.
  s_bp-partner-central_data-common-datax-bp_person-correspondlanguageiso = abap_true.

  s_bp-partner-central_data-common-datax-bp_centraldata-partnerlanguage    = 'X'.
  s_bp-partner-central_data-common-datax-bp_centraldata-partnerlanguageiso = 'X'.

  s_bp-partner-central_data-taxnumber-common-data-nat_person = 'X'.

*------------------------------------------------------------------------------
* VAT number (needed for BPs located in the EU)
*
* Number is normally validated by function module VAT_REGISTRATION_NUMBER_CHECK
* Tax types are stored in table TFKTAXNUMTYPE
*------------------------------------------------------------------------------
  APPEND INITIAL LINE TO t_taxnumbers ASSIGNING FIELD-SYMBOL(<fs_taxnumbers>).
  <fs_taxnumbers>-task               = c_task_insert.
  <fs_taxnumbers>-data_key-taxtype   = 'BR2'.
  <fs_taxnumbers>-data_key-taxnumber = p_cpf.
  s_bp-partner-central_data-taxnumber-taxnumbers = t_taxnumbers.

*------------------------------------------------------------------------------
* Address data
*------------------------------------------------------------------------------
  APPEND INITIAL LINE TO t_address ASSIGNING FIELD-SYMBOL(<fs_address>).
  <fs_address>-task = c_task_insert.

* Operations are store in table TB008S
  <fs_address>-data_key-operation               = 'XXDFLT'. "Standard operation
  <fs_address>-data-postal-data-standardaddress = 'X'.
  <fs_address>-data-postal-data-city            = p_cidade.
  <fs_address>-data-postal-data-district        = p_bairro.
  <fs_address>-data-postal-data-postl_cod1      = p_cep.
  <fs_address>-data-postal-data-taxjurcode      = p_txjcd.
  <fs_address>-data-postal-data-region          = p_uf.
  <fs_address>-data-postal-data-street          = p_rua.
  <fs_address>-data-postal-data-country         = 'BR'.
  <fs_address>-data-postal-data-langu           = 'P'.
  <fs_address>-data-postal-data-languiso        = 'PT'.

* Mark as changed
  <fs_address>-data-postal-datax-city           = abap_true.
  <fs_address>-data-postal-datax-district       = abap_true.
  <fs_address>-data-postal-datax-postl_cod1     = abap_true.
  <fs_address>-data-postal-datax-taxjurcode     = abap_true.
  <fs_address>-data-postal-datax-street         = abap_true.
  <fs_address>-data-postal-datax-country        = abap_true.
  <fs_address>-data-postal-datax-region         = abap_true.
  <fs_address>-data-postal-datax-langu          = abap_true.
  <fs_address>-data-postal-datax-langu_iso      = abap_true.

* Add address to main structure
  s_bp-partner-central_data-address-addresses = t_address.

  " dados bancários (BUS_EI_STRUC_BANKDETAIL)
  APPEND INITIAL LINE TO s_bp-partner-central_data-bankdetail-bankdetails ASSIGNING FIELD-SYMBOL(<ls_bankdetails>).
  <ls_bankdetails>-task = 'I'.
  <ls_bankdetails>-data-bank_acct     = p_bankn. " Nº conta bancária
  <ls_bankdetails>-data-bank_ctry     = p_banks. " País
  <ls_bankdetails>-data-bank_ctryiso  = p_banks. " País
  <ls_bankdetails>-data-bank_key      = p_bankl. " Chave do banco
  <ls_bankdetails>-data-ctrl_key      = '8x'.    " Chave de controle de bancos

  <ls_bankdetails>-datax-bank_acct    = 'X'.
  <ls_bankdetails>-datax-bank_ctry    = 'X'.
  <ls_bankdetails>-datax-bank_ctryiso = 'X'.
  <ls_bankdetails>-datax-bank_key     = 'X'.
  <ls_bankdetails>-datax-ctrl_key     = 'X'.

  " fornecedor
  s_bp-vendor-central_data-address-postal-data-langu      = 'P'.
  s_bp-vendor-central_data-address-postal-data-langu_iso  = 'PT'.
  s_bp-vendor-central_data-address-postal-datax-langu     = 'X'.
  s_bp-vendor-central_data-address-postal-datax-langu_iso = 'X'.

  " dados da empresa
  APPEND INITIAL LINE TO s_bp-vendor-company_data-company ASSIGNING FIELD-SYMBOL(<ls_company>).
  <ls_company>-task = 'I'.
  <ls_company>-data_key-bukrs = '1000'.
  <ls_company>-data-akont     = '00123456'.
  <ls_company>-data-fdgrv     = 'F00'.
  <ls_company>-data-pernr     = p_pernr.
  <ls_company>-data-zterm     = 'F000'.
  <ls_company>-data-reprf     = 'X'.
  <ls_company>-data-zwels     = 'CEOTU'.

  <ls_company>-datax-akont    = 'X'.
  <ls_company>-datax-fdgrv    = 'X'.
  <ls_company>-datax-pernr    = 'X'.
  <ls_company>-datax-zterm    = 'X'.
  <ls_company>-datax-reprf    = 'X'.
  <ls_company>-datax-zwels    = 'X'.

  " dados de compras
  APPEND INITIAL LINE TO s_bp-vendor-purchasing_data-purchasing ASSIGNING FIELD-SYMBOL(<ls_purchasing>).
  <ls_purchasing>-task = 'I'.
  <ls_purchasing>-data_key-ekorg = '1000'.
  <ls_purchasing>-data-waers     = 'BRL'.
  <ls_purchasing>-datax-waers    = 'X'.

*------------------------------------------------------------------------------
* Roles
*------------------------------------------------------------------------------
  APPEND INITIAL LINE TO t_role ASSIGNING FIELD-SYMBOL(<fs_role>).
  <fs_role>-task     = c_task_insert.
  <fs_role>-data_key = 'FLVN00'.

  APPEND INITIAL LINE TO t_role ASSIGNING <fs_role>.
  <fs_role>-task     = c_task_insert.
  <fs_role>-data_key = 'FLVN01'.

* Add role to main structure
  s_bp-partner-central_data-role-roles = t_role.

*------------------------------------------------------------------------------
* Validate data
*------------------------------------------------------------------------------
  cl_md_bp_maintain=>validate_single(
    EXPORTING
      i_data        = s_bp
    IMPORTING
      et_return_map = DATA(t_return_map)
  ).

  IF line_exists( t_return_map[ type = 'E' ] ) OR
     line_exists( t_return_map[ type = 'A' ] ).
    LOOP AT t_return_map INTO DATA(s_return_map).
      WRITE:/ s_return_map-message.
    ENDLOOP.
    EXIT.
  ENDIF.

*------------------------------------------------------------------------------
* Call API
*------------------------------------------------------------------------------
* Add single BP to IMPORTING table
  INSERT s_bp INTO TABLE t_bp.

  cl_md_bp_maintain=>maintain(
    EXPORTING
      i_data     = t_bp
      i_test_run = p_test
    IMPORTING
      e_return   = t_return
  ).

* Check result
  LOOP AT t_return INTO DATA(s_return).
    LOOP AT s_return-object_msg INTO DATA(s_msg).
      IF s_msg-type = 'E' OR s_msg-type = 'A'.
*       Error occurred
        v_error = abap_true.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
  IF v_error IS INITIAL.
    CASE p_test.
      WHEN abap_true.
*       Test mode
        " OK
      WHEN abap_false.
*       Non-test mode => Perform COMMIT
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
*       Get number of new BP (it's not returned by the API)
        IMPORT lv_partner TO v_bu_partner FROM MEMORY ID 'BUP_MEMORY_PARTNER'.
        WRITE:/ |Business Partner { v_bu_partner } has been created.|.
    ENDCASE.
  ENDIF.
