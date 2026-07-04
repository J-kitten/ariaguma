// app/javascript/application.js
document.addEventListener("turbo:load", () => {
  const button = document.getElementById("modal-login-btn");
  if (!button) return;
  button.addEventListener("click", () => {
    window.dispatchEvent(new Event("open-login-modal"));
  });
});
//# sourceMappingURL=/assets/application.js.map
