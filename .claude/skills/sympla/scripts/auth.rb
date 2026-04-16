require 'net/http'
require 'uri'
require 'json'

SYMPLA_API = 'https://api.sympla.com.br/public/v3'

def sympla_token
  # 1. ENV variable
  return ENV['SYMPLA_TOKEN'] if ENV['SYMPLA_TOKEN'] && !ENV['SYMPLA_TOKEN'].empty?

  # 2. ~/.sympla/config.json
  config_path = File.expand_path('~/.sympla/config.json')
  if File.exist?(config_path)
    config = JSON.parse(File.read(config_path)) rescue {}
    token = config['token']
    return token if token && !token.empty?
  end

  nil
end

def sympla_request(method, path, body: nil, params: nil)
  token = sympla_token
  unless token
    $stderr.puts 'SETUP_NEEDED'
    exit 1
  end

  url = URI("#{SYMPLA_API}#{path}")
  url.query = URI.encode_www_form(params) if params && !params.empty?

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.read_timeout = 30
  http.open_timeout = 10

  req = case method.to_s.upcase
        when 'GET'    then Net::HTTP::Get.new(url)
        when 'POST'   then Net::HTTP::Post.new(url)
        when 'PATCH'  then Net::HTTP::Patch.new(url)
        when 'DELETE' then Net::HTTP::Delete.new(url)
        else raise "Unknown method: #{method}"
        end

  req['s_token']      = token
  req['Content-Type'] = 'application/json'

  req.body = body.is_a?(String) ? body : JSON.generate(body) if body

  resp = http.request(req)

  unless resp.code.to_i.between?(200, 299)
    $stderr.puts "HTTP #{resp.code}: #{resp.body}"
    exit 1
  end

  resp.body.empty? ? {} : JSON.parse(resp.body)
end
