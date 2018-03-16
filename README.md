# build-proot.rb -- termux の開発コミュニティによる proot をビルドするための Ruby スクリプト

## 概要

この git リポジトリに置かれている Ruby スクリプトは、 [termux の開発コミュニティ][TERM]によって、システムコール [link(2)][LINK] を [symlink(2)][SLNK] によってエミュレートする機能が実装された [proot][PROT] をクロスコンパイル環境及び Android NDK toolchain に基づいて自動的にビルドする為の Ruby スクリプトです。

また、 [proot][PROT] 及び [proot][PROT] に依存するライブラリである [talloc][TLOC] のソースコードより自動的にビルドされたバイナリファイルである proot.{arm, arm-64} (ARM 及び ARM64 対応バイナリ) 及び proot.{x86-32,x86-64} (x86-32 及び x86-64 対応バイナリ) を同梱しています。

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

そして、　```./build-proot.rb``` スクリプトを起動すると、自動的に proot に依存する [talloc 2.1.11][TLOC] をダウンロードしてビルドした後、 [termux の開発コミュニティの github のリポジトリ群][TMRP]のうち、[コミットが c24fa3a4 のソースコード][PSRC]を取得して proot のビルドを行います。

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

## 同梱のバイナリファイルについて

以下に、この git リポジトリに同梱している proot.{arm, arm-64} (ARM 及び ARM64 対応バイナリ) 及び proot.{x86-32,x86-64} (x86-32 及び x86-64 対応バイナリ) の SHA256 のハッシュ値を示します。

ここで、ディレクトリ ```./cross-compile``` に置かれている ```proot.*``` のバイナリは、通常のクロスコンパイルに基づいてビルドされたものであり、ディレクトリ ```./android-ndk``` に置かれている ```proot.*``` のバイナリは、 Androoid NDK に基づいてビルドされたものです。

なお、 Ruby スクリプト ```build-proot.rb``` と同一のディレクトリに置かれている ```proot.*``` のバイナリは、 Android NDK に基づいてビルドされたものと同様です。

```
9d7717e6a337c49a7deec38074a35f043deda43b9d4b8d04b4794a62db6aaeba  ./cross-compile/proot.arm
d8b666ac9b4a61ea99e6d94cb956c8e699d64de26c5beb08e83bc230eb8e5db2  ./cross-compile/proot.arm-64
9f1eb8303e07570dcb533f2e84b81f2797fab80706d676b6b861b28074b275c0  ./cross-compile/proot.x86-32
c4c3f5dcfdaa2a52cb394ee28f95b6af32c6b335b4517c36b56948f7822ce12d  ./cross-compile/proot.x86-64

bc6cce6cea9c8f42d4ae8a543658a6ccdf34428734227aa75a90bb5e5192bf26  ./android-ndk/proot.arm
d03aab9ceb31eddb8ba83b52f5903b28e828953552b100226e3e0999f6c0d914  ./android-ndk/proot.arm-64
fd1849106822fa90ae0cc447e744d46a9b88f548f9249618c0384fc1754e133a  ./android-ndk/proot.x86-32
df0eebca891215362221b41b94aee579be620d0110e98f8e59f69d3e372f69b2  ./android-ndk/proot.x86-64
```

## 配布条件

この git リポジトリに置かれている本文書及び Ruby スクリプト ```build-proot.rb``` は、 [Z.OOL. (mailto:zool@zool.jpn.org)][ZOOL] が著作権を有し、別添する ```doc/COPYING.md``` のうち、 "LICENSE of Makefile and README.md" の項に記述されたライセンスの配布条件である [GNU public license version 3][GPL3] に従って配布されるものとします。

但し、この git リポジトリに同梱されている talloc 2.1.11 のソースコードである talloc-2.1.11.tar.gz は [Andrew Tridgell][ANDR] 氏が著作権を有し、別添する ```doc/COPYING.md``` のうち、 "LICENSE of talloc 2.1.11" の項に記述されたライセンスの配布条件である [GNU public license version 3][GPL3] に従って配布されるものとします。

そして、この git リポジトリに同梱されている proot のソースコードである proot-c24fa3a43af2336a93f63fe3fb3eac599f0e3592.zip 及びこれらのソースコードより生成されたバイナリファイルである proot.{arm,x86} は、 STMicroelectronics 社及び termux の開発コミュニティにおいて、別添する doc/COPYING.md のうち、 "LICENSE of PRoot" の項において記述された著作権者が著作権を有し、同項のライセンスの配布条件である [GNU public license version 2][GPL2] に従って配布されるものとします。

<!-- 外部リンク一覧 -->

[TERM]:https://termux.com/
[LINK]:http://man7.org/linux/man-pages/man2/link.2.html
[SLNK]:http://man7.org/linux/man-pages/man2/symlink.2.html
[PROT]:https://github.com/termux/proot
[TLOC]:https://download.samba.org/pub/talloc/talloc-2.1.11.tar.gz
[TMRP]:https://github.com/termux
[PSRC]:https://github.com/termux/proot/archive/c24fa3a43af2336a93f63fe3fb3eac599f0e3592.zip
[TANJ]:https://qiita.com/tanjo
[QTNJ]:https://qiita.com/tanjo/items/0c6549c6700160d5595b
[CASK]:https://caskroom.github.io/
[ZOOL]:http://zool.jpn.org/
[ANDR]:https://www.samba.org/~tridge/
[GPL2]:https://www.gnu.org/licenses/old-licenses/gpl-2.0.html
[GPL3]:https://www.gnu.org/licenses/gpl.html
