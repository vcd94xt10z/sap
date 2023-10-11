REPORT ZCADBP_PJ.

SELECTION-SCREEN BEGIN OF BLOCK main WITH FRAME TITLE text-001.
  PARAMETERS p_sort1 TYPE char30.
  PARAMETERS p_pnome TYPE char30.
  PARAMETERS p_unome TYPE char30.
  PARAMETERS p_cnpj  TYPE char14.
  PARAMETERS p_ie    TYPE char14.
  PARAMETERS p_im    TYPE char14.
  PARAMETERS p_pernr TYPE PERSNO.
SELECTION-SCREEN END OF BLOCK main.

SELECTION-SCREEN BEGIN OF BLOCK addr WITH FRAME TITLE text-002.
  PARAMETERS p_rua    TYPE char35.
  PARAMETERS p_num    TYPE char35.
  PARAMETERS p_bairro TYPE char35.
  PARAMETERS p_cidade TYPE char35.
  PARAMETERS p_uf     TYPE char2.
  PARAMETERS p_cep    TYPE char20.
  PARAMETERS p_txjcd  TYPE txjcd.
  PARAMETERS p_zonat  TYPE char20.
  PARAMETERS p_pais   TYPE land1.
  PARAMETERS p_fuso   TYPE char20.
  PARAMETERS p_tel    TYPE char20.
SELECTION-SCREEN END OF BLOCK addr.

SELECTION-SCREEN BEGIN OF BLOCK bank WITH FRAME TITLE text-003.
  PARAMETERS p_bankn TYPE bankn.  " Nº conta bancária
  PARAMETERS p_banks TYPE banks.  " Chave do país/região do banco
  PARAMETERS p_bankl TYPE bankl.  " Nº da agência bancária
SELECTION-SCREEN END OF BLOCK bank.

SELECTION-SCREEN BEGIN OF BLOCK company WITH FRAME TITLE text-004.
  PARAMETERS p_bukrs TYPE bukrs.  " Empresa
  PARAMETERS p_akont TYPE akont.  " Conta de reconciliação
  PARAMETERS p_fdgrv TYPE fdgrv.  " Planning Group
  PARAMETERS p_zwels TYPE dzwels. " Métodos de pagamento
  PARAMETERS p_vzskz TYPE dzwels. " Interest Indicator
SELECTION-SCREEN END OF BLOCK company.

SELECTION-SCREEN BEGIN OF BLOCK sales WITH FRAME TITLE text-004.
  PARAMETERS p_vkorg TYPE vkorg. " Org. vendas
  PARAMETERS p_vtweg TYPE vtweg. " Canal de vendas
  PARAMETERS p_spart TYPE spart. " Divisão

  PARAMETERS p_bzirk TYPE bzirk. " Região de vendas
  PARAMETERS p_kdgrp TYPE kdgrp. " Grupo de clientes
  PARAMETERS p_vkbur TYPE vkbur. " Escritório de vendas
  PARAMETERS p_vkgrp TYPE vkgrp. " Equipe de vendas
  PARAMETERS p_awahr TYPE awahr. " Probabilidade de ordem do item
  PARAMETERS p_waers TYPE waers. " Moeda
  PARAMETERS p_kurst TYPE kurst. " Categoria da taxa de câmbio
  PARAMETERS p_kalks TYPE kalks. " Classificação clientes p/determinação do esquema de cálculo
  PARAMETERS p_versg TYPE versg. " Grupo estatístico cliente
  PARAMETERS p_lprio TYPE lprio. " Prioridade de remessa
  PARAMETERS p_vwerk TYPE vwerk. " Centro fornecedor (próprio ou externo)
  PARAMETERS p_vsbed TYPE vsbed. " Condição de expedição
  PARAMETERS p_antlf TYPE antlf. " Número máximo de fornecimentos parciais permitidos por item
  PARAMETERS p_inco1 TYPE inco1. " Incoterms parte 1
  PARAMETERS p_inco2 TYPE inco2.
  PARAMETERS p_ktgrd TYPE ktgrd. " Bloqueio de ordem para cliente (área de vendas)
  PARAMETERS p_aufsd TYPE aufsd_x. " Bloqueio de contatos para cliente(área de vendas e distrib.)
  PARAMETERS p_cassd TYPE cassd_v. " Bloqueio de contatos para cliente(área de vendas e distrib.)
