require "rubygems"
require "ap"
require "irb/completion"

IRB.conf[:SAVE_HISTORY] = 100000
IRB.conf[:AUTO_INDENT]  = true
IRB.conf[:HISTORY_PATH] = File::expand_path("~/.irb_history")

unless IRB.version.include?('DietRB')
  IRB::Irb.class_eval do
    def output_value
      ap @context.last_value
    end
  end
else # MacRuby
  IRB.formatter = Class.new(IRB::Formatter) do
    def inspect_object(object)
      object.ai
    end
  end.new
end
