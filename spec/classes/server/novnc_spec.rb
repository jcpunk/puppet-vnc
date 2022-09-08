# frozen_string_literal: true

require 'spec_helper'

describe 'vnc::server::novnc' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_class('vnc::server::novnc::install') }
      it { is_expected.to contain_class('vnc::server::novnc::config').that_requires('Class[vnc::server::novnc::install]') }
      it { is_expected.to contain_class('vnc::server::novnc::config').that_notifies('Class[vnc::server::novnc::service]') }
      it { is_expected.to contain_class('vnc::server::novnc::install').that_notifies('Class[vnc::server::novnc::service]') }
    end
  end
end
