# frozen_string_literal: true

require 'spec_helper'

describe 'vnc::server::install' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'when using defaults' do
        it { is_expected.to compile }
        if os_facts[:os]['family'] == 'RedHat'
          it { is_expected.to contain_package('tigervnc-server').with_ensure('installed') }
          it { is_expected.to contain_package('tigervnc-server-module').with_ensure('installed') }
        elsif os_facts[:os]['family'] == 'Debian'
          it { is_expected.to contain_package('tigervnc-standalone-server').with_ensure('installed') }
          it { is_expected.to contain_package('tigervnc-xorg-extension').with_ensure('installed') }
        else
          it { is_expected.to have_package_resource_count(1) }
        end
      end

      context 'with no management' do
        let(:params) do
          {
            'manage_packages' => false,
          }
        end

        it { is_expected.to compile }
        it { is_expected.to have_package_resource_count(0) }
      end

      context 'with fun params' do
        let(:params) do
          {
            'manage_packages' => true,
            'packages' => ['asdf'],
            'packages_ensure' => 'latest',
          }
        end

        it { is_expected.to compile }
        it { is_expected.to have_package_resource_count(1) }
        it { is_expected.to contain_package('asdf').with_ensure('latest') }
      end
    end
  end
end
