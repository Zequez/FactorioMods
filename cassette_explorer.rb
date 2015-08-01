require 'webrick'
require 'yaml'

port = 2332
cassettes_dir = './spec/fixtures/vcr_cassettes/'
replace_relative_url = true

files = Dir["#{cassettes_dir}**/**"]

pages = {}
index = {}

files.each do |file|
  unless File.directory? file
    file_name = file.gsub(cassettes_dir, '')
    index[file_name] = []
    data = YAML.load_file(file)
    if data['http_interactions']
      data['http_interactions'].each do |interaction|
        uri = URI.parse(interaction['request']['uri'])
        body = interaction['response']['body']['string']
        if replace_relative_url
          base_path = uri.scheme + '://' + uri.host + uri.path.sub(/[^\/]+$/, '')
          body = body
            .gsub('href="./', "href=\"#{base_path}")
            .gsub('src="./', "src=\"#{base_path}")
        end

        pages[uri.to_s] = body
        index[file_name].push interaction['request']
      end
    end
  end
end

server = WEBrick::HTTPServer.new Port: port
server.mount_proc '/' do |req, res|
  if ( page = req.query["page"] )
    res.body = pages[page]
  else
    body = '<html><head><title>List of pages</title></head><body>'
    index.each do |key, requests|
      body += "<h3>#{key}</h3><ul>"
      requests.each do |request|
        uri = request['uri']
        escaped_url = CGI.escape(uri)
        body += "<li>"
        body += request['method'].upcase
        body += " <a href='./?page=#{escaped_url}'>#{uri}</a>"
        body += "</li>"
      end
      body += "</ul>"
    end
    body += '</body></html>'
    res.body = body
  end
end
server.start
