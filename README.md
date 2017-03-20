# termux の開発コミュニティによる proot をビルドするためのスクリプト

## 概要

スクリプトファイル build.sh は、 [termux の開発コミュニティ][1]によって、システムコール link(2) を symlink(2) によってエミュレートする機能が実装された [proot][2] を自動的にビルドするためのスクリプトです。

また、自動的にビルドされた結果である proot のバイナリファイルを同梱しています。

[1]:https://termux.com/
[2]:https://github.com/termux/proot

## 使用法

build.sh を使用する前に、予め端末にソースコードのビルドを行うための環境とクロスコンパイルを行うための環境をインストールする必要があります。 Ubuntu 系のディストリビューションの場合は、以下のようにパッケージのインストールを行います。

```
sudo apt-get install build-essential git wget
sudo apt-get install g++-arm-linux-gnueabihf qemu-user qemu-user-static
```

そして、 build.sh を起動すると、自動的に proot に依存する [talloc 2.1.9][3] をダウンロードしてビルドした後、 [termux の開発コミュニティの github のリポジトリ群][4]より [proot のリポジトリ][2]を取得して proot のビルドを行います。

[3]:https://download.samba.org/pub/talloc/talloc-2.1.9.tar.gz
[4]:https://github.com/termux
