require 'omf/project_authority/resource'
require 'omf-sfa/resource/oresource'
require 'time'

module OMF::ProjectAuthority::Resource

  # This class represents a user in the system.
  #
  class User < OMF::SFA::Resource::OResource
    DEF_LIFE_TIME = 86400 * 30 * 6

    oproperty :expiration, DataMapper::Property::Time
    oproperty :creation, DataMapper::Property::Time
    oproperty :email, String
    oproperty :project_memberships, :project_member, functional: false, inverse: :user

    def initialize(opts)
      super
      self.creation = Time.now
      self.expiration = Time.now + DEF_LIFE_TIME
    end

    def to_hash_long(h, objs = {}, opts = {})
      super
      h[:certificate] = href() + '/cert'
      h
    end

  end # classs
end # module
