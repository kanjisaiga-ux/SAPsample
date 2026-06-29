@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '承認申請'
define root view entity ZI_SA_AP_REQUEST
  as select from zsa_ap_req
  composition [0..*] of ZI_SA_AP_WORK as _WorkItem
{
  key request_uuid          as RequestUUID,
      request_no            as RequestNo,
      source_uuid           as SourceUUID,
      function_id           as FunctionID,
      approval_pattern      as ApprovalPattern,
      callback_id           as CallbackID,
      status                as Status,
      current_sequence      as CurrentSequence,
      requester_user        as RequesterUser,
      requester_cost_center as RequesterCostCenter,
      subject               as Subject,
      request_note          as RequestNote,
      submitted_at          as SubmittedAt,
      completed_at          as CompletedAt,
      created_by            as CreatedBy,
      created_at            as CreatedAt,
      local_last_changed_by as LocalLastChangedBy,
      local_last_changed_at as LocalLastChangedAt,
      last_changed_at       as LastChangedAt,
      _WorkItem
}
