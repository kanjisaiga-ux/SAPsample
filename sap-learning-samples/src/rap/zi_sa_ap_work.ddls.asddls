@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '承認者'
define view entity ZI_SA_AP_WORK
  as select from zsa_ap_work
  association to parent ZI_SA_AP_REQUEST as _Request
    on $projection.RequestUUID = _Request.RequestUUID
{
  key work_uuid             as WorkUUID,
      request_uuid          as RequestUUID,
      sequence_no           as SequenceNo,
      approver_user         as ApproverUser,
      approver_name         as ApproverName,
      status                as Status,
      action_at             as ActionAt,
      action_comment        as ActionComment,
      local_last_changed_at as LocalLastChangedAt,
      _Request
}
