require "json"
require "resolv"

require "bundler"
Bundler.setup(:default)
Bundler.require

TEMPLATE = <<-HTML
<!DOCTYPE html>
<html lang="en" dir="ltr">
  <head>
    <meta charset="UTF-8">
    <title>Resolve hostname</title>
  </head>

  <body>
    <form action="/">
      <p>
        <label>
          IP Address:
          <input type="text" value="%{ip}" name="ip" autofocus required>
          <input type="submit" value="Resolve">
        </label>
      </p>

      <p>
        %{result}
      </p>
    </form>
  </body>
</html>
HTML

App = Rack::Builder.app do
  map "/" do
    run proc {|env|
      request = Rack::Request.new(env)
      ip_address = request.params["ip"]
      format = request.params["format"]

      begin
        result = ip_address ? Resolv.new.getname(ip_address) : nil
      rescue Exception => error
        result = "Error: #{error.class} => #{error.message}"
      end

      attrs = {
        :ip => ip_address.to_s.gsub(/</, "&lt;"),
        :result => result
      }
      
      case format
      when 'json'
        content = attrs.to_json
        headers = {"Content-Type" => "application/json"}
      else
        content = TEMPLATE % attrs
        headers = {"Content-Type" => "text/html"}
      end
      
      [200, headers, [content]]
    }
  end
end
