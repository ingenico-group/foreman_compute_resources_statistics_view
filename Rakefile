# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'
require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "foreman_compute_resources_statistics_view"
  gem.homepage = "https://github.com/ingenico-group/foreman_compute_resources_statistics_view"
  gem.license = "MIT"
  gem.summary = %Q{Compute Resources Statistics View Plugin for Foreman }
  gem.description = %Q{Displays Statistics column in the Foreman Compute Resources list and show page}
  gem.email = "nagarjuna.r@indecomm.net"
  gem.authors = ["Nagarjuna Rachaneni"]
  # dependencies defined in Gemfile
end

task :default => :test
