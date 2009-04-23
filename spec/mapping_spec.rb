require File.dirname(__FILE__) + '/spec_helper'

describe Vimilicious, '#map' do

  # #map_commands_for will do whatever it can to get your 
  # mapping(s) working, even if it had to map too additional modes.
  #
  # first, it should look for one that contains all of the 
  # modes we want (*only* those modes).
  #
  # after that, it should see if it can find a way to *just* 
  # include the modes you want.
  #
  # if it can't find a way to *just* include the modes you want, 
  # it will select whichever alternative includes the least other modes.
  #
  # map::  Normal, Visual, Operator-pending 
  # map!:: Insert, Command-line 
  # nmap:: Normal 
  # vmap:: Visual 
  # omap:: Operator-pending 
  # cmap:: Command-line 
  # imap:: Insert 
  # lmap:: Insert, Command-line, Lang-Arg 
  it 'should be able to figure out which vim mapping command to use' do
    map_commands_for(:visual).should   == [:vmap]
    map_commands_for(:command).should  == [:cmap]
    map_commands_for(:lang).should     == [:lmap] # it has to, because it's the only option with lmap
    map_commands_for(:insert).should   == [:imap]
    map_commands_for(:operator).should == [:omap]
    map_commands_for(:normal).should   == [:nmap]
    
    # ok, now multiple ...
=begin
    map_commands_for(:insert, :command).should  == [:map!]
    map_commands_for(:normal, :visual).should   == [:map]

    map_commands_for(:normal, :command).length.should == 2
    map_commands_for(:normal, :command).should  include(:nmap)
    map_commands_for(:normal, :command).should  include(:cmap)

    map_commands_for(:normal, :operator).lenght.should == 2
    map_commands_for(:normal, :operator).should include(:nmap)
    map_commands_for(:normal, :operator).should include(:omap)
=end
  end

end
