# Memo Pad
## 概要
Sinatraで作成されたシンプルなメモアプリです。

## 機能
- メモの登録 / 編集 / 削除 
- メモ一覧表示
- レスポンシブ

## 環境
- bundler（動作確認 v2.2.20）
- ruby（動作確認 v3.0.1）

## インストール方法
 
```
$ git clone https://github.com/mashym91/fjord-sinatra-memo-app.git
$ cd fjord-sinatra-memo-app 
$ bundle install
$ bundle exec ruby app.rb
```
 
## テスト

```
$ APP_ENV=test bundle exec ruby test/app_test.rb
```
＊APP_ENV=testをつけないと実際の保存データが削除されてしまうので注意。

### 保存データ
メモデータはローカルの `./data/memos.json`に保存されています。対象ファイルを削除すると完全にデータが削除されます。

## 作者
 
[@mashym91](https://twitter.com/mashym91)

## ライセンス
 
[MIT](https://en.wikipedia.org/wiki/MIT_License)
