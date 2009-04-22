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

  # create a vim user command that calls a ruby method or block
  #
  #   :ruby create_command :test                # creates a :Test command that calls a 'test' method
  #   :ruby create_command 'test', :hi          # creates a :Test command that calls a 'hi' method
  #   :ruby create_command(:test){ puts 'hi' }  # creates a :Test command that calls the block passed in
  #
  # WARNING ... as of now, the args passed to these commands get turned into one big string which 
  # is passed along to the function and method.  i haven't figured out howto fix this yet  :(
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

  ### COMMANDS ###

  create_command('InspectArgs'){ |*args| puts "passed: #{args.inspect}" }

end

include Vimilicious
