module MCollective
    module Agent
        class Svnagent < RPC::Agent
            metadata :name        => "svnagent",
                     :description => "Agent to manage svn repos", 
                     :author      => "Nicolas Szalay",
                     :license     => "BSD",
                     :version     => "0.1",
                     :url         => "http://www.rottenbytes.info/",
                     :timeout     => 60
        
            def startup_hook
                @timeout = 60
            end
        
            action "update" do
                validate :path, String

   		revision=`cd #{request[:path]} && svn up` 
		# send back revision number
		reply[:data]=revision.chomp.split(" ")[-1].gsub(".","")
	    end
	        
        # end of class Svnagent
        end
    end
end
