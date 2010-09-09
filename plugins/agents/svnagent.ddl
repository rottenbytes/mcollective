metadata :name => "svnagent",
    :description => "Agent to manage SVN repos", 
	:author => "Nicolas Szalay <nico@rottenbytes.info",
	:license => "BSD",
	:version => "0.1",
	:url => "http://www.rottenbytes.info/",
	:timeout => 30

action "update", :description => "Updates the repo in the specified path" do
    input :path,
	    :prompt => "path",
	    :description =>  "full path of the repository",
	    :type => :string,
	    :validation  => '^[a-zA-Z\-_\d]+$',
	    :optional => false,
	 output :data
	    :description => "The repository revision number extracted"
	    :display_as => "Revision number"
end
