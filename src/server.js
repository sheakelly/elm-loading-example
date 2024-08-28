const http = require("http");

const host = "localhost";
const port = 9005;

const requestListener = function (req, res) {
  console.log(req.method);
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Request-Method", "*");
  res.setHeader("Access-Control-Allow-Methods", "OPTIONS, GET");
  res.setHeader("Access-Control-Allow-Headers", "*");
  if (req.method === "OPTIONS") {
    res.writeHead(200);
    res.end();
    return;
  }
  res.setHeader("Content-Type", "application/json");
  res.writeHead(200);
  const value = Math.floor(Math.random() * 100) + 1;
  console.log(value);
  res.end(JSON.stringify({ value }));
};

const server = http.createServer(requestListener);
server.listen(port, host, () => {
  console.log(`Server is running on http://${host}:${port}`);
});
