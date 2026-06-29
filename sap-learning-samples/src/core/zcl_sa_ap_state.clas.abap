CLASS zcl_sa_ap_state DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF request_status,
        draft       TYPE c LENGTH 15 VALUE 'DRAFT',
        in_approval TYPE c LENGTH 15 VALUE 'IN_APPROVAL',
        approved    TYPE c LENGTH 15 VALUE 'APPROVED',
        rejected    TYPE c LENGTH 15 VALUE 'REJECTED',
      END OF request_status,
      BEGIN OF work_status,
        waiting   TYPE c LENGTH 10 VALUE 'WAITING',
        ready     TYPE c LENGTH 10 VALUE 'READY',
        approved  TYPE c LENGTH 10 VALUE 'APPROVED',
        rejected  TYPE c LENGTH 10 VALUE 'REJECTED',
        skipped   TYPE c LENGTH 10 VALUE 'SKIPPED',
        cancelled TYPE c LENGTH 10 VALUE 'CANCELLED',
      END OF work_status.

    TYPES:
      BEGIN OF ty_work_item,
        sequence_no   TYPE n LENGTH 3,
        approver_user TYPE syuname,
        status        TYPE c LENGTH 10,
      END OF ty_work_item,
      tt_work_item TYPE STANDARD TABLE OF ty_work_item WITH EMPTY KEY,
      BEGIN OF ty_transition,
        final_approval TYPE abap_bool,
        next_sequence  TYPE n LENGTH 3,
        work_items     TYPE tt_work_item,
      END OF ty_transition.

    CLASS-METHODS can_submit
      IMPORTING status TYPE csequence
      RETURNING VALUE(result) TYPE abap_bool.

    CLASS-METHODS prepare
      IMPORTING work_items TYPE tt_work_item
      RETURNING VALUE(result) TYPE ty_transition.

    CLASS-METHODS approve
      IMPORTING
        work_items     TYPE tt_work_item
        sequence_no   TYPE n
        approver_user TYPE syuname
      RETURNING VALUE(result) TYPE ty_transition.

    CLASS-METHODS reject
      IMPORTING
        work_items     TYPE tt_work_item
        sequence_no   TYPE n
        approver_user TYPE syuname
      RETURNING VALUE(result) TYPE ty_transition.
ENDCLASS.

CLASS zcl_sa_ap_state IMPLEMENTATION.
  METHOD can_submit.
    result = xsdbool(
      status = request_status-draft OR
      status = request_status-rejected ).
  ENDMETHOD.

  METHOD prepare.
    result-work_items = work_items.
    SORT result-work_items BY sequence_no approver_user.
    IF result-work_items IS INITIAL.
      RETURN.
    ENDIF.

    result-next_sequence = result-work_items[ 1 ]-sequence_no.
    LOOP AT result-work_items ASSIGNING FIELD-SYMBOL(<work_item>).
      <work_item>-status = COND #(
        WHEN <work_item>-sequence_no = result-next_sequence
        THEN work_status-ready
        ELSE work_status-waiting ).
    ENDLOOP.
  ENDMETHOD.

  METHOD approve.
    result-work_items = work_items.
    READ TABLE result-work_items ASSIGNING FIELD-SYMBOL(<approved>)
      WITH KEY sequence_no = sequence_no
               approver_user = approver_user
               status = work_status-ready.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    <approved>-status = work_status-approved.
    LOOP AT result-work_items ASSIGNING FIELD-SYMBOL(<parallel>)
      WHERE sequence_no = sequence_no
        AND status = work_status-ready.
      <parallel>-status = work_status-skipped.
    ENDLOOP.

    DATA next_sequence TYPE n LENGTH 3 VALUE '000'.
    LOOP AT result-work_items ASSIGNING FIELD-SYMBOL(<waiting>)
      WHERE status = work_status-waiting.
      IF next_sequence = '000' OR <waiting>-sequence_no < next_sequence.
        next_sequence = <waiting>-sequence_no.
      ENDIF.
    ENDLOOP.

    IF next_sequence = '000'.
      result-final_approval = abap_true.
      RETURN.
    ENDIF.

    result-next_sequence = next_sequence.
    LOOP AT result-work_items ASSIGNING <waiting>
      WHERE sequence_no = next_sequence
        AND status = work_status-waiting.
      <waiting>-status = work_status-ready.
    ENDLOOP.
  ENDMETHOD.

  METHOD reject.
    result-work_items = work_items.
    READ TABLE result-work_items ASSIGNING FIELD-SYMBOL(<rejected>)
      WITH KEY sequence_no = sequence_no
               approver_user = approver_user
               status = work_status-ready.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    <rejected>-status = work_status-rejected.
    LOOP AT result-work_items ASSIGNING FIELD-SYMBOL(<open>)
      WHERE status = work_status-ready
         OR status = work_status-waiting.
      <open>-status = work_status-cancelled.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
