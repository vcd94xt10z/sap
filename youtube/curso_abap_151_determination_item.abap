method /BOBF/IF_FRW_DETERMINATION~EXECUTE.
  DATA: lt_data  TYPE zbo_soheader_ctt.
  DATA: lt_item  TYPE zbo_soitem_ctt.
  DATA: ld_id    TYPE int4.

  io_read->retrieve(
    EXPORTING
      iv_node = is_ctx-node_key
      it_key  = it_key
    IMPORTING
      et_data = lt_item
  ).

  io_read->retrieve_by_association(
    EXPORTING
      iv_node        = is_ctx-node_key
      it_key         = it_key
      iv_association = zif_zbo_so_c=>sc_association-item-to_root
      iv_fill_data   = abap_true
    IMPORTING
      et_data        = lt_data
  ).

  READ TABLE lt_data REFERENCE INTO DATA(lr_data) INDEX 1.
  ld_id = lr_data->soid.

  LOOP AT lt_item REFERENCE INTO DATA(lr_item) WHERE soid = 0.
    lr_item->soid  = ld_id.

    TRY.
      CALL METHOD io_modify->update
        EXPORTING
          iv_node = is_ctx-node_key
          iv_key =  lr_item->key
          is_data = lr_item
          it_changed_fields = VALUE #(
            ( zif_zbo_so_c=>sc_node_attribute-item-soid )
          ).
    CATCH /bobf/cx_frw.
    ENDTRY.
  ENDLOOP.
endmethod.
