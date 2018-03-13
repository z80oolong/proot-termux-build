# build-proot.rb -- termux の開発コミュニティによる proot をビルドするための Ruby スクリプト

## 概要

この git リポジトリに置かれている Ruby スクリプトは、 [termux の開発コミュニティ][TERM]によって、システムコール [link(2)][LINK] を [symlink(2)][SLNK] によってエミュレートする機能が実装された [proot][PROT] を自動的にビルドする為の Ruby スクリプトです。

また、 [proot][PROT] 及び [proot][PROT] に依存するライブラリである [talloc][TLOC] のソースコードより自動的にビルドされたバイナリファイルである proot.{arm, arm-64} (ARM 及び ARM64 対応バイナリ) 及び proot.{x86-32,x86-64} (x86-32 及び x86-64 対応バイナリ) を同梱しています。

## 使用法

### 通常のクロスコンパイラを使用する場合

この git リポジトリに置かれている Ruby スクリプトを使用する前に、予め端末にソースコードのビルドを行うための環境とクロスコンパイルを行うための環境をインストールする必要があります。 Ubuntu 系のディストリビューションの場合は、以下のようにパッケージのインストールを行います。

```
 $ sudo apt-get install build-essential libc6-dev-i386 git wget
 $ sudo apt-get install g++-arm-linux-gnueabihf g++-aarch64-linux-gnu qemu-user qemu-user-static
```

次に、ディレクトリ ```/usr/include``` に移動します。ここで、もしディレクトリ ```asm``` が存在しない場合は以下のようにして、ディレクトリ ```asm-generic``` から ```asm``` にシンボリックリンクを張ります。

```
 $ sudo ln -sf asm-generic asm
```

そして、　```./build-proot.rb``` スクリプトを起動すると、自動的に proot に依存する [talloc 2.1.10][TLOC] をダウンロードしてビルドした後、 [termux の開発コミュニティの github のリポジトリ群][TMRP]のうち、[コミットが 454b0b1 のソースコード][PSRC]を取得して proot のビルドを行います。

なお、各アーキテクチャに対応した proot のバイナリを生成する場合は、以下の通りに ```./build-proot.rb``` スクリプトを起動する必要があります。

```
 $ ./build-proot.rb --arch arm		# (ARM    対応の proot の場合、デフォルト)
 $ ./build-proot.rb --arch arm-64	# (ARM64  対応の proot の場合)
 $ ./build-proot.rb --arch x86-32	# (x86-32 対応の proot の場合)
 $ ./build-proot.rb --arch x86-64	# (x86-64 対応の proot の場合)
```

また、 talloc 及び proot バイナリを生成するためのクロスコンパイラ等が、ディレクトリ ```/usr``` 以外に置かれている場合には、オプション ```--cross-compile-prefix``` を用いて、クロスコンパイラの置かれているディレクトリを下記のように指定する必要があります。

```
 $ ./build-proot.rb --arch arm --cross-compile-prefix /usr/local	# (ARM    対応の proot の場合)
 $ ./build-proot.rb --arch arm-64 --cross-compile-prefix /usr/local	# (ARM64  対応の proot の場合)
 $ ./build-proot.rb --arch x86-32 --cross-compile-prefix /usr/local	# (x86-32 対応の proot の場合)
 $ ./build-proot.rb --arch x86-64 --cross-compile-prefix /usr/local	# (x86-64 対応の proot の場合)
```

### Android NDK を使用する場合

## 同梱のバイナリファイルについて

以下に、この git リポジトリに同梱している proot.{arm, arm-64} (ARM 及び ARM64 対応バイナリ) 及び proot.{x86-32,x86-64} (x86-32 及び x86-64 対応バイナリ) の SHA256 のハッシュ値を示します。

```
ea94dce029b1bffa7da6586dcdd1137ca14803ab29a145b8bb1113c18965663b  cross-compile/proot.arm
a2de032d785cf90a5f6130423f33d12dfb9ffb4fb94e7da0bfab5c423f99fd33  cross-compile/proot.arm-64
d9c1db0ce05b2ff123ba093748bc3a4f252e1ea8a4d1d8cc220f06b3a59bff27  cross-compile/proot.x86-32
207d5c150a22965c72994f1fa6ff09d9e3046ab229eb1b57fd7a3c2d373ab0ce  cross-compile/proot.x86-64

9ca38472b2e824a1a9facbfa3ee1d23ea7c5ed733be17b4612c2610cb8d1970c  android-ndk/proot.arm
63b261be6b3e66c3abd1768d60c5f88e410dfa1c339ea191a248afb958251a0f  android-ndk/proot.arm-64
a13cc90f1685d29b5ca2fa98d737a9f608eccf8beccb09cb2b310d51da25c1ba  android-ndk/proot.x86-32
ed327ebfddaf5d781166905da64c02199cc3980d60891f54d48ef2d76fb14ca9  android-ndk/proot.x86-64
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
