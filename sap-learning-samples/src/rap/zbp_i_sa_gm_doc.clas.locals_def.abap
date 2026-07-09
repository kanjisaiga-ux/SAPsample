CLASS lhc_document DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Document RESULT result.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Document RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Document RESULT result.
    METHODS initialize FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Document~initialize.
    METHODS validateHeader FOR VALIDATE ON SAVE
      IMPORTING keys FOR Document~validateHeader.
    METHODS StartApproval FOR MODIFY
      IMPORTING keys FOR ACTION Document~StartApproval RESULT result.
ENDCLASS.

CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS validateItem FOR VALIDATE ON SAVE
      IMPORTING keys FOR Item~validateItem.
ENDCLASS.
