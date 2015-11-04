class AddGroupMembershipSetting < ActiveRecord::Migration

  def self.up
    all_settings = Setting.plugin_redmine_ldap_sync
    return unless all_settings

    AuthSourceLdap.all.each do |as|
      settings = all_settings[as.name]

      say_with_time "Updating settings for '#{as.name}'" do
        settings[:group_membership] = 'on_groups'
        settings[:attr_user_groups] = 'memberof'
        settings[:attr_groupid] = 'distinguishedName'
        Setting.plugin_redmine_ldap_sync = all_settings
      end if settings
    end
  end

  def self.down
    # Nothing to do here
  end
end
