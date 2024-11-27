MRuby::Gem::Specification.new('mruby-scintilla-base') do |spec|
  spec.license = 'MIT'
  spec.authors = 'masahino'
  spec.version = '5.5.3'
  spec.add_dependency 'mruby-string-ext'
  spec.add_dependency 'mruby-metaprog'
  spec.add_test_dependency 'mruby-kernel-ext'

  def spec.download_scintilla
    require 'open-uri'
    require 'openssl'
    scintilla_ver = '553'
    lexilla_ver = '541'
    scintilla_url = "https://scintilla.org/scintilla#{scintilla_ver}.tgz"
    lexilla_url = "https://scintilla.org/lexilla#{lexilla_ver}.tgz"
    scintilla_build_root = "#{build_dir}/scintilla/"
    scintilla_dir = "#{scintilla_build_root}/scintilla"
    lexilla_dir = "#{scintilla_build_root}/lexilla"
    scintilla_h = "#{scintilla_dir}/include/Scintilla.h"
    lexilla_h = "#{lexilla_dir}/include/Lexilla.h"
    lexilla_a = "#{lexilla_dir}/bin/liblexilla.a"

    file scintilla_h do
      URI.open(scintilla_url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
        scintilla_tar = http.read
        FileUtils.mkdir_p scintilla_build_root
        IO.popen("tar xfz - -C #{filename scintilla_build_root}", 'wb') do |f|
          f.write scintilla_tar
        end
      end
    end

    file lexilla_h do
      URI.open(lexilla_url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
        lexilla_tar = http.read
        FileUtils.mkdir_p scintilla_build_root
        IO.popen("tar xfz - -C #{filename scintilla_build_root}", 'wb') do |f|
          f.write lexilla_tar
        end
      end
    end

    file lexilla_a => lexilla_h do
      cxxflags = ''
      if RUBY_PLATFORM.downcase.include?('cygwin')
        cxxflags = '--std=gnu++17'
      end
      sh %{(cd #{lexilla_dir}/src && make CXX=#{build.cxx.command} AR=#{build.archiver.command} CXXFLAGS=#{cxxflags})}
    end

    task :mruby_scintilla_base_compile_option do
      [cc, cxx, objc, mruby.cc, mruby.cxx, mruby.objc].each do |cc|
        cc.include_paths << "#{scintilla_dir}/include"
        cc.include_paths << "#{lexilla_dir}/include"
      end
    end

    linker.flags_before_libraries << lexilla_a
    linker.libraries << 'stdc++'

    file "#{dir}/src/scintilla-base.c" => [:mruby_scintilla_base_compile_option, scintilla_h, lexilla_h, lexilla_a]
    file "#{dir}/src/sci_lexer.c" => [:mruby_scintilla_base_compile_option, lexilla_h]
  end

  unless spec.build.cc.search_header_path('scintilla.h') || spec.build.cc.search_header_path('lexilla.h')
    spec.download_scintilla
  end
end
