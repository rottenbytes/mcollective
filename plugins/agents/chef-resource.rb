module MCollective
    module Agent
        # An agent that uses Opscode to manage resources
        # Original credit goes to R.I. Pienaar
        class Chefresource<RPC::Agent
            metadata    :name        => "SimpleRPC Chef Resource Agent",
                        :description => "Generic resource management",
                        :author      => "Nicolas Szalay <nico@rottenbytes.info>",
                        :license     => "BSD",
                        :version     => "1.0",
                        :url         => "https://github.com/rottenbytes/mcollective",
                        :timeout     => 60

            # Does the actual work with the chef provider and sets appropriate reply options
            action "handle" do
                validate :resourcetype, String
                validate :resourcename, String

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

                    run_context = Chef::RunContext.new(client.node, Chef::CookbookCollection.new(Chef::CookbookLoader.new))
                    recipe = Chef::Recipe.new("adhoc", "default", run_context)
                    # create the resource
		    resource = recipe.send(request[:resourcetype].to_sym, request[:resourcename])
		    # insert action, attribute, whatever supported by your resource type
                    request[:resourceactions].each { |action|
			action.each_pair { |k,v|
				resource.send(k,v)
			}
		    }
                    Log.instance.debug("Converging for resource #{request[:resourcetype]} '#{request[:resourcename]}'")
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
