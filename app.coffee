fs = require("fs")
http = require("http")
url = require("url")
httpProxy = require("http-proxy")
querystring = require("querystring")
multiparty = require("multiparty")

# Make hostname filter, port and output params required
argv = require('optimist').usage('Usage: $0 -h [hostname filter] -p [port] -o [output]').demand(['h','p','o']).argv

# Set up an http proxy
proxy = httpProxy.createProxyServer({})

# Create the http server
server = http.createServer (req, res) ->
  # Parse the URL
  urlObj = url.parse(req.url)

  # Create proxy target using the hostname provided in the URL
  # Since we just need to log the request it will just go on to the original destination
  target = "#{urlObj.protocol}//#{urlObj.host}"
  target = "#{target}:#{urlObtwbj.port}" if urlObj.port

  # We only care about logging specific requests
  appendToLog = if urlObj.host is argv.h then true else false

  # Just make sure that if there is a multipart form or upload we can handle it properly
  form = new multiparty.Form()
  form.parse req, (err, fields, files) ->
    # Once the body is complete log the request if the hostname has been matched
    body = querystring.stringify(fields)
    console.info "REQUEST: #{req.url} #{req.method} #{body}" if appendToLog
    fs.appendFile(argv.o, "#{req.url} #{req.method} #{body}\n", "utf8") if appendToLog

  # Finally proxy the request to the original destination
  proxy.web req, res, target: target

# Start the http server to the given port
console.info "Listening on port #{argv.p}"
server.listen argv.p