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

CLASS lhc_document IMPLEMENTATION.
  METHOD get_global_authorizations.
    result-%create = if_abap_behv=>auth-allowed.
  ENDMETHOD.

  METHOD get_instance_authorizations.
    READ ENTITIES OF zi_sa_gm_doc IN LOCAL MODE
      ENTITY Document FIELDS ( CreatedBy Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(documents).
    DATA current_user TYPE syuname.
    current_user = cl_abap_context_info=>get_user_technical_name( ).
    result = VALUE #( FOR document IN documents
      ( %tky = document-%tky
        %update = COND #(
          WHEN ( document-CreatedBy IS INITIAL OR document-CreatedBy = current_user ) AND
               ( document-Status = 'DRAFT' OR document-Status = 'REJECTED' )
          THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized )
        %delete = COND #(
          WHEN ( document-CreatedBy IS INITIAL OR document-CreatedBy = current_user ) AND
               document-Status = 'DRAFT'
          THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized ) ) ).
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zi_sa_gm_doc IN LOCAL MODE
      ENTITY Document FIELDS ( Status ApprovalUUID ) WITH CORRESPONDING #( keys )
      RESULT DATA(documents).
    result = VALUE #( FOR document IN documents
      ( %tky = document-%tky
        %features-%update = COND #(
          WHEN document-Status IS INITIAL OR
               document-Status = 'DRAFT' OR document-Status = 'REJECTED'
          THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )
        %features-%delete = COND #(
          WHEN document-Status = 'DRAFT'
          THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )
        %action-StartApproval = COND #(
          WHEN ( document-Status = 'DRAFT' OR document-Status = 'REJECTED' )
               AND document-ApprovalUUID IS INITIAL
          THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled ) ) ).
  ENDMETHOD.

  METHOD initialize.
    READ ENTITIES OF zi_sa_gm_doc IN LOCAL MODE
      ENTITY Document FIELDS ( DocumentUUID DocumentNo Status )
      WITH CORRESPONDING #( keys ) RESULT DATA(documents).
    MODIFY ENTITIES OF zi_sa_gm_doc IN LOCAL MODE
      ENTITY Document UPDATE FIELDS ( DocumentNo Status )
      WITH VALUE #( FOR document IN documents
        ( %tky = document-%tky
          DocumentNo = COND #( WHEN document-DocumentNo IS INITIAL
                               THEN |GM-{ document-DocumentUUID }|
                               ELSE document-DocumentNo )
          Status = COND #( WHEN document-Status IS INITIAL
                          THEN 'DRAFT' ELSE document-Status ) ) ).
  ENDMETHOD.

  METHOD validateHeader.
    READ ENTITIES OF zi_sa_gm_doc IN LOCAL MODE
      ENTITY Document FIELDS ( ProcessType PostingDate DocumentDate )
      WITH CORRESPONDING #( keys ) RESULT DATA(documents)
      ENTITY Document BY \_Item FIELDS ( ItemUUID )
      WITH CORRESPONDING #( keys ) RESULT DATA(items).
    LOOP AT documents INTO DATA(document).
      IF ( document-ProcessType <> 'PO_GR' AND
           document-ProcessType <> 'CC_GI' AND
           document-ProcessType <> 'CC_GR' )
         OR document-PostingDate IS INITIAL
         OR document-DocumentDate IS INITIAL
         OR NOT line_exists( items[ DocumentUUID = document-DocumentUUID ] ).
        APPEND VALUE #( %tky = document-%tky ) TO failed-document.
        APPEND VALUE #(
          %tky = document-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = '処理区分、日付、1件以上の明細を入力してください。' ) ) TO reported-document.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD StartApproval.
    READ ENTITIES OF zi_sa_gm_doc IN LOCAL MODE
      ENTITY Document ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(documents).
    LOOP AT documents INTO DATA(document).
      IF document-Status <> 'DRAFT' AND document-Status <> 'REJECTED'.
        APPEND VALUE #( %tky = document-%tky ) TO failed-document.
        APPEND VALUE #(
          %tky = document-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = 'Approval can only be requested for a draft or rejected document.' ) )
          TO reported-document.
        CONTINUE.
      ENDIF.

      DATA(request_cid) = |APR{ sy-tabix }|.
      MODIFY ENTITIES OF zi_sa_ap_request
        ENTITY Request CREATE FIELDS (
          SourceUUID FunctionID ApprovalPattern CallbackID Subject RequestNote )
        WITH VALUE #(
          ( %cid = request_cid
            SourceUUID = document-DocumentUUID
            FunctionID = 'GOODS_MOVEMENT'
            ApprovalPattern = keys[ KEY entity DocumentUUID = document-DocumentUUID ]-%param-ApprovalPattern
            CallbackID = 'POST_GM'
            Subject = |入出庫申請 { document-DocumentNo }|
            RequestNote = keys[ KEY entity DocumentUUID = document-DocumentUUID ]-%param-RequestNote ) )
        MAPPED DATA(mapped_request)
        FAILED DATA(request_failed)
        REPORTED DATA(request_reported).
      IF request_failed IS NOT INITIAL OR mapped_request-request IS INITIAL.
        APPEND VALUE #( %tky = document-%tky ) TO failed-document.
        APPEND VALUE #(
          %tky = document-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = 'The approval request could not be created. Check the approval route and required data.' ) )
          TO reported-document.
        CONTINUE.
      ENDIF.

      READ TABLE mapped_request-request ASSIGNING FIELD-SYMBOL(<mapped_request>)
        WITH KEY %cid = request_cid.
      IF sy-subrc <> 0 OR <mapped_request>-RequestUUID IS INITIAL.
        APPEND VALUE #( %tky = document-%tky ) TO failed-document.
        APPEND VALUE #(
          %tky = document-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = 'The approval request was not assigned an ID.' ) )
          TO reported-document.
        CONTINUE.
      ENDIF.

      MODIFY ENTITIES OF zi_sa_gm_doc IN LOCAL MODE
        ENTITY Document UPDATE FIELDS ( ApprovalUUID )
        WITH VALUE #( ( %tky = document-%tky ApprovalUUID = <mapped_request>-RequestUUID ) )
        FAILED DATA(gm_failed)
        REPORTED DATA(gm_reported).
      IF gm_failed IS NOT INITIAL.
        APPEND VALUE #( %tky = document-%tky ) TO failed-document.
        APPEND VALUE #(
          %tky = document-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = 'The approval request was created, but could not be linked to the goods movement.' ) )
          TO reported-document.
      ENDIF.
    ENDLOOP.

    READ ENTITIES OF zi_sa_gm_doc IN LOCAL MODE
      ENTITY Document ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(updated).
    result = VALUE #( FOR row IN updated ( %tky = row-%tky %param = row ) ).
  ENDMETHOD.
ENDCLASS.

CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS validateItem FOR VALIDATE ON SAVE
      IMPORTING keys FOR Item~validateItem.
ENDCLASS.

CLASS lhc_item IMPLEMENTATION.
  METHOD validateItem.
    READ ENTITIES OF zi_sa_gm_doc IN LOCAL MODE
      ENTITY Item ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(items).
    LOOP AT items INTO DATA(item).
      DATA(invalid_reference) = xsdbool(
        ( item-GoodsMovementType = '101' AND
          ( item-PurchaseOrder IS INITIAL OR item-PurchaseOrderItem IS INITIAL ) ) OR
        ( item-GoodsMovementType = '201' AND item-CostCenter IS INITIAL ) ).
      IF item-Material IS INITIAL OR item-Plant IS INITIAL OR
         item-Quantity <= 0 OR item-BaseUnit IS INITIAL OR invalid_reference = abap_true.
        APPEND VALUE #( %tky = item-%tky ) TO failed-item.
        APPEND VALUE #(
          %tky = item-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = '明細の必須項目または参照項目が正しくありません。' ) ) TO reported-item.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
