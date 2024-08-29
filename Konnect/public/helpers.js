inputField.addEventListener("keypress", (ev) => {
  if (ev.key != "Enter") return;
  sendMessage();
});

socketIO.on("disconnect", () => {
  onlineCount.innerText = "⚠️ Reconnecting...";
});

function mentionUser(username) {
  inputField.value += ` @${username} `;
  inputField.focus();
}

//TODO: getElementById unnecessary??
// search when internet returns
const filePicker = document.getElementById("filePicker");
const imagePickerPreview = document.getElementById("imagePickerPreview");
const cancelImagePick = document.getElementById("cancelImagePick");

// TODO Add image paste support
// inputField.addEventListener("paste", async (ev) => {
//   console.log(ev.clipboardData, ev.composedPath());
// });

filePicker.addEventListener("input", async () => {
  const file = filePicker.files[0];
  if (!file || !file.type.startsWith("image")) return;

  inputField.hidden = true;
  imagePickerPreview.hidden = false;
  cancelImagePick.hidden = false;
  const base64Image = await encodeBlobAsBase64(file);

  imagePickerPreview.src = "data:image/png;base64," + base64Image;
});

cancelImagePick.addEventListener("click", () => {
  inputField.hidden = false;
  imagePickerPreview.hidden = true;
  cancelImagePick.hidden = true;
  filePicker.value = null;
});

async function encodeBlobAsBase64(data) {
  return new Promise((resolve, reject) => {
    const fileReader = new FileReader();
    fileReader.onload = function () {
      var content = fileReader.result.split(",")[1];
      if (!content) reject("Empty content");
      resolve(content);
    };
    fileReader.readAsDataURL(data);
  });
}
