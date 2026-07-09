CLASS lhc_request DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Request RESULT result.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Request RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Request RESULT result.
    METHODS initialize FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Request~initialize.
    METHODS proposeRoute FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Request~proposeRoute.
    METHODS validateRequest FOR VALIDATE ON SAVE
      IMPORTING keys FOR Request~validateRequest.
    METHODS Submit FOR MODIFY
      IMPORTING keys FOR ACTION Request~Submit RESULT result.
    METHODS Approve FOR MODIFY
      IMPORTING keys FOR ACTION Request~Approve RESULT result.
    METHODS Reject FOR MODIFY
      IMPORTING keys FOR ACTION Request~Reject RESULT result.
ENDCLASS.
