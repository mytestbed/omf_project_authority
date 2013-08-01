
require 'omf-sfa/am/am-rest/rest_handler'
require 'omf/project_authority/resource'

module OMF::ProjectAuthority

  # Handles the collection of users on this AM.
  #
  class ProjectMemberHandler < OMF::SFA::AM::Rest::RestHandler

    def initialize(opts = {})
      super
      @resource_class = OMF::ProjectAuthority::Resource::ProjectMember

      # Define handlers
      opts[:project_member_handler] = self
      @user_handler = opts[:user_handler] || UserHandler.new(opts)
      @project_handler = opts[:user_handler] || ProjectHandler.new(opts)
      @coll_handlers = {
        user: lambda do |path, o| # This will force the showing of a SINGLE user
          path.insert(0, o[:context].user.uuid.to_s)
          @user_handler.find_handler(path, o)
        end,
        project: lambda do |path, o| # This will force the showing of a SINGLE project
          path.insert(0, o[:context].project.uuid.to_s)
          @project_handler.find_handler(path, o)
        end
      }
    end

    # SUPPORTING FUNCTIONS


    # def show_resource_list(opts)
      # # authenticator = Thread.current["authenticator"]
      # if user = opts[:context]
        # users = user.project_members
      # else
        # users = OMF::ProjectAuthority::Resource::ProjectMember.all()
      # end
      # show_resources(users, :users, opts)
    # end

  end
end
