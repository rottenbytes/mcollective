require 'mcollective'
include MCollective::RPC

mc = rpcclient("chefresource")
mc.progress = false

r = [ { "action" => "restart" }, { "supports" => {:status => true } } ]

mc.handle(:resourcename => "cron", :resourcetype => "service", :resourceactions => r).each do |resp|
  puts resp[:sender] + " => " + resp[:status].inspect
end
