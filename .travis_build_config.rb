MRuby::Build.new do |conf|
  toolchain :gcc
  conf.gembox 'default'

  conf.gem File.expand_path(File.dirname(__FILE__)) do |g|
    g.download_scintilla
  end
  conf.enable_test
  conf.linker do |linker|
    linker.libraries << "stdc++"
  end
end
