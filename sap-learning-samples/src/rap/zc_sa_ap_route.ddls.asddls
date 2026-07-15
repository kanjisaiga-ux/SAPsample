@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: '承認ルートメンテナンス'
@Search.searchable: true
define root view entity ZC_SA_AP_ROUTE
  provider contract transactional_query
  as projection on ZI_SA_AP_ROUTE
{
  key RouteUUID,
      @EndUserText.label: '承認ルートID'
      @Search.defaultSearchElement: true
      RouteID,
      @EndUserText.label: '機能ID'
      FunctionID,
      @EndUserText.label: '承認パターン'
      ApprovalPattern,
      @EndUserText.label: '申請者ユーザーID'
      RequesterUser,
      @EndUserText.label: '申請者原価センタ'
      RequesterCostCenter,
      @EndUserText.label: '有効開始日'
      ValidFrom,
      @EndUserText.label: '有効終了日'
      ValidTo,
      @EndUserText.label: '承認順'
      SequenceNo,
      @EndUserText.label: '承認者ユーザーID'
      ApproverUser,
      @EndUserText.label: '承認者名'
      @Search.defaultSearchElement: true
      ApproverName,
      @EndUserText.label: '有効フラグ'
      IsActive,
      @EndUserText.label: '登録者'
      CreatedBy,
      @EndUserText.label: '登録日時'
      CreatedAt,
      @EndUserText.label: '最終変更日時'
      LocalLastChangedAt
}
