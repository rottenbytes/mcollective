module MCollective
    module Agent
        # An agent to manage the Chef Daemon
        #
        # Many bits taken from the puppet agent from R.I. Pienaar
        #
        # Configuration Options:
        #    chef.client   - Where to find the chef client, defaults to /usr/sbin/chef-client
        #    chef.pidfile   - Where to find the chef client pid file
        class Chef<RPC::Agent
            metadata    :name        => "SimpleRPC Chef Client Agent",
                        :description => "Agent to manage the chef client",
                        :author      => "Nicolas Szalay",
                        :license     => "Apache License 2.0",
                        :version     => "1.0",
                        :url         => "http://www.rottenbytes.info",
                        :timeout     => 30

            def startup_hook
                @pidfile = @config.pluginconf["chef.pidfile"] || "/var/run/chef/client.pid"
                @client = @config.pluginconf["chef.client"] || "/usr/bin/chef-client"
            end

            action "status" do
                reply[:running] = 0
                if File.exists?(@pidfile) then
                    reply[:running] = 1
                end
            end

            action "runonce" do
                Log.debug("=> running #{@client}")
                reply[:stdout] = ""
                reply[:stderr] = ""
                reply[:status] = run(@client, :stdout => reply[:stdout], :stderr => reply[:stderr])
            end

        end # end of class Chef
    end
end

