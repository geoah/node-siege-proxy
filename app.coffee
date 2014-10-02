fs = require("fs")
http = require("http")
httpProxy = require("http-proxy")
argv = require('optimist').usage('Usage: $0 -t [target url] -p [port] -o [output]').demand(['t','p','o']).argv

proxy = httpProxy.createProxyServer({})

server = http.createServer (req, res) ->
  body = ""
  req.on "data", (chunk) -> body += chunk
  req.on "end", -> fs.appendFile(argv.o, "#{req.url} #{req.method} #{body}\n", "utf8")

  console.info "REQUEST: #{req.url} #{req.method} #{body}"

  proxy.web req, res, target: argv.t

console.info "Listening on port #{argv.p}"
server.listen argv.p