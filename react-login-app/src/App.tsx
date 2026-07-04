import { useEffect, useState } from "react";
import {
  signOut,
  onAuthStateChanged,
  //GoogleAuthProvider,
  //signInWithPopup,
} from "firebase/auth";

import { auth } from "./firebase";
import type { User } from "firebase/auth";
import AuthModal from "./AuthModal";

export default function App() {
  const [user, setUser] = useState<User | null>(null);
  const [open, setOpen] = useState(false); //add

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (currentUser) => {
      console.log("AUTH STATE CHANGED");
      console.log(currentUser);

      setUser(currentUser);
    });

    return unsubscribe;
  }, []);

  const login = async () => {
    setOpen(true);
  };

  const logout = async () => {
    await signOut(auth);
  };

  return (
    <div style={{ padding: "20px" }}>

      {!user ? (
        <>
          <button
            onClick={login}
            className="btn shadow rounded-pill px-4 py-3"
            style={{
              width: "90px",
              backgroundColor: "#001a59",
              color: "#f0eee0",
              padding: "10px 20px",
              borderRadius: "999px",
              border: "none",
              cursor: "pointer",
              fontSize: "10px !important"
           }}
          >
            ログイン
          </button>

          <AuthModal
            open={open}
            onClose={() => setOpen(false)}
            setUser={setUser}
          />

        </>
      ) : (
        <>
          <div>
            <span style={{ fontSize: "9px" }}>
              ログイン中: {user?.email}
            </span>
          </div>

          <button
            onClick={logout}
            className="btn shadow rounded-pill px-4 py-3"
            style={{
              width: "90px",
              backgroundColor: "#001a59",
              color: "#f0eee0",
              padding: "10px 20px",
              borderRadius: "999px",
              border: "none",
              cursor: "pointer",
              fontSize: "10px !important"
            }}
          >
            ログアウト
          </button>
        </>
      )}
    </div>
  );
}