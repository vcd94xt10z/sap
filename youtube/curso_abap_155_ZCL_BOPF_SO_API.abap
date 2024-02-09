*
* Autor Vinicius Cesar Dias
* Versão 0.2
*
class ZCL_BOPF_SO_API definition
  public
  create public .

public section.

  methods ACTION
    importing
      !ID_ACTION type /BOBF/ACT_KEY
      !ID_SOID type INT4
    exporting
      !ET_MESSAGE type BAPIRET2_T .
  methods CONSTRUCTOR .
  methods CREATE
    importing
      !IS_HEADER type ZBO_SOHEADER_CS
      !IT_ITEM type ZBO_SOITEM_CTT
    exporting
      !ET_MESSAGE type BAPIRET2_T .
  methods DELETE
    importing
      !ID_SOID type INT4
    exporting
      !ET_MESSAGE type BAPIRET2_T .
  methods READ_ALL
    exporting
      !ET_HEADER type ZBO_SOHEADER_CTT
      !ET_MESSAGE type BAPIRET2_T .
  methods READ_SINGLE
    importing
      !ID_SOID type INT4
    exporting
      !ES_HEADER type ZBO_SOHEADER_CS
      !ET_ITEM type ZBO_SOITEM_CTT
      !ET_MESSAGE type BAPIRET2_T .
  methods UPDATE
    importing
      !IS_HEADER type ZBO_SOHEADER_CS
      !IT_ITEM type ZBO_SOITEM_CTT
    exporting
      !ET_MESSAGE type BAPIRET2_T .
protected section.
private section.

  data MO_TXN_MNGR type ref to /BOBF/IF_TRA_TRANSACTION_MGR .
  data MO_SVC_MNGR type ref to /BOBF/IF_TRA_SERVICE_MANAGER .
  data MO_BO_CONF type ref to /BOBF/IF_FRW_CONFIGURATION .

  methods CONVERT_MESSAGES
    importing
      !IO_MESSAGE type ref to /BOBF/IF_FRW_MESSAGE
    exporting
      !ET_MESSAGE type BAPIRET2_T .
  methods GET_NODE_ROW
    importing
      !IV_KEY type /BOBF/CONF_KEY
      !IV_NODE_KEY type /BOBF/OBM_NODE_KEY
      !IV_EDIT_MODE type /BOBF/CONF_EDIT_MODE default /BOBF/IF_CONF_C=>SC_EDIT_READ_ONLY
      !IV_INDEX type I optional
    returning
      value(RR_DATA) type ref to DATA
    raising
      /BOBF/CX_DAC .
  methods GET_NODE_ROW_BY_ASSOC
    importing
      !IV_KEY type /BOBF/CONF_KEY
      !IV_NODE_KEY type /BOBF/OBM_NODE_KEY
      !IV_ASSOC_KEY type /BOBF/OBM_ASSOC_KEY
      !IV_EDIT_MODE type /BOBF/CONF_EDIT_MODE default                                   /BOBF/IF_CONF_C=>SC_EDIT_READ_ONLY
      !IV_INDEX type I optional
    returning
      value(RR_DATA) type ref to DATA
    raising
      /BOBF/CX_DAC .
  methods GET_NODE_TABLE
    importing
      !IV_KEY type /BOBF/CONF_KEY
      !IV_NODE_KEY type /BOBF/OBM_NODE_KEY
      !IV_EDIT_MODE type /BOBF/CONF_EDIT_MODE default /BOBF/IF_CONF_C=>SC_EDIT_READ_ONLY
    returning
      value(RR_DATA) type ref to DATA
    raising
      /BOBF/CX_DAC .
  methods GET_NODE_TABLE_BY_ASSOC
    importing
      !IV_KEY type /BOBF/CONF_KEY
      !IV_NODE_KEY type /BOBF/OBM_NODE_KEY
      !IV_ASSOC_KEY type /BOBF/OBM_ASSOC_KEY
      !IV_EDIT_MODE type /BOBF/CONF_EDIT_MODE default /BOBF/IF_CONF_C=>SC_EDIT_READ_ONLY
    returning
      value(RR_DATA) type ref to DATA
    raising
      /BOBF/CX_DAC .
  methods GET_SOID_KEY
    importing
      !ID_SOID type INT4
    returning
      value(RD_KEY) type STRING .
ENDCLASS.



