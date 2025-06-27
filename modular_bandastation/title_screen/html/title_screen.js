function call_byond(href, value) {
  window.location = `byond://?src=[REF(player)];${href}=${value}`;
}

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
  imgElement.src = image_src;
  imgBlurElement.src = image_src;
}

let attempts = 0;
const maxAttempts = 10;
function fixImage() {
  const img = new Image();
  img.src = image_src;
  if (img.naturalWidth !== 0 || img.naturalHeight !== 0) {
    attempts = 0;
    image_container.src = image_src;
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

/* Return focus to Byond after click */
function reFocus() {
  call_byond("focus", true);
}

document.addEventListener("keyup", reFocus);
document.addEventListener("mouseup", reFocus);

/* Tell Byond that the title screen is ready */
call_byond("titleReady", true);
