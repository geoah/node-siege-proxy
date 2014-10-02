node-siege-proxy
================

Basically proxies your http requests back to the original destination and logs any requests matching the provided hostname as siege requests or as curl.

## Examples

### Log all requests to locahost for use in siege.

    ./node_modules/coffee-script/bin/coffee app.coffee --output urls.txt --hostname localhost --port 3000

### Log all requests to localhost as curl.

    ./node_modules/coffee-script/bin/coffee app.coffee --output urls.txt --hostname localhost --port 3000 --curl