# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "hard-boiled/version"

Gem::Specification.new do |s|
  s.name        = "hard-boiled"
  s.version     = Hard::Boiled::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Lennart Melzer"]
  s.email       = ["me@lmaa.name"]
  s.homepage    = ""
  s.summary     = %q{Get your models boiled down to plain hashes!}
  s.description = %q{
    HardBoiled helps you reducing your complex models (including their associations)
    down to simple hashes usable for serialization into JSON or XML.

    It leverages a DSL similar to thoughtbot's FactoryGirl 
    to make mappings maintainable and pain-free.
  }

  s.rubyforge_project = "hard-boiled"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
