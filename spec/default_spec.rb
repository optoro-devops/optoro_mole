describe 'optoro_mole::default' do
  Resources::PLATFORMS.each do |platform, value|
    value['versions'].each do |version|
      context "On #{platform} #{version}" do
        include_context 'optoro_mole'

        let(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version, log_level: :error) do |node|
            node.set['lsb']['codename'] = value['codename']
          end.converge(described_recipe)
        end

        it 'should create the printer user' do
          expect(chef_run).to create_users_manage('printer')
        end

        it 'should create the printer private key file' do
          expect(chef_run).to create_file('/home/printer/.ssh/id_rsa').with(
            :owner => 'printer',
            :group => 'printer',
            :mode => 0600
          )
        end

        it 'should create the printer public key file' do
          expect(chef_run).to create_file('/home/printer/.ssh/id_rsa.pub').with(
            :owner => 'printer',
            :group => 'printer',
            :mode => 0744
          )
        end
      end
    end
  end
end