CLASS ZCL_BOPF_SO_API IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_BOPF_SO_API->ACTION
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_ACTION                      TYPE        /BOBF/ACT_KEY
* | [--->] ID_SOID                        TYPE        INT4
* | [<---] ET_MESSAGE                     TYPE        BAPIRET2_T
* +--------------------------------------------------------------------------------------</SIGNATURE>
method ACTION.
  DATA lv_soid_key   TYPE /bobf/conf_key.
  DATA lt_mod        TYPE /bobf/t_frw_modification.
  DATA lo_change     TYPE REF TO /bobf/if_tra_change.
  DATA lo_message    TYPE REF TO /bobf/if_frw_message.
  DATA lv_rejected   TYPE boole_d.
  DATA lx_bopf_ex    TYPE REF TO /bobf/cx_frw.
  DATA lv_err_msg    TYPE string.

  DATA lr_s_root     TYPE REF TO zbo_soheader_cs.
  DATA lr_s_item     TYPE REF TO zbo_soitem_cs.
  DATA ls_message    LIKE LINE OF et_message.

  DATA ls_header     TYPE zbo_soheader_cs.
  DATA lt_key        TYPE /bobf/t_frw_key.

  FIELD-SYMBOLS: <ls_mod> LIKE LINE OF lt_mod.

  CLEAR et_message.

  TRY.
    me->read_single(
      EXPORTING
        id_soid    = id_soid
      IMPORTING
        es_header  = ls_header
    ).

    me->mo_svc_mngr->do_action(
      EXPORTING
        iv_act_key = id_action
        it_key     = VALUE #( ( key = ls_header-key ) )
      IMPORTING
        eo_message = lo_message
    ).

    IF lo_message IS BOUND.
      IF lo_message->check( ) EQ abap_true.
        me->convert_messages(
          EXPORTING
            io_message = lo_message
          IMPORTING
            et_message = et_message
        ).
        RETURN.
      ENDIF.
    ENDIF.

    CALL METHOD me->mo_txn_mngr->save
      IMPORTING
        eo_message  = lo_message
        ev_rejected = lv_rejected.

    IF lv_rejected EQ abap_true.
      me->convert_messages(
        EXPORTING
          io_message = lo_message
        IMPORTING
          et_message = et_message
      ).
      RETURN.
    ENDIF.

    CLEAR ls_message.
    ls_message-type    = 'S'.
    ls_message-message = 'Ação executada'.
    APPEND ls_message TO et_message.
  CATCH /bobf/cx_frw INTO lx_bopf_ex.
    lv_err_msg = lx_bopf_ex->get_text( ).

    CLEAR ls_message.
    ls_message-type    = 'E'.
    ls_message-message = lv_err_msg.
    APPEND ls_message TO et_message.
  ENDTRY.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_BOPF_SO_API->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
method CONSTRUCTOR.
  me->mo_txn_mngr = /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( ).
  me->mo_svc_mngr = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( zif_zbo_so_c=>sc_bo_key ).
  me->mo_bo_conf  = /bobf/cl_frw_factory=>get_configuration( zif_zbo_so_c=>sc_bo_key ).
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_BOPF_SO_API->CONVERT_MESSAGES
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_MESSAGE                     TYPE REF TO /BOBF/IF_FRW_MESSAGE
* | [<---] ET_MESSAGE                     TYPE        BAPIRET2_T
* +--------------------------------------------------------------------------------------</SIGNATURE>
method CONVERT_MESSAGES.
  DATA lt_message  TYPE /bobf/t_frw_message_k.
  DATA lv_msg_text TYPE string.
  DATA ls_message  LIKE LINE OF et_message.

  FIELD-SYMBOLS <ls_message> LIKE LINE OF lt_message.

  IF io_message IS NOT BOUND.
    RETURN.
  ENDIF.

  CALL METHOD io_message->get_messages
    IMPORTING
      et_message = lt_message.

  LOOP AT lt_message ASSIGNING <ls_message>.
    lv_msg_text = <ls_message>-message->get_text( ).

    CLEAR ls_message.
    ls_message-type    = <ls_message>-severity.
    ls_message-message = lv_msg_text.
    APPEND ls_message TO et_message.
  ENDLOOP.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_BOPF_SO_API->CREATE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_HEADER                      TYPE        ZBO_SOHEADER_CS
