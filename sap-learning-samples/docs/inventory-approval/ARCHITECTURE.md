# 入出庫伝票・共通承認基盤 アーキテクチャ

## 採用方式

対象は SAP S/4HANA 2023 FPS02 / SAP_BASIS 758、OData V4、RAP、
Fiori elements List Report / Object Page とする。

実装は次の3つの業務オブジェクトに分離する。

1. `ZI_SA_GM_DOC`: 入出庫申請（ヘッダ・明細）
2. `ZI_SA_AP_REQUEST`: 承認申請（申請・承認スナップショット）
3. `ZI_SA_AP_ROUTE`: 承認ルートマスタ

入出庫伝票のSAP標準登録は、released RAP BO `I_MaterialDocumentTP` を
EMLで呼ぶ `ZCL_SA_GM_POSTER` に隔離する。

## 仕様を補完した決定

- RAPのmanaged early numberingを使うため、各ルートの技術キーは
  `RAW(16)` UUIDとする。画面表示用に連番形式の表示番号を別に保持する。
- 入出庫申請の有効データは承認前もアドオンテーブルだけに存在する。
  SAP標準入出庫伝票は最終承認時まで登録しない。
- 申請中の入出庫申請は変更・削除・再申請不可とする。
- 却下後は元の入出庫申請を修正できる。再申請時は新しい承認申請UUIDを採番する。
- 同一承認順の明細はOR承認とする。1名が承認すると同一順の残りを
  `SKIPPED` にし、次順を `READY` にする。
- 却下は即時に申請全体を `REJECTED` とし、未処理work itemを `CANCELLED` にする。
- 承認ルートは申請時にwork itemへスナップショットする。
  申請後にマスタを変更しても進行中申請には影響させない。
- 元機能の「メソッド名」は外部入力として実行しない。
  `FunctionID + CallbackID` を固定ファクトリで許可済みクラスへ解決する。

## 状態

### 入出庫申請

`DRAFT -> SUBMITTED -> POSTED`

却下時は `SUBMITTED -> REJECTED -> SUBMITTED`。標準登録失敗時は
`SUBMITTED -> POSTING_ERROR` とし、管理者が原因解消後に再実行する。

### 承認申請

`DRAFT -> IN_APPROVAL -> APPROVED`

却下時は `IN_APPROVAL -> REJECTED`。承認済み・却下済み申請は変更しない。

### Work item

`WAITING -> READY -> APPROVED`

同順の他承認者は `READY -> SKIPPED`。却下者は `READY -> REJECTED`、
その他の未処理明細は `CANCELLED`。

## 権限

- 入出庫申請: 登録者本人または業務管理者
- 承認: `ApproverUser = $session.user` かつ `WorkItemStatus = 'READY'`
- ルート保守: 専用PFCGロール
- SAP標準伝票登録: `I_MaterialDocumentTP` の実行権限

DCLだけでなくbehavior implementationでも更新直前に再検証する。

## トランザクション境界

承認更新と最終コールバックは同一RAP save sequenceで扱う。
標準入出庫伝票登録の `COMMIT ENTITIES` はコールバック内部で直接発行せず、
呼出元のRAPトランザクションに参加させる。API制約により分離コミットが必要な場合は、
outboxテーブルとApplication Jobによる非同期登録へ変更する。

## 既知の導入時確認事項

- `I_MaterialDocumentTP` の項目名とmovement typeごとの必須項目を対象システムで確認する。
- 101（購買発注入庫）、201（原価センタ出庫）、202（取消相当）を初期許可値とする。
  原価センタ入庫で使用するmovement typeは業務設定に合わせてマスタ化する。
- 原価センタのユーザーパラメータ取得はABAP Cloud released APIでは提供されないため、
  on-premise用アダプタに隔離する。ABAP Cloudモードでは組織コンテキストAPIへ差し替える。
- サービスバインディング公開、IAM/PFCG、Fiori Launchpad target mappingは環境依存作業とする。
