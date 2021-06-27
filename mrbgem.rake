MRuby::Gem::Specification.new('mruby-scintilla-base') do |spec|
  spec.license = 'MIT'
  spec.authors = 'masahino'
  spec.version = '5.1.0'

  def spec.download_scintilla
    require 'open-uri'
    require 'openssl'
    scintilla_ver = "510"
    scintilla_url = "https://scintilla.org/scintilla#{scintilla_ver}.tgz"
    lexilla_url = "https://scintilla.org/lexilla#{scintilla_ver}.tgz"
    scintilla_build_root = "#{build_dir}/scintilla/"
    scintilla_dir = "#{scintilla_build_root}/scintilla"
    lexilla_dir = "#{scintilla_build_root}/lexilla"
    scintilla_h = "#{scintilla_dir}/include/Scintilla.h"
    lexilla_h = "#{lexilla_dir}/include/Lexilla.h"

    unless File.exists?(scintilla_h)
      URI.open(scintilla_url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
        scintilla_tar = http.read
        FileUtils.mkdir_p scintilla_build_root
        IO.popen("tar xfz - -C #{filename scintilla_build_root}", "wb") do |f|
          f.write scintilla_tar
        end
      end
    end
    unless File.exists?(lexilla_h)
      URI.open(lexilla_url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
        lexilla_tar = http.read
        IO.popen("tar xfz - -C #{filename scintilla_build_root}", "wb") do |f|
          f.write lexilla_tar
        end
      end
    end

    [self.cc, self.cxx, self.objc, self.mruby.cc, self.mruby.cxx, self.mruby.objc].each do |cc|
      cc.include_paths << scintilla_dir+"/include"
      cc.include_paths << lexilla_dir+"/include"
    end
  end
end
