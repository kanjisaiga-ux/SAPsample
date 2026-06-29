# ローカル開発セットアップ

## 前提

- Git for Windows
- ABAP Development Tools（ADT）
- SAP S/4HANA 2023 FPS02 / SAP_BASIS 758へ接続できるユーザー
- 対象システムにabapGit

## 初回設定

```powershell
git clone https://github.com/kanjisaiga-ux/SAPsample.git C:\Users\maruk\dev\SAP
Set-Location C:\Users\maruk\dev\SAP
powershell -NoProfile -File .\scripts\Test-Repository.ps1
```

Gitのユーザー情報が未設定の場合だけ、自分の情報を設定する。

```powershell
git config --global user.name "Your Name"
git config --global user.email "your-address@example.com"
```

## SAPへの取り込み

1. SAP側で対象パッケージを用意する。クラシックABAPとABAP Cloudは
   パッケージを分け、言語バージョンを混在させない。
2. abapGitでオンラインリポジトリ
   `https://github.com/kanjisaiga-ux/SAPsample.git` を登録する。
3. ブランチと差分を確認してpullする。
4. 全オブジェクトを有効化し、構文チェックを行う。
5. ABAP UnitとATCを実行する。
6. 実行結果とSAP_BASISレベルをサンプルREADMEへ記録する。

abapGitの開始フォルダは `.abapgit.xml` により
`/sap-learning-samples/src/` に固定される。ABAPオブジェクトのシリアライズ結果は
このフォルダへ置き、`docs` やUI5資材と混在させない。
