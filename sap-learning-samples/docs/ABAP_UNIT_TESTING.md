# ABAP Unit テスト標準

## 1. 基本方針

単体テストにはABAP Unitを使用する。テストは対象オブジェクトと同じ変更で作成し、
abapGitで一緒に移送する。テスト順序、既存データ、現在時刻、実行ユーザーに依存させない。

## 2. 配置

- グローバルクラス: ADTの **Test Classes** includeにローカルテストクラスを書く。
  abapGitでは通常 `*.clas.testclasses.abap` として保存される。
- レポート: 対象プログラム末尾にローカルテストクラスを書く。
- CDS/RAP: 専用のテストクラスを作り、ABAP Docの `@testing` 関係を付ける。
- 再利用テスト基盤だけをグローバルテストクラスにし、通常の単体テストは
  対象プログラムのローカルクラスに置く。

## 3. 必須テスト

変更した公開動作ごとに、最低限次を用意する。

1. 正常系
2. 境界値または空入力
3. 異常系または依存先失敗
4. 不具合修正では、その不具合を再現する回帰テスト

重要な業務ルールは分岐を網羅する。カバレッジは目安として全体80%以上、
重要ロジック90%以上を目指すが、無意味なassertで数値だけを上げない。

## 4. テストクラス規約

既定値は `DURATION SHORT`、`RISK LEVEL HARMLESS` とする。変更が必要なら理由を記述する。

```abap
CLASS ltc_calculator DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA cut TYPE REF TO zcl_sa_calculator.

    METHODS setup.
    METHODS adds_two_values FOR TESTING.
ENDCLASS.

CLASS ltc_calculator IMPLEMENTATION.
  METHOD setup.
    cut = NEW #( ).
  ENDMETHOD.

  METHOD adds_two_values.
    " Arrange
    DATA(first)  = 2.
    DATA(second) = 3.

    " Act
    DATA(actual) = cut->add(
      first  = first
      second = second ).

    " Assert
    cl_abap_unit_assert=>assert_equals(
      act = actual
      exp = 5 ).
  ENDMETHOD.
ENDCLASS.
```

- テスト名は期待する振る舞いを表す。
- Arrange / Act / Assertを読み取れる構造にする。
- 1テストは原則1つの振る舞いを検証する。
- assertionには比較対象と、必要なら障害解析に役立つ `msg` を指定する。
- privateメソッドを直接テストするためだけに可視性を上げない。公開動作をテストする。

## 5. 依存性とテストダブル

- DBアクセスにはABAP SQL Test Double Framework、CDSにはCDS Test Double Frameworkを検討する。
- RAPではテストダブルとEMLを使い、各テスト後にトランザクションバッファを戻す。
- HTTP、時刻、UUID、ユーザー、外部APIはインターフェースで包み、テストダブルを注入する。
- 実テーブル、実通信、固定クライアント設定へ依存するテストは単体テストにしない。
- `setup` / `teardown` は各テストの独立性を保つためだけに使い、共有状態を残さない。

## 6. 実行

ローカルのリポジトリ検査:

```powershell
powershell -NoProfile -File .\scripts\Test-Repository.ps1
```

SAP上のABAP Unit実行（ADTサービスが有効であること）:

```powershell
$credential = Get-Credential
.\scripts\Invoke-AbapUnit.ps1 `
  -BaseUrl 'https://sap.example:44300' `
  -Client '100' `
  -Credential $credential `
  -ObjectUri '/sap/bc/adt/oo/classes/zcl_sa_example'
```

複数オブジェクトは `-ObjectUri` に配列で渡す。パスワードをコマンドライン、
スクリプト、環境ファイル、GitHub Secrets以外の平文ファイルへ保存しない。

ADTでは対象を選択し `Ctrl+Shift+F10` でも実行できる。コミット前は変更対象、
取り込み後は関連パッケージ全体のABAP UnitとATCを実行する。

## 7. 合格条件

- failure、error、warningが0件である。
- テスト未検出を成功扱いにしない。
- `DURATION` と `RISK LEVEL` が実態に合う。
- テストが失敗したまま無効化、コメントアウト、期待値変更で回避しない。
