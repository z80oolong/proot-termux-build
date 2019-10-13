#!/usr/bin/env ruby
#
# Copyright (C) Z.OOL. <zool@zool.jpn.org> 2017
#
# This file is distriduted under the GNU General Public License v3.
# See doc/COPYING.md for more details.

require "fileutils"
require "pathname"
require "optparse"

TALLOC_VERSION     = "2.1.14"
PROOT_VERSION      = "5.1.0.114"
#PROOT_VERSION      = "master"

TALLOC_URL         = "https://download.samba.org/pub/talloc/talloc-#{TALLOC_VERSION}.tar.gz"
PROOT_URL          = "https://github.com/z80oolong/proot/archive/v#{PROOT_VERSION}.zip"
#PROOT_URL          = "https://github.com/z80oolong/proot/archive/master.zip"

ANDROID_NDK_PREFIX = "/opt/android-ndk"
ANDROID_NDK_API    = 24

module ShellExec
  module_function

  def shell(*args)
    args = args.join(" "); puts "[Exec]: #{args}"
    abort "[Error]: Failed to execute #{args}" unless Kernel.system(args)
  end

  def x(*args)
    args = args.join(" "); result = eval "%x[#{args}]"
    abort "[Error]: Failed to execute #{args}" unless $?.success?
    return result.chomp
  end
end

class String
  include ShellExec

  def to_path
    return Pathname.new(self)
  end

  def which
    return Pathname.new(x("/usr/bin/which", self))
  end
end

class Pathname
  def /(other)
    Pathname.new(self + other.to_s)
  end

  def chdir(&block)
    return Dir.chdir(self.to_s, &block)
  end

  def rm_rf
    return ::FileUtils.rm_r(self.to_s, :force => true)
  end
end

