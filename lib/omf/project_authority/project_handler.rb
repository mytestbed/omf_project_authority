
require 'omf-sfa/am/am-rest/rest_handler'
require 'omf/project_authority/resource'
#require 'omf/project_authority/user_member_handler'

module OMF::ProjectAuthority

  # Handles the collection of users on this AM.
  #
  class ProjectHandler < OMF::SFA::AM::Rest::RestHandler

    def initialize(opts = {})
      super
      @resource_class = OMF::ProjectAuthority::Resource::Project

      # Define handlers
      opts[:project_handler] = self
      @coll_handlers = {
        #user_members: (opts[:user_member_handler] || UserMemberHandler.new(opts))
      }
    end

  end
end
