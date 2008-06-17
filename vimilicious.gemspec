Gem::Specification.new do |s|
  s.name = "vimilicious"
  s.version = "0.1.2"
  s.date = "2008-06-15"
  s.summary = "vim-ruby library for making vim easy"
  s.email = "remi@remitaylor.com"
  s.homepage = "http://github.com/remi/vimilicious"
  s.description = "vim-ruby library making it easier to work with vim via ruby"
  s.has_rdoc = true
  s.rdoc_options = ["--quiet", "--title", "domain-finder", "--opname", "index.html", "--line-numbers", "--main", "README", "--inline-source"]
  s.extra_rdoc_files = ['README']
  s.authors = ["remi Taylor"]

  # generate using: $ ruby -e "puts Dir['**/**'].select{|x| File.file?x}.inspect"
  s.files = ["COPYING", "lib/vimilicious.rb", "vimilicious.gemspec", "README", "examples/vikir.vim", "examples/vikir.rb"]

end
