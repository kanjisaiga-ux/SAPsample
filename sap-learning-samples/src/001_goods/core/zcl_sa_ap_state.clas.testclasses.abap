CLASS ltc_state DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS draft_can_be_submitted FOR TESTING.
    METHODS active_request_cannot_submit FOR TESTING.
    METHODS prepare_activates_first_group FOR TESTING.
    METHODS parallel_approval_skips_peer FOR TESTING.
    METHODS final_approval_is_reported FOR TESTING.
    METHODS rejection_cancels_open_items FOR TESTING.
ENDCLASS.

CLASS ltc_state IMPLEMENTATION.
  METHOD draft_can_be_submitted.
    cl_abap_unit_assert=>assert_true(
      act = zcl_sa_ap_state=>can_submit( zcl_sa_ap_state=>request_status-draft ) ).
  ENDMETHOD.

  METHOD active_request_cannot_submit.
    cl_abap_unit_assert=>assert_false(
      act = zcl_sa_ap_state=>can_submit( zcl_sa_ap_state=>request_status-in_approval ) ).
  ENDMETHOD.

  METHOD prepare_activates_first_group.
    DATA(result) = zcl_sa_ap_state=>prepare( VALUE #(
      ( sequence_no = '002' approver_user = 'USER_C' )
      ( sequence_no = '001' approver_user = 'USER_A' )
      ( sequence_no = '001' approver_user = 'USER_B' ) ) ).

    cl_abap_unit_assert=>assert_equals( act = result-next_sequence exp = '001' ).
    cl_abap_unit_assert=>assert_equals(
      act = result-work_items[ approver_user = 'USER_A' ]-status
      exp = zcl_sa_ap_state=>work_status-ready ).
    cl_abap_unit_assert=>assert_equals(
      act = result-work_items[ approver_user = 'USER_C' ]-status
      exp = zcl_sa_ap_state=>work_status-waiting ).
  ENDMETHOD.

  METHOD parallel_approval_skips_peer.
    DATA(result) = zcl_sa_ap_state=>approve(
      sequence_no   = '001'
      approver_user = 'USER_A'
      work_items    = VALUE #(
        ( sequence_no = '001' approver_user = 'USER_A' status = zcl_sa_ap_state=>work_status-ready )
        ( sequence_no = '001' approver_user = 'USER_B' status = zcl_sa_ap_state=>work_status-ready )
        ( sequence_no = '002' approver_user = 'USER_C' status = zcl_sa_ap_state=>work_status-waiting ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = result-work_items[ approver_user = 'USER_B' ]-status
      exp = zcl_sa_ap_state=>work_status-skipped ).
    cl_abap_unit_assert=>assert_equals(
      act = result-work_items[ approver_user = 'USER_C' ]-status
      exp = zcl_sa_ap_state=>work_status-ready ).
  ENDMETHOD.

  METHOD final_approval_is_reported.
    DATA(result) = zcl_sa_ap_state=>approve(
      sequence_no   = '001'
      approver_user = 'USER_A'
      work_items    = VALUE #(
        ( sequence_no = '001' approver_user = 'USER_A' status = zcl_sa_ap_state=>work_status-ready ) ) ).

    cl_abap_unit_assert=>assert_true( act = result-final_approval ).
  ENDMETHOD.

  METHOD rejection_cancels_open_items.
    DATA(result) = zcl_sa_ap_state=>reject(
      sequence_no   = '001'
      approver_user = 'USER_A'
      work_items    = VALUE #(
        ( sequence_no = '001' approver_user = 'USER_A' status = zcl_sa_ap_state=>work_status-ready )
        ( sequence_no = '001' approver_user = 'USER_B' status = zcl_sa_ap_state=>work_status-ready )
        ( sequence_no = '002' approver_user = 'USER_C' status = zcl_sa_ap_state=>work_status-waiting ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = result-work_items[ approver_user = 'USER_A' ]-status
      exp = zcl_sa_ap_state=>work_status-rejected ).
    cl_abap_unit_assert=>assert_equals(
      act = result-work_items[ approver_user = 'USER_C' ]-status
      exp = zcl_sa_ap_state=>work_status-cancelled ).
  ENDMETHOD.
ENDCLASS.
