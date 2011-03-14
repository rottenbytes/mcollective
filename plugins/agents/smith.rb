module MCollective
    module Agent
        class Smith < RPC::Agent
            action "report" do
                reply[:libdir] = @config.libdir
                reply[:agents] = Agents.agentlist
            end
                      
            action "updateagent" do
                validate :name, String
                validate :source, String
                validate :method, String
                validate :reload, /(true|false)/
                
                update_methods = [ "http", "file"]
                                
                if !update_methods.include? request[:method] then
                    reply.fail ":method must be one of " + update_methods.join(", ")
                else
                    destination = @config.libdir.to_s+"/mcollective/agent/"+request[:name]+".rb"
                    reply[:destination] = destination
                end
                    
                case request[:method]
                  when "http":
                      require "rubygems"
                      require 'open-uri'
                      # Get the file from http (request[:source]) to its destination
                      fp=open(destination,"w")

                      fp.write(open(request[:source]).read)
                      fp.close

                      # is there a way to control this ??
                      reply[:result] = true
                      
                  when "file":
                      require 'ftools'
                      # copy the file from request[:source] to the right place
                      begin File.syscopy(request[:source],destination)
                          reply[:result] = true
                      rescue
                          reply.fail "could not copy file while updating !"
                      end
                end # end of case
   
            if request[:reload] == "true" then
              Log.instance.debug("Reload requested after update of an agent (#{request[:name]})")
              ::Process.kill("USR1", $$)
            end
          end # end of updateagent action/method
            
          action "deleteagent" do
            validate :name, String
            validate :reload, /(true|false)/
            
            agentfile = @config.libdir.to_s+"/mcollective/agent/"+request[:name]+".rb"
            
            if File.exists?(agentfile) then
              # delete the file
              File.delete(agentfile)
            end
            
            if request[:reload] == "true" then
              Log.instance.debug("Reload requested after deletion of an agent (#{request[:name]})")
              ::Process.kill("USR1", $$)
            end
          end # end of deleteagent action/methodd
            
        end # end of class/class/module
    end 
end
