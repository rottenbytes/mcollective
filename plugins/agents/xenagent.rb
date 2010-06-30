require 'xen'
            
module MCollective
    module Agent
        class Xenagent < RPC::Agent
            metadata :name        => "xenagent",
                     :description => "Agent to manage xen", 
                     :author      => "Nicolas Szalay",
                     :license     => "BSD",
                     :version     => "0.1",
                     :url         => "http://www.rottenbytes.info/",
                     :timeout     => 30
        
            def startup_hook
                # Increase timeout because migration can be longer than the default one
                # Yes, it is quite bad
                @timeout = 30
            end
        
            # Basic echo server, kept for tests
            action "echo" do 
                validate :msg, String
     
                reply.data = request[:msg]
            end

	        action "find" do
		        validate :name, String
		                  
		        x=Xen::XenServer.new
		        if x.has? request[:name] then
		            reply.data = "Present"
		        else
		            reply.data = "Absent"
		        end
	        end
	        
	        action "list" do
	            x=Xen::XenServer.new
	            reply[:slices] = x.slices
	        end
	        
	        
	        action "stat" do
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
	        
	        action "migrate" do
	            validate :slice, String
	            validate :newhost, :ipv4address
	        
	            x=Xen::XenServer.new
	            result=x.migrate(request[:slice],request[:newhost])
	            reply[:result]=result
	        end
	        
	        action "create" do
	            validate :name, String
	            
	            x=Xen::XenServer.new
	            result=x.create(request[:name])
	            reply[:result]=result
	        end
	        
	        action "destroy" do
	            validate :name, String
	            
	            x=Xen::XenServer.new
	            result=x.destroy(request[:name])
	            reply[:result]=result
	        end
        # end of class
        end
    end
end
