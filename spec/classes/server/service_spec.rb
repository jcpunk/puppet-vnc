# frozen_string_literal: true

require 'spec_helper'

describe 'vnc::server::service' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'when using defaults' do
        it { is_expected.to compile }
        it { is_expected.to have_service_resource_count(0) }
      end

      context 'with bad params' do
        let(:params) do
          {
            'manage_services' => true,
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
            'manage_services' => false,
          }
        end

        it { is_expected.to have_service_resource_count(0) }
      end

      context 'with rich params' do
        let(:params) do
          {
            'manage_services' => true,
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
                'enable' => false,
                'ensure' => 'stopped',
              },
            },
          }
        end

        it { is_expected.to compile }
        it { is_expected.to have_service_resource_count(2) }
        it {
          is_expected.to contain_service('vncserver@:1.service')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('vncserver@:2.service')
            .with_ensure('stopped')
            .with_enable(false)
        }
      end
    end
  end
end
