# <
# Default Recipe Description
# >

printer_private_key = Chef::EncryptedDataBagItem.load('private_keys', 'printer')
printer_user = Chef::DataBagItem.load('users', 'printer')
public_key_file = printer_user['ssh_keys'].join("\n")

users_manage 'printer' do
  action [:remove, :create]
end

file printer_private_key['name'] do
  owner 'printer'
  group 'printer'
  content printer_private_key['private_key']
  mode 0600
end

file "#{printer_private_key['name']}.pub" do
  owner 'printer'
  group 'printer'
  content public_key_file
  mode 0744
end

cookbook_file '/usr/local/bin/kill-less-reaper.rb' do
  owner 'root'
  group 'root'
  mode 0755
end

cron 'kill-less-reaper' do
  user 'root'
  hour 1
  minute 0
  command '/usr/local/bin/kill-less-reaper.rb'
end
