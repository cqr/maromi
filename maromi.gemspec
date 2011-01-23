# -*- encoding: utf-8 -*-
require File.expand_path("../lib/maromi/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "maromi"
  s.version     = Maromi::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = []
  s.email       = []
  s.homepage    = "http://rubygems.org/gems/maromi"
  s.summary     = "TODO: Write a gem summary"
  s.description = "TODO: Write a gem description"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "maromi"
  
  %w{dm-core dm-migrations dm-validations oauth}.each do |rubygem|
    s.add_dependency rubygem
  end

  s.add_development_dependency "bundler", ">= 1.0.0"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
