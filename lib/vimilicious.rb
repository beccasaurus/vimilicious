# common methods for vim-ruby scripts
module Vimilicious

  # run vim command
  #
  #   :ruby puts cmd("echo 'hello!'")
  def cmd vim_ex_command
    VIM::command vim_ex_command
  end

  # evaluate vim expression
  #
  #   :ruby puts 'x = ' + vim_eval('x')
  def vim_eval vim_expression
    VIM::evaluate vim_expression
  end

  # execute 'normal' command
  #
  #   :ruby exec '<ESC>ihello there!<ESC>'
  def exec normal_vim_command
    cmd %[exec "normal #{normal_vim_command}"].gsub('<','\<')
  end

  # alias 'puts' to vim 'print' method
  #
  #   :ruby puts 'hello!'
  def puts message
    print message
  end

  # check to see if a vim variable is defined
  #
  #   :ruby puts 'x is defined? ' + vim_defined?'x'
  def vim_defined? var 
    vim_eval("exists('#{var}')") == '1' 
  end

  # get the value of a vim variable (else nil)
  #
  #   :ruby x = vim_var('x'); puts "x = #{x}"
  def vim_var var 
    vim_eval(var) if vim_defined?var
  end

  # get the current buffer
  #
  #   :ruby puts "the current line says: #{current_buffer.line}"
  def current_buffer
    VIM::Buffer.current # $curbuf
  end

  # get the current window
  #
  #   :ruby puts "the cursor is at: #{current_window.cursor.inspect}"
  def current_window
    VIM::Window.current # $curwin
  end

  # get the name of the current file
  #
  #   :ruby puts "currently editing: #{current_file}"
  def current_file
    current_buffer.name
  end

  # get the current cursor location (as array [line_number,position])
  #
  #   :ruby puts "the cursor is at: #{cursor.inspect}"
  def cursor
    current_window.cursor
  end

  # get the text of the currently selected line
  #
  #   :ruby puts "the current line says: #{current_line}"
  def current_line
    current_buffer.line
  end

  # set the text of the currently selected line
  #
  # we're not using the more conventional current_line= because
  # that simply creates a local variable named current_line
  #
  #   :ruby set_current_line 'hi there'
  def set_current_line text
    current_buffer[ current_buffer.line_number ] = text.to_s
  end

  # deletes the current buffer (closes the file) but keeps the current layout
  #
  #   :ruby clear
  def clear
    cmd 'let kwbd_bn= bufnr("%")|enew|exe "bdel ".kwbd_bn|unlet kwbd_bn'
    clear_buffer
  end

  # forcefully deletes the current buffer and clears the wholelayout
  #
  #   :ruby clear!
  def clear!
    cmd 'bd!'
    clear_buffer
  end

  # deletes all lines in the current_buffer
  def clear_buffer
    exec 'gg'
    current_buffer.length.times { current_buffer.delete(1) }
  end

  # append text to the end of the current_buffer
  #
  #   :ruby append 'hello there'
  def append text
    current_buffer.append current_buffer.length, text
  end

  # prompts user for input
  #
  #   :ruby prompt('username')
  def prompt name = 'input', format = lambda { |name| "#{name}: " }
    input = vim_eval("inputdialog('#{ format.call(name) }')")
    puts '' # clear statusline thinger
    input
  end

  # ruby method for mapping keyboard shortcuts to something
  #
  # this is a ruby wrapper around vim's map functions
  #
  # ==== VIM Modes
  #
  # map::  Normal, Visual, Operator-pending 
  # map!:: Insert, Command-line 
  # nmap:: Normal 
  # vmap:: Visual 
  # omap:: Operator-pending 
  # cmap:: Command-line 
  # imap:: Insert 
  # lmap:: Insert, Command-line, Lang-Arg 
  #
  # references:
  # - http://www.vim.org/htmldoc/map.html
  # - http://howto.wikia.com/wiki/Howto_map_keys_in_vim
  #
  # === Usage
  #
  #   map :normal, '<C-v>', do
  #     # some code that will run whenever
  #     # Control-V is pressed in Normal mode
  #   end
  #
  #   map '<F5>', ":echo 'hello from F5'<Enter>"
  #
  # ==== Parameters
  # modes::
  #   optional. either a single mode, eg. :normal or an Array of 
  #   multiple modes, eg. %w( visual command ). default: 'normal'
  #
  #   valid mode names: normal, visual, insert, command, operator, lang
  #
  # shortcut::
  #   a shortcut just like VIM normally understands, eg. <C-v>
  #
  # vim_command::
  #   optional.  this is a string command that we'll map 
  #   this shortcut to.  if this is passed, the &block 
  #   parameter is ignored and vim_command is run instead!
  #   you can still run ruby with this parameter by 
  #   passing something like '<Esc>:ruby puts 'hi'<Enter>' 
  #
  # &block::
  #   a block of code to run whenever the code is pressed
  #
  # TODO allow #map('<C-r>'){ ... } and use default mode
  # TODO allow #map('<C-r>', 'vim command')
  #
  def map modes, shortcut = nil, vim_command = nil, &block
    
    # first argument isn't a mode, it's a shortcut!
    unless modes.is_a?(Symbol) or modes.is_a?(Array)
      vim_command = shortcut
      shortcut    = modes
      modes       = :normal # default
    end

    modes_to_use = map_commands_for *modes
    raise "Don't know how to map #{ modes.inspect }" if modes_to_use.empty?

    if vim_command
      modes_to_use.each do |mode|
        cmd "#{ mode } #{ shortcut } #{ vim_command }"
      end

    elsif block
      unique_key = "#{ shortcut.inspect } #{ modes.inspect } #{ Time.now }"
      @mapped_blocks ||= { }
      @mapped_blocks[unique_key] = block
      modes_to_use.each do |mode|
        cmd "#{ mode } #{ shortcut } :ruby @mapped_blocks[%{#{ unique_key }}].call<Enter>"
      end

    else
      raise "Not sure what you want to map to ... no vim_command or block passed."
    end 
  end

  # returns the map command(s) you should use if you want 
  # to map with the mode(s) given
  #
  # see spec/mapping_spec.rb
  #
  #   >> map_commands_for(:normal)
  #   => :nmap
  #
  def map_commands_for *modes
    @mapmodes ||= {
      :map  => [ :normal, :visual, :operator ],
      :map! => [ :insert, :command ],
      :nmap => [ :normal ],
      :vmap => [ :visual ], 
      :omap => [ :operator ], 
      :cmap => [ :command ], 
      :imap => [ :insert ], 
      :lmap => [ :insert, :command, :lang ]
    }

    # symbolize
    modes = modes.map {|mode| mode.to_s.downcase.to_sym }
    
    # first, see if there's a mode that has the modes we want and nothing more
    mode_that_has_everything_we_want_and_nothing_else = @mapmodes.find do |mode_command, available_modes|
      match = true
      match = false unless available_modes.length == modes.length
      modes.each {|mode| match = false unless available_modes.include?(mode) }
      match
    end

    return [ mode_that_has_everything_we_want_and_nothing_else[0] ] if mode_that_has_everything_we_want_and_nothing_else

    # see if the modes we're looking for have a 1 <=> 1 mapping with available modes
    one_to_one_mapping_modes = modes.map do |mode|
      @mapmodes.find do |mode_command, available_modes|
        available_modes == [mode]
      end
    end

    return one_to_one_mapping_modes.map {|mode_command, available_modes| 
      mode_command
    } unless one_to_one_mapping_modes.include? nil

    # hmm, regardless of whether it'll have more than we want, see if we can find a mode 
    # that has all of the modes we're looking for
    modes_that_have_everything_we_want_and_some_more = @mapmodes.select do |mode_command, available_modes|
      match = true
      modes.each {|mode| match = false unless available_modes.include?(mode) }
      match
    end

    if modes_that_have_everything_we_want_and_some_more.length == 1
      return [ modes_that_have_everything_we_want_and_some_more[0][0] ]
    else
      [] # couldn't find anything  :/
    end

  end

  # create a vim user command that calls a ruby method or block
  #
  #   :ruby create_command :test                # creates a :Test command that calls a 'test' method
  #   :ruby create_command 'test', :hi          # creates a :Test command that calls a 'hi' method
  #   :ruby create_command(:test){ puts 'hi' }  # creates a :Test command that calls the block passed in
  #
  #   :ruby create_command(:foo){|*args| puts "called foo with args: #{ args.inspect }" }
  #
  #   :Foo 'hello', 'there', 1, 2, 3
  #   called foo with args: ["hi", "there", 1, 2, 3]
  #
  # ==== Notes
  #
  # the name of the command will be capitalized, so :test is callable as :Test
  #
  def create_command name, method = nil, &block
    command_name  = name.to_s.capitalize
    method_name   = (method.nil?) ? name.to_s : method.to_s
    function_name = command_name + 'AutoGeneratedFunction'
    
    # create a function that calls method (or block)
    if block.nil?
      cmd %[fu! #{ function_name }(...)\n  ruby #{ method_name } *eval("\#{ vim_eval('string(a:000)') }")\nendfu]
    else
      generated_method = command_name + '_auto_generated_method'
      Kernel.module_eval { define_method generated_method, block }
      cmd %[fu! #{ function_name }(...)\n  ruby #{ generated_method } *eval("\#{ vim_eval('string(a:000)') }")\nendfu]
    end

    # create a vim command that calls the vim function
    cmd %{command! -nargs=* #{ command_name } call #{ function_name }(<args>)}
  end

  # get the word under the cursor
  #
  #   :ruby puts "the cursor is on top of the word: #{current_word}"
  def current_word filter=/[,'`\.:\(\)\[\]\}\{]/, replace_with=''
    line, index = current_line, cursor[1]
    word_start, word_end = line.rindex(' ',index) || 0, line.index(' ',index)
    word_start += 1 if word_start > 0 
    word_end = line.length if word_end.nil?
    word = line[word_start, word_end-word_start] || ''
    word.gsub!(filter,replace_with) unless word.empty?
    word
  end

end

include Vimilicious

### COMMANDS ###

create_command('InspectArgs'){ |*args| puts "passed: #{args.inspect}" }
