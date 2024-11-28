REPORT ZBAPI_MATERIAL_SAVEDATA.

TYPES: BEGIN OF gy_data
     , matnr TYPE matnr
     , maktx TYPE maktx
     , END OF gy_data.

DATA: lt_data  TYPE STANDARD TABLE OF gy_data.
DATA: ls_data  TYPE gy_data.
DATA: lt_matnr TYPE STANDARD TABLE OF matnr.
DATA: ld_matnr TYPE matnr.

FIELD-SYMBOLS: <ls_data> TYPE gy_data.

SELECTION-SCREEN BEGIN OF BLOCK main WITH FRAME.
  PARAMETERS: p_file(128) TYPE c.
SELECTION-SCREEN END OF BLOCK main.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  call function 'WS_FILENAME_GET'
    exporting
      def_filename     = `data.xlsx`
      def_path         = '\'
      mask             = '.xlsx'
      mode             = 'O'
      title            = 'Select filename'
    importing
      filename         = p_file
    exceptions
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.

START-OF-SELECTION.
  CLEAR lt_data.

  zcl_xls_utils=>xls_to_itab(
    EXPORTING
      xls_file = CONV string( p_file )
    IMPORTING
      itab     = lt_data
  ).

  LOOP AT lt_data ASSIGNING <ls_data>.
    SELECT COUNT(*)
      FROM mara
     WHERE matnr = <ls_data>-matnr.

    IF sy-subrc = 0.
      CLEAR <ls_data>-matnr.
      CONTINUE.
    ENDIF.
  ENDLOOP.
  DELETE lt_data WHERE matnr = ``.

  LOOP AT lt_data INTO ls_data.
    PERFORM execute_bapi USING ls_data.
  ENDLOOP.

FORM execute_bapi USING is_data TYPE gy_data.
  DATA: ls_headdata             TYPE bapimathead.
  DATA: ls_clientdata           TYPE bapi_mara.
  DATA: ls_clientdatax          TYPE bapi_marax.
  DATA: ls_plantdata            TYPE bapi_marc.
  DATA: ls_plantdatax           TYPE bapi_marcx.
  DATA: ls_storagelocationdata  TYPE bapi_mard.
  DATA: ls_storagelocationdatax TYPE bapi_mardx.
  DATA: ls_return               TYPE bapiret2.
  DATA: lt_returnmessages       TYPE STANDARD TABLE OF bapi_matreturn2.
  DATA: ls_returnmessages       TYPE bapi_matreturn2.
  DATA: lt_materialdescription  TYPE STANDARD TABLE OF bapi_makt.
  DATA: ls_materialdescription  TYPE bapi_makt.
  DATA: ld_error                TYPE flag.

  CLEAR ls_materialdescription.
  ls_materialdescription-langu     = sy-langu.
  ls_materialdescription-matl_desc = is_data-maktx.
  APPEND ls_materialdescription TO lt_materialdescription.

  CLEAR ls_headdata.
  ls_headdata-material   = is_data-matnr.
  ls_headdata-ind_sector = `A`.
  ls_headdata-matl_type  = `ZABC`.
  ls_headdata-basic_view = `X`.
  ls_headdata-mrp_view   = `X`.

  CLEAR ls_clientdata.
  ls_clientdata-base_uom = `CX`.
  ls_clientdata-division = `01`.

  CLEAR ls_clientdatax.
  ls_clientdatax-base_uom = `X`.
  ls_clientdatax-division = `X`.

  CLEAR ls_plantdata.
  ls_plantdata-plant      = `ZABC`.
  ls_plantdata-pur_group  = `001`.
  ls_plantdata-mrp_type   = `Z1`.
  ls_plantdata-mrp_ctrler = `001`.
  ls_plantdata-lotsizekey = `Z2`.
  ls_plantdata-sm_key     = `001`.
  ls_plantdata-availcheck = `02`.

  CLEAR ls_plantdatax.
  ls_plantdatax-plant      = `ZABC`.
  ls_plantdatax-pur_group  = `X`.
  ls_plantdatax-mrp_type   = `X`.
  ls_plantdatax-mrp_ctrler = `X`.
  ls_plantdatax-lotsizekey = `X`.
  ls_plantdatax-sm_key     = `X`.
  ls_plantdatax-availcheck = `X`.

  CLEAR ls_storagelocationdata.
  ls_storagelocationdata-plant    = `ZABC`.
  ls_storagelocationdata-stge_loc = `T001`.

  CLEAR ls_storagelocationdatax.
  ls_storagelocationdatax-plant    = `ZABC`.
  ls_storagelocationdatax-stge_loc = `T001`.

  CLEAR ls_return.
  CLEAR lt_returnmessages.

  CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
    EXPORTING
      headdata                   = ls_headdata
      clientdata                 = ls_clientdata
      clientdatax                = ls_clientdatax
      plantdata                  = ls_plantdata
      plantdatax                 = ls_plantdatax
*     FORECASTPARAMETERS         =
*     FORECASTPARAMETERSX        =
*     PLANNINGDATA               =
*     PLANNINGDATAX              =
      storagelocationdata        = ls_storagelocationdata
      storagelocationdatax       = ls_storagelocationdatax
*     VALUATIONDATA              =
*     VALUATIONDATAX             =
*     WAREHOUSENUMBERDATA        =
*     WAREHOUSENUMBERDATAX       =
*     SALESDATA                  =
*     SALESDATAX                 =
*     STORAGETYPEDATA            =
*     STORAGETYPEDATAX           =
      FLAG_ONLINE                = ' '
*     FLAG_CAD_CALL              = ' '
*     NO_DEQUEUE                 = ' '
*     NO_ROLLBACK_WORK           = ' '
    IMPORTING
      return                     = ls_return
    TABLES
      materialdescription        = lt_materialdescription
*     UNITSOFMEASURE             =
*     UNITSOFMEASUREX            =
*     INTERNATIONALARTNOS        =
*     MATERIALLONGTEXT           =
*     TAXCLASSIFICATIONS         =
      returnmessages             = lt_returnmessages
*     PRTDATA                    =
*     PRTDATAX                   =
*     EXTENSIONIN                =
*     EXTENSIONINX               =
            .

  CLEAR ld_error.
  LOOP AT lt_returnmessages INTO ls_returnmessages.
    IF ls_returnmessages-type = `A` OR
       ls_returnmessages-type = `X` OR
       ls_returnmessages-type = `E`.
      ld_error = `X`.
    ENDIF.
  ENDLOOP.

  BREAK-POINT.

  IF ld_error = `X`.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    cl_rmsl_message=>display( lt_returnmessages ).
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = `X`.

    cl_rmsl_message=>display( lt_returnmessages ).
  ENDIF.
ENDFORM.