@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '入出庫申請明細'
define view entity ZI_SA_GM_ITEM
  as select from zsa_gm_itm
  association to parent ZI_SA_GM_DOC as _Document
    on $projection.DocumentUUID = _Document.DocumentUUID
{
  key item_uuid             as ItemUUID,
      document_uuid         as DocumentUUID,
      item_no               as ItemNo,
      material              as Material,
      plant                 as Plant,
      storage_location      as StorageLocation,
      goods_movement_type   as GoodsMovementType,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      quantity              as Quantity,
      base_unit             as BaseUnit,
      purchase_order        as PurchaseOrder,
      purchase_order_item   as PurchaseOrderItem,
      cost_center           as CostCenter,
      order_id              as OrderID,
      item_text             as ItemText,
      local_last_changed_at as LocalLastChangedAt,
      _Document
}
