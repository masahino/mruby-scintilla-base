MRuby::Gem::Specification.new('mruby-scintilla-base') do |spec|
  spec.license = 'MIT'
  spec.authors = 'masahino'

  def spec.download_scintilla
    require 'open-uri'
    scintilla_url = "https://downloads.sourceforge.net/scintilla/scintilla380.tgz"
    scintilla_build_root = "#{build_dir}/scintilla/"
    scintilla_dir = "#{scintilla_build_root}/scintilla380"
    scintilla_h = "#{scintilla_dir}/include/Scintilla.h"

    unless File.exists?(scintilla_h)
      open(scintilla_url, "r") do |http|
        scintilla_tar = http.read
        FileUtils.mkdir_p scintilla_build_root
        IO.popen("tar xfz - -C #{filename scintilla_build_root}", "w") do |f|
          f.write scintilla_tar
        end
      end
    end
    [self.cc, self.cxx, self.objc, self.mruby.cc, self.mruby.cxx, self.mruby.objc].each do |cc|
      cc.include_paths << scintilla_dir+"/include"
    end
  end
end
