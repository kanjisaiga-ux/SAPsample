CLASS ltc_callback DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS implements_contract FOR TESTING.
ENDCLASS.

CLASS ltc_callback IMPLEMENTATION.
  METHOD implements_contract.
    DATA callback TYPE REF TO zif_sa_ap_callback.
    callback = NEW zcl_sa_gm_callback( ).
    cl_abap_unit_assert=>assert_bound( act = callback ).
  ENDMETHOD.
ENDCLASS.
