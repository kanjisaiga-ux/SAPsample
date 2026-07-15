CLASS ltc_poster DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS empty_items_are_rejected FOR TESTING.
ENDCLASS.

CLASS ltc_poster IMPLEMENTATION.
  METHOD empty_items_are_rejected.
    DATA(result) = NEW zcl_sa_gm_poster( )->post(
      header = VALUE #( )
      items  = VALUE #( ) ).
    cl_abap_unit_assert=>assert_false( act = result-success ).
    cl_abap_unit_assert=>assert_not_initial( act = result-message ).
  ENDMETHOD.
ENDCLASS.
