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
      attrs = {
        :ip => ip_address.to_s.gsub(/</, "&lt;"),
        :result => ip_address ? Resolv.new.getname(ip_address) : nil
      }
      content = TEMPLATE % attrs
      [200, {"Content-Type" => "text/html"}, [content]]
    }
  end
end
