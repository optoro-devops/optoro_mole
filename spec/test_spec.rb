describe 'optoro_mole::test' do
  Resources::PLATFORMS.each do |platform, value|
    value['versions'].each do |version|
      context "On #{platform} #{version}" do
        include_context 'optoro_mole'

        let(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version, log_level: :error) do |node|
            node.set['lsb']['codename'] = value['codename']
          end.converge(described_recipe)
        end

        it 'should give sudo to the vagrant user' do
          expect(chef_run).to install_sudo('vagrant').with(
            :user => 'vagrant',
            :nopasswd => true
          )
        end
      end
    end
  end
end
