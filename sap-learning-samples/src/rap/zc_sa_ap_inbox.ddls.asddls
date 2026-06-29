@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '自分の承認対象'
@Search.searchable: true
define view entity ZC_SA_AP_INBOX
  as select from zsa_ap_work as Work
    inner join zsa_ap_req as Request
      on Request.request_uuid = Work.request_uuid
  association [1..1] to ZC_SA_AP_REQUEST as _Request
    on $projection.RequestUUID = _Request.RequestUUID
{
  key Work.work_uuid          as WorkUUID,
      Request.request_uuid    as RequestUUID,
      Request.request_no      as RequestNo,
      Request.function_id     as FunctionID,
      Request.subject         as Subject,
      Request.requester_user  as RequesterUser,
      Request.submitted_at    as SubmittedAt,
      Work.sequence_no        as SequenceNo,
      Work.approver_user      as ApproverUser,
      Work.status             as WorkItemStatus,
      _Request
}
where Work.approver_user = $session.user
  and Work.status = 'READY'
