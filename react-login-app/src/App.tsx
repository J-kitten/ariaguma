import { useEffect, useState } from "react";
import {
  signInWithPopup,
  signOut,
  onAuthStateChanged,
  GoogleAuthProvider,
} from "firebase/auth";

import { auth } from "./firebase";
import type { User } from "firebase/auth";
//import AuthModal from "./AuthModal";

export default function App() {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (currentUser) => {
      console.log("AUTH STATE CHANGED");
      console.log(currentUser);

      setUser(currentUser);
    });

    return unsubscribe;
  }, []);

  const login = async () => {
    const provider = new GoogleAuthProvider();

    try {
      const result = await signInWithPopup(auth, provider);

      console.log("LOGIN SUCCESS");
      console.log(result.user);
    } catch (error) {
      console.error(error);
    }
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
              backgroundColor: "#001a59",
              color: "#fff",
              padding: "10px 20px",
              borderRadius: "999px",
              border: "none",
              cursor: "pointer"
            }}
          >
            ログイン
          </button>

        </>
      ) : (
        <>
          <button
            onClick={logout}
            className="btn shadow rounded-pill px-4 py-3"
            style={{
              backgroundColor: "#001a59",
              color: "#fff",
              padding: "10px 20px",
              borderRadius: "999px",
              border: "none",
              cursor: "pointer"
            }}
          >
            ログアウト
          </button>

          <div>
            <span style={{ fontSize: "9px" }}>
              ログイン中: {user?.email}
            </span>
          </div>

        </>
      )}
    </div>
  );
}