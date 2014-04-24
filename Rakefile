require "bundler/setup"
require "bundler/gem_tasks"

if !ENV["APPRAISAL_INITIALIZED"] && !ENV["TRAVIS"]
  require "appraisal/task"
  Appraisal::Task.new
  task default: :appraisal
else
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new
  task default: :spec
end
