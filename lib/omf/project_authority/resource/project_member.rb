require 'omf/project_authority/resource'
require 'omf-sfa/resource/oresource'
require 'time'

module OMF::ProjectAuthority::Resource

  # This class defines the role of user in a project in the system.
  #
  class ProjectMember < OMF::SFA::Resource::OResource

    oproperty :project, :project, inverse: :project_members
    oproperty :user, :user, inverse: :project_memberships
    oproperty :role, String

    def resource_type
      'project_member'
    end

    # def to_hash_brief(opts = {})
      # h = super
      # #h[:urn] = self.urn || 'unknown'
      # h
    # end

  end # classs
end # module
