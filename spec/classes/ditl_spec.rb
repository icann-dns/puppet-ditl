require 'spec_helper'

describe 'ditl' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  # include_context :hiera
  let(:node) { 'ditl.example.com' }

  # below is the facts hash that gives you the ability to mock
  # facts on a per describe/context block.  If you use a fact in your
  # manifest you should mock the facts below.
  let(:facts) do
    {}
  end

  # below is a list of the resource parameters that you can override.
  # By default all non-required parameters are commented out,
  # while all required parameters will require you to add a value
  let(:params) do
    {
      upload_key_source: 'puppet:///modules/module_files/id_rsa',
      upload_user: 'dns-oarc',
      #:enabled => true,
      #:pcap_dir => '/opt/pcap',
      #:pattern => '*.{bz2,xz}',
      #:upload_host => 'capture.ditl.dns-oarc.net',
      #:upload_key_file => '/root/.ssh/oarc_id_dsa',
      #:clean_known_hosts => false,

    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  # This will need to get moved
  # it { pp catalogue.resources }
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      describe 'check default config' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('ditl') }
        it do
          is_expected.to contain_file('/usr/local/bin/ditl_upload').with(
            ensure: 'present',
            mode: '0755'
          ).with_content(
            %r{^PCAP_DIR=/opt/pcap}
          ).with_content(
            %r{-i /root/.ssh/oarc_id_dsa}
          ).with_content(
            %r{dns-oarc@capture.ditl.dns-oarc.net}
          ).with_content(
            %r{ls \$\{PCAP_DIR\}/\*\.\{bz2,xz\}}
          ).without_content(
            %r{ssh-keygen -f}
          )
        end
        it do
          is_expected.to contain_file('/usr/local/bin/ditl_retry').with(
            ensure: 'present',
            mode: '0755'
          ).with_content(
            %r{^PCAP_DIR=/opt/pcap}
          )
        it do
          is_expected.to contain_file('/root/.ssh/oarc_id_dsa').with(
            ensure: 'present',
            mode: '0600',
            source: 'puppet:///modules/module_files/id_rsa'
          )
        end
        it do
          is_expected.to contain_cron('ditl_upload').with(
            ensure: 'present',
            command: '/usr/local/bin/ditl_upload',
            user: 'root',
            minute: '*/10',
            require: 'File[/usr/local/bin/ditl_upload]'
          )
        end
        it do
          is_expected.to contain_cron('ditl_retry').with(
            ensure: 'present',
            command: '/usr/local/bin/ditl_retry',
            user: 'root',
            minute: '0',
            require: 'File[/usr/local/bin/ditl_retry]'
          )
        end
      end
      describe 'Change Defaults' do
        context 'upload_key_source' do
          before { params.merge!(upload_key_source: 'puppet:///modules/foo') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/root/.ssh/oarc_id_dsa').with(
              ensure: 'present',
              mode: '0600',
              source: 'puppet:///modules/foo'
            )
          end
        end
        context 'upload_user' do
          before { params.merge!(upload_user: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/bin/ditl_upload').with_content(
              %r{foobar@capture.ditl.dns-oarc.net}
            )
          end
        end
        context 'enabled' do
          before { params.merge!(enabled: false) }
          it { is_expected.to compile }
          it { is_expected.to contain_cron('ditl_upload').with_ensure('absent') }
          it { is_expected.to contain_cron('ditl_retry').with_ensure('absent') }
          it do
            is_expected.to contain_file('/root/.ssh/oarc_id_dsa').with_ensure(
              'absent'
            )
          end
          it do
            is_expected.to contain_file('/usr/local/bin/ditl_upload').with_ensure(
              'absent'
            )
          end
          it do
            is_expected.to contain_file('/usr/local/bin/ditl_retry').with_ensure(
              'absent'
            )
          end
        end
        context 'pcap_dir' do
          before { params.merge!(pcap_dir: '/foo/bar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/bin/ditl_upload').with_content(
              %r{^PCAP_DIR=/foo/bar}
            )
          end
          it do
            is_expected.to contain_file('/usr/local/bin/ditl_retry').with_content(
              %r{^PCAP_DIR=/foo/bar}
            )
          end
        end
        context 'pattern' do
          before { params.merge!(pattern: 'foobar.*') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/bin/ditl_upload').with_content(
              %r{ls \$\{PCAP_DIR\}/foobar\.\*}
            )
          end
        end
        context 'upload_host' do
          before { params.merge!(upload_host: 'foo.bar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/bin/ditl_upload').with_content(
              %r{dns-oarc@foo\.bar}
            )
          end
        end
        context 'upload_key_file' do
          before { params.merge!(upload_key_file: '/foo/bar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/foo/bar').with(
              ensure: 'present',
              mode: '0600',
              source: 'puppet:///modules/module_files/id_rsa'
            )
          end
          it do
            is_expected.to contain_file('/usr/local/bin/ditl_upload').with_content(
              %r{-i /foo/bar}
            )
          end
        end
        context 'clean_known_hosts' do
          before { params.merge!(clean_known_hosts: true) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/bin/ditl_upload').with_content(
              %r{ssh-keygen -f \"/root/\.ssh/known_hosts\" -R capture\.ditl\.dns-oarc\.net  >/dev/null 2>\&1}
            )
          end
        end
      end
      describe 'check bad type' do
        context 'upload_key_source' do
          before { params.merge!(upload_key_source: nil) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'upload_key_source' do
          before { params.merge!(upload_key_source: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'upload_key_source' do
          before { params.merge!(upload_key_source: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'upload_user' do
          before { params.merge!(upload_user: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'enabled' do
          before { params.merge!(enabled: 'foo') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'pcap_dir' do
          before { params.merge!(pcap_dir: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'pcap_dir' do
          before { params.merge!(pcap_dir: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'pattern' do
          before { params.merge!(pattern: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'upload_host' do
          before { params.merge!(upload_host: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'upload_key_file' do
          before { params.merge!(upload_key_file: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'clean_known_hosts' do
          before { params.merge!(clean_known_hosts: 'foo') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end
