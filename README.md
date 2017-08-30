# termux の開発コミュニティによる proot をビルドするためのスクリプト

## 概要

この git リポジトリに置かれている Makefile は、 [termux の開発コミュニティ][1]によって、システムコール link(2) を symlink(2) によってエミュレートする機能が実装された [proot][2] を自動的にビルドする為の Makefile です。

また、 proot 及び proot に依存するライブラリである talloc のソースコードより自動的にビルドされたバイナリファイルである proot.arm (ARM 対応バイナリ) 及び proot.x86 (x86 対応バイナリ) を同梱しています。

## 使用法

この git リポジトリに置かれている Makefile を使用する前に、予め端末にソースコードのビルドを行うための環境とクロスコンパイルを行うための環境をインストールする必要があります。 Ubuntu 系のディストリビューションの場合は、以下のようにパッケージのインストールを行います。

```
sudo apt-get install build-essential git wget
sudo apt-get install g++-arm-linux-gnueabihf qemu-user qemu-user-static
```

そして、　```make build``` により make コマンドを起動すると、自動的に proot に依存する [talloc 2.1.10][3] をダウンロードしてビルドした後、 [termux の開発コミュニティの github のリポジトリ群][4]より [proot のリポジトリ][2]のうち、[コミットが edc869d6 のソースコード][5]を取得して proot のビルドを行います。

## 配布条件

この git リポジトリに置かれている Makefile 及び talloc-cross-answer.txt は、 [Z.OOL. (mailto:zool@zool.jpn.org)][6] が著作権を有し、別添する LICENSE.md のうち、 "LICENSE of Makefile and talloc-cross-answer.txt" の項に記述されたライセンスの配布条件に従って配布されるものとします。

但し、この git リポジトリに同梱されている talloc 2.1.9 のソースコードである talloc-2.1.9.tar.gz は Andrew Tridgell 氏が著作権を有し、別添する LICENSE.md のうち、 "LICENSE of talloc 2.1.9" の項に記述されたライセンスの配布条件に従って配布されるものとします。

そして、この git リポジトリに同梱されている proot のソースコードである proot-edc869d60c7f5b6abf67052a327ef099aded7777.zip 及びこれらのソースコードより生成されたバイナリファイルである proot.{arm,x86} は STMicroelectronics 社及び termux の開発コミュニティが著作権を有し、別添する LICENSE.md のうち、 "LICENSE of PRoot" の項に記述されたライセンスの配布条件に従って配布されるものとします。

<!-- 外部リンク一覧 -->

[1]:https://termux.com/
[2]:https://github.com/termux/proot
[3]:https://download.samba.org/pub/talloc/talloc-2.1.10.tar.gz
[4]:https://github.com/termux
[5]:https://github.com/termux/proot/archive/proot-edc869d60c7f5b6abf67052a327ef099aded7777.zip
[6]:mailto:zool@zool.jpn.org