* | [--->] IT_ITEM                        TYPE        ZBO_SOITEM_CTT
* | [<---] ET_MESSAGE                     TYPE        BAPIRET2_T
* +--------------------------------------------------------------------------------------</SIGNATURE>
method CREATE.
  DATA lt_mod      TYPE /bobf/t_frw_modification.
  DATA lo_change   TYPE REF TO /bobf/if_tra_change.
  DATA lo_message  TYPE REF TO /bobf/if_frw_message.
  DATA lv_rejected TYPE boole_d.
  DATA lx_bopf_ex  TYPE REF TO /bobf/cx_frw.
  DATA lv_err_msg  TYPE string.

  DATA lr_s_root   TYPE REF TO zbo_soheader_cs.
  DATA lr_s_item   TYPE REF TO zbo_soitem_cs.

  DATA ls_item     LIKE LINE OF it_item.
  DATA ls_messsage LIKE LINE OF et_message.

  FIELD-SYMBOLS: <ls_mod> LIKE LINE OF lt_mod.

  CLEAR et_message.

  TRY.
    " cabeçalho
    CREATE DATA lr_s_root.

    lr_s_root->key        = /bobf/cl_frw_factory=>get_new_key( ).
    lr_s_root->soid       = is_header-soid.
    lr_s_root->customerid = is_header-customerid.
    lr_s_root->status     = is_header-status.

    APPEND INITIAL LINE TO lt_mod ASSIGNING <ls_mod>.
    <ls_mod>-node        = zif_zbo_so_c=>sc_node-root.
    <ls_mod>-change_mode = /bobf/if_frw_c=>sc_modify_create.
    <ls_mod>-key         = lr_s_root->key.
    <ls_mod>-data        = lr_s_root.

    " item
    LOOP AT it_item INTO ls_item.
      CREATE DATA lr_s_item.
      lr_s_item->key       = /bobf/cl_frw_factory=>get_new_key( ).
      lr_s_item->itemid    = ls_item-itemid.
      lr_s_item->matnr     = ls_item-matnr.
      lr_s_item->maktx     = ls_item-maktx.
      lr_s_item->quantity  = ls_item-quantity.
      lr_s_item->price_uni = ls_item-price_uni.
      lr_s_item->price_tot = lr_s_item->price_uni * lr_s_item->quantity.

      APPEND INITIAL LINE TO lt_mod ASSIGNING <ls_mod>.
      <ls_mod>-node        = zif_zbo_so_c=>sc_node-item.
      <ls_mod>-change_mode = /bobf/if_frw_c=>sc_modify_create.
      <ls_mod>-source_node = zif_zbo_so_c=>sc_node-root.
      <ls_mod>-association = zif_zbo_so_c=>sc_association-root-item.
      <ls_mod>-source_key  = lr_s_root->key.
      <ls_mod>-key         = lr_s_item->key.
      <ls_mod>-data        = lr_s_item.
    ENDLOOP.

    " persistencia
    CALL METHOD mo_svc_mngr->modify
      EXPORTING
        it_modification = lt_mod
      IMPORTING
        eo_change       = lo_change
        eo_message      = lo_message.

    IF lo_message IS BOUND.
      IF lo_message->check( ) EQ abap_true.
        me->convert_messages(
          EXPORTING
            io_message = lo_message
          IMPORTING
            et_message = et_message
        ).
        RETURN.
      ENDIF.
    ENDIF.

    CALL METHOD mo_txn_mngr->save
      IMPORTING
        eo_message  = lo_message
        ev_rejected = lv_rejected.

    IF lv_rejected EQ abap_true.
      me->convert_messages(
          EXPORTING
            io_message = lo_message
          IMPORTING
            et_message = et_message
        ).
        RETURN.
    ENDIF.

    CLEAR ls_messsage.
    ls_messsage-type    = 'S'.
    ls_messsage-message = 'Instância criada'.
    APPEND ls_messsage TO et_message.
  CATCH /bobf/cx_frw INTO lx_bopf_ex.
    lv_err_msg = lx_bopf_ex->get_text( ).

    CLEAR ls_messsage.
    ls_messsage-type    = 'E'.
    ls_messsage-message = lv_err_msg.
    APPEND ls_messsage TO et_message.
  ENDTRY.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_BOPF_SO_API->DELETE
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_SOID                        TYPE        INT4
* | [<---] ET_MESSAGE                     TYPE        BAPIRET2_T
* +--------------------------------------------------------------------------------------</SIGNATURE>
method DELETE.
  DATA lt_mod        TYPE /bobf/t_frw_modification.
  DATA lo_change     TYPE REF TO /bobf/if_tra_change.
  DATA lo_message    TYPE REF TO /bobf/if_frw_message.
  DATA lv_rejected   TYPE boole_d.
  DATA lx_bopf_ex    TYPE REF TO /bobf/cx_frw.
  DATA lv_err_msg    TYPE string.

  DATA lr_s_root     TYPE REF TO zbo_soheader_cs.
  DATA lr_s_item     TYPE REF TO zbo_soitem_cs.
  DATA ls_message    LIKE LINE OF et_message.

  DATA ls_header_ori TYPE zbo_soheader_cs.
  DATA lt_item_ori   TYPE zbo_soitem_ctt.
  DATA ls_item_ori   LIKE LINE OF lt_item_ori.

  FIELD-SYMBOLS: <ls_mod> LIKE LINE OF lt_mod.

  CLEAR et_message.

  TRY.
    me->read_single(
      EXPORTING
        id_soid    = id_soid
      IMPORTING
        es_header  = ls_header_ori
        et_item    = lt_item_ori
    ).

    lr_s_root ?= me->get_node_row(
      iv_key       = ls_header_ori-key
      iv_node_key  = zif_zbo_so_c=>sc_node-root
      iv_edit_mode = /bobf/if_conf_c=>sc_edit_exclusive
      iv_index     = 1
    ).

    APPEND INITIAL LINE TO lt_mod ASSIGNING <ls_mod>.
    <ls_mod>-node        = zif_zbo_so_c=>sc_node-root.
    <ls_mod>-change_mode = /bobf/if_frw_c=>sc_modify_delete.
    <ls_mod>-key         = lr_s_root->key.
    <ls_mod>-data        = lr_s_root.

    CALL METHOD me->mo_svc_mngr->modify
      EXPORTING
        it_modification = lt_mod
      IMPORTING
        eo_change       = lo_change
        eo_message      = lo_message.

    IF lo_message IS BOUND.
      IF lo_message->check( ) EQ abap_true.
        me->convert_messages(
          EXPORTING
            io_message = lo_message
          IMPORTING
            et_message = et_message
        ).
        RETURN.
      ENDIF.
    ENDIF.

    CALL METHOD me->mo_txn_mngr->save
      IMPORTING
        eo_message  = lo_message
        ev_rejected = lv_rejected.

    IF lv_rejected EQ abap_true.
      me->convert_messages(
        EXPORTING
          io_message = lo_message
        IMPORTING
          et_message = et_message
      ).
      RETURN.
    ENDIF.

    CLEAR ls_message.
    ls_message-type    = 'S'.
    ls_message-message = 'Instância removida'.
    APPEND ls_message TO et_message.
  CATCH /bobf/cx_frw INTO lx_bopf_ex.
    lv_err_msg = lx_bopf_ex->get_text( ).

    CLEAR ls_message.
    ls_message-type    = 'E'.
    ls_message-message = lv_err_msg.
    APPEND ls_message TO et_message.
  ENDTRY.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_BOPF_SO_API->GET_NODE_ROW
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_KEY                         TYPE        /BOBF/CONF_KEY
* | [--->] IV_NODE_KEY                    TYPE        /BOBF/OBM_NODE_KEY
* | [--->] IV_EDIT_MODE                   TYPE        /BOBF/CONF_EDIT_MODE (default =/BOBF/IF_CONF_C=>SC_EDIT_READ_ONLY)
* | [--->] IV_INDEX                       TYPE        I(optional)
* | [<-()] RR_DATA                        TYPE REF TO DATA
* | [!CX!] /BOBF/CX_DAC
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_NODE_ROW.
  DATA lr_t_data TYPE REF TO data.

  FIELD-SYMBOLS <lt_data> TYPE INDEX TABLE.
  FIELD-SYMBOLS <ls_row>  TYPE ANY.

  lr_t_data = get_node_table(
    iv_key       = iv_key
    iv_node_key  = iv_node_key
    iv_edit_mode = iv_edit_mode
  ).

  IF lr_t_data IS NOT BOUND.
    RAISE EXCEPTION TYPE /bobf/cx_dac.
  ENDIF.

  ASSIGN lr_t_data->* TO <lt_data>.

  IF iv_index IS SUPPLIED.
    READ TABLE <lt_data> INDEX iv_index ASSIGNING <ls_row>.
    IF sy-subrc EQ 0.
      GET REFERENCE OF <ls_row> INTO rr_data.
    ELSE.
      RAISE EXCEPTION TYPE /bobf/cx_dac.
    ENDIF.
  ELSE.
    rr_data = lr_t_data.
  ENDIF.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_BOPF_SO_API->GET_NODE_ROW_BY_ASSOC
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_KEY                         TYPE        /BOBF/CONF_KEY
* | [--->] IV_NODE_KEY                    TYPE        /BOBF/OBM_NODE_KEY
* | [--->] IV_ASSOC_KEY                   TYPE        /BOBF/OBM_ASSOC_KEY
* | [--->] IV_EDIT_MODE                   TYPE        /BOBF/CONF_EDIT_MODE (default =                                  /BOBF/IF_CONF_C=>SC_EDIT_READ_ONLY)
* | [--->] IV_INDEX                       TYPE        I(optional)
* | [<-()] RR_DATA                        TYPE REF TO DATA
* | [!CX!] /BOBF/CX_DAC
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_NODE_ROW_BY_ASSOC.
  DATA lr_t_data TYPE REF TO data.

  FIELD-SYMBOLS <lt_data> TYPE INDEX TABLE.
  FIELD-SYMBOLS <ls_row> TYPE ANY.

  lr_t_data = get_node_table_by_assoc(
    iv_key       = iv_key
    iv_node_key  = iv_node_key
    iv_assoc_key = iv_assoc_key
    iv_edit_mode = iv_edit_mode
  ).

  IF lr_t_data IS NOT BOUND.
    RAISE EXCEPTION TYPE /bobf/cx_dac.
  ENDIF.

  IF iv_index IS SUPPLIED.
    ASSIGN lr_t_data->* TO <lt_data>.
    READ TABLE <lt_data> INDEX iv_index ASSIGNING <ls_row>.
    IF sy-subrc EQ 0.
      GET REFERENCE OF <ls_row> INTO rr_data.
    ELSE.
      RAISE EXCEPTION TYPE /bobf/cx_dac.
    ENDIF.
  ELSE.
    rr_data = lr_t_data.
  ENDIF.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_BOPF_SO_API->GET_NODE_TABLE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_KEY                         TYPE        /BOBF/CONF_KEY
