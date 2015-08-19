require 'spec_helper'

describe Rack::CanonicalHost do
  let(:response) { [200, { 'Content-Type' => 'text/plain' }, ['OK']] }
  let(:inner_app) { lambda { |env| response } }

  def build_app(host=nil, options={}, inner_app=inner_app(), &block)
    Rack::Builder.new do
      use Rack::Lint
      use Rack::CanonicalHost, host, options, &block
      run inner_app
    end
  end

  shared_context 'a matching request' do
    context 'with a request to a matching host' do
      let(:url) { 'http://example.com/full/path' }

      it { should_not be_redirect }

      it 'calls the inner app' do
        expect(inner_app).to receive(:call).with(env).and_return(response)
        subject
      end
    end
  end

  shared_context 'a non-matching request' do
    context 'with a request to a non-matching host' do
      let(:url) { 'http://www.example.com/full/path' }

      it { should be_redirect.via(301).to('http://example.com/full/path') }

      it 'does not call the inner app' do
        expect(inner_app).to_not receive(:call)
        subject
      end
    end
  end

  shared_context 'matching and non-matching requests' do
    include_context 'a matching request'
    include_context 'a non-matching request'
  end

  context '#call' do
    let(:env) { Rack::MockRequest.env_for(url) }

    subject { app.call(env) }

    context 'without a host' do
      let(:app) { build_app(nil) }

      include_context 'a matching request'
    end

    context 'with an X-Forwarded-Host' do
      let(:app) { build_app('example.com') }
      let(:url) { 'http://proxied.url/full/path' }

      context 'which matches the canonical host' do
        let(:env) { Rack::MockRequest.env_for(url, 'HTTP_X_FORWARDED_HOST' => 'example.com:80') }

        include_context 'a matching request'
      end

      context 'which does not match the canonical host' do
        let(:env) { Rack::MockRequest.env_for(url, 'HTTP_X_FORWARDED_HOST' => 'www.example.com:80') }

        include_context 'a non-matching request'
      end
    end

    context 'without any options' do
      let(:app) { build_app('example.com') }

      include_context 'matching and non-matching requests'

      context 'when the request has a pipe in the URL' do
        let(:url) { 'https://example.com/full/path?value=withPIPE' }

        before { env['QUERY_STRING'].sub!('PIPE', '|') }

        it { expect { subject }.to_not raise_error }
      end
    end

    context 'with :ignore option' do
      let(:app) { build_app('example.com', :ignore => 'example.net') }

      include_context 'matching and non-matching requests'

      context 'with a request to an ignored host' do
        let(:url) { 'http://example.net/full/path' }

        it { should_not be_redirect }

        it 'calls the inner app' do
          expect(inner_app).to receive(:call).with(env).and_return(response)
          subject
        end
      end
    end

    context 'with :if option' do

      let(:app) { build_app('example.com', :if => 'www.example.net') }

      context 'with a request to a :if matching host' do
        let(:url) { 'http://www.example.net/full/path' }
        it { should be_redirect.to('http://example.com/full/path') }
      end

      context 'with a request to a :if non-matching host' do
        let(:url) { 'http://www.sexample.net/full/path' }
        it { should_not be_redirect }
      end

    end

    context 'with :if and regexp as an option' do

      let(:app) { build_app('example.com', :if => /.*\.example\.net/) }

      context 'with a request to a :if matching host' do
        let(:url) { 'http://subdomain.example.net/full/path' }
        it { should be_redirect.to('http://example.com/full/path') }
      end

      context 'with a request to a :if non-matching host' do
        let(:url) { 'http://example.net/full/path' }
        it { should_not be_redirect }
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

    context 'with URL containing JavaScript XSS' do
      let(:url) { 'http://subdomain.example.net/full/path' }
      let(:env) do
        Rack::MockRequest.env_for(url).tap do |env|
          env['QUERY_STRING'] = '"><script>alert(73541);</script>'
        end
      end

      let(:app) { build_app('example.com') }

      it { should be_redirect.to('http://example.com/full/path?%22%3E%3Cscript%3Ealert(73541)%3B%3C/script%3E') }
    end
  end
end
