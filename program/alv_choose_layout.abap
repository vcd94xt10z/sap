DATA: gs_alv_variant TYPE disvariant.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
  PARAMETERS p_layout TYPE slis_vari.
SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_layout.
  gs_alv_variant-report = sy-repid.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = gs_alv_variant
      i_save     = 'A'
    IMPORTING
      es_variant = gs_alv_variant
    EXCEPTIONS
      not_found  = 2.

  IF sy-subrc = 0.
    p_layout = gs_alv_variant-variant.
  ENDIF.