* | [--->] IV_NODE_KEY                    TYPE        /BOBF/OBM_NODE_KEY
* | [--->] IV_EDIT_MODE                   TYPE        /BOBF/CONF_EDIT_MODE (default =/BOBF/IF_CONF_C=>SC_EDIT_READ_ONLY)
* | [<-()] RR_DATA                        TYPE REF TO DATA
* | [!CX!] /BOBF/CX_DAC
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_NODE_TABLE.
  DATA lt_key       TYPE /bobf/t_frw_key.
  DATA ls_node_conf TYPE /bobf/s_confro_node.
  DATA lo_change    TYPE REF TO /bobf/if_tra_change.
  DATA lo_message   TYPE REF TO /bobf/if_frw_message.

  FIELD-SYMBOLS <ls_key> LIKE LINE OF lt_key.
  FIELD-SYMBOLS <lt_data> TYPE INDEX TABLE.

  CALL METHOD mo_bo_conf->get_node
    EXPORTING
      iv_node_key = iv_node_key
    IMPORTING
      es_node     = ls_node_conf.

  CREATE DATA rr_data TYPE (ls_node_conf-data_table_type).
  ASSIGN rr_data->* TO <lt_data>.

  APPEND INITIAL LINE TO lt_key ASSIGNING <ls_key>.
  <ls_key>-key = iv_key.

  CALL METHOD mo_svc_mngr->retrieve
    EXPORTING
      iv_node_key = iv_node_key
      it_key      = lt_key
    IMPORTING
      eo_message  = lo_message
      eo_change   = lo_change
      et_data     = <lt_data>.

  IF lo_message IS BOUND.
    IF lo_message->check( ) EQ abap_true.
