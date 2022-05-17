class BaseController
  def initialize(env)
    self.env = env
  end

  def current_user
    User.find_by(id: session["id"])
  end

  def session
    get_cookie('_session_id')
  end

  def set_session(key, value)
    set_cookie('_session_id', key, value)
  end

  def get_cookie(cookie)
    return JSON.parse(cookies[cookie]) if cookies[cookie]

    {}
  end

  def set_cookie(cookie, key, value)
    cookies[cookie] = JSON.dump(get_cookie(cookie).merge(key => value))
  end

  def cookies
    @cookies ||= begin
      if env['HTTP_COOKIE']
        env['HTTP_COOKIE'].split('; ').map do |cookie|
          name, value = cookie.split('=', 2)
          [name, CGI.unescape(value)]
        end.to_h
      else
        {}
      end
    end
  end

  def params
    @params ||= params_from_query.merge(params_from_body)
  end

  def redirect_to(path)
    self.body = "<!DOCTYPE html><html><body>Redirecting to #{path}</body></html>"
    self.status = 302
    self.headers = {
      'Content-Type' => 'text/html',
      'Location' => "http://#{env['SERVER_NAME']}:#{env['SERVER_PORT']}#{path}",
    }.merge(cookie_headers)
  end

  def render(filename = nil, json: nil, status: 200)
    self.body = json || File.read("views/#{filename}")
    self.status = status
    self.headers = { 'Content-Type' => json ? 'application/json' : 'text/html' }.merge(cookie_headers)
  end

  def to_rack
    [status, headers, [body]]
  end

  private

  attr_accessor :status, :headers, :body, :env

  def params_from_body
    return {} unless env['rack.input']

    @params_from_body ||= env['rack.input'].read.yield_self do |query|
      case env['CONTENT_TYPE']
      when 'application/json'
        JSON.parse(query)
      else
        CGI.parse(query).transform_values!(&:first)
      end
    end
  end

  def params_from_query
    return {} unless env['QUERY_STRING'] && env['QUERY_STRING'] != ""

    @params_from_query ||= env['QUERY_STRING'].yield_self do |query|
      CGI.parse(query).transform_values!(&:first)
    end
  end

  def cookie_headers
    {
      'Set-Cookie' => cookies.map do |name, value|
        cookie_value = CGI.escape(value.to_s)
        expires = 1.hour.from_now.utc
        "#{name}=#{cookie_value}; Expires=#{expires}"
      end
    }
  end
end
