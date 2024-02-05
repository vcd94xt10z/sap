method /BOBF/IF_FRW_DETERMINATION~EXECUTE.
  CLEAR et_failed_key.
  CLEAR eo_message.

  DATA: lt_data  TYPE zbo_soheader_ctt.
  DATA: ld_id    TYPE zbo_soheader-soid.

  io_read->retrieve(
    EXPORTING
      iv_node = is_ctx-node_key
      it_key  = it_key
    IMPORTING
      et_data = lt_data
  ).

  SELECT MAX( soid )
    FROM zbo_soheader
    INTO ld_id.

  ld_id = ld_id + 1.

  LOOP AT lt_data REFERENCE INTO DATA(lr_data) WHERE soid = 0.
    lr_data->soid  = ld_id.
    lr_data->erdat = sy-datum.
    lr_data->erzet = sy-uzeit.

    TRY.
      CALL METHOD io_modify->update
        EXPORTING
          iv_node = is_ctx-node_key
          iv_key =  lr_data->key
          is_data = lr_data
          it_changed_fields = VALUE #(
            ( zif_zbo_so_c=>sc_node_attribute-root-soid )
            ( zif_zbo_so_c=>sc_node_attribute-root-erdat )
            ( zif_zbo_so_c=>sc_node_attribute-root-erzet )
          ).
    CATCH /bobf/cx_frw.
    ENDTRY.

    ld_id = ld_id + 1.
  ENDLOOP.
endmethod.
