Redmine LDAP Sync [![Build Status](https://travis-ci.org/thorin/redmine_ldap_sync.svg?branch=master)](https://travis-ci.org/thorin/redmine_ldap_sync) [![Coverage Status](https://coveralls.io/repos/thorin/redmine_ldap_sync/badge.svg?branch=master)](https://coveralls.io/r/thorin/redmine_ldap_sync?branch=master) [![Code Climate](https://codeclimate.com/github/thorin/redmine_ldap_sync/badges/gpa.svg)](https://codeclimate.com/github/thorin/redmine_ldap_sync)
=================

This redmine plugin extends the ldap authentication with user/group
synchronization.

__Features__:

 * Synchronization of user fields and groups on login.
 * Detects and disables users that have been removed from LDAP.
 * Detects and disables users that have been marked as disabled on Active
   Directory (see [MS KB Article 305144][uacf] for details).
 * Can detect and include nested groups. Upon login the nested groups are
   retrieved from disk cache. This cache can only be updated with the rake task.
 * A rake task is available for manual or periodic synchronization of groups and
   users.

__Remarks__:

* The plugin is prepared and intended to run with any LDAP directory. But, the
  author can only guarantee it to work correctly with Active Directory and
  Slapd.
* An user will only be removed from groups that exist on LDAP. This behaviour
  is intended as it allows both ldap and non-ldap groups to coexist.
* Deleted groups on LDAP will not be deleted on redmine.

Installation & Upgrade
----------------------

### Install/Upgrade

1. **install.** - Copy your plugin directory into `#{RAILS_ROOT}/plugins`.
   If you are downloading the plugin directly from GitHub, you can do so by
   changing into the `#{RAILS_ROOT}/plugins` directory and issuing the command:
   ```
   git clone git://github.com/thorin/redmine_ldap_sync.git
   ```

   **upgrade** - Backup and replace the old plugin directory with the new
   plugin files. If you are downloading the plugin directly from GitHub, you
   can do so by changing into the plugin directory and issuing the command
   `git pull`.

2. Update the ruby gems by changing into the redmine's directory and run the
   following command.
   ```
   bundle install
   ```

3. **upgrade** - Still on the redmine's directory, run the following command
   to upgrade your database (make a db backup before).
   ```
   rake redmine:plugins:migrate RAILS_ENV=production
   ```

4. Change into redmine's directory `#{RAILS_ROOT}` and run the following
   command.
   ```
   rake -T redmine:plugins:ldap_sync RAILS_ENV=production
   ```
   If the installation/upgrade was successful you should now see the list of
   [Rake Tasks](#rake-tasks).

5. Restart Redmine.

You should now be able to see **Redmine LDAP Sync** listed among the plugins in
`Administration -> Plugins`.

### Uninstall

1. Change into redmine's directory `#{RAILS_ROOT}` and run the following
   command to downgrade the database (make a db backup before):
   ```
   rake redmine:plugins:migrate NAME=redmine_ldap_sync VERSION=0 RAILS_ENV=production
   ```

2. Remove the plugin from the plugins folder: `#{RAILS_ROOT}/plugins`
3. Restart Redmine.

Usage
-----

### Configuration

Open `Administration > Ldap Synchronization` to access the plugin
configuration:

**LDAP settings:**

+ **Base settings** - Preloads the configuration with predefined settings.
+ **Group base DN** - The path to where the groups are located. Eg,
  `ou=people,dc=smokeyjoe,dc=com`.
+ **Groups objectclass** - The groups object class.
+ **Users objectclass** - The users object class.
+ **Users search scope** - One level or whole subtree.
  - **One level**: searches one level below the user base DN, i.e. all its immediate children only.
  - **Whole subtree**: searches the whole subtree rooted at user base DN.
+ **Group name pattern** - (optional) An RegExp that should match up with the
  name of the groups that should be imported. Eg, `\.team$`.
+ **Group search filter** - (optional) An LDAP search filter to be applied
  whenever search for groups.
+ **Account disabled test** - A ruby boolean expression that should evaluate an
  account's flags (the variable `flags`) and return `true` if the account is
  disabled. Eg., `flags.to**i & 2 != 0` or `flags.include? 'D'`.
+ **Group membership** - Specifies how to determine the user's group
  membership.
  The possible values are:
  - **On the group class**: membership determined from the list of users
    contained on the group.
  - **On the user class**: membership determined from the list of groups
    contained on the user.
+ **Enable nested groups** - Enables and specifies how to identify the groups
  nesting. When enabled the plugin will look for the groups' parent groups, and
  so on, and add those groups to the users. The possible values are:
  - **Membership on the parent class**: group membership determined from the
    list of groups contained on the parent group.
  - **Membership on the member class**: group membership determined from the
    list of groups contained on the member group.

**LDAP attributes:**

+ **Group name (group)** - The ldap attribute from where to fetch the
  group's name. Eg, `sAMAccountName`.
+ **Account flags (user)** - The ldap attribute containing the account disabled
  flag. Eg., `userAccountControl`.
+ **Primary group (user)** - The ldap attribute that identifies the primary
  group of the user. This attribute will also be used as group id when
  searching for the group. Eg, `gidNumber`
+ **Members (group)** - The ldap attribute from where to fetch the
  group's members. Visible if the group membership is __on the group class__.
  Eg, `member`.
+ **Memberid (user)** - The ldap attribute from where to fetch the
  user's memberid. This attribute must match with the __members attribute__.
  Visible if the group membership is __on the group class__. Eg, `dn`.
+ **Groups (user)** - The ldap attribute from where to fetch the user's
  groups. Visible if the group membership is __on the user class__. Eg,
  `memberof`.
+ **Groupid (group)** - The ldap attribute from where to fetch the
  group's groupid. This attribute must match with the __groups attribute__.
  Visible if the group membership is __on the user class__. Eg,
  `distinguishedName`.
+ **Member groups (group)** - The ldap attribute from where to fetch the
  group's member groups. Visible if the nested groups __membership is on the
  parent class__. Eg, `member`.
+ **Memberid attribute (group)** - The ldap attribute from where to fetch the
  member group's memberid. This attribute must match with the __member groups
  attribute__. Eg, `distinguishedName`.
+ **Parent groups (group)** - The ldap attribute from where to fetch
  the group's parent groups. Visible if the nested groups __membership is on
  the member class__. Eg, `memberOf`.
+ **Parentid attribute (group)** - The ldap attribute from where to fetch the
  parent group's id. This attribute must match with the __parent groups
  attribute__. Eg, `distinguishedName`.

**Synchronization actions:**

+ **Users must be members of** - (optional) A group to wich the users must
  belong to to have access enabled to redmine.
+ **Administrators group** - (optional) All members of this group will become
  redmine administrators.
+ **Add users to group** - (optional) A group to wich all the users created
  from this LDAP authentication will added upon creation. This group should not
  exist on LDAP.
+ **Create new groups** - If enabled, groups that don't already exist on
  redmine will be created.
+ **Create new users** - If enabled, users that don't already exist on redmine
                         will be created when running the rake task.
+ **Synchronize on login** - Enables/Disables users synchronization on login.
The possible values are:
  - **User fields and groups**: Both the fields and groups will be
                                synchronized on login. If a user is disabled
                                on LDAP or removed from the *users must be
                                member of* group, the user will be locked and
                                the access denied.
  - **User fields**: Only the fields will be synchronized on login. If a user
                     is disabled on LDAP, the user will be locked and the
                     access denied. Changes on groups will not lock the user.
  - **Disabled**: No synchronization is done on login.
+ **Dynamic groups**[¹](#license) - Enables/Disables dynamic groups. The
possible values are:
  - **Enabled**: While searching for groups, *Ldap Sync* will also search for
                 dynamic groups.
  - **Enabled with a ttl**: The dynamic groups cache[²](#license) will expire
                            every **t** minutes.
  - **Disabled**: *Ldap Sync* will not search for dynamic groups.
+ **User/Group fields:**
  - **Synchronize** - If enabled, the selected field will be synchronized
    both on the rake tasks and after every login.
  - **LDAP attribute** - The ldap attribute to be used as reference on the
    synchronization.
  - **Default value** - Shows the value that will be used as default.

### Rake tasks

The following tasks are available:

    # rake -T redmine:plugins:ldap_sync
    rake redmine:plugins:ldap_sync:sync_all     # Synchronize both redmine's users and groups with LDAP
    rake redmine:plugins:ldap_sync:sync_groups  # Synchronize redmine's groups fields with those on LDAP
    rake redmine:plugins:ldap_sync:sync_users   # Synchronize redmine's users fields and groups with those on LDAP

This tasks can be used to do periodic synchronization.
For example:

    # Synchronize users with ldap @ every 60 minutes
    35 * * * *   www-data /usr/bin/rake -f /opt/redmine/Rakefile --silent redmine:plugins:ldap_sync:sync_users RAILS_ENV=production 2>&- 1>&-

The tasks recognize three environment variables:
+ **DRY_RUN** - Performs a run without changing the database.
+ **ACTIVATE_USERS** - Activates users if they're active on LDAP.
+ **LOG_LEVEL** - Controls the rake task verbosity.
  The possible values are:
  - **silent**: Nothing is written to the output.
  - **error**: Only errors are written to the output.
  - **change**: Only writes errors and changes made to the user/group's base.
  - **debug**: Detailed information about the execution is visible to help
               identify errors. This is the default value.

### Base settings

All the base settings are loaded from the plain YAML file
`config/base_settings.yml`.
Please be aware that those settings weren't tested and may not work.
Saying so, I'll need your help to make these settings more accurate.

License
-------
This plugin is released under the GPL v3 license. See LICENSE for more
information.


---
1. For details about dynamic groups see
   [OpenLDAP Overlays - Dynamic Lists][overlays-dynlist] or
   [slapo-dynlist(5) - Linux man page][slapo-dynlist].
2. Searching for an user's dynamic groups is an costly task. To easy it up, a
   cache is used to store the relationship between dynamic groups and users.
   When running the rake task this cache will be refreshed.

[uacf]: http://support.microsoft.com/kb/305144
[overlays-dynlist]: http://www.openldap.org/doc/admin24/overlays.html#Dynamic%20Lists
[slapo-dynlist]: http://www.openldap.org/software/man.cgi?query=slapo-dynlist
