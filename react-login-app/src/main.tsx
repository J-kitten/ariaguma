//src/main.tsx
import ReactDOM from "react-dom/client";
import App from "./App";

const root = document.getElementById("login-root");

if (root) {
  ReactDOM.createRoot(root).render(
      <App />
  );
}
