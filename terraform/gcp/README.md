# PLATEAU VIEW 4.0 Terraform for Google Cloud

PLATEAU VIEW 4.0（CMS・Editor・VIEW・Flow）を Google Cloud で構築するための Terraform 用ファイルです。システム構築手順は[『実証環境構築マニュアル Series No.09』](https://www.mlit.go.jp/plateau/file/libraries/doc/plateau_doc_0009_ver03.pdf)（以下、マニュアル）も併せて参照してください。

## 1. 改訂履歴

- 2025/03: PLATEAU VIEW 4.0 へのアップデートにあたり改訂
- 2024/03/13: PLATEAU VIEW 3.0 へのアップデートにあたり改訂
- 2023/03/31: 初版

## 2. 使用ツール

このマニュアルに従ってシステムを構築するためには、マニュアルの（１）使用ソフトウェア・サービスに記載されているものに加え、以下のツールが必要です。

- [gcloud CLI](https://cloud.google.com/sdk/docs/install): `v513.0.0` で検証済み
- [Terraform](https://www.terraform.io/): `v1.11.1` で検証済み

## 3. 手順

### 3.1 Terraform 変数ファイルの用意

最初に、[terraform.tfvars.example](./terraform.tfvars.example) をコピーします。

```console
cp terraform.tfvars.example terraform.tfvars
```

> [!TIP]
> ここでは`terraform.tfvars`と命名しましたが拡張子 `tfvars` であれば何でも構いません。

### 3.2 `gcloud`CLI のセットアップ

`gcloud`CLI を使用して、Google Cloud プロジェクトにログインします。

```console
gcloud auth login --update-adc
```

ブラウザが開くので Google アカウントでログインしてください。
ログインが完了したあとに、以下のコマンドを実行してプロジェクトを設定します。

```console
gcloud config set project <プロジェクトID>
```

### 3.3 Google Cloud のプロジェクトおよび GCS バケットの作成

Google Cloud コンソールからプロジェクトを作成します。
その後に、Terraform のバックエンドに使用するために、GCS（Google Cloud Storage）バケットを作成します。

作成したバケットのストレージクラスおよびロケーションを`google_storage_bucket.tf`に設定します。

以下の例では、ストレージクラス `STANDARD` およびロケーション `ASIA` に設定しています。

```diff
resource "google_storage_bucket" "terraform" {
-  location      = "<LOCATION>"
+ location      = "ASIA"
  name          = var.gcs_bucket
  storage_class = "<STORAGE_CLASS>"
+  storage_class = "STANDARD"
}
```

また、作成したバケットの名前を`terraform.tf`の`backend`の`bucket`に設定します。

```diff
terraform {
+  backend "gcs" {
+    bucket = "<作成したバケット名>"
+  }

  required_providers {
  ...
}
```

そして、作成した GCS バケットを取り込みます。

```console
# 初回一回のみ
$ terraform init

# APIの有効化
$ terraform import google_storage_bucket.terraform <バケット名>
```

### 3.4 MongoDB Atlas のセットアップ

[MongoDB Altas](https://www.mongodb.com/atlas)へログインして、デプロイメント(データベース)および接続に必要な以下の設定を行います。

- 読み取り/書き込み権限を所有するデータベースユーザーの作成
- IP アドレスの許可 (インターネットからアクセスを許可するため CIDR`0.0.0.0/0`を追加)

> [!WARNING]
> CIDR `0.0.0.0/0` でアクセスを許可するとインターネット上からアクセスできるようになるため、データベースユーザーの管理には十分注意してください。

データベース作成完了後に、データベース詳細ページから接続文字列（Connection String）を取得します。

### 3.5 Auth0 のセットアップ

[Auth0](https://auth0.com/)にログインして、テナントを作成した後、[公式の Quick Start](https://github.com/auth0/terraform-provider-auth0/blob/main/docs/guides/quickstart.md)を参考に、アプリケーションを作成してください。作成後、クライアントシークレットを取得してください。

### 3.6 Terraform 変数の設定

これまで構築してきた Google Cloud、MongoDB および Auth0 などの情報を`terraform.tfvars`に設定します。

### 3.7 Google Cloud API の有効化

ホスティングを行う前に、以下の API を有効化してください。

```console
$ terraform apply --target google_project_service.project
```

実行の承認を求められるので、 `yes` を入力してください（以降の `terraform apply` の実行でも同様にしてください）。

### 3.8 Cloud DNS マネージドゾーンの作成およびドメイン解決の委譲

以下のコマンドで Cloud DNS マネージドゾーンを作成します。

```console
terraform apply --target google_dns_managed_zone.zone
```

Google Cloud コンソール上で、作成されたリソースを確認することができます。
マネージドゾーン名を取得し、以下のコマンドを実行して`NS`レコードを取得します。

```console
gcloud dns record-sets list --zone <マネージドゾーン名> --format='value(nameServers)' --flatten 'nameServers'
```

出力された`NS`レコードを、ドメインのレジストラで、ドメインのネームサーバーとして設定してください。
設定方法は各レジストラによって異なりますので、レジストラのドキュメントを参照してください。

### 3.9 Terraform の実行

再度、すべてのリソースを作成するために以下のコマンドを実行します。

```console
terraform apply
```

実行が成功すると、以下のような出力が表示されます。

```console
$ terraform apply
...
plateauview_cms_url = "*"
plateauview_cms_webhook_secret = <sensitive>
plateauview_cms_webhook_url = "*"
plateauview_editor_url = "*"
plateauview_flow_token = "*"
plateauview_flow_url = "*"
plateauview_geo_url = "*"
plateauview_sdk_token = <sensitive>
plateauview_setup_token = "*"
plateauview_sidebar_token = <sensitive>
plateauview_sidecar_url = "*"
plateauview_tiles_url = "*"
```

これらの出力は、あとでログインするときに使います。なお、もう一度表示したいときは`terraform output`コマンドで表示することができます。また、`sensitive`と表示されているものは、マスクされており、以下のようなコマンドで実際の値を確認してください。

```console
terraform output <確認したいOutput>
```

| 変数                             | 説明                                                                                                                    |
| -------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `plateauview_cms_url`            | PLATEAU CMS の URL                                                                                                      |
| `plateauview_cms_webhook_secret` | 下記「CMS インテグレーション設定」で使用                                                                                |
| `plateauview_cms_webhook_url`    | 下記「CMS インテグレーション設定」で使用                                                                                |
| `plateauview_editor_url`         | PLATEAU Editor の URL                                                                                                   |
| `plateauview_flow_token`         | PLATEAU Flow のトリガー用シークレット                                                                                       |
| `plateauview_flow_url`           | PLATEAU Flow の URL                                                                                                     |
| `plateauview_geo_url`            | タイルなどを変換・処理するサーバーの URL                                                                                |
| `plateauview_sdk_token`          | PLATEAU SDK 用のトークン。SDK の UI で設定する（詳しくはマニュアルを参照）                                              |
| `plateauview_setup_token`        | PLATEAU CMS セットアップ用のトークン              |
| `plateauview_sidebar_token`      | ビューワのサイドバー用の API トークン。エディタ上でサイドバーウィジェットの設定から設定する（詳しくはマニュアルを参照） |
| `plateauview_sidecar_url`        | サイドカーサーバーの URL。エディタ上でサイドバーウィジェットの設定から設定する（詳しくはマニュアルを参照）              |
| `plateauview_tiles_url`          | タイル配信サーバーの URL                                                                                                |

### 3.10 DNS・ロードバランサ・証明書のデプロイ完了の確認

実際に`curl`コマンドなどでリクエストを送って、デプロイが完了していることを確認します。

```console
curl https://api.${DOMAIN}/ping
```

### 3.11 Auth0 ユーザー作成

先ほど作成した Auth0 テナントにユーザーを作成します。
その後に、届くメールでメールアドレスを認証するか、メールアドレス認証のステータスをアカウント詳細画面から`Verified`にすることを忘れないでください。

> [!WARNING]
> 必ず上記ステップでデプロイが完了していることを確認してから、Auth0 のユーザーを作成してください。先に作成した場合、正常に Editor や CMS にログインできなくなります。

### 3.12 CMS インテグレーション設定

Terraform のの `plateauview_cms_url` の URL（`https://cms.${DOMAIN}`）から PLATEAU CMS にログインします。

ログイン後、ワークスペース・My インテグレーションを作成します。

次に、インテグレーション内に以下の通り webhook を作成する。作成後、有効化を忘れないこと。

- URL: `terraform outputs`の`plateauview_cms_webhook_url`
- シークレット: `terraform outputs`の`plateauview_cms_webhook_secret`
- イベント: 全てのチェックボックスにチェックを入れる。

作成後、作成したワークスペースに作成したインテグレーションを追加し、オーナー権限に変更する。

先ほど作成したインテグレーションの詳細画面でインテグレーショントークンをコピーし、以下の `${PLATEAUVIEW_CMS_TOKEN}` に貼り付けて以下のコマンドを実行する。

```console
echo -n "${PLATEAUVIEW_CMS_TOKEN}" | gcloud secrets versions add plateau-view-REEARTH_PLATEUVIEW_CMS_TOKEN --data-file=-
```

環境変数の変更を適用するため、もう一度 Cloud Run をデプロイしてください。

```console
gcloud run deploy plateauview-api \
  --image eukarya/plateauview-api \
  --region asia-northeast1 \
  --platform managed \
  --quiet
```

### 4. 完了

以下のアプリケーションにログインし、正常に使用できることを確認します。ここの `${DOMAIN}` はドメインです。

- PLATEAU Editor: Terraform の outputs の `plateauview_editor_url` の値（`https://editor.${DOMAIN}`）
- PLATEAU CMS: Terraform の outputs の `plateauview_cms_url` の値（`https://cms.${DOMAIN}`）
- PLATEAU Flow: Terraform の outputs の `plateauview_flow_url` の値（`https://flow.${DOMAIN}`）

この後は画面上での設定作業になります。続きは[マニュアル](https://www.mlit.go.jp/plateau/file/libraries/doc/plateau_doc_0009_ver03.pdf)をご覧ください。
