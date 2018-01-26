# termux の開発コミュニティによる proot をビルドするための Makefile

## 概要

この git リポジトリに置かれている Makefile は、 [termux の開発コミュニティ][TERM]によって、システムコール [link(2)][LINK] を [symlink(2)][SLNK] によってエミュレートする機能が実装された [proot][PROT] を自動的にビルドする為の Makefile です。

また、 [proot][PROT] 及び [proot][PROT] に依存するライブラリである [talloc][TLOC] のソースコードより自動的にビルドされたバイナリファイルである proot.{arm, arm-64} (ARM 及び ARM64 対応バイナリ) 及び proot.{x86-32,x86-64} (x86-32 及び x86-64 対応バイナリ) を同梱しています。

## 使用法

この git リポジトリに置かれている Makefile を使用する前に、予め端末にソースコードのビルドを行うための環境とクロスコンパイルを行うための環境をインストールする必要があります。 Ubuntu 系のディストリビューションの場合は、以下のようにパッケージのインストールを行います。

```
 $ sudo apt-get install build-essential libc6-dev-i386 git wget
 $ sudo apt-get install g++-arm-linux-gnueabihf g++-aarch64-linux-gnu qemu-user qemu-user-static
```

次に、ディレクトリ ```/usr/include``` に移動します。ここで、もしディレクトリ ```asm``` が存在しない場合は以下のようにして、ディレクトリ ```asm-generic``` から ```asm``` にシンボリックリンクを張ります。

```
 $ sudo ln -sf asm-generic asm
```

そして、　```make all``` により make コマンドを起動すると、自動的に proot に依存する [talloc 2.1.10][TLOC] をダウンロードしてビルドした後、 [termux の開発コミュニティの github のリポジトリ群][TMRP]のうち、[コミットが 454b0b1 のソースコード][PSRC]を取得して proot のビルドを行います。

なお、各アーキテクチャに対応した proot のバイナリを生成する場合は、以下の通りに ```make all``` を起動する必要があります。

```
 $ make all ARCH=arm	# (ARM    対応の proot の場合、デフォルト)
 $ make all ARCH=arm-64	# (ARM64  対応の proot の場合)
 $ make all ARCH=x86-32	# (x86-32 対応の proot の場合)
 $ make all ARCH=x86-64	# (x86-64 対応の proot の場合)
```

## 同梱のバイナリファイルについて

以下に、この git リポジトリに同梱している proot.{arm, arm-64} (ARM 及び ARM64 対応バイナリ) 及び proot.{x86-32,x86-64} (x86-32 及び x86-64 対応バイナリ) の SHA256 のハッシュ値を示します。

```
6c96060bbe3128eb557c0d165197bb068581ef84e07d618432d66b1a5b629719  proot.arm
29f1f8800454a09f676c191c9f9dc32ae52e04d69f648716d7adf69eb2195afb  proot.arm-64
1c2b81e55dcb0075c2f5e4ce64d3b0c7be98c4acc092103e9332cb25aee9f631  proot.x86-32
4b6c1745f45b04668593ffb03febfc44bae741a0d02b160dee8d567d58f224d3  proot.x86-64
```

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
