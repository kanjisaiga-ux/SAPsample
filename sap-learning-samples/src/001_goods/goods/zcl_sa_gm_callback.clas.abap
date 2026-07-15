CLASS zcl_sa_gm_callback DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_sa_ap_callback.
ENDCLASS.

CLASS zcl_sa_gm_callback IMPLEMENTATION.
  METHOD zif_sa_ap_callback~execute.
    SELECT SINGLE FROM zsa_gm_hdr
      FIELDS document_uuid, process_type, posting_date, document_date, header_text, status
      WHERE document_uuid = @source_uuid
      INTO @DATA(header).
    IF sy-subrc <> 0 OR header-status <> 'SUBMITTED'.
      result-message = '登録対象の入出庫申請が存在しないか、申請中ではありません。'.
      RETURN.
    ENDIF.

    SELECT FROM zsa_gm_itm
      FIELDS item_uuid, material, plant, storage_location,
             goods_movement_type, quantity, base_unit,
             purchase_order, purchase_order_item, cost_center,
             order_id, item_text
      WHERE document_uuid = @source_uuid
      ORDER BY item_no
      INTO TABLE @DATA(db_items).

    DATA(items) = CORRESPONDING zcl_sa_gm_poster=>tt_item(
      db_items MAPPING movement_type = goods_movement_type ).
    DATA(post_result) = NEW zcl_sa_gm_poster( )->post(
      header = CORRESPONDING #( header )
      items  = items ).
    result = CORRESPONDING #( post_result ).

    MODIFY ENTITIES OF zi_sa_gm_doc
      ENTITY Document UPDATE FIELDS (
        Status MaterialDocument MaterialDocumentYear PostingMessage ApprovalUUID )
      WITH VALUE #(
        ( DocumentUUID = source_uuid
          Status = COND #( WHEN result-success = abap_true THEN 'POSTED' ELSE 'POSTING_ERROR' )
          MaterialDocument = result-document_no
          MaterialDocumentYear = result-document_year
          PostingMessage = result-message
          ApprovalUUID = request_uuid ) )
      FAILED DATA(update_failed).
    IF update_failed IS NOT INITIAL.
      result-success = abap_false.
      result-message = '標準伝票登録後の申請更新に失敗しました。'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
