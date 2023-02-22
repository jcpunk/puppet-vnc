# frozen_string_literal: true

require 'spec_helper'

describe 'vnc::server::config' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'when using defaults' do
        it { is_expected.to compile }
        it {
          is_expected.to contain_file('/etc/tigervnc')
            .with_ensure('directory')
            .with_owner('root')
            .with_group('root')
            .with_mode('0755')
        }
        it {
          is_expected.to contain_file('/etc/tigervnc/vncserver-config-defaults')
            .with_ensure('file')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
            .with_notify('Class[Vnc::Server::Service]')
            .with_content(%r{^localhost$})
            .with_content(%r{^session=gnome$})
        }
        it {
          is_expected.to contain_file('/etc/tigervnc/vncserver-config-mandatory')
            .with_ensure('file')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
            .with_notify('Class[Vnc::Server::Service]')
        }
        it {
          is_expected.to contain_file('/etc/tigervnc/vncserver.users')
            .with_ensure('file')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
        }
        it {
          is_expected.to contain_concat('/etc/polkit-1/rules.d/25-puppet-vncserver.rules')
            .with_owner('root')
            .with_group('root')
            .with_mode('0600')
        }
        it { is_expected.to have_concat__fragment_resource_count(1) }
        it { is_expected.to have_exec_resource_count(0) }
      end

      context 'with bad params' do
        let(:params) do
          {
            'manage_config' => true,
            'vnc_servers' => {
              'userA' => {
                'comment' => 'a comment',
                'displaynumber' => 1,
                'user_can_manage' => true,
              },
              'userB' => {
                'comment' => 'a different comment',
                'user_can_manage' => false,
              },
            },
          }
        end

        it { is_expected.not_to compile }
      end

      context 'without management' do
        let(:params) do
          {
            'manage_config' => false,
          }
        end

        it { is_expected.to have_file_resource_count(0) }
        it { is_expected.to have_concat__fragment_resource_count(0) }
        it { is_expected.to have_exec_resource_count(0) }
      end

      context 'with rich params' do
        let(:params) do
          {
            'manage_config' => true,
            'config_defaults_file' => '/tmp/foo/bar',
            'config_defaults' => { 'nolisten' => 'tcp' },
            'config_mandatory_file' => '/tmp/bar/foo',
            'config_mandatory' => { 'alwaysshared' => '', 'localhost' => nil },
            'vncserver_users_file' => '/tmp/baz',
            'polkit_file' => '/tmp/baa',
            'systemd_template_startswith' => 'thing@',
            'systemd_template_endswith' => 'socket',
            'vnc_servers' => {
              'userA' => {
                'comment' => 'a comment',
                'displaynumber' => 1,
                'user_can_manage' => true,
              },
              'userB' => {
                'comment' => 'a different comment',
                'displaynumber' => 2,
                'user_can_manage' => false,
                'seed_home_vnc' => false,
              },
              'userC' => {
                'displaynumber' => 3,
              },
            },
          }
        end

        it { is_expected.to compile }
        it {
          is_expected.to contain_file('/tmp/foo')
            .with_ensure('directory')
            .with_owner('root')
            .with_group('root')
            .with_mode('0755')
        }
        it {
          is_expected.to contain_file('/tmp/bar')
            .with_ensure('directory')
            .with_owner('root')
            .with_group('root')
            .with_mode('0755')
        }
        it {
          is_expected.to contain_file('/tmp/foo/bar')
            .with_ensure('file')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
            .with_content(%r{^nolisten=tcp$})
        }
        it {
          is_expected.to contain_file('/tmp/bar/foo')
            .with_ensure('file')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
            .with_content(%r{^alwaysshared$})
            .with_content(%r{^localhost$})
        }
        it {
          is_expected.to contain_file('/tmp/baz')
            .with_ensure('file')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
            .with_content(%r{^:1=userA$})
            .with_content(%r{^:2=userB$})
            .with_content(%r{^:3=userC$})
        }
        it {
          is_expected.to contain_concat('/tmp/baa')
            .with_owner('root')
            .with_group('root')
            .with_mode('0600')
        }
        it { is_expected.to have_concat__fragment_resource_count(2) } # 1 header, 1 user
        it { is_expected.to have_exec_resource_count(12) }

        it { is_expected.to contain_exec('create ~userA/.vnc') }
        it { is_expected.to contain_exec('chmod 700 ~userA/.vnc') }
        it { is_expected.to contain_exec('create ~userA/.vnc/config') }
        it { is_expected.to contain_exec('chmod 600 ~userA/.vnc/config') }
        it { is_expected.to contain_exec('create ~userA/.vnc/passwd') }
        it { is_expected.to contain_exec('chmod 600 ~userA/.vnc/passwd') }

        it { is_expected.not_to contain_exec('create ~userB/.vnc') }
        it { is_expected.not_to contain_exec('create ~userB/.vnc/config') }
        it { is_expected.not_to contain_exec('create ~userB/.vnc/passwd') }

        it { is_expected.to contain_exec('create ~userC/.vnc') }
        it { is_expected.to contain_exec('chmod 700 ~userC/.vnc') }
        it { is_expected.to contain_exec('create ~userC/.vnc/config') }
        it { is_expected.to contain_exec('chmod 600 ~userC/.vnc/config') }
        it { is_expected.to contain_exec('create ~userC/.vnc/passwd') }
        it { is_expected.to contain_exec('chmod 600 ~userC/.vnc/passwd') }
      end

      context 'without vnc home seeds and reverse management' do
        let(:params) do
          {
            'manage_config' => true,
            'seed_home_vnc' => false,
            'user_can_manage' => true,
            'config_defaults_file' => '/tmp/foo/bar',
            'config_defaults' => { 'nolisten' => 'tcp' },
            'config_mandatory_file' => '/tmp/bar/foo',
            'config_mandatory' => { 'alwaysshared' => '', 'localhost' => nil },
            'vncserver_users_file' => '/tmp/baz',
            'polkit_file' => '/tmp/baa',
            'systemd_template_startswith' => 'thing@',
            'systemd_template_endswith' => 'socket',
            'vnc_servers' => {
              'userA' => {
                'comment' => 'a comment',
                'displaynumber' => 1,
                'user_can_manage' => false,
              },
              'userB' => {
                'comment' => 'a different comment',
                'displaynumber' => 2,
                'seed_home_vnc' => true,
              },
            },
          }
        end

        it { is_expected.to compile }
        it {
          is_expected.to contain_file('/tmp/foo')
            .with_ensure('directory')
            .with_owner('root')
            .with_group('root')
            .with_mode('0755')
        }
        it {
          is_expected.to contain_file('/tmp/bar')
            .with_ensure('directory')
            .with_owner('root')
            .with_group('root')
            .with_mode('0755')
        }
        it {
          is_expected.to contain_file('/tmp/foo/bar')
            .with_ensure('file')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
            .with_content(%r{^nolisten=tcp$})
        }
        it {
          is_expected.to contain_file('/tmp/bar/foo')
            .with_ensure('file')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
            .with_content(%r{^alwaysshared$})
            .with_content(%r{^localhost$})
        }
        it {
          is_expected.to contain_file('/tmp/baz')
            .with_ensure('file')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
        }
        it {
          is_expected.to contain_concat('/tmp/baa')
            .with_owner('root')
            .with_group('root')
            .with_mode('0600')
        }
        it { is_expected.to have_concat__fragment_resource_count(2) } # 1 header, 1 user
        it { is_expected.to have_exec_resource_count(6) }

        it { is_expected.to contain_exec('create ~userB/.vnc') }
        it { is_expected.to contain_exec('chmod 700 ~userB/.vnc') }
        it { is_expected.to contain_exec('create ~userB/.vnc/config') }
        it { is_expected.to contain_exec('chmod 600 ~userB/.vnc/config') }
        it { is_expected.to contain_exec('create ~userB/.vnc/passwd') }
        it { is_expected.to contain_exec('chmod 600 ~userB/.vnc/passwd') }

        it { is_expected.not_to contain_exec('create ~userA/.vnc') }
        it { is_expected.not_to contain_exec('create ~userA/.vnc/config') }
        it { is_expected.not_to contain_exec('create ~userA/.vnc/passwd') }
      end
    end
  end
end
