CLASS zcl_sa_ap_callback_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    CLASS-METHODS get
      IMPORTING
        function_id TYPE csequence
        callback_id TYPE csequence
      RETURNING VALUE(callback) TYPE REF TO zif_sa_ap_callback.
ENDCLASS.

CLASS zcl_sa_ap_callback_factory IMPLEMENTATION.
  METHOD get.
    CASE function_id.
      WHEN 'GOODS_MOVEMENT'.
        IF callback_id = 'POST_GM'.
          callback = NEW zcl_sa_gm_callback( ).
        ENDIF.
      WHEN OTHERS.
        CLEAR callback.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
