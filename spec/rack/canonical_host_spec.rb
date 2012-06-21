require 'spec_helper'

describe Rack::CanonicalHost do
  let(:response) { [200, { 'Content-Type' => 'text/plain' }, 'OK'] }
  let(:inner_app) { lambda { |env| response } }

  def build_app(host=nil, options={}, inner_app=inner_app, &block)
    Rack::Builder.new do
      use Rack::Lint
      use Rack::CanonicalHost, host, options, &block
      run inner_app
    end
  end

  shared_context 'matching and non-matching requests' do
    context 'with a request to a matching host' do
      let(:url) { 'http://example.com/full/path' }

      it { should_not be_redirect }

      it 'calls the inner app' do
        inner_app.should_receive(:call).with(env).and_return(response)
        subject
      end
    end

    context 'with a request to a non-matching host' do
      let(:url) { 'http://www.example.com/full/path' }

      it { should be_redirect.via(301).to('http://example.com/full/path') }

      it 'does not call the inner app' do
        inner_app.should_not_receive(:call)
        subject
      end
    end
  end

  context '#call' do
    let(:env) { Rack::MockRequest.env_for(url) }

    subject { app.call(env) }

    context 'without any options' do
      let(:app) { build_app('example.com') }

      include_context 'matching and non-matching requests'
    end

    context 'with :ignore option' do
      let(:app) { build_app('example.com', :ignore => ['example.net']) }

      include_context 'matching and non-matching requests'

      context 'with a request to an ignored host' do
        let(:url) { 'http://example.net/full/path' }

        it { should_not be_redirect }

        it 'calls the inner app' do
          inner_app.should_receive(:call).with(env).and_return(response)
          subject
        end
      end
    end

    context 'with a block' do
      let(:app) { build_app { 'example.com' } }

      include_context 'matching and non-matching requests'

      context 'that returns nil' do
        let(:app) { build_app('example.com') { nil } }

        include_context 'matching and non-matching requests'
      end
    end
  end
end
