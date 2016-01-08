require "irb/completion"
begin
  require "awesome_print"
  AwesomePrint.pry!
rescue LoadError
  puts "not found awesome_print."
end

Pry.config.editor = "vim"
Pry.config.history.file = "~/.irb_history"

# alias
Pry.config.commands.alias_command "n", "next"
Pry.config.commands.alias_command "c", "continue"
