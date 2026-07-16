@EndUserText.label: '承認申請開始パラメータ'
define abstract entity ZSA_AP_START
{
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_SA_AP_ROUTE', element: 'ApprovalPattern' } }]
  ApprovalPattern : abap.char(20);
  RequestNote     : abap.char(255);
}
