// app/javascript/modal.js
document.addEventListener("DOMContentLoaded", () => {
  const btn = document.getElementById("modal-login-btn");
  if (btn) {
    btn.addEventListener("click", () => {
      window.dispatchEvent(new Event("open-login-modal"));
    });
  }
});
//# sourceMappingURL=/assets/modal.js.map
