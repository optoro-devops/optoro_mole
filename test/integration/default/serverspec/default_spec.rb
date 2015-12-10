# Serverspec tests for rabbitmq sensu configuration
require 'spec_helper'

describe 'printer user' do
  describe user('printer') do
    it { should exist }
    it { should have_login_shell '/bin/bash' }
    it { should have_home_directory '/home/printer' }
  end

  describe file('/home/printer/.ssh/id_rsa') do
    it { should exist }
    it { should be_owned_by 'printer' }
    it { should be_grouped_into 'printer' }
  end

  describe file('/home/printer/.ssh/id_rsa.pub') do
    it { should exist }
    it { should be_owned_by 'printer' }
    it { should be_grouped_into 'printer' }
  end
end
