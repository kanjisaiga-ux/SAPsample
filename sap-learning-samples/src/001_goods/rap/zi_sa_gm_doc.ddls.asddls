@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '入出庫申請'
define root view entity ZI_SA_GM_DOC
  as select from zsa_gm_hdr
  composition [0..*] of ZI_SA_GM_ITEM as _Item
{
  key document_uuid         as DocumentUUID,
      document_no           as DocumentNo,
      process_type          as ProcessType,
      status                as Status,
      posting_date          as PostingDate,
      document_date         as DocumentDate,
      header_text           as HeaderText,
      approval_uuid         as ApprovalUUID,
      material_document     as MaterialDocument,
      material_document_year as MaterialDocumentYear,
      posting_message       as PostingMessage,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      _Item
}
