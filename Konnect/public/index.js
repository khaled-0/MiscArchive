const onlineCount = document.getElementById("onlineCount");

const messagesContainer = document.getElementById("messagesContainer");
const inputField = document.getElementById("inputField");
const sendButton = document.getElementById("sendButton");

var autoscroll = true;

const socketIO = io({
  transports: ["websocket"],
});

var username = localStorage.getItem("username");
var uid = localStorage.getItem("uid");

while (!username) username = prompt("Enter your username");

sendButton.onclick = sendMessage;

socketIO.on("connect", () => {
  socketIO.emit("login", { username: username, uid: uid });
});

socketIO.once("login", (data) => {
  localStorage.setItem("uid", data.uid);
  localStorage.setItem("username", data.username);

  uid = data.uid;
  document.getElementById("username").innerText = data.username;
  document.querySelector(".inputBox").style.display = null;
  inputField.focus();
});

socketIO.on("message", insertMessage);
socketIO.on("broadcast", insertEvent);

function insertMessage(data) {
  const msg = document.createElement("li");

  if (data.image) {
    const img = document.createElement("img");
    img.src = data.message;
    msg.append(img);
  } else {
    msg.innerText = data.message;
  }

  if (data.uid == uid) {
    msg.dataset["self"] = true;
  } else {
    const info = document.createElement("span");
    info.innerText = new Date(data.timestamp).toLocaleTimeString();
    info.innerText += ` \u2022 ${data.username}`;

    info.onclick = () => mentionUser(data.username);
    msg.prepend(info);
  }

  messagesContainer.append(msg);
  if (autoscroll) messagesContainer.lastChild.scrollIntoView();
}

function insertEvent(data) {
  var broadcast = document.createElement("span");
  broadcast.className = "broadcast";
  broadcast.innerText = data.message;
  messagesContainer.append(broadcast);
  if (autoscroll) messagesContainer.lastChild.scrollIntoView();
  setOnlineCount(data.online);
}

function sendMessage() {
  if (inputField.hidden) return sendImageMessage();

  const msg = inputField.value;
  if (String(msg).trim() == "") return;

  socketIO.emit("message", { message: msg });
  inputField.value = "";
  inputField.focus();
}

function setOnlineCount(data) {
  const count = Number(data) - 1 || 0;
  if (count > 0) onlineCount.innerText = `with ${count} other`;
  else onlineCount.innerText = `nobody here`;
}

function sendImageMessage() {
  socketIO.emit("message", { message: imagePickerPreview.src, image: true });
  cancelImagePick.click();
}
