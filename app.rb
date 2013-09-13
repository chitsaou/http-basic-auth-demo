require 'sinatra/base'

class BasicApp < Sinatra::Base
  enable :logging

  helpers do
    def logger
      request.logger
    end

    def authenticate!(realm, username, password)
      return if authorized?(username, password)
      www_authenticate = "Basic"
      www_authenticate += " realm=\"#{realm}\""
      headers['WWW-Authenticate'] = www_authenticate
      halt 401, "Unauthorized\n"
    end

    def authorized?(username, password)
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      if @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == [username, password]
        true
      else
        logger.info "Auth failed while accessing #{request.path}."
        if @auth.provided?
          logger.info "Credentials: #{@auth.credentials}"
        else
          logger.info "No Credentials"
        end
        false
      end
    end
  end
end

module Protected
  class A1 < BasicApp
    get '/' do
      authenticate! "Protected A", "abc", "a1"
      "secret A1"
    end
  end

  class A2 < BasicApp
    get '/' do
      authenticate! "Protected A", "abc", "a2"
      "secret A2"
    end
  end

  class B < BasicApp
    get '/' do
      authenticate! "Protected B", "abc", "b"
      "secret B"
    end
  end
end

class Public < Sinatra::Base
  get '/' do
    "public :)"
  end
end
