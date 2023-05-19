CLASS gcl_alv1 IMPLEMENTATION.
  method handle_data_changed.
    " modificar (opcional)
  ENDMETHOD.
  method handle_data_changed_finished.
    " modificar (opcional)
  ENDMETHOD.
  method handle_double_click.
    " modificar (opcional)
  ENDMETHOD.
  method handle_enter.
    " modificar (opcional)
  ENDMETHOD.
  method handle_hotspot_click.
    " modificar (opcional)
  ENDMETHOD.
  method fill_fieldcat. "  (ponto 2)
    DATA ls_fieldcat TYPE LVC_S_FCAT.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'ID'.
    ls_fieldcat-key       = 'X'.
    ls_fieldcat-scrtext_s = 'Id'.
    ls_fieldcat-scrtext_m = 'Id'.
    ls_fieldcat-scrtext_l = 'Id'.
    APPEND ls_fieldcat TO mt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'NAME'.
    ls_fieldcat-scrtext_s = 'Nome'.
    ls_fieldcat-scrtext_m = 'Nome'.
    ls_fieldcat-scrtext_l = 'Nome'.
    "ls_fieldcat-edit      = 'X'.
    ls_fieldcat-outputlen = 40.
    APPEND ls_fieldcat TO mt_fieldcat.
  ENDMETHOD.
  method fill_layout. " modificar (opcional)
    super->fill_layout( ).
    ms_layout-zebra      = 'X'.
    ms_layout-no_toolbar = ''.

    " Legenda
    " A – Multiple columns, multiple rows with selection buttons.
    " B – Simple selection, listbox, Single row/column
    " C – Multiple rows without buttons
    " D – Multiple rows with buttons and select all ICON
    ms_layout-sel_mode = 'A'.
  ENDMETHOD.
ENDCLASS.