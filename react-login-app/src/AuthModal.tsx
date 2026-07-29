import { useState } from "react";
import type { User } from "firebase/auth";
import {
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  sendPasswordResetEmail,
  //signInWithRedirect, 
  GoogleAuthProvider,
  signInWithPopup,
  //signOut,
} from "firebase/auth";
import { auth } from "./firebase";
import { FirebaseError } from "firebase/app";

type Props = {
  open: boolean;
  onClose: () => void;
  setUser: (user: User | null) => void;
};

export default function AuthModal({ open, onClose, setUser }: Props) {
  console.log("AUTHMODAL VERSION 2026-07-06");

  if (!open) return null;
  console.log("AuthModal render");
  console.log("open =", open);

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

/* signInWithRedirect(auth, provider); を使う場合
  useEffect(() => {
    const checkLogin = async () => {
      const result = await getRedirectResult(auth);

      if (result?.user) {
        console.log("LOGIN SUCCESS:", result.user);
        setUser(result.user);
      }
    };

    checkLogin();
  }, []);
*/

  // --- Googleログイン（popup版）---
  const googleLogin = async () => {
    const provider = new GoogleAuthProvider();

    provider.setCustomParameters({
      prompt: "select_account",
    });

    try {
      const result = await signInWithPopup(auth, provider);

      setUser(result.user);
      onClose();
      await loginToRails(result.user);

    } catch (error: unknown) {

      if (error instanceof FirebaseError) {
        switch (error.code) {

          case "auth/popup-closed-by-user":
            alert("Googleログイン画面が閉じられました。再試行してください。");
            break;

          case "auth/too-many-requests":
            alert("試行回数が多すぎます。しばらく時間を置いて再試行してください。");
            break;

          case "auth/unauthorized-domain":
            alert(
              "Googleログインのドメイン設定が未登録です。Firebaseコンソールの承認済みドメインを確認してください。"
            );
            break;

          default:
            alert("Googleログインに失敗しました。");
        }
      } else {
        alert("予期しないエラーが発生しました。");
      }
    }
  };

  // --- 新規登録 ---
  const register = async () => {
    try {
      const userCredential = await createUserWithEmailAndPassword(
        auth,
        email,
        password
      );

      await loginToRails(userCredential.user);
      setUser(userCredential.user);
      onClose();
      window.location.href = "/";

    } catch (error: any) {
      if (error instanceof FirebaseError) {
        switch (error.code) {
          case "auth/email-already-in-use":
            alert("このメールアドレスはすでに登録されています。");
            break;

          case "auth/invalid-email":
            alert("メールアドレスの形式が正しくありません。");
            break;

          case "auth/weak-password":
            alert("パスワードは6文字以上にしてください。");
            break;

          case "auth/too-many-requests":
            alert("試行回数が多すぎます。しばらく時間を置いて再試行してください。");
            break;

          default:
            alert("登録に失敗しました。");
        }
      } else {
        alert("予期しないエラーが発生しました。");
      }
    }
  };

  // --- ログイン ---
  const login = async () => {
    console.log("LOGINED");

    try {
      const userCredential = await signInWithEmailAndPassword(
        auth,
        email,
        password
      );

      // FirebaseのIDトークンをRailsへ送信
      await loginToRails(userCredential.user);

    } catch (error: unknown) {
      console.log("LOGIN ERROR =", error);

      const firebaseError = error as FirebaseError;

      console.log("ERROR CODE =", firebaseError.code);

      if (error instanceof FirebaseError) {

        switch (firebaseError.code) {

          case "auth/missing-password":
            alert("パスワードが正しくありません。再入力してください。");
            break;

          case "auth/invalid-email":
            alert("メールアドレスが無効です。");
            break;

          case "auth/wrong-password":
            alert("パスワードが正しくありません。再入力してください。");
            break;

          case "auth/invalid-credential":
            alert("メールアドレスまたはパスワードが正しくありません。");
            break;

          case "auth/user-not-found":
            alert("このメールアドレスは登録されていません。");
            break;

          case "auth/too-many-requests":
            alert("試行回数が多すぎます。しばらく時間を置いて再試行してください。");
            break;

          default:
            alert("ログインに失敗しました。");
        }

      } else {
        alert("予期しないエラーが発生しました。");
      }
    }
  };

  // --- パスワードリセット ---
  const resetPassword = async () => {
    if (!email || email.trim() === "") {
      alert("メールアドレスが入力されていません。");
      return;
    }

    try {
      await sendPasswordResetEmail(auth, email);
      alert("メールを送信しました");
    } catch (error: unknown) {
      if (error instanceof FirebaseError) {
        switch (error.code) {
          case "auth/user-not-found":
            alert("このメールアドレスは登録されていません。");
            break;

          case "auth/invalid-email":
            alert("メールアドレスの形式が正しくありません。");
            break;

          case "auth/too-many-requests":
            alert("試行回数が多すぎます。しばらく時間を置いて再試行してください。");
            break;

          default:
            alert("パスワード再設定に失敗しました。");
        }
      } else {
        alert("予期しないエラーが発生しました。");
      }
    }
  };

  const loginToRails = async (firebaseUser: User) => {
    console.log("LOGIN TO RAILS START");

    const idToken = await firebaseUser.getIdToken();

    const response = await fetch("/firebase_login", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token":
          document
            .querySelector<HTMLMetaElement>('meta[name="csrf-token"]')
            ?.content || "",
      },
      credentials: "same-origin",
      body: JSON.stringify({ id_token: idToken }),
    });

    console.log("Rails login status:", response.status);

    if (response.ok) {
      //setUser(auth.currentUser);
      setUser(firebaseUser);
      onClose();
      window.location.href = "/mypage";
      return;
    } else {
      alert("Railsログインに失敗しました");
      return;
    }

  };

  return (
    <div
      style={{
        position: "fixed",
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        zIndex: 9999
      }}
    >
      <div
        style={{
          background: "#ffffff", 
          padding: 35,
          width: 400,
          margin: "70px auto",
          borderRadius: 8,
          boxShadow: "0 4px 8px rgba(0,0,0,0.2)",
          textAlign: "center"
        }}
      >

        <div
          style={{
            display: "flex",
            flexDirection: "row",
            alignItems: "center",
            gap: "6px",
            flexWrap: "nowrap"
          }}
        >
          <img
            src="/diamond.png"
            alt=""
            style={{
              height: "35px",
              opacity: 0.7,
              display: "block",
              paddingBottom: "5px"
            }}
          />

          <span style={{ fontSize: "16px", whiteSpace: "nowrap" }}>
            Login | 新規登録
          </span>

          <button
            onClick={onClose}
            style={{
              marginLeft: "auto",
              border: "none",
              background: "transparent",
              padding: 0,
              cursor: "pointer",
              textAlign: "right",
              paddingBottom: "10px"
            }}
          >
            <img
              src="/close-button.png"
              alt="close"
              style={{
                opacity: 0.7,
                display: "block",
                height: "50px",
              }}
            />
          </button>

        </div>

        <input
          placeholder="メールアドレス"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          style={{ width: "90%", marginBottom: 8, padding: 6 }}
        />

        <input
          placeholder="パスワード"
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          style={{ width: "90%", marginBottom: 8, padding: 6 }}
        />

        <button
          onClick={login}
          style={{
            backgroundColor: "#dff7f7",
            color: "#000000",
            border: "none",
            borderRadius: "999px",
            padding: "10px 24px",
            cursor: "pointer",
            boxShadow: "0 2px 4px rgba(0,0,0,0.2)",
            width: "90%", 
            marginBottom: 4
          }}
        >
          ログイン
        </button>

        <button
          onClick={register}
          style={{
            backgroundColor: "#dff7f7",
            color: "#000000",
            border: "none",
            borderRadius: "999px",
            padding: "10px 24px",
            cursor: "pointer",
            boxShadow: "0 2px 4px rgba(0,0,0,0.2)",
            width: "90%", 
            marginBottom: 4
          }}
        >
          新規登録
        </button>

        <button
          onClick={resetPassword}
          style={{
            backgroundColor: "#dff7f7",
            color: "#000000",
            border: "none",
            borderRadius: "999px",
            padding: "10px 24px",
            cursor: "pointer",
            boxShadow: "0 2px 4px rgba(0,0,0,0.2)",
            width: "90%", 
            marginBottom: 4
          }}
        >
          パスワード再設定
        </button>

        <button
          onClick={googleLogin}
          style={{
            backgroundColor: "#dff7f7",
            color: "#000000",
            border: "none",
            borderRadius: "999px",
            padding: "10px 24px",
            cursor: "pointer",
            boxShadow: "0 2px 4px rgba(0,0,0,0.2)",
            width: "90%", 
            marginBottom: 4
          }}
        >
          Googleログイン
        </button>

        <button
          onClick={onClose}
          style={{
            backgroundColor: "#001a59",
            color: "#f0eee0",
            border: "none",
            borderRadius: "999px",
            padding: "10px 24px",
            cursor: "pointer",
            boxShadow: "0 2px 4px rgba(0,0,0,0.2)",
            width: "90%", 
            marginBottom: 4
          }}
        >
          閉じる
        </button>
      </div>
    </div>
  );
}
