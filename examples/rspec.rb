# \r  will run the current 'it' block that you are inside of
# \R  will run the entire spec file that you have open

def previous_it_block
  it_block_line = nil
  (1..line_number).to_a.reverse.each do |line_number|
    if line_text(line_number) =~ /^\s*(it|describe) /
      it_block_line = line_number
      break
    end
  end
  it_block_line
end

def run_whole_spec
  cmd "! clear && spec -c -f specdoc #{ current_file }"
end

def run_current_it_block
  if previous_it_block
    cmd "! clear && spec -c -f specdoc -l #{ previous_it_block } #{ current_file }"
  else
    run_whole_spec
  end
end

map('\r'){ run_current_it_block }
map('\R'){ run_whole_spec }
