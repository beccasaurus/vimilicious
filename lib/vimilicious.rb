# common methods for vim-ruby scripts

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
