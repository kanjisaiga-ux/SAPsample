@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '承認ルートマスタ'
define root view entity ZI_SA_AP_ROUTE
  as select from zsa_ap_route
{
  key route_uuid            as RouteUUID,
      route_id              as RouteID,
      function_id           as FunctionID,
      approval_pattern      as ApprovalPattern,
      requester_user        as RequesterUser,
      requester_cost_center as RequesterCostCenter,
      valid_from             as ValidFrom,
      valid_to               as ValidTo,
      sequence_no           as SequenceNo,
      approver_user         as ApproverUser,
      approver_name         as ApproverName,
      is_active              as IsActive,
      created_by             as CreatedBy,
      created_at             as CreatedAt,
      local_last_changed_by  as LocalLastChangedBy,
      local_last_changed_at  as LocalLastChangedAt,
      last_changed_at        as LastChangedAt
}
