module Solylace
end

Dir[ File.join( File.dirname(__FILE__), 'solylace', '*.rb' ) ].each do |file|
  require file
end
