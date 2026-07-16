@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Goods movement process type value help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_SA_GM_PROC_TYPE_VH
  as select from t000
{
  @ObjectModel.text.element: [ 'ProcessTypeText' ]
  key cast( 'PO_GR' as abap.char( 10 ) ) as ProcessType,
      cast( 'Purchase order reference goods receipt' as abap.char( 40 ) ) as ProcessTypeText
}
where mandt = $session.client
union all
select from t000
{
  key cast( 'CC_GI' as abap.char( 10 ) ) as ProcessType,
      cast( 'Cost center goods issue' as abap.char( 40 ) ) as ProcessTypeText
}
where mandt = $session.client
union all
select from t000
{
  key cast( 'CC_GR' as abap.char( 10 ) ) as ProcessType,
      cast( 'Cost center goods receipt' as abap.char( 40 ) ) as ProcessTypeText
}
where mandt = $session.client
