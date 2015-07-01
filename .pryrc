require "irb/completion"
begin
  require "awesome_print"
  AwesomePrint.pry!
rescue
  puts "not found awesome_print."
end

Pry.config.editor = "vim"
Pry.config.history.file = "~/.irb_history"
