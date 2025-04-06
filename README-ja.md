# MoonBit and Zig

> MoonBit とモダンなシステムプログラミング言語間の相互運用性を探る実験的なプロジェクトです。

## プロジェクトの目的

このプロジェクトは、MoonBit で HTTP クライアントを実装するというニーズから生まれました。従来の `libcurl` ベースのソリューションとは異なり、以下の目標のもと、探索的なアプローチを採用しています。

1. `libcurl` からの完全な独立
2. Zig 標準ライブラリを用いたHTTPクライアントの実装
3. MoonBit と C/Zig 間の統合パターンの探求

## 技術選定の理由

基盤となる実装にCではなく Zig を選択した主な理由は以下の通りです。

1. **依存関係管理**
  * C言語のエコシステムでは、依存関係の管理が複雑になりがちです。
  * 多くの場合、コンパイラ（gccなど）、ライブラリパス、リンク設定を手動で構成する必要があります。
  * 一方、Zigはモダンなビルドシステムと包括的な標準ライブラリを提供します。

2. **標準ライブラリの機能**
  * Zig の標準ライブラリには、HTTP クライアントの実装が組み込まれています。
  * そのため、コアとなる HTTP 機能に外部ライブラリへの依存が必要ありません。

3. **相互運用性**
  * C ABIを介して連携しています（フェーズ1）。
  * 将来的には MoonBit と Zig の直接的な相互運用を目指しています ~~（フェーズ2）~~ （実装する）。

## アーキテクチャの変遷

主要なコンポーネントは以下の通りです。

* **MoonBit：** 主要なアプリケーション開発言語
* **Zig：** HTTP クライアントの基盤ロジックを実装
* ~~**C：** MoonBit - Zig 間の中間ブリッジ（フェーズ1）~~

### 過去のアーキテクチャ（フェーズ1）

[#21e56bb](/tree/21e56bb8ed27bd0aee0389d5417cf8a58068f46f)

```
MoonBit -> C ABI -> Zig
```

### 現在のアーキテクチャ（フェーズ2）

```
MoonBit -> Zig
```

## 使用例

```moonbit
fn main {
  // GET リクエストを実行
  println(@http.curl_get("https://api.example.com"))
  
  // POST リクエストを実行
  println(@http.curl_post("https://api.example.com", "{'data': 'test'}"))
}
```

### CLI

```bash
> ./zig-out/bin/moonbit_zig
 No request url.

 Usage:
  moonbit_zig <url>

> ./zig-out/bin/moonbit_zig https://jsonplaceholder.typicode.com/todos/1
It Works! You've requested: https://jsonplaceholder.typicode.com/todos/1
{
  "userId": 1,
  "id": 1,
  "title": "delectus aut autem",
  "completed": false
}
```

## ビルド方法

このプロジェクトは `zig build` システムを利用します。ビルドするには `moon` コマンドを使用してください。

```bash
moon build --target native
```

## 注意事項

1. Zig 0.11.0 以降が必要です。
2. MoonBit のランタイム環境が適切に設定されていることを確認してください。
3. 現在サポートされているプラットフォームは macOS/aarch64 のみです。
