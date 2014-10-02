fs = require("fs")
http = require("http")
httpProxy = require("http-proxy")
querystring = require("querystring")
multiparty = require("multiparty")

argv = require('optimist').usage('Usage: $0 -t [target url] -p [port] -o [output]').demand(['t','p','o']).argv

proxy = httpProxy.createProxyServer({})

server = http.createServer (req, res) ->
  form = new multiparty.Form()
  form.parse req, (err, fields, files) ->
    body = querystring.stringify(fields)
    console.info "REQUEST: #{req.url} #{req.method} #{body}"
    fs.appendFile(argv.o, "#{req.url} #{req.method} #{body}\n", "utf8")

  proxy.web req, res, target: argv.t

console.info "Listening on port #{argv.p}"
server.listen argv.p