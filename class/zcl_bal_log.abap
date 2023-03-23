class ZCL_BAL_LOG definition
  public
  final
  create public .

public section.

  data LOG type BAL_S_LOG .
  data LOG_HANDLE type BALLOGHNDL .
  data LOG_HANDLE_TAB type BAL_T_LOGH .

  methods CONSTRUCTOR
    importing
      !ID_OBJECT type BALOBJ_D
      !ID_SUBOBJECT type BALSUBOBJ optional
      !ID_EXTNUMBER type BALNREXT optional
    exceptions
      LOG_NOT_FOUND .
  methods ADD_MSG
    importing
      !IS_MSG type BAL_S_MSG
    returning
      value(RD_SUBRC) type SYSUBRC .
  methods SAVE
    returning
      value(RD_SUBRC) type SYSUBRC .
  methods DISPLAY
    importing
      !ID_TITLELIST type ANY optional .
  class-methods SDEMO1
    importing
      !ID_OBJECT type BALOBJ_D .
  class-methods SDEMO2 .
  class-methods SDISPLAY
    importing
      !ID_OBJECT type BALOBJ_D
      !ID_SUBOBJECT type BALSUBOBJ optional
      !ID_EXTNUMBER type BALNREXT optional
      !ID_TITLELIST type ANY optional .
  class-methods SDISPLAY_MSG_LIST
    importing
      value(IT_MSG) type BAL_TT_MSG .
protected section.
private section.
ENDCLASS.



CLASS ZCL_BAL_LOG IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_BAL_LOG->ADD_MSG
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_MSG                         TYPE        BAL_S_MSG
* | [<-()] RD_SUBRC                       TYPE        SYSUBRC
* +--------------------------------------------------------------------------------------</SIGNATURE>
method ADD_MSG.
  " Campos obrigatórios
  IF is_msg-msgid = ''.
    rd_subrc = 99.
    RETURN.
  ENDIF.

  CALL FUNCTION 'BAL_LOG_MSG_ADD'
    EXPORTING
      i_log_handle      = me->log_handle
      i_s_msg           = is_msg
    EXCEPTIONS
      log_not_found    = 1
      msg_inconsistent = 2
      log_is_full      = 3
      others           = 4.

  rd_subrc = sy-subrc.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_BAL_LOG->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_OBJECT                      TYPE        BALOBJ_D
* | [--->] ID_SUBOBJECT                   TYPE        BALSUBOBJ(optional)
* | [--->] ID_EXTNUMBER                   TYPE        BALNREXT(optional)
* | [EXC!] LOG_NOT_FOUND
* +--------------------------------------------------------------------------------------</SIGNATURE>
method CONSTRUCTOR.
  me->log-object    = id_object.
  me->log-subobject = id_subobject.
  me->log-aluser    = sy-uname.
  me->log-alprog    = sy-repid.
  me->log-extnumber = id_extnumber.

  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING
      i_s_log                 = me->log
    IMPORTING
      e_log_handle            = me->log_handle
    EXCEPTIONS
      log_header_inconsistent = 1
      OTHERS                  = 2.

  IF sy-subrc <> 0.
    RAISE LOG_NOT_FOUND.
  ENDIF.

  INSERT me->log_handle INTO TABLE me->log_handle_tab.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_BAL_LOG->DISPLAY
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_TITLELIST                   TYPE        ANY(optional)
* +--------------------------------------------------------------------------------------</SIGNATURE>
method DISPLAY.
  CALL FUNCTION 'APPL_LOG_DISPLAY'
    EXPORTING
      OBJECT                         = me->log-object
      SUBOBJECT                      = me->log-subobject
      EXTERNAL_NUMBER                = me->log-extnumber
*     OBJECT_ATTRIBUTE               = 0
*     SUBOBJECT_ATTRIBUTE            = 0
*     EXTERNAL_NUMBER_ATTRIBUTE      = 0
*     DATE_FROM                      = SY-DATUM
*     TIME_FROM                      = '000000'
*     DATE_TO                        = SY-DATUM
*     TIME_TO                        = SY-UZEIT
*     TITLE_SELECTION_SCREEN         = 'Teste'
      TITLE_LIST_SCREEN              = id_titlelist
*     COLUMN_SELECTION               = '11112221122   '
      SUPPRESS_SELECTION_DIALOG      = 'X'
