fs = require("fs")
http = require("http")
url = require("url")
exec = require("child_process").exec
exectimer = require("exectimer")

# Parse urls file
urls = fs.readFileSync("urls.txt").toString().split("\n")

reqs = 
  total: 0
  x2xx: 0
  s4xx: 0
  s5xx: 0

stats = ->
  timer = exectimer.timers.curl

  console.log "Number of requests: #{JSON.stringify(reqs)}"
  console.log "  average: " + timer.parse(timer.mean())
  console.log "  median: " + timer.parse(timer.median())
  console.log "  min: " + timer.parse(timer.min())

bench = (curlCmd) ->
  reqs.total += 1
  tick = new exectimer.Tick("curl")
  tick.start()
  child = exec(curlCmd, (error, stdout, stderr) ->
    tick.stop()
    reqs.x2xx += 1
    # console.log "stdout: " + stdout
    # console.log "stderr: " + stderr
    # console.log "exec error: " + error  if error isnt null
    stats() if reqs.total is reqs.x2xx
  )

bench url for url in urls

