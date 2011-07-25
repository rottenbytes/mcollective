module MCollective
    module Agent
        # An agent that uses Opscode to manage services
        # Made from the puppet version
        # Original credit goes to R.I. Pienaar
        class Service<RPC::Agent
            metadata    :name        => "SimpleRPC Service Agent, Chef version",
                        :description => "Agent to manage services",
                        :author      => "Nicolas Szalay <nico@rottenbytes.info>",
                        :license     => "BSD",
                        :version     => "1.0",
                        :url         => "https://github.com/rottenbytes/mcollective",
                        :timeout     => 60

            ["stop", "start", "restart"].each do |act|
                action act do
                    do_service_action(act)
                end
            end

            private

            # Does the actual work with the chef provider and sets appropriate reply options
            def do_service_action(action)
                validate :service, String

                require 'chef'
                require 'chef/client'
                require 'chef/run_context'

                begin
                    Chef::Config[:solo] = true
                    Chef::Config[:log_level] = :debug
                    Chef::Log.level(:debug)
                    client = Chef::Client.new
                    client.run_ohai
                    client.build_node

                    run_context = Chef::RunContext.new(client.node, Chef::CookbookCollection.new(Chef::CookbookLoader.new("/tmp")))
                    recipe = Chef::Recipe.new("adhoc", "default", run_context)
                    resource = recipe.send(:service, request[:service])
                    resource.send("action",action)
                    resource.send("supports", {:status => true } )
                    
                    Log.instance.debug("Doing '#{action}' for service '#{request[:service]}'")
                    status=Chef::Runner.new(run_context).converge
                       
                    reply["status"] = status
                rescue Exception => e
                    reply.fail "#{e}"
                end
            end
        end
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
