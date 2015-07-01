require "irb/completion"
require "irb/ext/save-history"
begin
  require "awesome_print"
  AwesomePrint.irb!
rescue
  puts "not found awesome_print."
end

IRB.conf[:SAVE_HISTORY] = 100000
IRB.conf[:AUTO_INDENT]  = true
IRB.conf[:USE_READLINE] = true
IRB.conf[:HISTORY_PATH] = File::expand_path("~/.irb_history")