SELECTION-SCREEN END OF BLOCK sales.

SELECTION-SCREEN BEGIN OF BLOCK options WITH FRAME TITLE text-005.
  PARAMETERS p_test  TYPE flag.
  PARAMETERS p_debug TYPE flag.
SELECTION-SCREEN END OF BLOCK options.

INITIALIZATION.
  " endereço
  p_sort1  = 'APELIDO'.
  p_pnome  = 'NOME COMPLETO'.
  p_rua    = 'RUA TESTE'.
  p_num    = '123'.
  p_bairro = 'VILA TESTE'.
  p_cep    = '88888-000'.
  p_cidade = 'CIDADE TESTE'.
  p_pais   = 'BR'.
  p_uf     = 'SP'.
  p_txjcd  = 'SP 123456'.
  p_zonat  = '0000001'.
  p_fuso   = 'BRAZIL'.
  p_tel    = '11 99998888'.

  " documentos
  p_cnpj   = '12345678910'.
  p_ie     = '1111111'.
  p_im     = 'ISENTO'.

  " dados da empresa
  p_bukrs  = '7000'.
  p_akont  = '123456'.
  p_fdgrv  = '001'.
  p_zwels  = 'ABCDE'.
  p_vzskz  = 'P0'.

  " dados de venda
  p_vkorg = '7000'.
  p_vtweg = '10'.
  p_spart = '00'.

  p_bzirk = 'BR0001'.
  p_kdgrp = '01'.
  p_vkbur = '100'.
  p_vkgrp = '100'.
  p_awahr = '100'.
  p_waers = 'BRL'.
  p_kurst = 'B'.
  p_kalks = '1'.
  p_versg = '1'.
  p_lprio = '2'.
  p_vwerk = '7000'.
  p_vsbed = '01'.
  p_antlf = '1'.
  p_inco1 = 'CIF'.
  p_inco2 = 'TESTE'.
  p_ktgrd = '01'.
  p_aufsd = '01'.
  p_cassd = 'X'.

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

  " Create GUID for new BP
  TRY.
      DATA(v_guid) = cl_system_uuid=>if_system_uuid_static~create_uuid_c32( ).
    CATCH cx_uuid_error INTO DATA(r_uuid_exc).
      MESSAGE r_uuid_exc->get_text( ) TYPE 'E'.
  ENDTRY.

  " -------------------------------------------------------------------------------------------------
  " parceiro: dados centrais
  " -------------------------------------------------------------------------------------------------
  s_bp-partner-header-object_task                                          = c_task_insert.
  s_bp-partner-header-object_instance-bpartnerguid                         = v_guid.

  s_bp-partner-central_data-common-data-bp_control-category                = '2'.    " Category: 1 for Person, 2 for Organization, 3 for Group
  s_bp-partner-central_data-common-data-bp_control-grouping                = 'PNPJ'. " The grouping depends on the system settings

  s_bp-partner-central_data-common-data-bp_centraldata-title_key           = '0003'.
  s_bp-partner-central_data-common-data-bp_centraldata-searchterm1         = p_sort1.
  s_bp-partner-central_data-common-data-bp_organization-name1              = p_pnome.
  s_bp-partner-central_data-common-data-bp_centraldata-partnerlanguage     = 'P'.
  s_bp-partner-central_data-common-data-bp_centraldata-partnerlanguageiso  = 'PT'.
  s_bp-partner-central_data-taxnumber-common-data-nat_person               = ''.

  s_bp-partner-central_data-common-datax-bp_centraldata-title_key          = 'X'.
  s_bp-partner-central_data-common-datax-bp_centraldata-searchterm1        = 'X'.
  s_bp-partner-central_data-common-datax-bp_organization-name1             = 'X'.
  s_bp-partner-central_data-common-datax-bp_centraldata-partnerlanguage    = 'X'.
  s_bp-partner-central_data-common-datax-bp_centraldata-partnerlanguageiso = 'X'.

  s_bp-partner-central_data-taxnumber-common-datax-nat_person              = 'X'.

  s_bp-partner-ukmbp_data-profile-data-risk_class                          = '006'.
  s_bp-partner-ukmbp_data-profile-datax-risk_class                         = 'X'.

  " parceiro: telefones
  APPEND INITIAL LINE TO s_bp-partner-central_data-communication-phone-phone
    ASSIGNING FIELD-SYMBOL(<ls_phone>).
  <ls_phone>-contact-data-telephone  = p_tel.
  <ls_phone>-contact-datax-telephone = 'X'.

  " parceiro: documentos

  " Inscrição Federal (CNPJ)
  APPEND INITIAL LINE TO t_taxnumbers ASSIGNING FIELD-SYMBOL(<fs_taxnumbers>).
  <fs_taxnumbers>-task               = c_task_insert.
  <fs_taxnumbers>-data_key-taxtype   = 'BR1'.
  <fs_taxnumbers>-data_key-taxnumber = p_cnpj.
  s_bp-partner-central_data-taxnumber-taxnumbers = t_taxnumbers.

  " Inscrição Estadual (IE)
  APPEND INITIAL LINE TO t_taxnumbers ASSIGNING <fs_taxnumbers>.
  <fs_taxnumbers>-task               = c_task_insert.
  <fs_taxnumbers>-data_key-taxtype   = 'BR3'.
  <fs_taxnumbers>-data_key-taxnumber = p_ie.
  s_bp-partner-central_data-taxnumber-taxnumbers = t_taxnumbers.

  " Inscrição Municipal (IM)
  APPEND INITIAL LINE TO t_taxnumbers ASSIGNING <fs_taxnumbers>.
  <fs_taxnumbers>-task               = c_task_insert.
  <fs_taxnumbers>-data_key-taxtype   = 'BR4'.
  <fs_taxnumbers>-data_key-taxnumber = p_im.
  s_bp-partner-central_data-taxnumber-taxnumbers = t_taxnumbers.

  " parceiro: endereço
  APPEND INITIAL LINE TO t_address ASSIGNING FIELD-SYMBOL(<fs_address>).
  <fs_address>-task                             = c_task_insert.

  <fs_address>-data_key-operation               = 'XXDFLT'. "Standard operation
  <fs_address>-data-postal-data-standardaddress = 'X'.
  <fs_address>-data-postal-data-city            = p_cidade.
  <fs_address>-data-postal-data-district        = p_bairro.
  <fs_address>-data-postal-data-postl_cod1      = p_cep.
  <fs_address>-data-postal-data-taxjurcode      = p_txjcd.
  <fs_address>-data-postal-data-region          = p_uf.
  <fs_address>-data-postal-data-street          = p_rua.
  <fs_address>-data-postal-data-house_no        = p_num.
  <fs_address>-data-postal-data-time_zone       = P_fuso.
  <fs_address>-data-postal-data-country         = p_pais.
  <fs_address>-data-postal-data-langu           = 'P'.
  <fs_address>-data-postal-data-languiso        = 'PT'.
  <fs_address>-data-postal-data-transpzone      = p_zonat.

  <fs_address>-data-postal-datax-city           = abap_true.
  <fs_address>-data-postal-datax-district       = abap_true.
  <fs_address>-data-postal-datax-postl_cod1     = abap_true.
  <fs_address>-data-postal-datax-taxjurcode     = abap_true.
  <fs_address>-data-postal-datax-street         = abap_true.
  <fs_address>-data-postal-datax-house_no       = abap_true.
  <fs_address>-data-postal-datax-country        = abap_true.
  <fs_address>-data-postal-datax-region         = abap_true.
  <fs_address>-data-postal-datax-langu          = abap_true.
  <fs_address>-data-postal-datax-langu_iso      = abap_true.
  <fs_address>-data-postal-datax-transpzone     = abap_true.

  " telefone
  APPEND INITIAL LINE TO <fs_address>-data-communication-phone-phone ASSIGNING FIELD-SYMBOL(<ls_phone3>).
  <ls_phone3>-contact-data-telephone            = p_tel.
  <ls_phone3>-contact-datax-telephone           = 'X'.

  s_bp-partner-central_data-address-addresses   = t_address.

  " parceiro: dados bancários
