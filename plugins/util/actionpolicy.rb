module MCollective
    module Util
         class ActionPolicy
              def self.authorize(request)
                  unless request.caller == "uid=0"
                      raise("You must be root to access to #{request.agent}::#{request.action}")
                  end
              end
         end
    end
end


