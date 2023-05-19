CLASS gcl_alv1 DEFINITION INHERITING FROM zcl_abstract_alv_v1.
  PUBLIC SECTION.
    METHODS handle_data_changed          REDEFINITION.
    METHODS handle_data_changed_finished REDEFINITION.
    METHODS handle_double_click          REDEFINITION.
    METHODS handle_enter                 REDEFINITION.
    METHODS handle_hotspot_click         REDEFINITION.
    METHODS fill_fieldcat                REDEFINITION.
    METHODS fill_layout                  REDEFINITION.
ENDCLASS.