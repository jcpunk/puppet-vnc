# frozen_string_literal: true

require 'spec_helper'

describe 'vnc::client::novnc::service' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with defaults' do
        it { is_expected.to compile }
        it {
          is_expected.to contain_systemd__unit_file('websockify.service')
            .with_ensure('present')
            .with_enable(true)
            .with_active(true)
            .with_subscribe([nil])
            .with_content(%r{^User=novnc$})
            .with_content(%r{^Group=novnc$})
            .with_content(%r{^ExecStart=/usr/bin/websockify --verbose --web=/usr/share/novnc --token-plugin=ReadOnlyTokenFile --token-source=/etc/websockify/tokens.cfg ::1:6080$})
        }
      end

      context 'with weird params' do
        let(:params) do
          {
            'websockify_command'        => '/some/command',
            'websockify_service_user'   => 'test_user',
            'websockify_service_group'  => 'test_group',
            'websockify_service_name'   => 'test.service',
            'websockify_service_ensure' => 'stopped',
            'websockify_service_enable' => false,
            'websockify_token_plugin'   => 'TEST_TOKEN_PLUGIN',
            'websockify_token_source'   => 'TEST_TOKEN_SOURCE',
            'websockify_port'           => 6480,
            'websockify_webroot'        => '/some/webroot',
            'websockify_use_ssl'        => true,
            'websockify_use_ssl_only'   => true,
            'websockify_ssl_ca'         => '/cert.ca',
            'websockify_ssl_cert'       => '/cert.cert',
            'websockify_ssl_key'        => '/cert.key',
          }
        end

        let :pre_condition do
          <<-PRECOND
            file { '/cert.ca' : }
            file { '/cert.cert' : }
            file { '/cert.key' : }
          PRECOND
        end

        it { is_expected.to compile }
        # rubocop:disable Layout/LineLength
        it {
          is_expected.to contain_systemd__unit_file('test.service')
            .with_ensure('present')
            .with_enable(false)
            .with_active(false)
            .with_subscribe(['File[/cert.cert]', 'File[/cert.key]', 'File[/cert.ca]'])
            .with_content(%r{^User=test_user$})
            .with_content(%r{^Group=test_group$})
            .with_content(%r{^ExecStart=/some/command --verbose --web=/some/webroot --cert=/cert.cert --key=/cert.key --cafile=/cert.ca --ssl-only --token-plugin=TEST_TOKEN_PLUGIN --token-source=TEST_TOKEN_SOURCE 6480$})
        }
        # rubocop:enable Layout/LineLength
      end

      context 'with auth params but not ssl only' do
        let(:params) do
          {
            'websockify_command'        => '/my/command',
            'websockify_service_user'   => 'testuser',
            'websockify_service_group'  => 'testgroup',
            'websockify_service_name'   => 'testauth.service',
            'websockify_token_plugin'   => 'TOKEN_PLUGIN',
            'websockify_token_source'   => 'TOKEN_SOURCE',
            'websockify_auth_plugin'    => 'AUTH_PLUGIN',
            'websockify_auth_source'    => 'AUTH_SOURCE',
            'websockify_port'           => '127.0.0.1:2480',
            'websockify_webroot'        => '/this/webroot',
            'websockify_prefer_ipv6'    => true,
            'websockify_use_ssl'        => true,
            'websockify_use_ssl_only'   => false,
            'websockify_ssl_ca'         => '/tlscert.ca',
            'websockify_ssl_cert'       => '/tlscert.cert',
            'websockify_ssl_key'        => '/tlscert.key',
          }
        end

        let :pre_condition do
          <<-PRECOND
            file { '/tlscert.ca' : }
            file { '/tlscert.cert' : }
            file { '/tlscert.key' : }
          PRECOND
        end

        it { is_expected.to compile }
        # rubocop:disable Layout/LineLength
        it {
          is_expected.to contain_systemd__unit_file('testauth.service')
            .with_ensure('present')
            .with_enable(true)
            .with_active(true)
            .with_subscribe(['File[/tlscert.cert]', 'File[/tlscert.key]', 'File[/tlscert.ca]'])
            .with_content(%r{^User=testuser$})
            .with_content(%r{^Group=testgroup$})
            .with_content(%r{^ExecStart=/my/command --verbose --web=/this/webroot --prefer-ipv6 --cert=/tlscert.cert --key=/tlscert.key --cafile=/tlscert.ca --auth-plugin=AUTH_PLUGIN --auth-source=AUTH_SOURCE --token-plugin=TOKEN_PLUGIN --token-source=TOKEN_SOURCE 127.0.0.1:2480$})
        }
        # rubocop:enable Layout/LineLength
      end
    end
  end
end
