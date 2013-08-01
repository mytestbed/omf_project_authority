require 'omf/project_authority/resource'
require 'omf-sfa/resource/oresource'
require 'time'

module OMF::ProjectAuthority::Resource

  # This class represents a user in the system.
  #
  class Project < OMF::SFA::Resource::OResource

    oproperty :creation, DataMapper::Property::Time
    oproperty :description, String
    oproperty :email, String
    oproperty :parent_project, :project, inverse: :sub_projects
    oproperty :sub_projects, :project, functional: false, inverse: :parent_project
    oproperty :project_members, :project_member, functional: false, inverse: :project


    def initialize(opts)
      super
      self.creation = Time.now
    end

  end # classs
end # module
