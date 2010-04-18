module MCollective
    module Agent
        class Smith < RPC::Agent
            def report_action
                reply[:libdir] = @config.libdir
                reply[:agents] = Agents.agentlist
            end
                      
            def updateagent_action
                validate :name, String
                validate :source, String
                validate :method, String
                # todo : use some authorization mechs here
                # see http://www.devco.net/archives/2010/04/11
                
                update_methods = [ "http", "file"]
                
                if !update_methods.include? request[:method] then
                    reply.fail ":method must be one of " + update_methods.join(", ")
                else
                    destination = @config.libdir+"/mcollective/agent/"+request[:name]+".rb"
                    reply[:destination] = destination
                    
                    case request[:method]
                        when "http":
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
                        end # end of when
                end
            end # end of updateagent_action method
            
        end
    end # end of module
end
