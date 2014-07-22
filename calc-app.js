var net = require("net")

var server = net.createServer();


//Node basically doing that exact same sweet async function from non-block.rb
server.on("connection", function(socket) {
  socket.on("data", function (data1) {
    var i1 = parseInt(data1);
    socket.once("data", function(data2) {
      var i2 = parseInt(data2);
      socket.write((i1 + i2).toString(), function () {
        socket.end();
      });
    });
  });
});

server.listen(3000);

