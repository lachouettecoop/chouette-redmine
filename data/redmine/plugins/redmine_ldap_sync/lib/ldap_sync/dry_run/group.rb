# encoding: utf-8
# Copyright (C) 2011-2013  The Redmine LDAP Sync Authors
#
# This file is part of Redmine LDAP Sync.
#
# Redmine LDAP Sync is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Redmine LDAP Sync is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Redmine LDAP Sync.  If not, see <http://www.gnu.org/licenses/>.
module LdapSync::DryRun::Group

  module InstanceMethods
    def find_or_create_by_lastname(lastname, attributes = {})
      group = find_by_lastname(lastname)
      return group if group.present?

      group = ::Group.new(attributes.merge(:lastname => lastname))
      puts "   !! New group '#{lastname}'" if (group.valid?)

      group
    end
  end

  def self.included(receiver)
    receiver.send(:include, InstanceMethods)

    receiver.instance_eval do
      has_and_belongs_to_many :users do
        def <<(users)
          puts "   !! Added to group '#{proxy_association.owner.lastname}'"
        end
      end
    end
  end

end
