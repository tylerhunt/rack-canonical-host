RSpec.describe Rack::CanonicalHost do
  let(:app_response) { [200, { 'content-type' => 'text/plain' }, %w(OK)] }
  let(:inner_app) { ->(env) { app_response } }

  def build_app(host=nil, options={}, inner_app=inner_app(), &block)
    Rack::Builder.new do
      use Rack::Lint
      use Rack::CanonicalHost, host, options, &block
      run inner_app
    end
  end

  shared_examples 'a matching request' do
    context 'with a request to a matching host' do
      it { should_not be_redirect }

      it 'calls the inner app' do
        expect(inner_app).to receive(:call).with(env).and_call_original
        call_app
      end
    end
  end

  shared_examples 'a non-matching request' do
    context 'with a request to a non-matching host' do
      it { should redirect_to('http://example.com/full/path') }

      it 'does not call the inner app' do
        expect(inner_app).to_not receive(:call)
        call_app
      end

      it { expect(response).to_not have_header('cache-control') }
    end
  end

  context '#call' do
    let(:url) { 'http://example.com/full/path' }
    let(:headers) { {} }

    let(:app) { build_app('example.com') }
    let(:env) { Rack::MockRequest.env_for(url, headers) }

    def call_app
      app.call(env)
    end

    subject(:response) { call_app }

    it_behaves_like 'a matching request'

    it_behaves_like 'a non-matching request' do
      let(:url) { 'http://www.example.com/full/path' }
    end

    context 'when the request has a pipe in the URL' do
      let(:url) { 'https://example.com/full/path?value=withPIPE' }

      before do
        env['QUERY_STRING'].sub!('PIPE', '|')
      end

      it { expect { call_app }.to_not raise_error }
    end

    context 'when the request has JavaScript in the URL' do
      let(:url) { 'http://www.example.com/full/path' }

      let(:app) { build_app('example.com') }

      it 'escapes the JavaScript' do
        allow_any_instance_of(Rack::Request)
          .to receive(:query_string)
          .and_return('"><script>alert(73541);</script>')

        expect(response)
          .to redirect_to('http://example.com/full/path?%22%3E%3Cscript%3Ealert(73541)%3B%3C/script%3E')
      end
    end

    context 'when the app raises an invalid URI error' do
      let(:inner_app) { ->(env) { raise Addressable::URI::InvalidURIError } }

      it 'raises the error' do
        expect { call_app }.to raise_error Addressable::URI::InvalidURIError
      end
    end

    context 'with an X-Forwarded-Host' do
      let(:url) { 'http://proxy.test/full/path' }

      context 'which matches the canonical host' do
        let(:headers) { { 'HTTP_X_FORWARDED_HOST' => 'example.com:80' } }

        it_behaves_like 'a matching request'
      end

      context 'which does not match the canonical host' do
        let(:headers) { { 'HTTP_X_FORWARDED_HOST' => 'www.example.com:80' } }

        it_behaves_like 'a non-matching request'
      end

      context 'which is an invalid uri' do
        let(:headers) { { 'HTTP_X_FORWARDED_HOST' => '[${jndi:ldap://172.16.26.190:52314/nessus}]/' } }

        it { should_not be_redirect }

        it { expect(response[0]).to be 400 }

        it 'does not call the inner app' do
          expect(inner_app).to_not receive(:call)
          call_app
        end

        it { expect(response).to_not have_header('cache-control') }
      end
    end

    context 'without a host' do
      let(:app) { build_app(nil) }

      it_behaves_like 'a matching request'
    end

    context 'with :ignore option' do
      context 'with lambda/proc' do
        let(:app) {
          build_app(
            'example.com',
            ignore: ->(uri) { uri.host == 'example.net' }
          )
        }

        it_behaves_like 'a matching request'

        it_behaves_like 'a non-matching request' do
          let(:url) { 'http://www.example.com/full/path' }
        end

        context 'with a request to an ignored host' do
          let(:url) { 'http://example.net/full/path' }

          it { should_not be_redirect }

          it 'calls the inner app' do
            expect(inner_app).to receive(:call).with(env).and_call_original
            call_app
          end
        end
      end

      context 'with string' do
        let(:app) { build_app('example.com', ignore: 'example.net') }

        it_behaves_like 'a matching request'

        it_behaves_like 'a non-matching request' do
          let(:url) { 'http://www.example.com/full/path' }
        end

        context 'with a request to an ignored host' do
          let(:url) { 'http://example.net/full/path' }

          it { should_not be_redirect }

          it 'calls the inner app' do
            expect(inner_app).to receive(:call).with(env).and_call_original
            call_app
          end
        end
      end

      context 'with regular expression' do
        let(:app) { build_app('example.com', ignore: /ex.*\.net/) }

        it_behaves_like 'a matching request'

        it_behaves_like 'a non-matching request' do
          let(:url) { 'http://www.example.com/full/path' }
        end

        context 'with a request to an ignored host' do
          let(:url) { 'http://example.net/full/path' }

          it { should_not be_redirect }

          it 'calls the inner app' do
            expect(inner_app).to receive(:call).with(env).and_call_original
            call_app
          end
        end
      end
    end

    context 'with :if option' do
      context 'with a lambda/proc' do
        let(:app) {
          build_app(
            'www.example.com',
            if: ->(uri) { uri.host == 'example.com' }
          )
        }

        context 'with a request to a matching host' do
          let(:url) { 'http://example.com/full/path' }

          it { should redirect_to('http://www.example.com/full/path') }
        end

        context 'with a request to a non-matching host' do
          let(:url) { 'http://api.example.com/full/path' }

          it { should_not be_redirect }
        end
      end

      context 'with string' do
        let(:app) { build_app('www.example.com', if: 'example.com') }

        context 'with a request to a matching host' do
          let(:url) { 'http://example.com/full/path' }

          it { should redirect_to('http://www.example.com/full/path') }
        end

        context 'with a request to a non-matching host' do
          let(:url) { 'http://api.example.com/full/path' }

          it { should_not be_redirect }
        end
      end

      context 'with a regular expression' do
        let(:app) { build_app('example.com', if: '.*\.example\.com') }

        context 'with a request to a matching host' do
          let(:url) { 'http://www.example.com/full/path' }

          it { should_not redirect_to('http://example.com/full/path') }
        end

        context 'with a request to a non-matching host' do
          let(:url) { 'http://www.example.net/full/path' }

          it { should_not be_redirect }
        end
      end
    end

    context 'with a :cache_control option' do
      let(:url) { 'http://subdomain.example.net/full/path' }

      context 'with a max-age value' do
        let(:app) {
          build_app('example.com', cache_control: 'max-age=3600')
        }

        it {
          expect(response).to have_header('cache-control').with('max-age=3600')
        }
      end

      context 'with a no-cache value' do
        let(:app) { build_app('example.com', cache_control: 'no-cache') }

        it { expect(subject).to have_header('cache-control').with('no-cache') }
      end

      context 'with a false value' do
        let(:app) { build_app('example.com', cache_control: false) }

        it { expect(subject).to_not have_header('cache-control') }
      end

      context 'with a nil value' do
        let(:app) { build_app('example.com', cache_control: false) }

        it { expect(subject).to_not have_header('cache-control') }
      end
    end

    context 'with a block' do
      let(:app) { build_app { 'example.com' } }

      it_behaves_like 'a matching request'

      it_behaves_like 'a non-matching request' do
        let(:url) { 'http://www.example.com/full/path' }
      end

      context 'that returns nil' do
        let(:app) { build_app('example.com') { nil } }

        it_behaves_like 'a matching request'

        it_behaves_like 'a non-matching request' do
          let(:url) { 'http://www.example.com/full/path' }
        end
      end
    end
  end
end
