require 'puppet/util/network_device'
Puppet::Type.newtype(:netapp_e_password) do
  @doc = 'Manage Netapp E series storage array password'

  apply_to_device

  validate do
    raise Puppet::Error, 'You must specify a storage system id.' unless @parameters.include?(:storagesystem)
    raise Puppet::Error, 'You must specify a current admin password.' unless @parameters.include?(:current)
    raise Puppet::Error, 'You must specify a new password.' unless @parameters.include?(:new)
    raise Puppet::Error, 'You must specify a type of password.' unless @parameters.include?(:admin)
  end

  newparam(:storagesystem, :namevar => true) do
    desc 'Storage system id'
  end

  newparam(:current) do
    desc 'Current admin password'
  end

  newparam(:new) do
    desc 'New password'
  end

  newproperty(:ensure) do
    desc 'Check if particular type of password is set up'
    defaultto :set

    def retrieve
      if resource[:force]
        Puppet.debug('Password change forced')
        :notset
      else
        Puppet.notice('check password existence')
        provider.passwords_status
      end
    end

    newvalue :notset
    newvalue :set do
      provider.set_password
    end
  end

  newparam(:admin, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc 'If this is true, this will set the admin password, if false, it sets the RO password'
  end

  newparam(:force, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc 'If true it will always try change password, even if already set. We can not check if passwords match'
    defaultto :false
  end
end
