# frozen_string_literal: true

require 'spec_helper'

describe 'vnc::server::export::novnc' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'when using defaults' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('novnc') }
      end

      context 'with interesting arguments' do
        let(:params) do
          {
            'vnc_servers' => {
              'userA' => {
                'comment' => 'a comment',
                'displaynumber' => 1,
                'user_can_manage' => true,
              },
              'userB' => {
                'comment' => 'a different comment',
                'displaynumber' => 12,
                'user_can_manage' => false,
              },
            }
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('novnc') }
        it {
          is_expected.to contain_file('/etc/websockify/tokens.cfg')
            .with_ensure('file')
            .with_owner('root')
            .with_group('novnc')
            .with_mode('0640')
            .with_content(%r{4392d73e: localhost:5901})
            .with_content(%r{a79614aa: localhost:5912})
        }
        it {
          is_expected.to contain_file('/var/www/novnc_users_list.html')
        }
      end
    end
  end
end
