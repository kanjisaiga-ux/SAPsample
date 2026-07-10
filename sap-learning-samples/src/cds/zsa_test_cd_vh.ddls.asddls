@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sample value help for TEST_CD as CHAR2'
@ObjectModel.dataCategory: #VALUE_HELP
@Search.searchable: true
define view entity ZSA_TEST_CD_VH
  as select from za0599_test_t01
{
      @EndUserText.label: 'Value Help Code'
      @Search.defaultSearchElement: true
  key cast( substring( test_cd, 1, 2 ) as abap.char(2) ) as TestCd2,

      @EndUserText.label: 'Original TEST_CD'
      test_cd as OriginalTestCd,

      @EndUserText.label: 'Text'
      @Search.defaultSearchElement: true
      test_text as TestText
}