*  APPEND INITIAL LINE TO s_bp-partner-central_data-bankdetail-bankdetails ASSIGNING FIELD-SYMBOL(<ls_bankdetails>).
*  <ls_bankdetails>-task = 'I'.
*  <ls_bankdetails>-data-bank_acct     = p_bankn. " Nº conta bancária
*  <ls_bankdetails>-data-bank_ctry     = p_banks. " País
*  <ls_bankdetails>-data-bank_ctryiso  = p_banks. " País
*  <ls_bankdetails>-data-bank_key      = p_bankl. " Chave do banco
*  <ls_bankdetails>-data-ctrl_key      = '8x'.    " Chave de controle de bancos
*
*  <ls_bankdetails>-datax-bank_acct    = 'X'.
*  <ls_bankdetails>-datax-bank_ctry    = 'X'.
*  <ls_bankdetails>-datax-bank_ctryiso = 'X'.
*  <ls_bankdetails>-datax-bank_key     = 'X'.
*  <ls_bankdetails>-datax-ctrl_key     = 'X'.

  " parceiro: roles
  APPEND INITIAL LINE TO t_role ASSIGNING FIELD-SYMBOL(<fs_role>).
  <fs_role>-task     = c_task_insert.
  <fs_role>-data_key = 'FLCU00'. " FI Customer

  APPEND INITIAL LINE TO t_role ASSIGNING <fs_role>.
  <fs_role>-task     = c_task_insert.
  <fs_role>-data_key = 'FLCU01'. " Customer

  s_bp-partner-central_data-role-roles = t_role.

  " -------------------------------------------------------------------------------------------------
  " cliente: dados
  " -------------------------------------------------------------------------------------------------
  s_bp-customer-header-object_task                     = 'I'.
  s_bp-customer-central_data-address-task              = 'I'.
  s_bp-customer-central_data-address-postal-data-name  = p_pnome.
  s_bp-customer-central_data-central-data-cfopc        = '00'.
  s_bp-customer-central_data-central-data-katr10       = 'SUB'.
  s_bp-customer-central_data-central-data-sperr        = 'X'.

  s_bp-customer-central_data-address-postal-datax-name = 'X'.
  s_bp-customer-central_data-central-datax-cfopc       = 'X'.
  s_bp-customer-central_data-central-datax-katr10      = 'X'.
  s_bp-customer-central_data-central-datax-sperr       = 'X'.

  " cliente: telefones
  APPEND INITIAL LINE TO s_bp-customer-central_data-address-communication-phone-phone
    ASSIGNING FIELD-SYMBOL(<ls_phone2>).
  <ls_phone2>-contact-data-telephone  = p_tel.
  <ls_phone2>-contact-datax-telephone = 'X'.

  " cliente: dados da empresa
  APPEND INITIAL LINE TO s_bp-customer-company_data-company ASSIGNING FIELD-SYMBOL(<ls_company>).
  <ls_company>-data_key-bukrs = p_bukrs.

  <ls_company>-data-akont  = p_akont.
  <ls_company>-data-fdgrv  = p_fdgrv.
  <ls_company>-data-xzver  = 'X'.
  <ls_company>-data-zwels  = p_zwels.
  <ls_company>-data-vzskz  = p_vzskz.
  <ls_company>-data-sperr  = 'X'.

  <ls_company>-datax-akont = 'X'.
  <ls_company>-datax-fdgrv = 'X'.
  <ls_company>-datax-xzver = 'X'.
  <ls_company>-datax-zwels = 'X'.
  <ls_company>-datax-vzskz = 'X'.
  <ls_company>-datax-sperr = 'X'.

  " cliente: dados de vendas
  APPEND INITIAL LINE TO s_bp-customer-sales_data-sales ASSIGNING FIELD-SYMBOL(<ls_sales>).
  <ls_sales>-data_key-vkorg = p_vkorg.
  <ls_sales>-data_key-vtweg = p_vtweg.
  <ls_sales>-data_key-spart = P_spart.

  " aba: orders
  <ls_sales>-data-bzirk     = p_bzirk. " Sales District
  <ls_sales>-data-kdgrp     = p_kdgrp. " Customer Group
  <ls_sales>-data-vkbur     = p_vkbur. " Sales Office
  <ls_sales>-data-vkgrp     = p_vkgrp. " Sales Group
  <ls_sales>-data-awahr     = p_awahr. " Order Probability of Item (DI)
  <ls_sales>-data-waers     = p_waers. " Currency
  <ls_sales>-data-kurst     = p_kurst. " Exchange Rate Type
  <ls_sales>-data-kalks     = p_kalks. " Customer Classification for Pricing Procedure Determination
  <ls_sales>-data-versg     = p_versg. " Customer Statistics Group

  " aba: shipping
  <ls_sales>-data-lprio     = p_lprio. " Delivery Priority (DI)
  <ls_sales>-data-vwerk     = p_vwerk. " Delivering Plant (Own or External)
  <ls_sales>-data-vsbed     = p_vsbed. " Shipping Conditions
  <ls_sales>-data-antlf     = p_antlf. " Maximum Number of Permitted Part Deliveries per Item (DI)

  " aba: billing
  <ls_sales>-data-inco1     = p_inco1. " Incoterms (Part 1)
  <ls_sales>-data-inco2     = p_inco2.
  <ls_sales>-data-ktgrd     = p_ktgrd.

  " aba: status
  <ls_sales>-data-aufsd     = p_aufsd. " Central order block for customer
  <ls_sales>-data-cassd     = p_cassd. " Central sales block for customer

  " aba: orders
  <ls_sales>-datax-bzirk     = 'X'.
  <ls_sales>-datax-kdgrp     = 'X'.
  <ls_sales>-datax-vkbur     = 'X'.
  <ls_sales>-datax-vkgrp     = 'X'.
  <ls_sales>-datax-awahr     = 'X'.
  <ls_sales>-datax-waers     = 'X'.
  <ls_sales>-datax-kurst     = 'X'.
  <ls_sales>-datax-kalks     = 'X'.
  <ls_sales>-datax-versg     = 'X'.

  " aba: shipping
  <ls_sales>-datax-lprio     = 'X'.
  <ls_sales>-datax-vwerk     = 'X'.
  <ls_sales>-datax-vsbed     = 'X'.
  <ls_sales>-datax-antlf     = 'X'.

  " aba: billing
  <ls_sales>-datax-inco1     = 'X'.
  <ls_sales>-datax-inco2     = 'X'.
  <ls_sales>-datax-ktgrd     = 'X'.

  " aba: status
  <ls_sales>-datax-aufsd     = 'X'.
  <ls_sales>-datax-cassd     = 'X'.

  BREAK-POINT.

  " validações
  cl_md_bp_maintain=>validate_single(
    EXPORTING
      i_data        = s_bp
    IMPORTING
      et_return_map = DATA(t_return_map)
  ).

  IF line_exists( t_return_map[ type = 'E' ] ) OR
     line_exists( t_return_map[ type = 'A' ] ).
    LOOP AT t_return_map INTO DATA(s_return_map).
      WRITE:/ s_return_map-id, s_return_map-number, s_return_map-message.
    ENDLOOP.
    EXIT.
  ENDIF.

  " inserindo parceiro
  INSERT s_bp INTO TABLE t_bp.

  cl_md_bp_maintain=>maintain(
    EXPORTING
      i_data     = t_bp
      i_test_run = p_test
    IMPORTING
      e_return   = t_return
  ).

  LOOP AT t_return INTO DATA(s_return).
    LOOP AT s_return-object_msg INTO DATA(s_msg).
      IF s_msg-type = 'E' OR s_msg-type = 'A'.
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
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
        " Get number of new BP (it's not returned by the API)
        IMPORT lv_partner TO v_bu_partner FROM MEMORY ID 'BUP_MEMORY_PARTNER'.
        WRITE:/ |Business Partner { v_bu_partner } has been created.|.
    ENDCASE.
  ENDIF.