*      me->convert_messages(
*        EXPORTING
*          io_message = lo_message
*        IMPORTING
*          et_message = et_message
*      ).
      RAISE EXCEPTION TYPE /bobf/cx_dac.
    ENDIF.
  ENDIF.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_BOPF_SO_API->GET_NODE_TABLE_BY_ASSOC
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_KEY                         TYPE        /BOBF/CONF_KEY
* | [--->] IV_NODE_KEY                    TYPE        /BOBF/OBM_NODE_KEY
* | [--->] IV_ASSOC_KEY                   TYPE        /BOBF/OBM_ASSOC_KEY
* | [--->] IV_EDIT_MODE                   TYPE        /BOBF/CONF_EDIT_MODE (default =/BOBF/IF_CONF_C=>SC_EDIT_READ_ONLY)
* | [<-()] RR_DATA                        TYPE REF TO DATA
* | [!CX!] /BOBF/CX_DAC
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_NODE_TABLE_BY_ASSOC.
  DATA lt_key         TYPE /bobf/t_frw_key.
  DATA ls_node_conf   TYPE /bobf/s_confro_node.
  DATA ls_association TYPE /bobf/s_confro_assoc.
  DATA lo_change      TYPE REF TO /bobf/if_tra_change.
  DATA lo_message     TYPE REF TO /bobf/if_frw_message.

  FIELD-SYMBOLS <ls_key> LIKE LINE OF lt_key.
  FIELD-SYMBOLS <lt_data> TYPE INDEX TABLE.

  CALL METHOD mo_bo_conf->get_assoc
    EXPORTING
      iv_assoc_key = iv_assoc_key
      iv_node_key  = iv_node_key
    IMPORTING
      es_assoc     = ls_association.

  IF ls_association-target_node IS NOT BOUND.
    RAISE EXCEPTION TYPE /bobf/cx_dac.
  ENDIF.

  ls_node_conf = ls_association-target_node->*.

  CREATE DATA rr_data TYPE (ls_node_conf-data_table_type).
  ASSIGN rr_data->* TO <lt_data>.

  APPEND INITIAL LINE TO lt_key ASSIGNING <ls_key>.
  <ls_key>-key = iv_key.

  CALL METHOD mo_svc_mngr->retrieve_by_association
    EXPORTING
      iv_node_key    = iv_node_key
      it_key         = lt_key
      iv_association = iv_assoc_key
      iv_fill_data   = abap_true
    IMPORTING
      eo_message     = lo_message
      eo_change      = lo_change
      et_data        = <lt_data>.

  IF lo_message IS BOUND.
    IF lo_message->check( ) EQ abap_true.
      "display_messages( lo_message ).
      RAISE EXCEPTION TYPE /bobf/cx_dac.
    ENDIF.
  ENDIF.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_BOPF_SO_API->GET_SOID_KEY
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_SOID                        TYPE        INT4
* | [<-()] RD_KEY                         TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method GET_SOID_KEY.
  DATA lt_parameters TYPE /bobf/t_frw_query_selparam.
  DATA lt_keys       TYPE /bobf/t_frw_key.
  DATA lx_bopf_ex    TYPE REF TO /bobf/cx_frw.
  DATA lv_err_msg    TYPE string.

  FIELD-SYMBOLS <ls_parameter> LIKE LINE OF lt_parameters.
  FIELD-SYMBOLS <ls_key>       LIKE LINE OF lt_keys.

  CLEAR rd_key.

  APPEND INITIAL LINE TO lt_parameters ASSIGNING <ls_parameter>.
  <ls_parameter>-attribute_name = zif_zbo_so_c=>sc_query_attribute-root-select_by_element-soid.
  <ls_parameter>-sign           = 'I'.
  <ls_parameter>-option         = 'EQ'.
  <ls_parameter>-low            = id_soid.

  CALL METHOD mo_svc_mngr->query
    EXPORTING
      iv_query_key            = zif_zbo_so_c=>sc_query-root-select_by_element
      it_selection_parameters = lt_parameters
    IMPORTING
      et_key                  = lt_keys.

  READ TABLE lt_keys INDEX 1 ASSIGNING <ls_key>.
  IF sy-subrc EQ 0.
    rd_key = <ls_key>-key.
  ENDIF.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_BOPF_SO_API->READ_ALL
