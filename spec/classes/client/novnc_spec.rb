# frozen_string_literal: true

require 'spec_helper'

describe 'vnc::client::novnc' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_class('vnc::client::novnc::install') }
      it { is_expected.to contain_class('vnc::client::novnc::config').that_requires('Class[vnc::client::novnc::install]') }
      it { is_expected.to contain_class('vnc::client::novnc::config').that_notifies('Class[vnc::client::novnc::service]') }
      it { is_expected.to contain_class('vnc::client::novnc::install').that_notifies('Class[vnc::client::novnc::service]') }
    end
  end
end
