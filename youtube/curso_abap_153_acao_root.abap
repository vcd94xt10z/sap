method /BOBF/IF_FRW_ACTION~EXECUTE.
  DATA: lt_req_attribute TYPE /bobf/t_frw_name.
  DATA: lt_soheader_root TYPE zbo_soheader_ctt.

  CLEAR et_failed_key.
  CLEAR eo_message.
  CLEAR et_data.
  CLEAR ev_static_action_failed.

  INSERT zif_zbo_so_c=>sc_node_attribute-root-status
    INTO TABLE lt_req_attribute.

  io_read->retrieve(
    EXPORTING
      iv_node = zif_zbo_so_c=>sc_node-root
      it_key = it_key
      iv_fill_data = abap_true
      it_requested_attributes = lt_req_attribute
    IMPORTING
      et_data = lt_soheader_root
  ).

  eo_message = /bobf/cl_frw_factory=>get_message( ).

  LOOP AT lt_soheader_root REFERENCE INTO DATA(lr_soheader_root).
    CASE is_ctx-act_key.
      WHEN zif_zbo_so_c=>sc_action-root-fornecer.
        IF lr_soheader_root->status <> '1'.
          eo_message->add_message(
            EXPORTING
              is_msg       = value #(
                msgid = 'ACM'
                msgno = '001'
                msgv1 = 'Status deve ser 1 (Novo)'
              )
              iv_node      = is_ctx-node_key
              iv_key       = lr_soheader_root->key
              iv_attribute = zif_zbo_so_c=>sc_node_attribute-root-status
          ).
          RETURN.
        ENDIF.
        lr_soheader_root->status = '2'.
      WHEN zif_zbo_so_c=>sc_action-root-faturar.
        IF lr_soheader_root->status <> '2'.
          eo_message->add_message(
            EXPORTING
              is_msg       = value #(
                msgid = 'ACM'
                msgno = '001'
                msgv1 = 'Status deve ser 2 (FORNECIDO)'
              )
              iv_node      = is_ctx-node_key
              iv_key       = lr_soheader_root->key
              iv_attribute = zif_zbo_so_c=>sc_node_attribute-root-status
          ).
          RETURN.
        ENDIF.
        lr_soheader_root->status = '3'.
    ENDCASE.

    io_modify->update(
      iv_node = is_ctx-node_key
      iv_key  = lr_soheader_root->key
      is_data = lr_soheader_root
      it_changed_fields = lt_req_attribute
  ).
  ENDLOOP.
endmethod.
