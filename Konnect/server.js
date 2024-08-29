import dotenv from "dotenv";
import express from "express";
import process from "process";
import { Server as SocketIOServer } from "socket.io";

dotenv.config();

const app = express();
const host = process.env.HOST || "localhost";
const port = Number(process.env.PORT) || 3000;

app.use("/", express.static("./public"));

const socketIO = new SocketIOServer({
  maxHttpBufferSize: 1e8,
  allowUpgrades: false,
  transports: ["websocket"],
});

var connections = 0;
socketIO.on("connect", (client) => {
  connections++;
  client.once("login", (data) => {
    client.username = data.username ?? client.id;
    client.uid = data.uid ?? client.id;
    if (client.uid == "todo") client.uid = client.id; //TODO remove

    client.emit("login", { username: client.username, uid: client.uid });
    socketIO.emit("broadcast", {
      message: `${client.username} joined.`,
      online: connections,
    });
  });

  client.once("disconnect", () => {
    connections--;
    socketIO.emit("broadcast", {
      message: `${client.username} left.`,
      online: connections,
    });
  });

  client.on("message", (data) => {
    if (!client.uid) client.disconnect();

    socketIO.emit("message", {
      ...data,
      timestamp: Date.now(),
      username: client.username,
      uid: client.uid,
    });
  });
});

// redisClient.connect();
const expressApp = app.listen(port, host);
socketIO.listen(expressApp);
console.log("Konnect Running!!");
