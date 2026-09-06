MRuby::Gem::Specification.new('mruby-scintilla-base') do |spec|
  spec.license = 'MIT'
  spec.authors = 'masahino'
  spec.version = '5.6.6'
  spec.add_dependency 'mruby-string-ext'
  spec.add_dependency 'mruby-metaprog'
  spec.add_test_dependency 'mruby-kernel-ext'

  def spec.download_scintilla
    return if @scintilla_download_configured

    @scintilla_download_configured = true
    require 'open-uri'
    require 'openssl'
    scintilla_ver = '566'
    lexilla_ver = '553'
    scintilla_url = "https://scintilla.org/scintilla#{scintilla_ver}.tgz"
    lexilla_url = "https://scintilla.org/lexilla#{lexilla_ver}.tgz"
    scintilla_build_root = "#{build_dir}/scintilla/"
    scintilla_dir = "#{scintilla_build_root}/scintilla"
    lexilla_dir = "#{scintilla_build_root}/lexilla"
    scintilla_h = "#{scintilla_dir}/include/Scintilla.h"
    lexilla_h = "#{lexilla_dir}/include/Lexilla.h"
    lexilla_a = "#{lexilla_dir}/bin/liblexilla.a"

    file scintilla_h do
      URI.open(scintilla_url, open_timeout: 10, read_timeout: 30) do |http|
        scintilla_tar = http.read
        FileUtils.mkdir_p scintilla_build_root
        IO.popen("tar xfz - -C #{filename scintilla_build_root}", 'wb') do |f|
          f.write scintilla_tar
        end
        raise "tar failed: #{scintilla_url} (#{$?.exitstatus})" unless $?.success?
      end
      raise "#{scintilla_h} not produced" unless File.exist?(scintilla_h)
    end

    file lexilla_h do
      URI.open(lexilla_url, open_timeout: 10, read_timeout: 30) do |http|
        lexilla_tar = http.read
        FileUtils.mkdir_p scintilla_build_root
        IO.popen("tar xfz - -C #{filename scintilla_build_root}", 'wb') do |f|
          f.write lexilla_tar
        end
        raise "tar failed: #{lexilla_url} (#{$?.exitstatus})" unless $?.success?
      end
      raise "#{lexilla_h} not produced" unless File.exist?(lexilla_h)
    end

    file lexilla_a => lexilla_h do
      cxxflags = ''
      if RUBY_PLATFORM.downcase.include?('cygwin')
        cxxflags = '--std=gnu++17'
      end
      sh %{(cd #{lexilla_dir}/src && make CXX=#{build.cxx.command} AR=#{build.archiver.command} CXXFLAGS=#{cxxflags})}
    end

    [cc, cxx, objc, mruby.cc, mruby.cxx, mruby.objc].each do |compiler|
      compiler.include_paths << "#{scintilla_dir}/include"
      compiler.include_paths << "#{lexilla_dir}/include"
    end

    task :mruby_scintilla_base_compile_option do
      linker.flags_before_libraries << lexilla_a
      linker.libraries << 'stdc++'
    end

    file "#{dir}/src/scintilla-base.c" => [:mruby_scintilla_base_compile_option, scintilla_h, lexilla_h, lexilla_a]
    file "#{dir}/src/sci_lexer.c" => [:mruby_scintilla_base_compile_option, lexilla_h]
  end

  # Path of the lexilla static archive produced by download_scintilla.
  # Other scintilla-* gems that need to link lexilla should ask here rather
  # than hard-coding this gem's build layout.
  def spec.lexilla_archive
    "#{build_dir}/scintilla/lexilla/bin/liblexilla.a"
  end

  spec.download_scintilla
end