*     COLUMN_SELECTION_MSG_JUMP      = '1'
*     EXTERNAL_NUMBER_DISPLAY_LENGTH = 20
*     I_S_DISPLAY_PROFILE            =
*     I_VARIANT_REPORT               = ' '
*     I_SRT_BY_TIMSTMP               = ' '
*   IMPORTING
*     NUMBER_OF_PROTOCOLS            =
    EXCEPTIONS
      no_authority                   = 1
      others                         = 2.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_BAL_LOG->SAVE
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RD_SUBRC                       TYPE        SYSUBRC
* +--------------------------------------------------------------------------------------</SIGNATURE>
method SAVE.
  CALL FUNCTION 'BAL_DB_SAVE'
    EXPORTING
      i_client         = sy-mandt
      i_save_all       = abap_true
      i_t_log_handle   = me->log_handle_tab
    EXCEPTIONS
      log_not_found    = 1
      save_not_allowed = 2
      numbering_error  = 3
      OTHERS           = 4.

  rd_subrc = sy-subrc.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_BAL_LOG=>SDEMO1
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_OBJECT                      TYPE        BALOBJ_D
* +--------------------------------------------------------------------------------------</SIGNATURE>
method SDEMO1.
  DATA ls_msg TYPE bal_s_msg.
  DATA lo_obj TYPE REF TO zcl_bal_log.

  lo_obj = new zcl_bal_log( id_object = id_object ).

  CLEAR ls_msg.
  ls_msg-msgty = 'E'.
  ls_msg-msgid = 'ZDEV'.
  ls_msg-msgno = '000'.
  ls_msg-msgv1 = 'Teste'.
  lo_obj->add_msg( is_msg = ls_msg ).

  lo_obj->save( ).
  lo_obj->display( ).
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_BAL_LOG=>SDEMO2
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
method SDEMO2.
  DATA: ld_pro TYPE char1.
  DATA: lt_msg TYPE bal_tt_msg.
  DATA: ls_msg LIKE LINE OF lt_msg.

  DO 5 TIMES.
    ld_pro = sy-index.
    IF sy-index > 4.
      ld_pro = ''.
    ENDIF.

    CLEAR ls_msg.
    ls_msg-msgid     = '01'.
    ls_msg-msgno     = '001'.
    ls_msg-msgty     = 'S'.
    ls_msg-probclass = ld_pro.
    APPEND ls_msg TO lt_msg.

    CLEAR ls_msg.
    ls_msg-msgid     = '01'.
    ls_msg-msgno     = '001'.
    ls_msg-msgty     = 'W'.
    ls_msg-probclass = ld_pro.
    APPEND ls_msg TO lt_msg.

    CLEAR ls_msg.
    ls_msg-msgid     = '01'.
    ls_msg-msgno     = '001'.
    ls_msg-msgty     = 'E'.
    ls_msg-probclass = ld_pro.
    APPEND ls_msg TO lt_msg.

    CLEAR ls_msg.
    ls_msg-msgid     = '01'.
    ls_msg-msgno     = '001'.
    ls_msg-msgty     = 'I'.
    ls_msg-probclass = ld_pro.
    APPEND ls_msg TO lt_msg.
  ENDDO.

  sdisplay_msg_list( it_msg = lt_msg ).
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_BAL_LOG=>SDISPLAY
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_OBJECT                      TYPE        BALOBJ_D
* | [--->] ID_SUBOBJECT                   TYPE        BALSUBOBJ(optional)
* | [--->] ID_EXTNUMBER                   TYPE        BALNREXT(optional)
* | [--->] ID_TITLELIST                   TYPE        ANY(optional)
* +--------------------------------------------------------------------------------------</SIGNATURE>
method SDISPLAY.
  CALL FUNCTION 'APPL_LOG_DISPLAY'
    EXPORTING
      OBJECT                         = id_object
      SUBOBJECT                      = id_subobject
      EXTERNAL_NUMBER                = id_extnumber
*     OBJECT_ATTRIBUTE               = 0
*     SUBOBJECT_ATTRIBUTE            = 0
*     EXTERNAL_NUMBER_ATTRIBUTE      = 0
*     DATE_FROM                      = SY-DATUM
*     TIME_FROM                      = '000000'
*     DATE_TO                        = SY-DATUM
*     TIME_TO                        = SY-UZEIT
*     TITLE_SELECTION_SCREEN         = 'Teste'
      TITLE_LIST_SCREEN              = id_titlelist
*     COLUMN_SELECTION               = '11112221122   '
      SUPPRESS_SELECTION_DIALOG      = 'X'
*     COLUMN_SELECTION_MSG_JUMP      = '1'
*     EXTERNAL_NUMBER_DISPLAY_LENGTH = 20
*     I_S_DISPLAY_PROFILE            =
*     I_VARIANT_REPORT               = ' '
*     I_SRT_BY_TIMSTMP               = ' '
*   IMPORTING
*     NUMBER_OF_PROTOCOLS            =
    EXCEPTIONS
      no_authority                   = 1
      others                         = 2.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_BAL_LOG=>SDISPLAY_MSG_LIST
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_MSG                         TYPE        BAL_TT_MSG
* +--------------------------------------------------------------------------------------</SIGNATURE>
method SDISPLAY_MSG_LIST.
  DATA ls_log TYPE bal_s_log.
  DATA ls_msg TYPE bal_s_msg.

  " cria o log
  CLEAR ls_log.
  ls_log-extnumber = 'Log'.
  ls_log-aluser    = sy-uname.
  ls_log-alprog    = sy-repid.

  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING
      i_s_log = ls_log
    EXCEPTIONS
      OTHERS  = 1.

  " adiciona as mensagens
  LOOP AT it_msg INTO ls_msg.
    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_s_msg       = ls_msg
      EXCEPTIONS
        log_not_found = 0
        others        = 1.
  ENDLOOP.

  " Exibe
  CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
    EXCEPTIONS
      profile_inconsistent = 1
      internal_error       = 2
      no_data_available    = 3
      no_authority         = 4
      others               = 5.
endmethod.
ENDCLASS.
