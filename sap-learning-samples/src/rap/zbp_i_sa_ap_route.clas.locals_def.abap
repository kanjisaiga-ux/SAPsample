CLASS lhc_route DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Route RESULT result.
    METHODS validateRoute FOR VALIDATE ON SAVE
      IMPORTING keys FOR Route~validateRoute.
ENDCLASS.
