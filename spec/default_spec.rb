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
            owner: 'printer',
            group: 'printer',
            mode: 0600
          )
        end

        it 'should create the printer public key file' do
          expect(chef_run).to create_file('/home/printer/.ssh/id_rsa.pub').with(
            owner: 'printer',
            group: 'printer',
            mode: 0744
          )
        end

        it 'should create the reaper script file' do
          expect(chef_run).to render_file('/usr/local/bin/kill-less-reaper.rb')
        end

        it 'should create a cron job to reap stale connections' do
          expect(chef_run).to create_cron('kill-less-reaper').with(
            user: 'root',
            hour: '1',
            minute: '0',
            command: '/usr/local/bin/kill-less-reaper.rb'
          )
        end
      end
    end
  end
end
