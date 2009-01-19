# Require vendor librairies
vndpath = File.join(File.dirname(__FILE__), 'vendor')
$:.unshift vndpath unless $:.member?(vndpath)
require 'metash/lib/metash'

module Solylace
end

# Require Solylace modules
slpath = File.join(File.dirname(__FILE__), 'solylace')
$:.unshift slpath unless $:.member?(slpath)

%w(binder buffer command selection configuration configuration_dsl).each do |mod|
  require mod
end
