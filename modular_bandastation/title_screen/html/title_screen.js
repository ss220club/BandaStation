// MARK: State/Info updates
function toggleGoodBadClass(element, condition) {
  element.classList.add(condition ? "good" : "bad");
  element.classList.remove(!condition ? "good" : "bad");
}

let ready_int = 0;
const readyElement = document.querySelector(".lobby-toggle_ready");
function toggleReady(setReady) {
  toggleGoodBadClass(readyElement, setReady === "1"); // YES. Byond sends true/false like a "1"/"0"
}

const noticeElement = document.getElementById("container_notice");
function updateNotice(notice) {
  const emptyNotice = notice === undefined;
  noticeElement.classList.toggle("hidden", emptyNotice);
  noticeElement.innerHTML = emptyNotice ? "" : notice;
}

const character_name_slot = document.getElementById("character_name");
function updateCharacterName(name) {
  character_name_slot.setAttribute("data-name", name);
}

const info_placement = document.getElementById("round_info");
function updateInfo(info) {
  info_placement.innerHTML = info;
}

function traitSignup(assign, id) {
  if (!id) {
    return;
  }

  const traitID = `lobby-trait-${Number(id)}`;
  const trait_link = document.getElementById(traitID);
  toggleGoodBadClass(trait_link, assign === "true");
}

const adminButtons = document.getElementById("lobby_admin");
function toggleAdmin(visible) {
  adminButtons.classList.toggle("hidden", visible !== "true");
}

// MARK: Image processing
let imgSrc;
const imgElement = document.getElementById("screen_image");
const imgBlurElement = document.getElementById("screen_blur");
function updateImage(image) {
  imgSrc = image;
  imgElement.src = imgSrc;
  imgBlurElement.src = imgSrc;
}

let attempts = 0;
const maxAttempts = 10;
function fixImage() {
  const testImg = new Image();
  testImg.src = imgSrc;
  if (testImg.naturalWidth !== 0 || testImg.naturalHeight !== 0) {
    attempts = 0;
    updateImage(imgSrc);
    return;
  }

  if (attempts === maxAttempts) {
    attempts = 0;
    return;
  }

  attempts++;
  setTimeout(fixImage, 1000);
}

// MARK: Loading
const loadingName = document.getElementById("character_name");
function updateLoadingName(name) {
  loadingName.setAttribute("data-loading", name);
}

const logoElement = document.getElementById("logo");
function updateLoadedCount(count) {
  logoElement.setAttribute("data-loaded", `${Math.round(count)}%`);
  document.documentElement.style.setProperty(
    "--loading-percentage",
    `${count}%`,
  );
}

function finishLoading() {
  document.documentElement.style = "";
  document.documentElement.className = "";
}

// MARK: Authentication
const parent = document.getElementById("external_auth");
const authCheckbox = document.getElementById("hide_auth");
const authButton = document.getElementById("open_auth");
function toggleAuthModal() {
  const checked = authCheckbox.checked;
  authCheckbox.checked = !checked;

  if (!checked) {
    call_byond("discord_oauth_close", true);
    setTimeout(() => {
      authButton.style.display = "";
      parent.className = "";
    }, 200);
  }
}

function updateAuthBrowser() {
  parent.className = "open";
  authButton.style.display = "none";
  setTimeout(() => updateExternalWindowPos(), 1000);
}

function updateExternalWindowPos() {
  const titleBarHeight = 43; // I hate Byond sometimes
  const pixelRatio = window.devicePixelRatio ?? 1;
  const rect = parent.getBoundingClientRect();
  const parentSize = {
    pos: [rect.left * pixelRatio, rect.top + titleBarHeight * pixelRatio],
    size: [
      (rect.right - rect.left) * pixelRatio,
      (rect.bottom - rect.top) * pixelRatio,
    ],
  };

  BYOND.winset("authwindow", {
    pos: `${parentSize.pos[0]},${parentSize.pos[1]}`,
    size: `${parentSize.size[0]},${parentSize.size[1]}`,
  });
}

window.addEventListener("resize", updateExternalWindowPos);

/* Return focus to Byond after click */
function reFocus() {
  call_byond("focus", true);
}

document.addEventListener("keyup", reFocus);
document.addEventListener("mouseup", reFocus);

/* Tell Byond that the title screen is ready */
call_byond("titleReady", true);
