@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: '入出庫伝票明細'
define view entity ZC_SA_GM_ITEM
  as projection on ZI_SA_GM_ITEM
{
  key ItemUUID,
      DocumentUUID,
      ItemNo,
      Material,
      Plant,
      StorageLocation,
      GoodsMovementType,
      Quantity,
      BaseUnit,
      PurchaseOrder,
      PurchaseOrderItem,
      CostCenter,
      OrderID,
      ItemText,
      LocalLastChangedAt,
      _Document : redirected to parent ZC_SA_GM_DOC
}
