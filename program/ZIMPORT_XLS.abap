--- REPORT ZIMPORT_XLSX.

REPORT  ZIMPORT_XLSX.
INCLUDE ZIMPORT_XLSX_TOP.
INCLUDE ZIMPORT_XLSX_SCR.
INCLUDE ZIMPORT_XLSX_CL1.
INCLUDE ZIMPORT_XLSX_SOS.

--- INCLUDE ZIMPORT_XLSX_TOP.
CLASS lcl_main DEFINITION DEFERRED.

DATA: gt_data TYPE STANDARD TABLE OF ZDATA.
DATA: gs_data TYPE ZDATA.

DATA: go_main TYPE REF TO lcl_main.

--- INCLUDE ZIMPORT_XLSX_SCR.
SELECTION-SCREEN BEGIN OF BLOCK main WITH FRAME.
  PARAMETERS p_file TYPE localfile.
SELECTION-SCREEN END OF BLOCK main.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CLEAR p_file.
  CALL FUNCTION 'F4_FILENAME'
    IMPORTING
      file_name = p_file.
	  
--- INCLUDE ZIMPORT_XLSX_CL1.
CLASS lcl_main DEFINITION.
  PUBLIC SECTION.
    METHODS load_file.
    METHODS import_data.
ENDCLASS.
CLASS lcl_main IMPLEMENTATION.
  METHOD load_file.
    CLEAR gt_data.
    zcl_xls_utils=>xls_to_itab(
      EXPORTING
        xls_file = CONV #( p_file )
        server   = ''
      IMPORTING
        itab     = gt_data
      EXCEPTIONS
        others   = 1
    ).
  ENDMETHOD.
  METHOD import_data.
    DELETE FROM ZDATA.
    INSERT ZDATA FROM TABLE gt_data.
  ENDMETHOD.
ENDCLASS.

--- INCLUDE ZIMPORT_XLSX_SOS.
START-OF-SELECTION.
  go_main = new lcl_main( ).
  go_main->load_file( ).
  go_main->import_data( ).
  WRITE 'Importação concluída'.
