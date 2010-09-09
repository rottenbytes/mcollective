metadata :name => "xenagent",
    :description => "Agent to manage xen", 
	:author => "Nicolas Szalay <nico@rottenbytes.info",
	:license => "BSD",
	:version => "0.1",
	:url => "http://www.rottenbytes.info/",
	:timeout => 30

action "list", :description => "Find all dom0 and displays associated domUs" do
end

action "find", :description => "Finds the specified domU" do
    input :name,
	    :prompt => "domU name",
	    :description => "The domU name",
	    :type => :string,
        :validation  => '^[a-zA-Z\-_\d]+$',
	    :optional => false
end

action "stat", :description => "returns load avg & domu times" do
    output "slices",
        :description => "The list of domUs",
        :display_as => "Slices"
        
    output "load",
        :description => "The dom0 load",
        :display_as => "dom0 load"        

    output "times",
        :description => "The domUs times",
        :display_as => "Times"        
end

action "migrate", :description => "Migrate a domU to another dom0" do
    input :name,
	    :prompt => "domU name",
	    :description => "The domU name",
	    :type => :string,
	    :validation  => '^[a-zA-Z\-_\d]+$',
	    :optional => false

    input :newhost,
	    :prompt => "dom0 name",
	    :description => "The destination dom0",
	    :type => :string,
        :validation  => '^[a-zA-Z\-_\d]+$',
	    :optional => false
end

action "create", :description => "Starts the specified domU" do
    input :name,
        :prompt => "domU name",
        :description => "The domU to start",
        :type => :string,
        :validation  => '^[a-zA-Z\-_\d]+$',
        :optional => false
end

action "destroy", :description => "Destroys the specified domU" do
    input :name,
	    :prompt => "domU name",
	    :description => "The domU to destroy",
	    :type => :string,
        :validation  => '^[a-zA-Z\-_\d]+$',
	    :optional => false
end

