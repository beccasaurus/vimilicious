#
# mock of the VIM class so our specs pass
#
class VIM
  class << self
    %w( cmd command ).each do |valid_method_name|
      define_method(valid_method_name){|*args| }
    end
  end
end

require File.dirname(__FILE__) + '/../lib/vimilicious'
