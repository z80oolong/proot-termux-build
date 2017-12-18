# termux の開発コミュニティによる proot をビルドするための Makefile

## 概要

この git リポジトリに置かれている Makefile は、 [termux の開発コミュニティ][TERM]によって、システムコール [link(2)][LINK] を [symlink(2)][SLNK] によってエミュレートする機能が実装された [proot][PROT] を自動的にビルドする為の Makefile です。

また、 [proot][PROT] 及び [proot][PROT] に依存するライブラリである [talloc][TLOC] のソースコードより自動的にビルドされたバイナリファイルである proot.arm (ARM 対応バイナリ) 及び proot.{x86-32,x86-64} (x86-32 及び x86-64 対応バイナリ) を同梱しています。

## 使用法

この git リポジトリに置かれている Makefile を使用する前に、予め端末にソースコードのビルドを行うための環境とクロスコンパイルを行うための環境をインストールする必要があります。 Ubuntu 系のディストリビューションの場合は、以下のようにパッケージのインストールを行います。

```
 $ sudo apt-get install build-essential libc6-dev-i386 git wget
 $ sudo apt-get install g++-arm-linux-gnueabihf qemu-user qemu-user-static
```

次に、ディレクトリ ```/usr/include``` に移動します。ここで、もしディレクトリ ```asm``` が存在しない場合は以下のようにして、ディレクトリ ```asm-generic``` から ```asm``` にシンボリックリンクを張ります。

```
 $ sudo ln -sf asm-generic asm
```

そして、　```make build``` により make コマンドを起動すると、自動的に proot に依存する [talloc 2.1.10][TLOC] をダウンロードしてビルドした後、 [termux の開発コミュニティの github のリポジトリ群][TMRP]のうち、[コミットが 454b0b1 のソースコード][PSRC]を取得して proot のビルドを行います。

## 配布条件

この git リポジトリに置かれている本文書及び Makefile は、 [Z.OOL. (mailto:zool@zool.jpn.org)][ZOOL] が著作権を有し、別添する ```doc/COPYING.md``` のうち、 "LICENSE of Makefile and README.md" の項に記述されたライセンスの配布条件である [GNU public license version 3][GPL3] に従って配布されるものとします。

但し、この git リポジトリに同梱されている talloc 2.1.10 のソースコードである talloc-2.1.10.tar.gz は [Andrew Tridgell][ANDR] 氏が著作権を有し、別添する ```doc/COPYING.md``` のうち、 "LICENSE of talloc 2.1.10" の項に記述されたライセンスの配布条件である [GNU public license version 3][GPL3] に従って配布されるものとします。

そして、この git リポジトリに同梱されている proot のソースコードである proot-454b0b121f03a662f53844a8865f518757e0a315.zip 及びこれらのソースコードより生成されたバイナリファイルである proot.{arm,x86} は、 STMicroelectronics 社及び termux の開発コミュニティにおいて、別添する doc/COPYING.md のうち、 "LICENSE of PRoot" の項において記述された著作権者が著作権を有し、同項のライセンスの配布条件である [GNU public license version 2][GPL2] に従って配布されるものとします。

<!-- 外部リンク一覧 -->

[TERM]:https://termux.com/
[LINK]:http://man7.org/linux/man-pages/man2/link.2.html
[SLNK]:http://man7.org/linux/man-pages/man2/symlink.2.html
[PROT]:https://github.com/termux/proot
[TLOC]:https://download.samba.org/pub/talloc/talloc-2.1.10.tar.gz
[TMRP]:https://github.com/termux
[PSRC]:https://github.com/termux/proot/archive/454b0b121f03a662f53844a8865f518757e0a315.zip
[ZOOL]:http://zool.jpn.org/
[ANDR]:https://www.samba.org/~tridge/
[GPL2]:https://www.gnu.org/licenses/old-licenses/gpl-2.0.html
[GPL3]:https://www.gnu.org/licenses/gpl.html
