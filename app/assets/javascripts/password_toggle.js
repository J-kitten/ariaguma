document.addEventListener("turbo:load", setupPasswordToggle);
document.addEventListener("turbo:frame-load", setupPasswordToggle); // Turbo Frame用（必要なら）

function setupPasswordToggle() {
  const toggle = document.getElementById("toggle-password");
  const passwordField = document.getElementById("password-field");

  if (toggle && passwordField && !toggle.dataset.initialized) {
    toggle.addEventListener("click", () => {
      const isText = passwordField.type === "text";
      passwordField.type = isText ? "password" : "text";

      const showIcon = toggle.dataset.showIcon;
      const hideIcon = toggle.dataset.hideIcon;
      toggle.src = isText ? hideIcon : showIcon;
    });

    toggle.dataset.initialized = "true"; // 二重バインド防止
  }
}
