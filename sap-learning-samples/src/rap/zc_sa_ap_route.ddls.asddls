@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '承認ルートメンテナンス'
@Search.searchable: true
define root view entity ZC_SA_AP_ROUTE
  provider contract transactional_query
  as projection on ZI_SA_AP_ROUTE
{
  key RouteUUID,
      RouteID,
      FunctionID,
      ApprovalPattern,
      RequesterUser,
      RequesterCostCenter,
      ValidFrom,
      ValidTo,
      SequenceNo,
      ApproverUser,
      ApproverName,
      IsActive,
      CreatedBy,
      CreatedAt,
      LocalLastChangedAt
}
