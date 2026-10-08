import http from "node:http";
import os from "node:os";

const port = Number(process.env.PORT || 8080);

const server = http.createServer((req, res) => {
  const payload = {
    status: "ok",
    lesson: "30",
    service: "ECS Fargate",
    message: "Wlasny obraz Docker uruchomiony jako task ECS Fargate.",
    hostname: os.hostname(),
    time: new Date().toISOString()
  };

  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(JSON.stringify(payload, null, 2));
});

server.listen(port, "0.0.0.0", () => {
  console.log(`lesson30 app listening on ${port}`);
});
