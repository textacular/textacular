source 'https://rubygems.org'

gemspec

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

github 'rails/rails', branch: 'main' do
  gem 'activerecord'
end

gem "pg", "~> 1.1"
