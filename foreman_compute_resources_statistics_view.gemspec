$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "foreman_compute_resources_statistics_view/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.name = %q{foreman_compute_resources_statistics_view}
  s.version     = ForemanComputeResourcesStatisticsView::VERSION
  s.authors = ["Nagarjuna Rachaneni"]
  s.email = "nn.nagarjuna@gmail.com"
  s.description = "Displays statistics column in the Foreman Compute Resources list and show page"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = Dir["{app,test,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]
  s.homepage = "https://github.com/ingenico-group/foreman_compute_resources_statistics_view"
  s.licenses = ["MIT"]
  s.summary = "Compute Resource Statistics View Plugin for Foreman"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.add_dependency "deface"
end

