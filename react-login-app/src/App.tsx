import { useEffect, useState } from "react";
import { onAuthStateChanged, signOut } from "firebase/auth";
import { createPortal } from "react-dom";

import { auth } from "./firebase";
import type { User } from "firebase/auth";
import AuthModal from "./AuthModal";
import Profile from "./Profile";

export default function App() {
  const [user, setUser] = useState<User | null>(null);
  const [open, setOpen] = useState(false);
  const [showProfile, setShowProfile] = useState(false);
  const [authChecked, setAuthChecked] = useState(false);

  const profileModalRoot = document.getElementById("profile-modal-root");

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (firebaseUser) => {
      console.log("Firebase auth state changed =", firebaseUser);
      setUser(firebaseUser);
      setAuthChecked(true);
    });

    return () => {
      unsubscribe();
    };
  }, []);

  useEffect(() => {
    console.log("App useEffect started");
    console.log("current URL =", window.location.href);
    console.log("search =", window.location.search);

    const searchParams = new URLSearchParams(window.location.search);
    const openLogin = searchParams.get("open_login");

    console.log("open_login =", openLogin);

    if (openLogin === "1") {
      console.log("ログインモーダルを開きます");
      setOpen(true);
    }

    const profileHandler = () => {
      setShowProfile(true);
    };

    const logoutHandler = async () => {
      try {
        const csrfToken = document.querySelector<HTMLMetaElement>('meta[name="csrf-token"]')?.content || "";

        const response = await fetch("/firebase_logout", {
          method: "DELETE",
          credentials: "same-origin",
          headers: {
            "X-CSRF-Token": csrfToken,
          },
        });

        if (!response.ok) {
          console.error("Rails logout failed =", response.status);
          return;
        }

        await signOut(auth);
        setUser(null);
        window.location.href = "/";
      } catch (error) {
        console.error("Firebase logout error =", error);
      }
    };

    window.addEventListener("open-profile", profileHandler);
    window.addEventListener("firebase-logout", logoutHandler);

    return () => {
      window.removeEventListener("open-profile", profileHandler);
      window.removeEventListener("firebase-logout", logoutHandler);
    };
  }, []);

  if (!authChecked) {
    return null;
  }

  return (
    <div style={{ padding: "20px" }}>
      {!user ? (
        <button
          onClick={() => setOpen(true)}
          className="btn shadow rounded-pill px-4 py-3"
          style={{
            width: "90px",
            backgroundColor: "#001a59",
            color: "#ffffff",
            borderRadius: "999px",
            border: "none",
            cursor: "pointer",
            fontSize: "10px",
          }}
        >
          MyPAGE
        </button>
      ) : (
        <button
          onClick={() => window.dispatchEvent(new Event("firebase-logout"))}
          className="btn shadow rounded-pill px-4 py-3"
          style={{
            width: "90px",
            backgroundColor: "#001a59",
            color: "#ffffff",
            borderRadius: "999px",
            border: "none",
            cursor: "pointer",
            fontSize: "10px",
          }}
        >
          LogOut
        </button>
      )}

      <AuthModal
        open={open}
        onClose={() => setOpen(false)}
        setUser={setUser}
      />

      {showProfile &&
        profileModalRoot &&
        createPortal(
          <div
            style={{
              position: "fixed",
              inset: 0,
              backgroundColor: "rgba(0, 0, 0, 0.35)",
              display: "flex",
              justifyContent: "center",
              alignItems: "center",
              zIndex: 9999,
              padding: "15px",
            }}
          >
            <div
              style={{
                width: "100%",
                maxWidth: "520px",
                maxHeight: "90vh",
                overflowY: "auto",
                backgroundColor: "#fff",
                padding: "25px",
                borderRadius: "16px",
                boxShadow: "0 10px 30px rgba(0,0,0,0.25)",
              }}
            >
              <div className="text-end">
                <button
                  type="button"
                  onClick={() => setShowProfile(false)}
                  className="btn-close"
                  aria-label="閉じる"
                />
              </div>

              <h5 className="text-center mb-4">
                プロフィール再設定
              </h5>

              <Profile />

              <div className="text-center mt-4">
                <button
                  type="button"
                  onClick={() => setShowProfile(false)}
                  className="btn rounded-pill px-4"
                  style={{
                    width: "100px",
                    height: "40px",
                    backgroundColor: "#dff7f7",
                    color: "#001a59",
                    fontSize: "12px",
                    outline: "none",
                    boxShadow: "none",
                    border: "1px solid #dff7f7",
                    borderRadius: "999px",
                  }}
                >
                  閉じる
                </button>
              </div>
            </div>
          </div>,
          profileModalRoot
        )}
    </div>
  );
}