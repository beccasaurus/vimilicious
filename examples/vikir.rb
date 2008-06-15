# vikir.rb
#
# VI Wiki In Ruby

# Usage:          (assumes <Leader> is /, and all else is default)
#
#        \v h     goto HomePage
#        \v i     goto Index of all Wiki Pages
#        \v r     refresh highlighting (or apply to any file to see valid wiki pages)
#        \v f     follow word under cursor (regardless of whether or not it exists)
#        \v o     open word under cursor (same as follow but will open in window 2, if available)
#        \v s     follow in split (horizontal)
#        \v v     follow in split (vertical)
#        \v e     open explorer (vertical split with index on left)
#        \v m     render as markdown and preview in browser (requires 'markdown' in path to do the work)
#
# Highlights:
#
#        SIMPLE
#
#        \v r applies highlighting on *top* of any currently displayed highlighting
#

require 'rubygems'
require 'vimilicious'

## -- CONSTANTS -- ##
WIKI_DIR = '~/wiki'.gsub '~', ENV['HOME']
HOME_PAGE = 'HomePage'
COMMAND_PREFIX = '<Leader>v'
HIGHLIGHT_AS = 'Identifier'
DEFAULT_FILETYPE = 'mkd'

## -- HELPER METHODS -- ##
def page name
   File.join WIKI_DIR, name
end
def in_wiki? location=current_file
  location.include?WIKI_DIR if location
end
def pages
  Dir[File.join(WIKI_DIR,'*')]
end
  
## -- ACTION METHODS -- ##
def goto place
  cmd "cd #{WIKI_DIR}"
  cmd "e #{page place}"
  highlight unless File.directory?page(place)
end
def index
  goto ''
end
def home
  goto HOME_PAGE
end
def follow place=current_word
  goto place
end
def follow_in_split place=current_word, open_below=true
  cmd 'sp'
  exec '<C-w>' + (open_below ? 'j' : 'k')
  follow place
end
def follow_in_vsplit place=current_word, open_right_of=true
  cmd 'vsp'
  exec '<C-w>' + (open_right_of ? 'l' : 'h')
  follow place
end
def explorer
  follow_in_vsplit '', false
  exec '40<C-w><'
end
def open place=current_word
  exec '<C-w>l' if VIM::Window.count > 1 # assume window is on right (for now)
  follow place
  exec '<C-w>h^' # more back to left (feels right)
end
def highlight
  if File.directory?current_file # assume this is the wiki dir and simple reload it
    goto ''; return
  end
  cmd "set ft=#{DEFAULT_FILETYPE}" unless DEFAULT_FILETYPE.empty?
  pages.each do |file|
    cmd "syntax match VikirPage '#{File.basename file}'"
  end
end
def markdown
  Thread.new { `markdown '#{current_file}'` }
end

## -- COMMAND MAPPING -- ##
commands = { 
  :h => :home,
  :i => :index,
  :r => :highlight,
  :f => :follow,
  :s => :follow_in_split,
  :v => :follow_in_vsplit,
  :e => :explorer,
  :o => :open,
  :m => :markdown
}
commands.each do |command, method|
  cmd %{ map #{COMMAND_PREFIX}#{command} :ruby #{method}<CR>  }
end

## -- SYNTAX HIGHLIGHTING -- ##
cmd "hi def link VikirPage #{HIGHLIGHT_AS}"
highlight if in_wiki?
