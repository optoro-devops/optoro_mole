shared_context 'optoro_mole' do
  before do
    allow(Chef::EncryptedDataBagItem).to receive(:load).with('private_keys', 'printer').and_return(
      'id' => 'printer',
      'name' => '/home/printer/.ssh/id_rsa',
      'private_keys' => ['TESTKEY']
    )

    allow(Chef::DataBagItem).to receive(:load).with('users', 'printer').and_return(
      'id' => 'printer',
      'ssh_keys' => [
        'ssh-rsa TESTKEY=='
      ],
      'groups' => [
        'printer'
      ],
      'shell' => '/bin/bash'
    )
  end
end
