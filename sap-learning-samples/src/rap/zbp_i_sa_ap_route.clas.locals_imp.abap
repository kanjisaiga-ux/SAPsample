CLASS lhc_route DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Route RESULT result.
    METHODS validateRoute FOR VALIDATE ON SAVE
      IMPORTING keys FOR Route~validateRoute.
ENDCLASS.

CLASS lhc_route IMPLEMENTATION.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM'
      ID 'ACTVT' FIELD '02'
      ID 'TABLE' FIELD 'ZSA_AP_ROUTE'.
    DATA(allowed) = COND #(
      WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
      ELSE if_abap_behv=>auth-unauthorized ).
    result-%create = allowed.
    result-%update = allowed.
    result-%delete = allowed.
  ENDMETHOD.

  METHOD validateRoute.
    READ ENTITIES OF zi_sa_ap_route IN LOCAL MODE
      ENTITY Route ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(routes).
    LOOP AT routes INTO DATA(route).
      IF route-RouteID IS INITIAL OR route-FunctionID IS INITIAL OR
         route-ApprovalPattern IS INITIAL OR route-SequenceNo = '000' OR
         route-ApproverUser IS INITIAL OR
         ( route-ValidTo IS NOT INITIAL AND route-ValidTo < route-ValidFrom ).
        APPEND VALUE #( %tky = route-%tky ) TO failed-route.
        APPEND VALUE #(
          %tky = route-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = '承認ルートの必須項目または有効期間が正しくありません。' ) ) TO reported-route.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
