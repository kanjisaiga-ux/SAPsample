@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: '承認申請'
@Search.searchable: true
@ObjectModel.semanticKey: [ 'RequestNo' ]
define root view entity ZC_SA_AP_REQUEST
  provider contract transactional_query
  as projection on ZI_SA_AP_REQUEST
{
  key RequestUUID,
      @Search.defaultSearchElement: true
      RequestNo,
      @Consumption.semanticObject: 'ZSAGoodsMovement'
      SourceUUID,
      FunctionID,
      ApprovalPattern,
      CallbackID,
      Status,
      CurrentSequence,
      RequesterUser,
      RequesterCostCenter,
      Subject,
      RequestNote,
      SubmittedAt,
      CompletedAt,
      CreatedBy,
      CreatedAt,
      LocalLastChangedAt,
      _WorkItem : redirected to composition child ZC_SA_AP_WORK
}