class BuildEnvironment
  include ShellExec

  private

  def initialize_build_util
    @env     = "env".which;    @tar     = "tar".which
    @unzip   = "unzip".which;  @wget    = "wget".which
    @make    = "make".which;   @install = "install".which
  end

  def initialize_arch_build_host(arch, android_ndk_prefix)
    if android_ndk_prefix.nil?
      @android_ndk_arch = nil
      case arch
      when "arm"
        @arch = arch
        @build_host = "arm-linux-gnueabihf"
      when "arm-64"
        @arch = arch
        @build_host = "aarch64-linux-gnu"
      when "x86-32", "x86-64"
        @arch = arch
        @build_host = "x86_64-linux-gnu"
      else
        raise "Failed to initialize, AUnknown arch = #{arch}"
      end
    else
      case arch
      when "arm"
        @arch = @android_ndk_arch = arch
        @build_host = "arm-linux-androideabi"
      when "arm-64"
        @arch = arch; @android_ndk_arch = "arm64"
        @build_host = "aarch64-linux-android"
      when "x86-32"
        @arch = arch; @android_ndk_arch = "x86"
        @build_host = "i686-linux-android"
      when "x86-64"
        @arch = arch; @android_ndk_arch = "x86_64"
        @build_host = "x86_64-linux-android"
      else
        raise "Failed to initialize, Unknown arch = #{arch}"
      end
    end
  end

  def initialize_path(android_ndk_prefix, cross_compile_prefix)
    @android_ndk_prefix   = (android_ndk_prefix || ::ANDROID_NDK_PREFIX).to_path
    @cross_compile_prefix = (cross_compile_prefix || "/usr").to_path
    @build_prefix         = (Pathname.pwd/"opt")
    @talloc_prefix        = (@build_prefix/"talloc-#{::TALLOC_VERSION}")
  end

  def initialize_flags
    if @android_ndk_arch.nil?
      case @arch
      when "arm"
        @cflags   = "-mthumb -O2 -I#{@talloc_prefix}/include -I#{@cross_compile_prefix}/include -I#{@cross_compile_prefix}/#{@build_host}/include"
        @cppflags = "-mthumb -DARG_MAX=131072 -I#{@talloc_prefix}/include -I#{@cross_compile_prefix}/include -I#{@cross_compile_prefix}/#{@build_host}/include"
        @ldflags  = "-L#{@talloc_prefix}/lib -L#{@cross_compile_prefix}/lib -L#{@cross_compile_prefix}/#{@build_host}/lib"
      when "arm-64", "x86-64"
        @cflags   = "-O2 -I#{@talloc_prefix}/include -I#{@cross_compile_prefix}/include -I#{@cross_compile_prefix}/#{@build_host}/include"
        @cppflags = "-DARG_MAX=131072 -I#{@talloc_prefix}/include -I#{@cross_compile_prefix}/include -I#{@cross_compile_prefix}/#{@build_host}/include"
        @ldflags  = "-L#{@talloc_prefix}/lib -L#{@cross_compile_prefix}/lib -L#{@cross_compile_prefix}/#{@build_host}/lib"
      when "x86-32"
        @cflags   = "-O2 -I#{@talloc_prefix}/include -I#{@cross_compile_prefix}/include -I#{@cross_compile_prefix}/#{@build_host}/include"
        @cppflags = "-DARG_MAX=131072 -I#{@talloc_prefix}/include -I#{@cross_compile_prefix}/include -I#{@cross_compile_prefix}/#{@build_host}/include"
        @ldflags  = "-m32 -L#{@talloc_prefix}/lib -L#{@cross_compile_prefix}/lib -L#{@cross_compile_prefix}/#{@build_host}/lib"
      end
    else
      case @arch
      when "arm"
        @cflags   = "-mthumb -march=armv7-a -O2 -I#{@talloc_prefix}/include"
        @cppflags = "-mthumb -march=armv7-a -O2 -DARG_MAX=131072 -I#{@talloc_prefix}/include"
      when "arm-64"
        @cflags   = "-march=armv8-a -O2 -I#{@talloc_prefix}/include"
        @cppflags = "-march=armv8-a -O2 -DARG_MAX=131072 -I#{@talloc_prefix}/include"
      when "x86-32", "x86-64"
        @cflags   = "-O2 -I#{@talloc_prefix}/include"
        @cppflags = "-O2 -DARG_MAX=131072 -I#{@talloc_prefix}/include"
      end
      @ldflags = "-L#{@talloc_prefix}/lib"
    end
  end

  def initialize_compiler
    cross_compile = "#{@cross_compile}"
    if @android_ndk_arch.nil? then
      case @arch
      when "x86-32"
        @cc  = "#{@cross_compile_prefix}/bin/#{@build_host}-gcc -m32"
        @cpp = "#{@cross_compile_prefix}/bin/#{@build_host}-cpp -m32"
      else
        @cc  = "#{@cross_compile_prefix}/bin/#{@build_host}-gcc"
        @cpp = "#{@cross_compile_prefix}/bin/#{@build_host}-cpp"
      end
      @ar      = "#{@cross_compile_prefix}/bin/#{@build_host}-ar"
      @ranlib  = "#{@cross_compile_prefix}/bin/#{@build_host}-ranlib"
      @strip   = "#{@cross_compile_prefix}/bin/#{@build_host}-strip"
      @ld      = "#{@cross_compile_prefix}/bin/#{@build_host}-ld"
      @objcopy = "#{@cross_compile_prefix}/bin/#{@build_host}-objcopy"
      @objdump = "#{@cross_compile_prefix}/bin/#{@build_host}-objdump"
    else
      toolchain_prefix = "#{@build_prefix}/toolchain-#{@android_ndk_arch}/bin".to_path
      sysroot          = "#{@build_prefix}/toolchain-#{@android_ndk_arch}/sysroot".to_path
      @cc              = "#{toolchain_prefix}/#{@build_host}-gcc --sysroot=#{sysroot}"
      @cpp             = "#{toolchain_prefix}/#{@build_host}-cpp --sysroot=#{sysroot}"
      @ar              = "#{toolchain_prefix}/#{@build_host}-ar"
      @ranlib          = "#{toolchain_prefix}/#{@build_host}-ranlib"
      @strip           = "#{toolchain_prefix}/#{@build_host}-strip"
      @ld              = "#{toolchain_prefix}/#{@build_host}-ld"
      @objcopy         = "#{toolchain_prefix}/#{@build_host}-objcopy"
      @objdump         = "#{toolchain_prefix}/#{@build_host}-objdump"
    end
  end

  def initialize_misc
    @ans_txt    = (Pathname.pwd/"talloc-cross-answer.txt")
    @make_opt   = "-j4"
  end

  def initialize(arch, android_ndk_prefix = nil, cross_compile_prefix = nil)
    initialize_build_util
    initialize_arch_build_host(arch, android_ndk_prefix)
    initialize_path(android_ndk_prefix, cross_compile_prefix)
    initialize_flags
    initialize_compiler
    initialize_misc
  end

  public

  attr_reader :env, :tar, :unzip, :wget, :make, :install
  attr_reader :arch, :android_ndk_arch
  attr_reader :cflags, :cppflags, :ldflags
  attr_reader :cc, :cpp, :ar, :ranlib, :strip, :ld, :objcopy, :objdump
  attr_reader :android_ndk_prefix, :build_prefix, :talloc_prefix
  attr_reader :ans_txt, :make_opt

  def to_s
    result =  %[ENV                = "#{@env}"\n]
    result << %[TAR                = "#{@tar}"\n]
    result << %[UNZIP              = "#{@unzip}"\n]
    result << %[WGET               = "#{@wget}"\n]
    result << %[MAKE               = "#{@make}"\n]
    result << %[INSTALL            = "#{@install}"\n]
    result << %[ARCH               = "#{@arch}"\n]
    result << %[ANDROID_NDK_ARCH   = "#{@android_ndk_arch}"\n]
    result << %[CFLAGS             = "#{@cflags}"\n]
    result << %[CPPFLAGS           = "#{@cppflags}"\n]
    result << %[LDFLAGS            = "#{@ldflags}"\n]
    result << %[CC                 = "#{@cc}"\n]
    result << %[CPP                = "#{@cpp}"\n]
    result << %[AR                 = "#{@ar}"\n]
    result << %[RANLIB             = "#{@ranlib}"\n]
    result << %[STRIP              = "#{@strip}"\n]
    result << %[LD                 = "#{@ld}"\n]
    result << %[OBJCOPY            = "#{@objcopy}"\n]
    result << %[OBJDUMP            = "#{@objdump}"\n]
    result << %[ANDROID_NDK_PREFIX = "#{@android_ndk_prefix}"\n]
    result << %[BUILD_PREFIX       = "#{@build_prefix}"\n]
    result << %[TALLOC_PREFIX      = "#{@talloc_prefix}"\n]
    result << %[ANS_TXT            = "#{@ans_txt}"\n]
    result << %[MAKER_OPT          = "#{@make_opt}"\n]
    return result
  end
