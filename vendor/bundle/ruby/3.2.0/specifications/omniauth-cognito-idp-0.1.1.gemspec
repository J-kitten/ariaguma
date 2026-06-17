# -*- encoding: utf-8 -*-
# stub: omniauth-cognito-idp 0.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "omniauth-cognito-idp".freeze
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Sage Business Cloud Accounting API Team".freeze]
  s.date = "2020-03-26"
  s.description = "Use the Amazon Cognito IdP with OmniAuth".freeze
  s.email = "sageoneapi@sage.com".freeze
  s.homepage = "http://github.com/Sage/omniauth-cognito-idp".freeze
  s.rubygems_version = "3.4.10".freeze
  s.summary = "OmniAuth Strategy for Amazon Cognito".freeze

  s.installed_by_version = "3.4.10" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<jwt>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<omniauth-oauth2>.freeze, [">= 0"])
  s.add_development_dependency(%q<aws-sdk-cognitoidentityprovider>.freeze, [">= 0"])
  s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
  s.add_development_dependency(%q<pry>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
  s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
  s.add_development_dependency(%q<sinatra>.freeze, [">= 0"])
end
