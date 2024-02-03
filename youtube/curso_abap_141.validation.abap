method /BOBF/IF_FRW_VALIDATION~EXECUTE.
  CLEAR eo_message.
  CLEAR et_failed_key.

  DATA: lt_data    TYPE ztddchamado.
  DATA: ls_message TYPE symsg.

  io_read->retrieve(
    EXPORTING
      iv_node                 = is_ctx-node_key
      it_key                  = it_key
      iv_fill_data            = abap_true        " Data element for domain BOOLE: TRUE (='X') and FALSE (=' ')
      it_requested_attributes = VALUE #( ( ZIF_DD_CHAMADO_C=>sc_node_attribute-zdd_chamado-assunto ) )
    IMPORTING
      et_data                 = lt_data
  ).

  eo_message = /bobf/cl_frw_factory=>get_message( ).

  ls_message-msgid = 'FB'.
  ls_message-msgno = 420.
  ls_message-msgty = 'E'.

  LOOP AT lt_data INTO DATA(ls_data).
    IF ls_data-assunto = ''.
      CLEAR ls_message-msgv1.

      ls_message-msgv1 = 'Assunto vazio'.

      eo_message->add_message(
        EXPORTING
          is_msg       = ls_message
          iv_node      = is_ctx-node_key
          iv_key       = ls_data-key
          iv_attribute = ZIF_DD_CHAMADO_C=>sc_node_attribute-zdd_chamado-assunto
      ).

      INSERT VALUE #( key = ls_data-key ) INTO TABLE et_failed_key.
    ENDIF.
  ENDLOOP.
endmethod.
