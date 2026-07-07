@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '承認ルートメンテナンス'
@Search.searchable: true
define root view entity ZC_SA_AP_ROUTE
  provider contract transactional_query
  as projection on ZI_SA_AP_ROUTE
{
  key RouteUUID,
      @Search.defaultSearchElement: true
      RouteID,
      FunctionID,
      ApprovalPattern,
      RequesterUser,
      RequesterCostCenter,
      ValidFrom,
      ValidTo,
      SequenceNo,
      ApproverUser,
      @Search.defaultSearchElement: true
      ApproverName,
      IsActive,
      CreatedBy,
      CreatedAt,
      LocalLastChangedAt
}
