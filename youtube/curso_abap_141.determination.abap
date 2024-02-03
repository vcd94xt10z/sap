method /BOBF/IF_FRW_DETERMINATION~EXECUTE.
  CLEAR et_failed_key.
  CLEAR eo_message.

  DATA: lt_data  TYPE ztddchamado.
  DATA: ld_id    TYPE zsddchamado-chamadoid.

  io_read->retrieve(
    EXPORTING
      iv_node = is_ctx-node_key
      it_key  = it_key
    IMPORTING
      et_data = lt_data
  ).

  SELECT MAX( chamadoid )
    FROM zchamado
    INTO ld_id.

  ld_id = ld_id + 1.

  LOOP AT lt_data REFERENCE INTO DATA(lr_data) WHERE chamadoid = 0.
    lr_data->chamadoid = ld_id.

    TRY.
      CALL METHOD io_modify->update
        EXPORTING
          iv_node = is_ctx-node_key
          iv_key =  lr_data->key
          is_data = lr_data
          it_changed_fields = VALUE #( ( ZIF_DD_CHAMADO_C=>sc_node_attribute-zdd_chamado-chamadoid ) ).
    CATCH /bobf/cx_frw.
    ENDTRY.

    ld_id = ld_id + 1.
  ENDLOOP.
endmethod.