* +-------------------------------------------------------------------------------------------------+
* | [<---] ET_HEADER                      TYPE        ZBO_SOHEADER_CTT
* | [<---] ET_MESSAGE                     TYPE        BAPIRET2_T
* +--------------------------------------------------------------------------------------</SIGNATURE>
method READ_ALL.
  DATA lo_message TYPE REF TO /bobf/if_frw_message.

  CLEAR et_header.
  CLEAR et_message.

  mo_svc_mngr->query(
    EXPORTING
      iv_query_key = zif_zbo_so_c=>sc_query-root-select_all
      "iv_query_key = zif_zbo_so_c=>sc_query-root-select_by_element
      iv_fill_data = abap_true
    IMPORTING
      eo_message   = lo_message
      et_data      = et_header
  ).

  IF lo_message IS BOUND.
    IF lo_message->check( ) EQ abap_true.
      me->convert_messages(
        EXPORTING
          io_message = lo_message
        IMPORTING
          et_message = et_message
      ).
      RETURN.
    ENDIF.
  ENDIF.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_BOPF_SO_API->READ_SINGLE
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_SOID                        TYPE        INT4
* | [<---] ES_HEADER                      TYPE        ZBO_SOHEADER_CS
* | [<---] ET_ITEM                        TYPE        ZBO_SOITEM_CTT
* | [<---] ET_MESSAGE                     TYPE        BAPIRET2_T
* +--------------------------------------------------------------------------------------</SIGNATURE>
method READ_SINGLE.
  DATA lv_soid_key TYPE /bobf/conf_key.
  DATA lx_bopf_ex  TYPE REF TO /bobf/cx_frw.
  DATA lv_err_msg  TYPE string.
  DATA ls_item     LIKE LINE OF et_item.
  DATA ls_message  LIKE LINE OF et_message.

  DATA lr_s_root TYPE REF TO zbo_soheader_cs.
  DATA lr_s_item TYPE REF TO zbo_soitem_cs.

  DATA lt_data TYPE REF TO data.

  FIELD-SYMBOLS: <lt_data> TYPE STANDARD TABLE.

  CLEAR es_header.
  CLEAR et_item.
  CLEAR et_message.

  TRY.
    lv_soid_key = me->get_soid_key( id_soid = id_soid ).
    IF lv_soid_key IS INITIAL.
      CLEAR ls_message.
      ls_message-type    = 'E'.
      ls_message-message = 'Registro não encontrado'.
      APPEND ls_message TO et_message.
      RETURN.
    ENDIF.

    lr_s_root ?= me->get_node_row(
      iv_key      = lv_soid_key
      iv_node_key = zif_zbo_so_c=>sc_node-root
      iv_index    = 1
    ).

    " cabeçalho
    CLEAR es_header.
    es_header-key        = lr_s_root->key.
    es_header-parent_key = lr_s_root->parent_key.
    es_header-root_key   = lr_s_root->root_key.
    es_header-soid       = lr_s_root->soid.
    es_header-customerid = lr_s_root->customerid.
    es_header-erdat      = lr_s_root->erdat.
    es_header-erzet      = lr_s_root->erzet.
    es_header-status     = lr_s_root->status.

    " item
    CALL METHOD me->get_node_row_by_assoc(
      EXPORTING
        iv_key       = lv_soid_key
        iv_node_key  = zif_zbo_so_c=>sc_node-root
        iv_assoc_key = zif_zbo_so_c=>sc_association-root-item
      RECEIVING
        rr_data      = lt_data
    ).

    ASSIGN lt_data->* TO <lt_data>.
    LOOP AT <lt_data> REFERENCE INTO lr_s_item.
      CLEAR ls_item.
      ls_item-key        = lr_s_item->key.
      ls_item-parent_key = lr_s_item->parent_key.
      ls_item-root_key   = lr_s_item->root_key.
      ls_item-soid       = lr_s_item->soid.
      ls_item-itemid     = lr_s_item->itemid.
      ls_item-matnr      = lr_s_item->matnr.
      ls_item-maktx      = lr_s_item->maktx.
      ls_item-quantity   = lr_s_item->quantity.
      ls_item-price_uni  = lr_s_item->price_uni.
      ls_item-price_tot  = lr_s_item->price_tot.
      APPEND ls_item TO et_item.
    ENDLOOP.
  CATCH /bobf/cx_frw INTO lx_bopf_ex.
    lv_err_msg = lx_bopf_ex->get_text( ).

    CLEAR ls_message.
    ls_message-type    = 'E'.
    ls_message-message = lv_err_msg.
    APPEND ls_message TO et_message.
  ENDTRY.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_BOPF_SO_API->UPDATE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_HEADER                      TYPE        ZBO_SOHEADER_CS
