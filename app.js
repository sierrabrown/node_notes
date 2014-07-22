// Module included to allow server creationg
var http = require('http'),
    url = require('url'),
    querystring = require('querystring');

//Another module provided by node (line above) allowing us to parse urls


//Returns server object
var server = http.createServer()

// When it receives an http request it'll build a request and response object.
// Then we call a callback telling it what to do.
server.on("request", function (req, res){
  //Let's take a look at the request parameters.
  //Right now this line will just echo the url: console.log(req.url)
  var parsedUrl = url.parse(req.url)
  var parsedQuery = querystring.parse(parsedUrl.query);
  res.write(JSON.stringify(parsedUrl));
  res.write("\n")
  res.write("\n")
  res.write(JSON.stringify(parsedQuery));
  res.write("This was HOT LOADED\n");
  //Unlike rails node doesn't know when you stop with the request so
  //finishing with end is necessary
  res.end();
})
//Starts server listening
server.listen(3000)

// now if we type node app.js, the server hangs waiting for stuff to happen
// browser windows will similarly freeze with the loading bar spinning

// No hot code loding out of the box
// Node demon will watch files and restart a script

// 1. Create server
// 2. Request handler
// 3. Using modules
// 4. Get request, send response back
// 5. Since every server needs a request handler you can pass in the server creation as a callback