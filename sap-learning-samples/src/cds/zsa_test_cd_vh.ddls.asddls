@AbapCatalog.sqlViewName: 'ZSATSTCDVH'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sample classic value help for TEST_CD'
@ObjectModel.dataCategory: #VALUE_HELP
@Search.searchable: true
define view ZSA_TEST_CD_VH
  as select from za0599_test_t01
{
      @EndUserText.label: 'Value Help Code'
      @Search.defaultSearchElement: true
  key cast( substring( test_cd, 1, 1 ) as zze1fieldstatus preserving type ) as TestCd1,

      @EndUserText.label: 'Original TEST_CD'
      test_cd as OriginalTestCd,

      @EndUserText.label: 'Text'
      @Search.defaultSearchElement: true
      test_text as TestText
}
