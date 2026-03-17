CONSTANTS: c_task_insert TYPE bus_ei_object_task VALUE 'I'.

  DATA:
    s_bp            TYPE cvis_ei_extern,
    t_bp            TYPE cvis_ei_extern_t,
    t_address       TYPE bus_ei_bupa_address_t,
    t_role          TYPE bus_ei_bupa_roles_t,
    t_ident_numbers TYPE bus_ei_bupa_identification_t,
    t_taxnumbers    TYPE bus_ei_bupa_taxnumber_t,
    t_return        TYPE bapiretm,
    v_bu_partner    TYPE bu_partner.

  DATA: ld_title_key TYPE tsad3t-title.
  DATA: ls_bapiret2  TYPE bapiret2.
  DATA: ld_test      TYPE flag.

  CLEAR ed_error.

  " Create GUID for new BP
  TRY.
    DATA(v_guid) = cl_system_uuid=>if_system_uuid_static~create_uuid_c32( ).
  CATCH cx_uuid_error INTO DATA(r_uuid_exc).
    ed_error = 'X'.

    CLEAR ls_bapiret2.
    ls_bapiret2-type    = 'E'.
    ls_bapiret2-message = |Erro ao gerar GUID: { r_uuid_exc->get_text( ) }|.
    APPEND ls_bapiret2 TO et_bapiret2.
    RETURN.
  ENDTRY.

  " -------------------------------------------------------------------------------------------------
  " parceiro: dados centrais
  " -------------------------------------------------------------------------------------------------
  s_bp-partner-header-object_task                                          = c_task_insert.
  s_bp-partner-header-object_instance-bpartnerguid                         = v_guid.
  s_bp-partner-header-object_instance-bpartner                             = is_data-partner.

  s_bp-partner-central_data-common-data-bp_control-category                = '2'.           " Category: 1 for Person, 2 for Organization, 3 for Group
  s_bp-partner-central_data-common-data-bp_control-grouping                = is_data-ktokk. " The grouping depends on the system settings

  CLEAR ld_title_key.

  SELECT SINGLE title
    INTO ld_title_key
    FROM tsad3t
   WHERE title_medi = is_data-anred
     and langu      = 'P'.

  s_bp-partner-central_data-common-data-bp_centraldata-title_key           = ld_title_key.  " 0003 Empresa (TSAD3)
  s_bp-partner-central_data-common-data-bp_centraldata-searchterm1         = is_data-sortl. " Termo de Pesquisa
  s_bp-partner-central_data-common-data-bp_organization-name1              = is_data-name1. " Nome da empresa
  s_bp-partner-central_data-common-data-bp_centraldata-partnerlanguage     = 'P'.
  s_bp-partner-central_data-common-data-bp_centraldata-partnerlanguageiso  = 'PT'.
  s_bp-partner-central_data-taxnumber-common-data-nat_person               = ''.

  s_bp-partner-central_data-common-datax-bp_centraldata-title_key          = 'X'.
  s_bp-partner-central_data-common-datax-bp_centraldata-searchterm1        = 'X'.
  s_bp-partner-central_data-common-datax-bp_organization-name1             = 'X'.
  s_bp-partner-central_data-common-datax-bp_centraldata-partnerlanguage    = 'X'.
  s_bp-partner-central_data-common-datax-bp_centraldata-partnerlanguageiso = 'X'.

  s_bp-partner-central_data-taxnumber-common-datax-nat_person              = 'X'.

  "s_bp-partner-ukmbp_data-profile-data-risk_class                          = '006'.
  "s_bp-partner-ukmbp_data-profile-datax-risk_class                         = 'X'.

  " parceiro: telefones
  APPEND INITIAL LINE TO s_bp-partner-central_data-communication-phone-phone
    ASSIGNING FIELD-SYMBOL(<ls_phone>).
  <ls_phone>-contact-data-telephone  = is_data-telf1.
  <ls_phone>-contact-datax-telephone = 'X'.

  " parceiro: fax
  IF is_data-telfx <> ''.
    APPEND INITIAL LINE TO s_bp-partner-central_data-communication-fax-fax
      ASSIGNING FIELD-SYMBOL(<ls_fax>).
    <ls_fax>-contact-data-fax  = is_data-telfx.
    <ls_fax>-contact-datax-fax = 'X'.
  ENDIF.

  " parceiro: email
  IF is_data-email <> ''.
    APPEND INITIAL LINE TO s_bp-partner-central_data-communication-smtp-smtp
      ASSIGNING FIELD-SYMBOL(<ls_smtp>).
    <ls_smtp>-contact-data-e_mail  = is_data-email.
    <ls_smtp>-contact-datax-e_mail = 'X'.
  ENDIF.

  " parceiro: site
  IF is_data-knurl <> ''.
    APPEND INITIAL LINE TO s_bp-partner-central_data-communication-uri-uri
      ASSIGNING FIELD-SYMBOL(<ls_uri>).
    <ls_uri>-contact-data-uri       = is_data-knurl.
    <ls_uri>-contact-data-uri_type  = 'HPG'.
    <ls_uri>-contact-datax-uri      = 'X'.
    <ls_uri>-contact-datax-uri_type = 'X'.
  ENDIF.

  " parceiro: endereço
  APPEND INITIAL LINE TO t_address ASSIGNING FIELD-SYMBOL(<fs_address>).
  <fs_address>-task                             = c_task_insert.

  <fs_address>-data_key-operation               = 'XXDFLT'. "Standard operation
  <fs_address>-data-postal-data-standardaddress = 'X'.
  <fs_address>-data-postal-data-city            = is_data-ort01.
  <fs_address>-data-postal-data-district        = is_data-ort02.
  <fs_address>-data-postal-data-postl_cod1      = is_data-pstlz.
  "<fs_address>-data-postal-data-taxjurcode      = ''.
  <fs_address>-data-postal-data-region          = is_data-regio.
  <fs_address>-data-postal-data-street          = is_data-stras.
  "<fs_address>-data-postal-data-house_no        = ''.
  "<fs_address>-data-postal-data-time_zone       = ''.
  <fs_address>-data-postal-data-country         = is_data-land1.
  <fs_address>-data-postal-data-langu           = 'P'.
  <fs_address>-data-postal-data-languiso        = 'PT'.
  "<fs_address>-data-postal-data-transpzone      = ''.

  <fs_address>-data-postal-datax-city           = abap_true.
  <fs_address>-data-postal-datax-district       = abap_true.
  <fs_address>-data-postal-datax-postl_cod1     = abap_true.
  "<fs_address>-data-postal-datax-taxjurcode     = abap_true.
  <fs_address>-data-postal-datax-street         = abap_true.
  "<fs_address>-data-postal-datax-house_no       = abap_true.
  <fs_address>-data-postal-datax-country        = abap_true.
  <fs_address>-data-postal-datax-region         = abap_true.
  <fs_address>-data-postal-datax-langu          = abap_true.
  <fs_address>-data-postal-datax-langu_iso      = abap_true.
  "<fs_address>-data-postal-datax-transpzone     = abap_true.

  " telefone
  APPEND INITIAL LINE TO <fs_address>-data-communication-phone-phone ASSIGNING FIELD-SYMBOL(<ls_phone3>).
  <ls_phone3>-contact-data-telephone            = is_data-telf1.
  <ls_phone3>-contact-datax-telephone           = 'X'.

  s_bp-partner-central_data-address-addresses   = t_address.

  " parceiro: roles
  APPEND INITIAL LINE TO t_role ASSIGNING FIELD-SYMBOL(<fs_role>).
  <fs_role>-task     = c_task_insert.
  <fs_role>-data_key = 'FLVN00'. " Fornecedor (FI)

  APPEND INITIAL LINE TO t_role ASSIGNING <fs_role>.
  <fs_role>-task     = c_task_insert.
  <fs_role>-data_key = 'FLVN01'. " Fornecedor (MM)

  s_bp-partner-central_data-role-roles = t_role.

  " -------------------------------------------------------------------------------------------------
  " fornecedor: dados
  " -------------------------------------------------------------------------------------------------
  s_bp-vendor-header-object_task                     = 'I'.
  s_bp-vendor-central_data-address-task              = 'I'.
