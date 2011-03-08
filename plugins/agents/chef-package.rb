module MCollective
    module Agent
        # An agent that uses chef provider to manage packages
        # Based on the puppet version oneh
        class Package<RPC::Agent
            metadata    :name        => "SimpleRPC Agent For Package Management",
                        :description => "Agent To Manage Packages",
                        :author      => "Nicolas Szalay <nico@rottenbytes.info>",
                        :license     => "GPLv2",
                        :version     => "1.0",
                        :url         => "http://www.rottenbytes.info/",
                        :timeout     => 180

            ["install", "upgrade", "remove", "purge"].each do |act|
                action act do
                    validate :package, :shellsafe
                    do_pkg_action(request[:package], act.to_sym)
                end
            end

            action "apt_update" do
                reply.fail! "Cannot find apt-get at /usr/bin/apt-get" unless File.exist?("/usr/bin/apt-get")
                reply[:output] = %x[/usr/bin/apt-get update]
                reply[:exitcode] = $?.exitstatus

                reply.fail! "apt-get update failed, exit code was #{reply[:exitcode]}" unless reply[:exitcode] == 0
            end


            private
            def do_pkg_action(package, action)
                begin
                    require 'chef'
                    require 'chef/client'
                    require 'chef/run_context'

                    Chef::Config[:solo] = true
                    Chef::Config[:log_level] = :debug
                    Chef::Log.level(:debug)
                    client = Chef::Client.new
                    client.run_ohai
                    client.build_node

                    run_context = Chef::RunContext.new(client.node, Chef::CookbookCollection.new(Chef::CookbookLoader.new))
                    recipe = Chef::Recipe.new("adhoc", "default", run_context)
                    resource = recipe.send(:package, package)
                    resource.send("action",action)

                    Log.instance.debug("Doing '#{action}' for package '#{package}'")
                    status=Chef::Runner.new(run_context).converge
                    
                    reply["status"] = status
                rescue Exception => e
                    reply.fail e.to_s
                end
            end

        end
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
