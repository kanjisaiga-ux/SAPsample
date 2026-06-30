CLASS zcl_sa_gm_poster DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_header,
        document_uuid TYPE sysuuid_x16,
        process_type  TYPE c LENGTH 10,
        posting_date  TYPE d,
        document_date TYPE d,
        header_text   TYPE c LENGTH 60,
      END OF ty_header,
      BEGIN OF ty_item,
        item_uuid           TYPE sysuuid_x16,
        material            TYPE matnr,
        plant               TYPE werks_d,
        storage_location    TYPE lgort_d,
        movement_type       TYPE c LENGTH 4,
        quantity            TYPE menge_d,
        base_unit           TYPE meins,
        purchase_order      TYPE ebeln,
        purchase_order_item TYPE ebelp,
        cost_center         TYPE kostl,
        order_id            TYPE aufnr,
        item_text           TYPE sgtxt,
      END OF ty_item,
      tt_item TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.

    METHODS post
      IMPORTING
        header TYPE ty_header
        items  TYPE tt_item
      RETURNING VALUE(result) TYPE zif_sa_ap_callback=>ty_result.
ENDCLASS.

CLASS zcl_sa_gm_poster IMPLEMENTATION.
  METHOD post.
    IF items IS INITIAL.
      result-message = '入出庫明細がありません。'.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF I_MaterialDocumentTP
      ENTITY MaterialDocument
        CREATE FROM VALUE #(
          ( %cid = 'HEADER'
            PostingDate = header-posting_date
            DocumentDate = header-document_date
            MaterialDocumentHeaderText = header-header_text
            GoodsMovementCode = COND #(
              WHEN header-process_type = 'CC_GI' THEN '03'
              ELSE '01' ) ) )
      ENTITY MaterialDocument
        CREATE BY \_MaterialDocumentItem
        FROM VALUE #(
          ( %cid_ref = 'HEADER'
            %target = VALUE #(
              FOR item IN items INDEX INTO index
              ( %cid = |ITEM{ index }|
                Material = item-material
                Plant = item-plant
                StorageLocation = item-storage_location
                GoodsMovementType = item-movement_type
                QuantityInEntryUnit = item-quantity
                EntryUnit = item-base_unit
                PurchaseOrder = item-purchase_order
                PurchaseOrderItem = item-purchase_order_item
                CostCenter = item-cost_center
                OrderID = item-order_id
                MaterialDocumentItemText = item-item_text ) ) ) )
      MAPPED DATA(mapped)
      FAILED DATA(failed)
      REPORTED DATA(reported).

    IF failed IS NOT INITIAL.
      result-message = 'SAP標準入出庫伝票の登録に失敗しました。'.
      RETURN.
    ENDIF.

    IF mapped-materialdocument IS INITIAL.
      result-message = 'SAP標準APIから伝票番号が返されませんでした。'.
      RETURN.
    ENDIF.

    result-success = abap_true.
    result-document_no = mapped-materialdocument[ 1 ]-MaterialDocument.
    result-document_year = mapped-materialdocument[ 1 ]-MaterialDocumentYear.
    result-message = 'SAP標準入出庫伝票を登録しました。'.
  ENDMETHOD.
ENDCLASS.
