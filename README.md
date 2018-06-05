# build-proot.rb -- termux の開発コミュニティによる proot をビルドするための Ruby スクリプト

## 概要

この git リポジトリに置かれている Ruby スクリプトは、 [termux の開発コミュニティ][TERM]によって、システムコール [link(2)][LINK] を [symlink(2)][SLNK] によってエミュレートする機能が実装された [proot][PROT] をクロスコンパイル環境及び Android NDK toolchain に基づいて自動的にビルドする為の Ruby スクリプトです。

なお、このスクリプトによってコンパイルされる [proot][PROT] は、 VFAT 領域等、シンボリックリンクに対応していないファイルシステムの領域において、システムコール [link(2)][LINK] を実行した時に、リンク元のファイルが別名に変更されたままとなる不具合を修正する差分ファイルが適用されています。

## 使用法

### Debian パッケージによるクロスコンパイル環境を使用する場合

この git リポジトリに置かれている Ruby スクリプトである ```build-proot.rb``` を使用する前に、予めクロスコンパイル用の端末にソースコードのビルドを行うための環境とクロスコンパイルを行うための環境をインストールする必要があります。 Ubuntu 系のディストリビューションの場合は、以下のようにパッケージのインストールを行います。

```
 $ sudo apt-get install build-essential libc6-dev-i386 git wget
 $ sudo apt-get install g++-arm-linux-gnueabihf g++-aarch64-linux-gnu qemu-user qemu-user-static
```

次に、ディレクトリ ```/usr/include``` に移動します。ここで、もしディレクトリ ```asm``` が存在しない場合は以下のようにして、ディレクトリ ```asm-generic``` から ```asm``` にシンボリックリンクを張ります。

```
 $ sudo ln -sf asm-generic asm
```

そして、　```./build-proot.rb``` スクリプトを起動すると、自動的に proot に依存する [talloc 2.1.11][TLOC] をダウンロードしてビルドした後、 [termux の開発コミュニティの github のリポジトリ群][TMRP]のうち、[コミットが 3bc068685 のソースコード][PSRC]を取得して proot のビルドを行います。

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

### Android NDK によるクロスコンパイル環境を使用する場合

Debian パッケージによるクロスコンパイル環境に代えて、 Android NDK toolchain によるクロスコンパイル環境を導入することにより、 Ruby スクリプト ```./build-proot.rb``` を使用して proot をビルドするには、予め下記の Debian パッケージをインストールする必要があります。

```
 $ sudo apt-get install build-essential git wget qemu-user qemu-user-static
```

次に、 proot をビルドする端末に Android NDK をインストールします。具体的なインストール手法については、 [tanjo 氏][TANJ]による "[Android の Linux 環境をターミナルから構築する][QTNJ]" の投稿の他、 Android NDK に関する各種資料を参考にして下さい。

なお、 Linuxbrew が導入されている端末に Android NDK のインストールする場合は、 2018 年 3 月現在で ```android-sdk, android-ndk``` の両 Formula が [Caskroom][CASK] に移行しているため、下記のようにしてインストールする必要があります。

```
 $ brew install -dv https://raw.githubusercontent.com/Linuxbrew/homebrew-core/a0f7020167cec6ee73c7d99ca89b1bd433ee6536/Formula/android-sdk.rb
 $ brew install -dv https://raw.githubusercontent.com/Linuxbrew/homebrew-core/b0eae852a26b09e17111caa75b6c8e9d636b9055/Formula/android-ndk.rb
```

そして、下記のようにして、 ```./build-proot.rb``` スクリプトに、オプション ```--android-ndk-preix``` に Android NDK のインストール先のディレクトリを指定して起動すると、前述の通常のクロスコンパイル環境の場合と同様に、自動的に [termux の開発コミュニティの github のリポジトリ群][TMRP]のうち、[コミットが c24fa3a4 のソースコード][PSRC]を取得して proot のビルドを行います。

```
 $ ./build-proot.rb --arch arm --android-ndk-prefix /opt/android-ndk	# (ARM    対応の proot の場合。以下、 Android NDK のインストール先を /opt/android-ndk とする)
 $ ./build-proot.rb --arch arm-64 --android-ndk-prefix /opt/android-ndk	# (ARM64  対応の proot の場合)
 $ ./build-proot.rb --arch x86-32 --android-ndk-prefix /opt/android-ndk	# (x86-32 対応の proot の場合)
 $ ./build-proot.rb --arch x86-64 --android-ndk-prefix /opt/android-ndk	# (x86-64 対応の proot の場合)
```

## バイナリファイルの同梱について
 
安定版 v0.5 のリリースより、本 git リポジトリにおいて、コンパイル済のバイナリファイル proot.{arm, x86-32, x86-64} 等の同梱を廃止致します。誠に恐れ入りますが、どうか御了承ください。

今後は、以下の proot-termux-build の安定版の配布ページにおいて、安定版のコンパイル済のバイナリファイル及び、コンパイルに使用したソースコードと差分ファイルを配布致しますので、実行形式のバイナリファイルは、下記の URL より入手して下さいますよう、どうか宜しく御願い致します。

- proot-termux-build の安定版の配布ページ
    - [https://github.com/z80oolong/proot-termux-build/releases][RELA]

## 配布条件

この git リポジトリに置かれている本文書及び Ruby スクリプト ```build-proot.rb``` は、 [Z.OOL. (mailto:zool@zool.jpn.org)][ZOOL] が著作権を有し、別添する ```doc/COPYING.md``` のうち、 "LICENSE of Makefile and README.md" の項に記述されたライセンスの配布条件である [GNU public license version 3][GPL3] に従って配布されるものとします。

<!-- 外部リンク一覧 -->

[TERM]:https://termux.com/
[LINK]:http://man7.org/linux/man-pages/man2/link.2.html
[SLNK]:http://man7.org/linux/man-pages/man2/symlink.2.html
[PROT]:https://github.com/termux/proot
[TLOC]:https://download.samba.org/pub/talloc/talloc-2.1.11.tar.gz
[TMRP]:https://github.com/termux
[PSRC]:https://github.com/termux/proot/archive/proot-3bc06868508b858e9dc290e29815ecd690e9cb0c.zip
[TANJ]:https://qiita.com/tanjo
[QTNJ]:https://qiita.com/tanjo/items/0c6549c6700160d5595b
[CASK]:https://caskroom.github.io/
[RELA]:https://github.com/z80oolong/proot-termux-build/releases
[ZOOL]:http://zool.jpn.org/
[GPL3]:https://www.gnu.org/licenses/gpl.html
