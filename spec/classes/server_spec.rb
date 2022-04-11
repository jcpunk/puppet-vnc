# frozen_string_literal: true

require 'spec_helper'

describe 'vnc::server' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      # it { pp catalogue.resources }
      it { is_expected.to compile }
      it { is_expected.to contain_class('vnc::server::install') }
      it { is_expected.to contain_class('vnc::server::config').that_requires('Class[vnc::server::install]') }
      it { is_expected.to contain_class('vnc::server::service').that_requires('Class[vnc::server::config]') }
    end
  end
end
