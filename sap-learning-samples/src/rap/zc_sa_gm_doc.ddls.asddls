@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '入出庫伝票登録'
@Search.searchable: true
@ObjectModel.semanticKey: [ 'DocumentNo' ]
define root view entity ZC_SA_GM_DOC
  provider contract transactional_query
  as projection on ZI_SA_GM_DOC
{
  key DocumentUUID,
      @Search.defaultSearchElement: true
      DocumentNo,
      ProcessType,
      Status,
      PostingDate,
      DocumentDate,
      HeaderText,
      ApprovalUUID,
      MaterialDocument,
      MaterialDocumentYear,
      PostingMessage,
      CreatedBy,
      CreatedAt,
      LocalLastChangedAt,
      _Item : redirected to composition child ZC_SA_GM_ITEM
}
