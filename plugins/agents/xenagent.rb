require 'xen'
            
module MCollective
    module Agent
        class Xenagent < RPC::Agent
            def startup_hook
                # Increase timeout because migration can be longer than the default one
                # Yes, it is quite bad
                @timeout = 30
            end
        
            # Basic echo server, kept for tests
            def echo_action
                validate :msg, String
     
                reply.data = request[:msg]
            end

	        def find_action
		        validate :name, String
		                  
		        x=Xen::XenServer.new
		        if x.has? request[:name] then
		            reply.data = "Present"
		        else
		            reply.data = "Absent"
		        end
	        end
	        
	        def list_action
	            x=Xen::XenServer.new
	            reply[:slices] = x.slices
	        end
	        
	        
	        def stat_action
	            x=Xen::XenServer.new
	            # We don't care about domain 0
	            slices = x.slices
	            slices.delete("Domain-0")
	            reply[:slices] = slices
	            # UGLY -- this is purely linux -- need to be fixed
	            reply[:load] = open("/proc/loadavg","r").readline.split()[0].to_f
	            reply[:times] = {}
	            if !slices.empty? then 
	                slices.each { |s| reply[:times][s]=x.get(s).time }
	            end
	        end
	        
	        def migrate_action
	            validate :slice, String
	            validate :newhost, :ipv4address
	        
	            x=Xen::XenServer.new
	            result=x.migrate(request[:slice],request[:newhost])
	            reply[:result]=result
	        end
	        
        # end of class
        end
    end
end