* | [--->] IT_ITEM                        TYPE        ZBO_SOITEM_CTT
* | [<---] ET_MESSAGE                     TYPE        BAPIRET2_T
* +--------------------------------------------------------------------------------------</SIGNATURE>
method UPDATE.
  DATA lv_soid_key   TYPE /bobf/conf_key.
  DATA lt_mod        TYPE /bobf/t_frw_modification.
  DATA lo_change     TYPE REF TO /bobf/if_tra_change.
  DATA lo_message    TYPE REF TO /bobf/if_frw_message.
  DATA lv_rejected   TYPE boole_d.
  DATA lx_bopf_ex    TYPE REF TO /bobf/cx_frw.
  DATA lv_err_msg    TYPE string.

  DATA lr_s_root     TYPE REF TO zbo_soheader_cs.
  DATA lr_s_item     TYPE REF TO zbo_soitem_cs.
  DATA ls_message    LIKE LINE OF et_message.
  DATA ls_item       LIKE LINE OF it_item.

  DATA ls_header_ori TYPE zbo_soheader_cs.
  DATA lt_item_ori   TYPE zbo_soitem_ctt.
  DATA ls_item_ori   LIKE LINE OF lt_item_ori.

  FIELD-SYMBOLS: <ls_mod> LIKE LINE OF lt_mod.

  CLEAR et_message.

  TRY.
    me->read_single(
      EXPORTING
        id_soid    = is_header-soid
      IMPORTING
        es_header  = ls_header_ori
        et_item    = lt_item_ori
    ).

    lr_s_root ?= me->get_node_row(
      iv_key       = ls_header_ori-key
      iv_node_key  = zif_zbo_so_c=>sc_node-root
      iv_edit_mode = /bobf/if_conf_c=>sc_edit_exclusive
      iv_index     = 1
    ).

    " cabeçalho
    lr_s_root->customerid = is_header-customerid.
    lr_s_root->status     = is_header-status.

    APPEND INITIAL LINE TO lt_mod ASSIGNING <ls_mod>.
    <ls_mod>-node        = zif_zbo_so_c=>sc_node-root.
    <ls_mod>-change_mode = /bobf/if_frw_c=>sc_modify_update.
    <ls_mod>-key         = lr_s_root->key.
    <ls_mod>-data        = lr_s_root.

    " item
    LOOP AT it_item INTO ls_item.
      CLEAR ls_item_ori.
      READ TABLE lt_item_ori INTO ls_item_ori WITH KEY itemid = ls_item-itemid.

      CREATE DATA lr_s_item.
      lr_s_item->key        = ls_item_ori-key.
      lr_s_item->parent_key = ls_item_ori-parent_key.
      lr_s_item->root_key   = ls_item_ori-root_key.
      lr_s_item->soid       = ls_item-soid.
      lr_s_item->itemid     = ls_item-itemid.
      lr_s_item->matnr      = ls_item-matnr.
      lr_s_item->maktx      = ls_item-maktx.
      lr_s_item->quantity   = ls_item-quantity.
      lr_s_item->price_uni  = ls_item-price_uni.
      lr_s_item->price_tot  = lr_s_item->price_uni * lr_s_item->quantity.

      IF lr_s_item->key IS INITIAL.
        " criação de item
        lr_s_item->key        = /bobf/cl_frw_factory=>get_new_key( ).
        lr_s_item->parent_key = lr_s_root->key.
        lr_s_item->root_key   = lr_s_root->key.

        APPEND INITIAL LINE TO lt_mod ASSIGNING <ls_mod>.
        <ls_mod>-node        = zif_zbo_so_c=>sc_node-item.
        <ls_mod>-change_mode = /bobf/if_frw_c=>sc_modify_create.
        <ls_mod>-source_node = zif_zbo_so_c=>sc_node-root.
        <ls_mod>-association = zif_zbo_so_c=>sc_association-root-item.
        <ls_mod>-source_key  = lr_s_root->key.
        <ls_mod>-key         = lr_s_item->key.
        <ls_mod>-data        = lr_s_item.
      ELSE.
        " atualização de item
        APPEND INITIAL LINE TO lt_mod ASSIGNING <ls_mod>.
        <ls_mod>-node        = zif_zbo_so_c=>sc_node-item.
        <ls_mod>-change_mode = /bobf/if_frw_c=>sc_modify_update.
        <ls_mod>-key         = lr_s_item->key.
        <ls_mod>-data        = lr_s_item.
      ENDIF.
    ENDLOOP.

    " remoção de item
    LOOP AT lt_item_ori INTO ls_item_ori.
      READ TABLE it_item INTO ls_item WITH KEY itemid = ls_item_ori-itemid.
      IF sy-subrc = 4.
        APPEND INITIAL LINE TO lt_mod ASSIGNING <ls_mod>.
        <ls_mod>-node        = zif_zbo_so_c=>sc_node-item.
        <ls_mod>-change_mode = /bobf/if_frw_c=>sc_modify_delete.
        <ls_mod>-key         = ls_item_ori-key.
        <ls_mod>-data        = REF #( ls_item_ori ).
      ENDIF.
    ENDLOOP.

    CALL METHOD me->mo_svc_mngr->modify
      EXPORTING
        it_modification = lt_mod
      IMPORTING
        eo_change       = lo_change
        eo_message      = lo_message.

    IF lo_message IS BOUND.
      IF lo_message->check( ) EQ abap_true.
        me->convert_messages(
          EXPORTING
            io_message = lo_message
          IMPORTING
            et_message = et_message
        ).
        RETURN.
      ENDIF.
    ENDIF.

    CALL METHOD me->mo_txn_mngr->save
      IMPORTING
        eo_message  = lo_message
        ev_rejected = lv_rejected.

    IF lv_rejected EQ abap_true.
      me->convert_messages(
        EXPORTING
          io_message = lo_message
        IMPORTING
          et_message = et_message
      ).
      RETURN.
    ENDIF.

    CLEAR ls_message.
    ls_message-type    = 'S'.
    ls_message-message = 'Instância atualizada'.
    APPEND ls_message TO et_message.
  CATCH /bobf/cx_frw INTO lx_bopf_ex.
    lv_err_msg = lx_bopf_ex->get_text( ).

    CLEAR ls_message.
    ls_message-type    = 'E'.
    ls_message-message = lv_err_msg.
    APPEND ls_message TO et_message.
  ENDTRY.
endmethod.
ENDCLASS.
