@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: '入出庫伝票登録'
@Search.searchable: true
@ObjectModel.semanticKey: [ 'DocumentNo' ]
define root view entity ZC_SA_GM_DOC
  provider contract transactional_query
  as projection on ZI_SA_GM_DOC
{
  @UI.hidden: true
  key DocumentUUID,
      @Search.defaultSearchElement: true
      DocumentNo,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_SA_GM_PROC_TYPE_VH', element: 'ProcessType' }, useForValidation: true }]
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
