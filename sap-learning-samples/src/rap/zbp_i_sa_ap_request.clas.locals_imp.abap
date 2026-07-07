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

CLASS lhc_request IMPLEMENTATION.
  METHOD get_global_authorizations.
    result-%create = if_abap_behv=>auth-allowed.
  ENDMETHOD.

  METHOD get_instance_authorizations.
    READ ENTITIES OF zi_sa_ap_request IN LOCAL MODE
      ENTITY Request FIELDS ( RequesterUser Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(requests).
    DATA(current_user) = cl_abap_context_info=>get_user_technical_name( ).
    result = VALUE #( FOR request IN requests
      ( %tky = request-%tky
        %update = COND #(
          WHEN request-RequesterUser = current_user AND
               ( request-Status = zcl_sa_ap_state=>request_status-draft OR
                 request-Status = zcl_sa_ap_state=>request_status-rejected )
          THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized )
        %delete = COND #(
          WHEN request-RequesterUser = current_user AND
               request-Status = zcl_sa_ap_state=>request_status-draft
          THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized ) ) ).
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zi_sa_ap_request IN LOCAL MODE
      ENTITY Request FIELDS ( Status RequesterUser ) WITH CORRESPONDING #( keys )
      RESULT DATA(requests).
    DATA(current_user) = cl_abap_context_info=>get_user_technical_name( ).
    result = VALUE #( FOR request IN requests
      ( %tky = request-%tky
        %features-%update = COND #(
          WHEN request-Status = zcl_sa_ap_state=>request_status-draft
          THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )
        %features-%delete = COND #(
          WHEN request-Status = zcl_sa_ap_state=>request_status-draft
          THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )
        %action-Submit = COND #(
          WHEN request-RequesterUser = current_user AND
               zcl_sa_ap_state=>can_submit( request-Status ) = abap_true
          THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )
        %action-Approve = COND #(
          WHEN request-Status = zcl_sa_ap_state=>request_status-in_approval
          THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )
        %action-Reject = COND #(
          WHEN request-Status = zcl_sa_ap_state=>request_status-in_approval
          THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled ) ) ).
  ENDMETHOD.

  METHOD initialize.
    READ ENTITIES OF zi_sa_ap_request IN LOCAL MODE
      ENTITY Request FIELDS ( RequestUUID Status RequesterUser RequestNo )
      WITH CORRESPONDING #( keys ) RESULT DATA(requests).
    MODIFY ENTITIES OF zi_sa_ap_request IN LOCAL MODE
      ENTITY Request UPDATE FIELDS ( Status RequesterUser RequestNo )
      WITH VALUE #( FOR request IN requests
        ( %tky = request-%tky
          Status = COND #( WHEN request-Status IS INITIAL
                           THEN zcl_sa_ap_state=>request_status-draft
                           ELSE request-Status )
          RequesterUser = COND #( WHEN request-RequesterUser IS INITIAL
                                  THEN cl_abap_context_info=>get_user_technical_name( )
                                  ELSE request-RequesterUser )
          RequestNo = COND #( WHEN request-RequestNo IS INITIAL
                              THEN |AP-{ request-RequestUUID }|
                              ELSE request-RequestNo ) ) )
      REPORTED DATA(update_reported).
    reported = CORRESPONDING #( DEEP update_reported ).
  ENDMETHOD.

  METHOD proposeRoute.
    READ ENTITIES OF zi_sa_ap_request IN LOCAL MODE
      ENTITY Request FIELDS ( RequestUUID FunctionID ApprovalPattern RequesterUser RequesterCostCenter )
      WITH CORRESPONDING #( keys ) RESULT DATA(requests).

    LOOP AT requests INTO DATA(request).
      SELECT FROM zsa_ap_route
        FIELDS route_id
        WHERE function_id = @request-FunctionID
          AND approval_pattern = @request-ApprovalPattern
          AND is_active = @abap_true
          AND valid_from <= @sy-datum
          AND valid_to >= @sy-datum
          AND ( requester_user = @request-RequesterUser OR requester_user = @space )
        AND ( requester_cost_center = @request-RequesterCostCenter OR requester_cost_center = @space )
        ORDER BY requester_user DESCENDING, requester_cost_center DESCENDING
        INTO TABLE @DATA(route_candidates)
        UP TO 1 ROWS.
      IF route_candidates IS INITIAL.
        CONTINUE.
      ENDIF.
      DATA(route_id) = route_candidates[ 1 ]-route_id.

      SELECT FROM zsa_ap_route
        FIELDS sequence_no, approver_user, approver_name
        WHERE route_id = @route_id
          AND is_active = @abap_true
          AND valid_from <= @sy-datum
          AND valid_to >= @sy-datum
        ORDER BY sequence_no, approver_user
        INTO TABLE @DATA(route_steps).

      MODIFY ENTITIES OF zi_sa_ap_request IN LOCAL MODE
        ENTITY Request CREATE BY \_WorkItem
        FIELDS ( SequenceNo ApproverUser ApproverName Status )
        WITH VALUE #(
          ( %tky = request-%tky
            %target = VALUE #( FOR step IN route_steps
              ( %cid = |{ step-sequence_no }{ step-approver_user }|
                SequenceNo = step-sequence_no
                ApproverUser = step-approver_user
                ApproverName = step-approver_name
                Status = zcl_sa_ap_state=>work_status-waiting ) ) ) )
        REPORTED DATA(create_reported).
      reported = CORRESPONDING #( DEEP create_reported ).
    ENDLOOP.
  ENDMETHOD.

  METHOD validateRequest.
    READ ENTITIES OF zi_sa_ap_request IN LOCAL MODE
      ENTITY Request FIELDS ( SourceUUID FunctionID ApprovalPattern CallbackID )
      WITH CORRESPONDING #( keys ) RESULT DATA(requests)
      ENTITY Request BY \_WorkItem FIELDS ( SequenceNo ApproverUser )
      WITH CORRESPONDING #( keys ) RESULT DATA(work_items).
    LOOP AT requests INTO DATA(request).
      IF request-SourceUUID IS INITIAL OR request-FunctionID IS INITIAL OR
         request-ApprovalPattern IS INITIAL OR request-CallbackID IS INITIAL OR
         work_items IS INITIAL.
        APPEND VALUE #( %tky = request-%tky ) TO failed-request.
        APPEND VALUE #(
          %tky = request-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = '申請情報または承認者が不足しています。' ) ) TO reported-request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD Submit.
    READ ENTITIES OF zi_sa_ap_request IN LOCAL MODE
      ENTITY Request ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(requests)
      ENTITY Request BY \_WorkItem ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(work_items).
    LOOP AT requests INTO DATA(request).
      IF zcl_sa_ap_state=>can_submit( request-Status ) = abap_false.
        APPEND VALUE #( %tky = request-%tky ) TO failed-request.
        CONTINUE.
      ENDIF.

      SELECT SINGLE FROM zsa_ap_req FIELDS request_uuid
        WHERE source_uuid = @request-SourceUUID
          AND function_id = @request-FunctionID
          AND status = @zcl_sa_ap_state=>request_status-in_approval
          AND request_uuid <> @request-RequestUUID
        INTO @DATA(active_request).
      IF sy-subrc = 0.
        APPEND VALUE #( %tky = request-%tky ) TO failed-request.
        APPEND VALUE #(
          %tky = request-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = 'この伝票は既に承認申請中です。' ) ) TO reported-request.
        CONTINUE.
      ENDIF.

      DATA(transition) = zcl_sa_ap_state=>prepare( VALUE #(
        FOR work IN work_items WHERE ( RequestUUID = request-RequestUUID )
        ( sequence_no = work-SequenceNo
          approver_user = work-ApproverUser
          status = work-Status ) ) ).
      IF transition-work_items IS INITIAL.
        APPEND VALUE #( %tky = request-%tky ) TO failed-request.
        CONTINUE.
      ENDIF.

      MODIFY ENTITIES OF zi_sa_ap_request IN LOCAL MODE
        ENTITY Request UPDATE FIELDS ( Status CurrentSequence )
        WITH VALUE #( ( %tky = request-%tky
                        Status = zcl_sa_ap_state=>request_status-in_approval
                        CurrentSequence = transition-next_sequence ) )
        ENTITY WorkItem UPDATE FIELDS ( Status )
        WITH VALUE #( FOR work IN work_items WHERE ( RequestUUID = request-RequestUUID )
          ( %tky = work-%tky
            Status = transition-work_items[
              sequence_no = work-SequenceNo
              approver_user = work-ApproverUser ]-status ) )
        REPORTED DATA(update_reported).

      IF request-FunctionID = 'GOODS_MOVEMENT'.
        MODIFY ENTITIES OF zi_sa_gm_doc
          ENTITY Document UPDATE FIELDS ( Status ApprovalUUID )
          WITH VALUE #( ( DocumentUUID = request-SourceUUID
                          Status = 'SUBMITTED'
                          ApprovalUUID = request-RequestUUID ) )
          FAILED DATA(gm_failed).
        IF gm_failed IS NOT INITIAL.
          APPEND VALUE #( %tky = request-%tky ) TO failed-request.
        ENDIF.
      ENDIF.
      reported = CORRESPONDING #( DEEP update_reported ).
    ENDLOOP.

    READ ENTITIES OF zi_sa_ap_request IN LOCAL MODE
      ENTITY Request ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(updated).
    result = VALUE #( FOR row IN updated ( %tky = row-%tky %param = row ) ).
  ENDMETHOD.

  METHOD Approve.
    READ ENTITIES OF zi_sa_ap_request IN LOCAL MODE
      ENTITY Request ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(requests)
      ENTITY Request BY \_WorkItem ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(work_items).
    DATA(current_user) = cl_abap_context_info=>get_user_technical_name( ).

    LOOP AT requests INTO DATA(request).
      DATA(transition) = zcl_sa_ap_state=>approve(
        sequence_no = request-CurrentSequence
        approver_user = current_user
        work_items = VALUE #(
          FOR work IN work_items WHERE ( RequestUUID = request-RequestUUID )
          ( sequence_no = work-SequenceNo
            approver_user = work-ApproverUser
            status = work-Status ) ) ).
      IF transition-work_items = VALUE zcl_sa_ap_state=>tt_work_item(
        FOR work IN work_items WHERE ( RequestUUID = request-RequestUUID )
        ( sequence_no = work-SequenceNo approver_user = work-ApproverUser status = work-Status ) ).
        APPEND VALUE #( %tky = request-%tky ) TO failed-request.
        CONTINUE.
      ENDIF.

      DATA(request_status) = COND #( WHEN transition-final_approval = abap_true
                                     THEN zcl_sa_ap_state=>request_status-approved
                                     ELSE zcl_sa_ap_state=>request_status-in_approval ).
      IF transition-final_approval = abap_true.
        DATA(callback) = zcl_sa_ap_callback_factory=>get(
          function_id = request-FunctionID callback_id = request-CallbackID ).
        IF callback IS NOT BOUND.
          APPEND VALUE #( %tky = request-%tky ) TO failed-request.
          CONTINUE.
        ENDIF.
        DATA(callback_result) = callback->execute(
          request_uuid = request-RequestUUID source_uuid = request-SourceUUID ).
        IF callback_result-success = abap_false.
          APPEND VALUE #( %tky = request-%tky ) TO failed-request.
          APPEND VALUE #(
            %tky = request-%tky
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text = callback_result-message ) ) TO reported-request.
          CONTINUE.
        ENDIF.
      ENDIF.

      MODIFY ENTITIES OF zi_sa_ap_request IN LOCAL MODE
        ENTITY Request UPDATE FIELDS ( Status CurrentSequence )
        WITH VALUE #( ( %tky = request-%tky
                        Status = request_status
                        CurrentSequence = transition-next_sequence ) )
        ENTITY WorkItem UPDATE FIELDS ( Status ActionComment )
        WITH VALUE #( FOR work IN work_items WHERE ( RequestUUID = request-RequestUUID )
          ( %tky = work-%tky
            Status = transition-work_items[
              sequence_no = work-SequenceNo
              approver_user = work-ApproverUser ]-status
            ActionComment = COND #(
              WHEN work-ApproverUser = current_user AND
                   work-SequenceNo = request-CurrentSequence
              THEN keys[ KEY entity %tky = request-%tky ]-%param-ApprovalComment
              ELSE work-ActionComment ) ) ).
    ENDLOOP.
    READ ENTITIES OF zi_sa_ap_request IN LOCAL MODE
      ENTITY Request ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(updated).
    result = VALUE #( FOR row IN updated ( %tky = row-%tky %param = row ) ).
  ENDMETHOD.

  METHOD Reject.
    READ ENTITIES OF zi_sa_ap_request IN LOCAL MODE
      ENTITY Request ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(requests)
      ENTITY Request BY \_WorkItem ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(work_items).
    DATA(current_user) = cl_abap_context_info=>get_user_technical_name( ).

    LOOP AT requests INTO DATA(request).
      DATA(transition) = zcl_sa_ap_state=>reject(
        sequence_no = request-CurrentSequence
        approver_user = current_user
        work_items = VALUE #(
          FOR work IN work_items WHERE ( RequestUUID = request-RequestUUID )
          ( sequence_no = work-SequenceNo
            approver_user = work-ApproverUser
            status = work-Status ) ) ).
      MODIFY ENTITIES OF zi_sa_ap_request IN LOCAL MODE
        ENTITY Request UPDATE FIELDS ( Status )
        WITH VALUE #( ( %tky = request-%tky Status = zcl_sa_ap_state=>request_status-rejected ) )
        ENTITY WorkItem UPDATE FIELDS ( Status ActionComment )
        WITH VALUE #( FOR work IN work_items WHERE ( RequestUUID = request-RequestUUID )
          ( %tky = work-%tky
            Status = transition-work_items[
              sequence_no = work-SequenceNo
              approver_user = work-ApproverUser ]-status
            ActionComment = COND #(
              WHEN work-ApproverUser = current_user AND
                   work-SequenceNo = request-CurrentSequence
              THEN keys[ KEY entity %tky = request-%tky ]-%param-ApprovalComment
              ELSE work-ActionComment ) ) ).

      IF request-FunctionID = 'GOODS_MOVEMENT'.
        MODIFY ENTITIES OF zi_sa_gm_doc
          ENTITY Document UPDATE FIELDS ( Status ApprovalUUID )
          WITH VALUE #(
            ( DocumentUUID = request-SourceUUID
              Status = 'REJECTED'
              ApprovalUUID = VALUE #( ) ) ).
      ENDIF.
    ENDLOOP.
    READ ENTITIES OF zi_sa_ap_request IN LOCAL MODE
      ENTITY Request ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(updated).
    result = VALUE #( FOR row IN updated ( %tky = row-%tky %param = row ) ).
  ENDMETHOD.
ENDCLASS.
