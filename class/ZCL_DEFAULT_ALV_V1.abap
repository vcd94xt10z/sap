class ZCL_DEFAULT_ALV_V1 definition
  public
  inheriting from ZCL_ABSTRACT_ALV_V1
  create public .

public section.
  METHODS handle_data_changed          REDEFINITION.
  METHODS handle_data_changed_finished REDEFINITION.
  METHODS handle_double_click          REDEFINITION.
  METHODS handle_enter                 REDEFINITION.
  METHODS handle_hotspot_click         REDEFINITION.
protected section.
private section.
ENDCLASS.



CLASS ZCL_DEFAULT_ALV_V1 IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_DEFAULT_ALV_V1->HANDLE_DATA_CHANGED
* +-------------------------------------------------------------------------------------------------+
* | [--->] ER_DATA_CHANGED                LIKE
* | [--->] E_ONF4                         LIKE
* | [--->] E_ONF4_BEFORE                  LIKE
* | [--->] E_ONF4_AFTER                   LIKE
* | [--->] E_UCOMM                        LIKE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method handle_data_changed.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_DEFAULT_ALV_V1->HANDLE_DATA_CHANGED_FINISHED
* +-------------------------------------------------------------------------------------------------+
* | [--->] E_MODIFIED                     LIKE
* | [--->] ET_GOOD_CELLS                  LIKE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method handle_data_changed_finished.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_DEFAULT_ALV_V1->HANDLE_DOUBLE_CLICK
* +-------------------------------------------------------------------------------------------------+
* | [--->] E_ROW                          LIKE
* | [--->] E_COLUMN                       LIKE
* | [--->] ES_ROW_NO                      LIKE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method handle_double_click.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_DEFAULT_ALV_V1->HANDLE_ENTER
* +-------------------------------------------------------------------------------------------------+
* | [--->] ER_DATA_CHANGED                LIKE
* | [--->] E_ONF4                         LIKE
* | [--->] E_ONF4_BEFORE                  LIKE
* | [--->] E_ONF4_AFTER                   LIKE
* | [--->] E_UCOMM                        LIKE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method handle_enter.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_DEFAULT_ALV_V1->HANDLE_HOTSPOT_CLICK
* +-------------------------------------------------------------------------------------------------+
* | [--->] E_ROW_ID                       LIKE
* | [--->] E_COLUMN_ID                    LIKE
* | [--->] ES_ROW_NO                      LIKE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method handle_hotspot_click.
  ENDMETHOD.
ENDCLASS.
