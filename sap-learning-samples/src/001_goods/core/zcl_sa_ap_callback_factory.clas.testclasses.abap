CLASS ltc_factory DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS known_callback_is_created FOR TESTING.
    METHODS unknown_callback_is_rejected FOR TESTING.
ENDCLASS.

CLASS ltc_factory IMPLEMENTATION.
  METHOD known_callback_is_created.
    cl_abap_unit_assert=>assert_bound(
      act = zcl_sa_ap_callback_factory=>get(
        function_id = 'GOODS_MOVEMENT'
        callback_id = 'POST_GM' ) ).
  ENDMETHOD.

  METHOD unknown_callback_is_rejected.
    cl_abap_unit_assert=>assert_not_bound(
      act = zcl_sa_ap_callback_factory=>get(
        function_id = 'GOODS_MOVEMENT'
        callback_id = 'UNSAFE_METHOD' ) ).
  ENDMETHOD.
ENDCLASS.