*  s_bp-vendor-central_data-address-postal-data-name  = p_pnome.
*  s_bp-vendor-central_data-central-data-cfopc        = '00'.
*  s_bp-vendor-central_data-central-data-katr10       = 'SUB'.
  s_bp-vendor-central_data-central-data-sperr        = 'X'.
  "s_bp-vendor-central_data-central-data-brsch        = is_data-brsch. " Setor Industrial
*
*  s_bp-vendor-central_data-address-postal-datax-name = 'X'.
*  s_bp-vendor-central_data-central-datax-cfopc       = 'X'.
*  s_bp-vendor-central_data-central-datax-katr10      = 'X'.
  s_bp-vendor-central_data-central-datax-sperr       = 'X'.
  "s_bp-vendor-central_data-central-datax-brsch       = 'X'.

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
      CLEAR ls_bapiret2.
      ls_bapiret2-type    = s_return_map-type.
      ls_bapiret2-id      = s_return_map-id.
      ls_bapiret2-number  = s_return_map-number.
      ls_bapiret2-message = s_return_map-message.
      APPEND ls_bapiret2 TO et_bapiret2.
    ENDLOOP.

    ed_error = 'X'.
    RETURN.
  ENDIF.

  " inserindo parceiro
  INSERT s_bp INTO TABLE t_bp.

  cl_md_bp_maintain=>maintain(
    EXPORTING
      i_data     = t_bp
      i_test_run = ld_test
    IMPORTING
      e_return   = t_return
  ).

  LOOP AT t_return INTO DATA(s_return).
    LOOP AT s_return-object_msg INTO DATA(s_msg).
      IF s_msg-type = 'E' OR s_msg-type = 'A'.
        ed_error = abap_true.
      ENDIF.

      CLEAR ls_bapiret2.
      ls_bapiret2-type    = s_msg-type.
      ls_bapiret2-id      = s_msg-id.
      ls_bapiret2-number  = s_msg-number.
      ls_bapiret2-message = s_msg-message.
      APPEND ls_bapiret2 TO et_bapiret2.
    ENDLOOP.
  ENDLOOP.

  IF ed_error IS INITIAL.
    CASE ld_test.
      WHEN abap_true.
*       Test mode
        " OK
      WHEN abap_false.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
        " Get number of new BP (it's not returned by the API)
        IMPORT lv_partner TO v_bu_partner FROM MEMORY ID 'BUP_MEMORY_PARTNER'.
    ENDCASE.
  ENDIF.
