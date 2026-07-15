# 入出庫伝票・共通承認サンプル

## 構成

- `src/001_goods/data`: アドオンテーブル
- `src/001_goods/core`: 承認状態遷移、コールバック契約
- `src/001_goods/goods`: SAP標準入出庫伝票登録アダプタ
- `src/001_goods/rap`: CDS、behavior definition、behavior implementation
- `src/001_goods/ui`: metadata extension、service definition/binding
- `ui5/001_goods/goods-movement`: 入出庫申請 List Report / Object Page
- `ui5/001_goods/approval-inbox`: 自分の承認対象 List Report / 承認 Object Page
- `ui5/001_goods/approval-request`: 承認ルート選択・申請 List Report / Object Page
- `ui5/001_goods/approval-route`: 承認ルート保守 List Report / Object Page
- `src/002_value_help/cds`: 検索ヘルプ用クラシック CDS View のサンプル

## 推奨パッケージ

abapGitのルートパッケージを `ZSA` とした場合、フォルダロジック
`PREFIX` により次のサブパッケージを使用する。

- `ZSA_001_GOODS`
- `ZSA_001_GOODS_CORE`
- `ZSA_001_GOODS_DATA`
- `ZSA_001_GOODS_GOODS`
- `ZSA_001_GOODS_RAP`
- `ZSA_001_GOODS_UI`
- `ZSA_002_VALUE_HELP`
- `ZSA_002_VALUE_HELP_CDS`

`PREFIX` ではフォルダ階層がサブパッケージ階層に対応する。パッケージを変更する場合は、
先にSAP側で変更してから、このリポジトリで同じフォルダ構成にする。

## 導入順

1. abapGitでpullする。
2. テーブル、interface/class、CDS、BDEF、behavior pool、DDLX、SRVD、SRVBの順で有効化する。
3. `ZUI_SA_INV_AP_O4` をADTで開き、OData V4 service bindingをpublishする。
4. `I_MaterialDocumentTP` がreleased APIとして利用可能であることをADT API Stateで確認する。
5. ルート保守アプリで初期データを登録する。
6. UI5 4アプリを対象ABAP repositoryへdeployし、Launchpad target mappingを作成する。
7. ABAP UnitとATCを実行する。
8. テスト用購買発注で101入庫、原価センタで201出庫、並列承認、却下・再申請を確認する。

## 初期ルート例

| RouteID | FunctionID | Pattern | Requester | Cost Center | Seq | Approver |
|---|---|---|---|---|---:|---|
| GM_DEFAULT | GOODS_MOVEMENT | DEFAULT | 空白 | 空白 | 10 | USER_A |
| GM_DEFAULT | GOODS_MOVEMENT | DEFAULT | 空白 | 空白 | 10 | USER_B |
| GM_DEFAULT | GOODS_MOVEMENT | DEFAULT | 空白 | 空白 | 20 | USER_C |

USER_AまたはUSER_Bのどちらかが承認するとUSER_Cへ進む。

## テスト

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Test-Repository.ps1 -RequireTests
npx @abaplint/cli@2.119.40
```

SAPへ取り込んだ後:

```powershell
$credential = Get-Credential
.\scripts\Invoke-AbapUnit.ps1 `
  -BaseUrl 'https://sap.example:44300' `
  -Client '100' `
  -Credential $credential `
  -ObjectUri @(
    '/sap/bc/adt/oo/classes/zcl_sa_ap_state',
    '/sap/bc/adt/oo/classes/zcl_sa_ap_callback_factory',
    '/sap/bc/adt/oo/classes/zcl_sa_gm_poster',
    '/sap/bc/adt/oo/classes/zcl_sa_gm_callback'
  )
```

## SAPシステムで必ず確認する箇所

このリポジトリだけではSAP DictionaryとRAPコンパイラを実行できないため、
初回取り込み時に次を対象システムで確認する。

- SAP_BASIS 758における`I_MaterialDocumentTP`の正確な項目名とlate numbering応答
- 購買発注カテゴリ・勘定設定・移動タイプごとの必須項目
- behavior implementation内から標準BOを更新する際のsave sequence
- 日本語主言語のオブジェクトメタデータ
- OData V4 URLとUI5最低バージョン

標準BOのsave sequenceで同期登録とアドオン更新を1LUWにできない場合は、
最終承認時にoutboxを作成しApplication Jobで登録する方式へ切り替える。
