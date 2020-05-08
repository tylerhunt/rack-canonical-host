RSpec.describe Rack::CanonicalHost do
  let(:app_response) { [200, { 'Content-Type' => 'text/plain' }, %w(OK)] }
  let(:inner_app) { lambda { |env| response } }

  before do
    allow(inner_app)
      .to receive(:call)
      .with(env)
      .and_return(app_response)
  end

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
        expect(inner_app).to receive(:call).with(env)
        call_app
      end
    end
  end

  shared_context 'a non-matching request' do
    context 'with a request to a non-matching host' do
      let(:url) { 'http://www.example.com/full/path' }

      it { should redirect_to('http://example.com/full/path') }

      it 'does not call the inner app' do
        expect(inner_app).to_not receive(:call)
        call_app
      end

      it { expect(response).to_not have_header('Cache-Control') }
    end
  end

  shared_context 'matching and non-matching requests' do
    include_context 'a matching request'
    include_context 'a non-matching request'
  end

  context '#call' do
    let(:headers) { {} }

    let(:app) { build_app('example.com') }
    let(:env) { Rack::MockRequest.env_for(url, headers) }

    def call_app
      app.call(env)
    end

    subject(:response) { call_app }

    include_context 'a matching request'
    include_context 'a non-matching request'

    context 'when the request has a pipe in the URL' do
      let(:url) { 'https://example.com/full/path?value=withPIPE' }

      before { env['QUERY_STRING'].sub!('PIPE', '|') }

      it { expect { call_app }.to_not raise_error }
    end

    context 'when the request has JavaScript in the URL' do
      let(:url) { 'http://www.example.com/full/path' }

      let(:headers) {
        { 'QUERY_STRING' => '"><script>alert(73541);</script>' }
      }

      let(:app) { build_app('example.com') }

      it 'escapes the JavaScript' do
        expect(response)
          .to redirect_to('http://example.com/full/path?%22%3E%3Cscript%3Ealert(73541)%3B%3C/script%3E')
      end
    end

    context 'with an X-Forwarded-Host' do
      let(:url) { 'http://proxy.test/full/path' }

      context 'which matches the canonical host' do
        let(:headers) { { 'HTTP_X_FORWARDED_HOST' => 'example.com:80' } }

        include_context 'a matching request'
      end

      context 'which does not match the canonical host' do
        let(:headers) { { 'HTTP_X_FORWARDED_HOST' => 'www.example.com:80' } }

        include_context 'a non-matching request'
      end
    end

    context 'without a host' do
      let(:app) { build_app(nil) }

      include_context 'a matching request'
    end

    context 'with :ignore option' do
      context 'with string' do
        let(:app) { build_app('example.com', :ignore => 'example.net') }

        include_context 'a matching request'
        include_context 'a non-matching request'

        context 'with a request to an ignored host' do
          let(:url) { 'http://example.net/full/path' }

          it { should_not be_redirect }

          it 'calls the inner app' do
            expect(inner_app).to receive(:call).with(env)
            call_app
          end
        end
      end

      context 'with regular expression' do
        let(:app) { build_app('example.com', :ignore => /ex.*\.net/) }

        include_context 'a matching request'
        include_context 'a non-matching request'

        context 'with a request to an ignored host' do
          let(:url) { 'http://example.net/full/path' }

          it { should_not be_redirect }

          it 'calls the inner app' do
            expect(inner_app).to receive(:call).with(env)
            call_app
          end
        end
      end
    end

    context 'with :if option' do
      context 'with string' do
        let(:app) { build_app('www.example.com', :if => 'example.com') }

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
        let(:app) { build_app('example.com', :if => '.*\.example\.com') }

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
          build_app('example.com', :cache_control => 'max-age=3600')
        }

        it {
          expect(response).to have_header('Cache-Control').with('max-age=3600')
        }
      end

      context 'with a no-cache value' do
        let(:app) { build_app('example.com', :cache_control => 'no-cache') }

        it { expect(subject).to have_header('Cache-Control').with('no-cache') }
      end

      context 'with a false value' do
        let(:app) { build_app('example.com', :cache_control => false) }

        it { expect(subject).to_not have_header('Cache-Control') }
      end

      context 'with a nil value' do
        let(:app) { build_app('example.com', :cache_control => nil) }

        it { expect(subject).to_not have_header('Cache-Control') }
      end
    end

    context 'with a :temporary option' do
      let(:url) { 'http://subdomain.example.net/full/path' }

      context 'with a truthy value' do
        let(:app) { build_app('example.com', :temporary => true) }

        it 'should use a 307 redirect' do
          expect(response).
            to redirect_to('http://example.com/full/path').via(307)
        end
      end

      context 'with a false value' do
        let(:app) { build_app('example.com', :temporary => false) }

        it 'should use a 301 redirect' do
          expect(response).
            to redirect_to('http://example.com/full/path').via(301)
        end
      end

      context 'with a nil value' do
        let(:app) { build_app('example.com', :temporary => nil) }

        it 'should use a 301 redirect' do
          expect(response).
            to redirect_to('http://example.com/full/path').via(301)
        end
      end
    end

    context 'with :append option' do
      let(:app) { build_app('example.com', :append => true) }

      context 'with matching request' do
        let(:url) { 'http://example.com/path?query=1' }
        it { should_not be_redirect }
      end

      context 'with non-matching request' do
        let(:url) { 'http://subdomain.example.net/path?query=1' }

        it 'should add the original domain as a query param' do
          expect(response).
            to redirect_to(/http:\/\/example\.com\/path\?.+/)

          expect(response).to have_query_params({
            'original_host' => 'subdomain.example.net',
            'query' => '1'
          })
        end
      end
    end

    context 'with a :prefix option' do
      [
        true,
        :subdomain
      ].each do |value|
        context "with #{value.is_a?(Symbol) ? ':' : ''}#{value} value" do
          context 'with subdomain' do
            let(:url) { 'http://subdomain.example.net/path?query=1' }

            let(:app) { build_app('example.com', :prefix => value) }

            it 'should prepend the subdomain to the path' do
              expect(response).
                to redirect_to('http://example.com/subdomain/path?query=1')
            end

            context 'with multilevel TLD' do
              let(:url) { 'http://multi.example.co.uk/path?query=1' }

              it 'should treat the TLD correctly and prepend the subdomain' do
                expect(response).
                  to redirect_to('http://example.com/multi/path?query=1')
              end
            end

            context 'with multilevel subdomain' do
              let(:url) { 'http://a.b.c.example.net/path?query=1' }

              it 'should prepend each subdomain in order from top to bottom' do
                expect(response).
                  to redirect_to('http://example.com/c/b/a/path?query=1')
              end

              context 'with :separator option' do
                context 'unencoded' do
                  let(:app) {
                    build_app('example.com', :prefix => value, separator: '|')
                  }
                  it 'should separate each subdomain with a URL encoded separator' do
                    expect(response).
                    to redirect_to('http://example.com/c%7Cb%7Ca/path?query=1')
                  end
                end

                context 'encoded' do
                  let(:app) {
                    build_app('example.com', :prefix => value, separator: '%7C')
                  }

                  it 'should separate each subdomain with the given encoded separator' do
                    expect(response).
                    to redirect_to('http://example.com/c%7Cb%7Ca/path?query=1')
                  end
                end
              end

              context 'with multilevel TLD' do
                let(:url) { 'http://a.b.c.example.co.uk/path?query=1' }

                it 'should prepend the correct subdomains' do
                  expect(response).
                    to redirect_to('http://example.com/c/b/a/path?query=1')
                end
              end
            end
          end

          context 'without subdomain' do
            let(:url) { 'http://example.net/path?query=1' }

            it { should redirect_to('http://example.com/path?query=1') }
          end

          context 'without hostname' do
            let(:url) { '/path?query=1' }

            it { should redirect_to('http://example.com/path?query=1') }
          end
        end
      end

      context "with :bottom_to_top value" do
        context 'with subdomain' do
          let(:url) { 'http://subdomain.example.net/path?query=1' }

          let(:app) { build_app('example.com', :prefix => :bottom_to_top) }

          it 'should prepend the subdomain to the path' do
            expect(response).
              to redirect_to('http://example.com/subdomain/path?query=1')
          end

          context 'with multilevel TLD' do
            let(:url) { 'http://multi.example.co.uk/path?query=1' }

            it 'should treat the TLD correctly and prepend the subdomain' do
              expect(response).
                to redirect_to('http://example.com/multi/path?query=1')
            end
          end

          context 'with multilevel subdomain' do
            let(:url) { 'http://a.b.c.example.net/path?query=1' }

            it 'should prepend each subdomain ordered from bottom to top' do
              expect(response).
                to redirect_to('http://example.com/a/b/c/path?query=1')
            end

            context 'with multilevel TLD' do
              let(:url) { 'http://a.b.c.example.co.uk/path?query=1' }

              it 'should prepend the correct subdomains' do
                expect(response).
                  to redirect_to('http://example.com/a/b/c/path?query=1')
              end
            end
          end
        end

        context 'without subdomain' do
          let(:url) { 'http://example.net/path?query=1' }

          it { should redirect_to('http://example.com/path?query=1') }
        end

        context 'without hostname' do
          let(:url) { '/path?query=1' }

          it { should redirect_to('http://example.com/path?query=1') }
        end
      end

      context 'with a string' do
        context 'with non-matching request' do
          let(:url) { 'http://subdomain.example.net/path?query=1' }

          context 'with trailing slash' do
            let(:app) { build_app('example.com', :prefix => 'prefix/') }

            it { should redirect_to('http://example.com/prefix/path?query=1') }
          end

          context 'with preceding slash' do
            let(:app) { build_app('example.com', :prefix => '/prefix') }

            it { should redirect_to('http://example.com/prefix/path?query=1') }
          end

          context 'with no slash' do
            let(:app) { build_app('example.com', :prefix => 'prefix') }

            it { should redirect_to('http://example.com/prefix/path?query=1') }
          end

          context 'with an empty value' do
            context 'with slash' do
              let(:app) { build_app('example.com', :prefix => '/') }

              it { should redirect_to('http://example.com/path?query=1') }
            end

            context 'with no slash' do
              let(:app) { build_app('example.com', :prefix => '') }

              it { should redirect_to('http://example.com/path?query=1') }
            end
          end
        end

        context 'with matching request' do
          let(:url) { 'http://example.com/path?query=1' }

          let(:app) { build_app('example.com', :prefix => 'prefix') }

          it { should_not be_redirect }
        end


        context 'without hostname' do
          let(:url) { '/path?query=1' }

          let(:app) { build_app('example.com', :prefix => 'prefix') }

          it { should redirect_to('http://example.com/prefix/path?query=1') }
        end
      end

      context 'with a false value' do
        let(:url) { 'http://subdomain.example.net/path?query=1' }

        let(:app) { build_app('example.com', :prefix => false) }

        it { should redirect_to('http://example.com/path?query=1') }
      end

      context 'with a nil value' do
        let(:url) { 'http://subdomain.example.net/path?query=1' }

        let(:app) { build_app('example.com', :prefix => nil) }

        it { should redirect_to('http://example.com/path?query=1') }
      end
    end

    context 'with a block' do
      let(:app) { build_app { 'example.com' } }

      include_context 'a matching request'
      include_context 'a non-matching request'

      context 'that returns nil' do
        let(:app) { build_app('example.com') { nil } }

        include_context 'a matching request'
        include_context 'a non-matching request'
      end
    end
  end
end
