# データモデル

## ZSA_GM_HDR

| 項目 | 型 | 内容 |
|---|---|---|
| CLIENT | CLNT | クライアント |
| DOCUMENT_UUID | SYSUUID_X16 | managed early numbering技術キー |
| DOCUMENT_NO | CHAR20 | 表示番号 |
| PROCESS_TYPE | CHAR10 | `PO_GR` / `CC_GI` / `CC_GR` |
| STATUS | CHAR15 | 申請状態 |
| POSTING_DATE | DATS | 転記日 |
| DOCUMENT_DATE | DATS | 伝票日 |
| HEADER_TEXT | CHAR60 | ヘッダテキスト |
| APPROVAL_UUID | SYSUUID_X16 | 最新承認申請 |
| MATERIAL_DOCUMENT | MBLNR | SAP入出庫伝票 |
| MATERIAL_DOCUMENT_YEAR | MJAHR | 年度 |
| POSTING_MESSAGE | CHAR255 | 登録結果 |
| CREATED_BY / CREATED_AT | RAP管理項目 | 登録監査 |
| LOCAL_LAST_CHANGED_* / LAST_CHANGED_AT | RAP管理項目 | 更新監査 |

## ZSA_GM_ITM

UUIDキー、親UUID、明細番号、品目、プラント、保管場所、移動タイプ、数量、
単位、購買発注・明細、原価センタ、指図、明細テキストを保持する。

## ZSA_AP_ROUTE

1行を1承認者として保持し、同じルートの行は`ROUTE_ID`で束ねる。`FUNCTION_ID`、`APPROVAL_PATTERN`、
`REQUESTER_USER`、`REQUESTER_COST_CENTER`、有効期間、承認順、承認者、
有効フラグを持つ。検索では具体値を空白（ワイルドカード）より優先する。

## ZSA_AP_REQ

承認申請ヘッダ。UUID、表示番号、元機能ID、承認パターン、コールバックID、
元伝票UUID、申請者・原価センタ、ステータス、現在承認順、件名、申請日時、
完了日時、監査項目を保持する。

## ZSA_AP_WORK

申請時点の承認ルートスナップショット。UUID、申請UUID、承認順、
承認者ID・表示名、ステータス、処理日時、コメントを保持する。

## 一意性

- 承認ルート: ルートID＋承認順＋承認者
- 入出庫明細: 親UUID＋明細番号
- 承認work item: 申請UUID＋承認順＋承認者
- 申請中制約: 元機能ID＋元伝票UUIDについて `IN_APPROVAL` は最大1件

最後の制約はDB一意索引だけでは状態条件を表現できないため、ロック取得後に
behavior implementationで検証する。
