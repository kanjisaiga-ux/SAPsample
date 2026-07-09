@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: '承認ルート'
define view entity ZC_SA_AP_WORK
  as projection on ZI_SA_AP_WORK
{
  key WorkUUID,
      RequestUUID,
      SequenceNo,
      ApproverUser,
      ApproverName,
      Status,
      ActionAt,
      ActionComment,
      LocalLastChangedAt,
      _Request : redirected to parent ZC_SA_AP_REQUEST
}