end

class BuildPRootTermux
  include ShellExec

  private

  def make_ndk_toolchain
    unless (@build.build_prefix/"toolchain-#{@build.android_ndk_arch}").directory? then
      args =  ["#{@build.android_ndk_prefix}/build/tools/make_standalone_toolchain.py"]
      args << "--arch #{@build.android_ndk_arch}" << "--api #{::ANDROID_NDK_API}"
      args << "--force" << "--verbose"
      args << "--install-dir #{@build.build_prefix}/toolchain-#{@build.android_ndk_arch}"
      shell(*args)
    end
  end

  def build_talloc
    if (Pathname.pwd/"talloc-#{::TALLOC_VERSION}.tar.gz").file? then
      puts "[EXISTS]: File #{Pathname.pwd}/talloc-#{::TALLOC_VERSION}.tar.gz"
    else
      shell("#{@build.wget}", "-O", "#{Pathname.pwd}/talloc-#{::TALLOC_VERSION}.tar.gz", ::TALLOC_URL)
    end

    if (Pathname.pwd/"talloc-#{::TALLOC_VERSION}").directory? then
      puts "[EXISTS]: Directory #{Pathname.pwd}/talloc-#{::TALLOC_VERSION}"
    else
      shell("#{@build.tar}", "-zxvf", "#{Pathname.pwd}/talloc-#{::TALLOC_VERSION}.tar.gz")
    end

    (Pathname.pwd/"talloc-#{::TALLOC_VERSION}").chdir do
      args =  ["#{@build.env}"]
      args << %[CC="#{@build.cc}"] << %[CPP="#{@build.cpp}"] << %[AR="#{@build.ar}"]
      args << %[RANLIB="#{@build.ranlib}"] << %[STRIP="#{@build.strip}"]
      args << %[LD="#{@build.ld}"] << %[OBJCOPY="#{@build.objcopy}"]
      args << %[CFLAGS="#{@build.cflags}"] << %[CPPFLAGS="#{@build.cppflags}"] << %[LDFLAGS="#{@build.ldflags}"]

      args << "./configure" << "install" << "#{@make_opt}"
      args << "--prefix=#{@build.talloc_prefix}" << "--cross-compile" << "--cross-answers=#{@build.ans_txt}"
      args << "--disable-python" << "--without-gettext" << "--disable-rpath"

      shell(*args)
    end

    (Pathname.pwd/"talloc-#{::TALLOC_VERSION}/bin/default").chdir do
      shell("#{@build.ar}", "rsuv", "./libtalloc.a", "./talloc_5.o", "./lib/replace/replace_2.o", "./lib/replace/cwrap_2.o", "./lib/replace/closefrom_2.o")
    end

    shell("#{@build.install}", "-v", "-m", "0644", "#{Pathname.pwd}/talloc-#{::TALLOC_VERSION}/bin/default/libtalloc.a", "#{@build.talloc_prefix}/lib")
  end

  def build_termux_proot
    if (Pathname.pwd/"proot-#{::PROOT_VERSION}.zip").file? then
      puts "[EXISTS]: File #{Pathname.pwd}/proot-#{::PROOT_VERSION}.zip"
    else
      shell("#{@build.wget}", "-O", "#{Pathname.pwd}/proot-#{::PROOT_VERSION}.zip", ::PROOT_URL)
    end

    if (Pathname.pwd/"proot-#{::PROOT_VERSION}").directory? then
      puts "[EXISTS]: Directory #{Pathname.pwd}/proot-#{::PROOT_VERSION}"
    else
      shell("#{@build.unzip}", "#{Pathname.pwd}/proot-#{::PROOT_VERSION}.zip")
    end
    (Pathname.pwd/"proot-#{::PROOT_VERSION}/src").chdir do
      args =  ["#{@build.env}", "LC_ALL=C", "#{@build.make}", "#{@build.make_opt}", "-f", "./GNUmakefile"]
      args << %[LOADER_ARCH_CFLAGS="#{@build.cflags}"] << %[CC="#{@build.cc}"] << %[LD="#{@build.cc}"]
      args << %[STRIP="#{@build.strip}"] << %[OBJCOPY="#{@build.objcopy}"] << %[OBJDUMP="#{@build.objdump}"]
      args << %[CPPFLAGS="-D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE -I. #{@build.cppflags}"]
      args << %[CFLAGS="-Wall -Wextra #{@build.cflags}"]
      args << %[LDFLAGS="#{@build.ldflags} -static -ltalloc -Wl,-z,noexecstack"] << "V=1"

      shell(*args)
      shell("#{@build.strip}", "./proot")
    end

    if @build.android_ndk_arch.nil? then
      (Pathname.pwd/"cross-compile").mkpath
      shell("#{@build.install}", "-v", "-m", "0755", "#{Pathname.pwd}/proot-#{::PROOT_VERSION}/src/proot", "#{Pathname.pwd}/cross-compile/proot.#{@build.arch}")
      shell("#{@build.install}", "-v", "-m", "0755", "#{Pathname.pwd}/proot-#{::PROOT_VERSION}/src/proot", "#{Pathname.pwd}/cross-compile/proot-cross.#{@build.arch}")
    else
      (Pathname.pwd/"android-ndk").mkpath
      shell("#{@build.install}", "-v", "-m", "0755", "#{Pathname.pwd}/proot-#{::PROOT_VERSION}/src/proot", "#{Pathname.pwd}/proot.#{@build.arch}")
      shell("#{@build.install}", "-v", "-m", "0755", "#{Pathname.pwd}/proot-#{::PROOT_VERSION}/src/proot", "#{Pathname.pwd}/android-ndk/proot.#{@build.arch}")
    end
  end

  def clean
    puts "[Remove]: Directory #{Pathname.pwd}/talloc-#{::TALLOC_VERSION}"
    (Pathname.pwd/"talloc-#{::TALLOC_VERSION}").rm_rf

    puts "[Remove]: Directory #{Pathname.pwd}/proot-#{::PROOT_VERSION}"
    (Pathname.pwd/"proot-#{::PROOT_VERSION}").rm_rf

    puts "[Remove]: Directory #{@build.talloc_prefix}"
    @build.talloc_prefix.rm_rf
  end

  def distclean
    clean

    puts "[Remove]: File #{Pathname.pwd}/talloc-#{::TALLOC_VERSION}.tar.gz"
    if (Pathname.pwd/"talloc-#{::TALLOC_VERSION}.tar.gz").file? then
      (Pathname.pwd/"talloc-#{::TALLOC_VERSION}.tar.gz").delete
    end

    puts "[Remove]: File #{Pathname.pwd}/proot-#{::PROOT_VERSION}.zip"
    if (Pathname.pwd/"proot-#{::PROOT_VERSION}.zip").file? then
      (Pathname.pwd/"proot-#{::PROOT_VERSION}.zip").delete
    end

    ["arm", "arm64", "x86", "x86_64"].each do |arch|
      puts "[Remove]: Doirectory #{@build.build_prefix}/toolchain-#{arch}"
      (@build.build_prefix/"toolchain-#{arch}").rm_rf
    end
  end

  public

  def run(argv)
    arch = "arm"; android_ndk_prefix = cross_compile_prefix = nil
    clean_flag = distclean_flag = false

    OptionParser.new do |opt|
      opt.on("--arch ARCH")                 {|val| arch = val}
      opt.on("--android-ndk-prefix PATH")   {|val| android_ndk_prefix = val}
      opt.on("--cross-compile-prefix PATH") {|val| cross_compile_prefix = val}
      opt.on("--clean")                     { clean_flag = true }
      opt.on("--distclean")                 { distclean_flag = true }
      opt.parse!(argv)
    end

    @build = BuildEnvironment.new(arch, android_ndk_prefix, cross_compile_prefix)

    if distclean_flag then
      distclean
    elsif clean_flag then
      clean
    else
      clean
      make_ndk_toolchain unless @build.android_ndk_arch.nil?
      build_talloc
      build_termux_proot
    end
  end

  def self.run(argv)
    self.new.run(argv)
  end
end

BuildPRootTermux.run(ARGV)
