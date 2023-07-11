class ZCL_ECC_TO_S4HANA definition
  public
  final
  create public .

public section.

  class-methods CLASS_CONSTRUCTOR .
  class-methods SHOW_BP
    importing
      value(ID_KUNNR) type KUNNR optional
      value(ID_LIFNR) type LIFNR optional
    exceptions
      ERROR .
  class-methods GET_PARTNER_BY_KUNNR
    importing
      value(ID_KUNNR) type KUNNR
    returning
      value(RD_PARTNER) type PARTNER .
  class-methods GET_PARTNER_BY_LIFNR
    importing
      value(ID_LIFNR) type LIFNR
    returning
      value(RD_PARTNER) type PARTNER .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ECC_TO_S4HANA IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_ECC_TO_S4HANA=>CLASS_CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
method CLASS_CONSTRUCTOR.
*
* Autor Vinicius Cesar Dias
* https://github.com/vcd94xt10z
* Ultima atualização: 11/07/2023
*
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_ECC_TO_S4HANA=>GET_PARTNER_BY_KUNNR
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_KUNNR                       TYPE        KUNNR
* | [<-()] RD_PARTNER                     TYPE        PARTNER
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_PARTNER_BY_KUNNR.
*
* Autor Vinicius Cesar Dias
* https://github.com/vcd94xt10z
*
  DATA ld_partner_guid TYPE cvi_cust_link-partner_guid.

  CLEAR rd_partner.

  SELECT SINGLE partner_guid
    FROM cvi_cust_link
    INTO ld_partner_guid
   WHERE customer = id_kunnr.

  IF sy-subrc = 0.
    CALL FUNCTION 'BUPA_NUMBERS_GET'
      EXPORTING
        iv_partner_guid = ld_partner_guid
      IMPORTING
        ev_partner      = rd_partner.
  ELSE.
    SELECT SINGLE partner
      FROM bd001
      INTO rd_partner
     WHERE kunnr = id_kunnr.
  ENDIF.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_ECC_TO_S4HANA=>GET_PARTNER_BY_LIFNR
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_LIFNR                       TYPE        LIFNR
* | [<-()] RD_PARTNER                     TYPE        PARTNER
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_PARTNER_BY_LIFNR.
*
* Autor Vinicius Cesar Dias
* https://github.com/vcd94xt10z
*
  DATA ld_partner_guid TYPE cvi_vend_link-partner_guid.

  CLEAR rd_partner.

  SELECT SINGLE partner_guid
    FROM cvi_vend_link
    INTO ld_partner_guid
   WHERE vendor = id_lifnr.

  IF sy-subrc = 0.
    CALL FUNCTION 'BUPA_NUMBERS_GET'
      EXPORTING
        iv_partner_guid = ld_partner_guid
      IMPORTING
        ev_partner      = rd_partner.
  ELSE.
    SELECT SINGLE partner
      FROM bc001
      INTO rd_partner
     WHERE lifnr = id_lifnr.
  ENDIF.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_ECC_TO_S4HANA=>SHOW_BP
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_KUNNR                       TYPE        KUNNR(optional)
* | [--->] ID_LIFNR                       TYPE        LIFNR(optional)
* | [EXC!] ERROR
* +--------------------------------------------------------------------------------------</SIGNATURE>
method SHOW_BP.
*
* Autor Vinicius Cesar Dias
* https://github.com/vcd94xt10z
*
  DATA: ld_partner TYPE bus_partner-number.
  DATA: ls_role    TYPE bus_roles.
  DATA: lo_error   TYPE REF TO cx_root.

  CLEAR ld_partner.

  IF id_kunnr IS NOT INITIAL.
    ld_partner = get_partner_by_kunnr( id_kunnr = id_kunnr ).
  ELSEIF id_lifnr IS NOT INITIAL.
    ld_partner = get_partner_by_lifnr( id_lifnr = id_lifnr ).
  ENDIF.

  IF ld_partner = ''.
    RETURN.
  ENDIF.

  DATA(lo_request) = NEW cl_bupa_navigation_request( ).
  DATA(lo_options) = NEW cl_bupa_dialog_joel_options( ).

  lo_request->set_partner_number( ld_partner ).
  lo_request->set_bupa_activity( lo_request->gc_activity_display ). " 01 - Create, 02 - Change, 03 - Display
  lo_options->set_navigation_disabled( abap_true ).
  lo_options->set_bupr_create_not_allowed( abap_true ).
  lo_options->set_activity_switching_off( abap_true ).

  lo_request->set_bupa_partner_role( ls_role ).

  IF id_lifnr IS NOT INITIAL.
    ls_role-role = 'FLVN00'.
    lo_request->set_bupa_sub_header_id( 'FLVN01' ).
  ELSEIF id_kunnr IS NOT INITIAL.
    ls_role-role = 'FLCU00'.
    lo_request->set_bupa_sub_header_id( 'FLCU01' ).
  ENDIF.

  lo_options->set_activity_switching_off( abap_true ).

  TRY.
    cl_bupa_dialog_joel=>start_with_navigation(
      iv_request = lo_request
      iv_options = lo_options
    ).
  CATCH cx_root INTO lo_error.
    RAISE error.
  ENDTRY.
endmethod.
ENDCLASS.