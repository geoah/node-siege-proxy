fs = require("fs")
http = require("http")
url = require("url")
httpProxy = require("http-proxy")
querystring = require("querystring")
multiparty = require("multiparty")
curlify = require("request-as-curl")

# Make hostname filter, port and output params required
argv = require('optimist').usage('Usage: $0 --hostname [hostname filter] --port [port] --output [output file] --format [siege,raw,curl]').demand(['hostname','port','output','format']).argv

# Set up an http proxy
proxyServer = httpProxy.createProxyServer({})

# Create the http server
server = http.createServer (req, res) ->
  # Parse the URL
  urlObj = url.parse(req.url)

  # Create proxy target using the hostname provided in the URL
  # Since we just need to log the request it will just go on to the original destination
  target = "#{urlObj.protocol}//#{urlObj.host}"
  target = "#{target}:#{urlObtwbj.port}" if urlObj.port

  # We only care about logging specific requests
  appendToLog = if urlObj.host is argv.hostname then true else false

  # Handle request differently depending on the output format
  switch argv.format
    when "siege"
      # Just make sure that if there is a multipart form or upload we can handle it properly
      form = new multiparty.Form()
      form.parse req, (err, fields, files) ->
        # The body stream is complete
        body = querystring.stringify(fields)
        requestString = "#{req.url} #{req.method} #{body}"
        # Write to output file
        if appendToLog
          console.info "REQUEST: #{requestString}" 
          fs.appendFile(argv.output, "#{requestString}\n", "utf8")

    when "raw"
      # Keep original complete request body as req.rawBody
      body = ""
      req.on "data", (chunk) -> body += chunk
      req.on "end", ->
        requestString = "#{req.url} #{req.method} #{body}"
        # Write to output file
        if appendToLog
          console.info "REQUEST: #{requestString}" 
          fs.appendFile(argv.output, "#{requestString}\n", "utf8")
  
    when "curl"
      # Keep original complete request body as req.rawBody
      body = ""
      req.on "data", (chunk) -> body += chunk
      req.on "end", ->
        curlCmd = curlify(req)
        # There seems to be an issue with request-as-curl and normal http requests?
        # It appends the hostname to the url and we can't really use that.
        # TODO Maybe *I* am fucking something up here. 
        requestString = curlCmd.replace "curl '#{target}", "curl '"
        # Write to output file
        if appendToLog
          console.info "REQUEST: #{requestString}" 
          fs.appendFile(argv.output, "#{requestString}\n", "utf8")

  # Proxy the request to the original destination
  proxyServer.web req, res, target: target

# Start the http server to the given port
console.info "Listening on port #{argv.port}"
server.listen argv.port