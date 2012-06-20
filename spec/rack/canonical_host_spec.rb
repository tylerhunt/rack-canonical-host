require 'spec_helper'

describe Rack::CanonicalHost do
  context '#call' do
    let(:requested_uri) { URI.parse('http://myapp.com/test/path') }
    let(:env) { Rack::MockRequest.env_for(requested_uri.to_s) }
    let(:response) { stack(requested_uri.host).call(env) }

    subject { response }

    context 'with a request to a matching host' do
      it { should_not redirect }

      it 'calls up the stack with the received env' do
        parent_app.should_receive(:call).with(env).and_return(parent_response)
        subject
      end
    end

    context 'with a request to a non-matching host' do
      let(:response) { stack('new-host.com').call(env) }

      context 'but the new-host is set in the ignored options' do
        let(:response) { stack('new-host.com', { ignored_hosts: ["myapp.com"] }).call(env) }

        it { should_not redirect }

        it 'calls up the stack with the received env' do
          parent_app.should_receive(:call).with(env).and_return(parent_response)
          subject
        end
      end

      context 'and the new-host is not set in the ignored options' do
        it { should redirect.via(301) }
        it { should redirect.to('http://new-host.com/test/path') }

        it 'does not call further up the stack' do
          parent_app.should_receive(:call).never
          subject
        end
      end

    end

    context 'when initialized with a block' do
      let(:block) { Proc.new { |env| "block-host.com" } }
      let(:response) { stack(&block).call(env) }

      context 'with a request to a host matching the block result' do
        let(:requested_uri) { URI.parse('http://block-host.com') }

        it { should_not redirect }

        it 'calls up the stack with the received env' do
          parent_app.should_receive(:call).with(env).and_return(parent_response)
          subject
        end
      end

      context 'with a request host that does not match the block result' do
        let(:requested_uri) { URI.parse('http://block-host.com') }
        let(:env) { Rack::MockRequest.env_for('http://different-host.com/path') }

        it { should redirect.via(301) }
        it { should redirect.to('http://block-host.com/path') }

        it 'does not call further up the stack' do
          parent_app.should_receive(:call).never
          subject
        end
      end
    end
  end


  private


  def parent_response
    [200, {'Content-Type' => 'text/plain'}, 'Success']
  end

  def parent_app
    @parent_app ||= Proc.new { |env| parent_response }
  end

  def stack(host = nil, options={}, p = parent_app, &block)
    Rack::Builder.new do
      use Rack::Lint
      use Rack::CanonicalHost, host, options, &block
      run p
    end
  end
end
