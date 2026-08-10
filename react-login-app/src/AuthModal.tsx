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
  console.log("AUTHMODAL VERSION 2026-08-06-1945");

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  if (!open) return null;
  console.log("AuthModal render");
  console.log("open =", open);

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

  /* Googleログイン */
  const googleLogin = async () => {
    const provider = new GoogleAuthProvider();

    provider.setCustomParameters({
      prompt: "select_account",
    });

    try {
      const result = await signInWithPopup(auth, provider);

      await loginToRails(result.user);

    } catch (error: unknown) {
      if (error instanceof FirebaseError) {
        switch (error.code) {
          case "auth/popup-closed-by-user":
            alert(
              "Googleログイン画面が閉じられました。再試行してください。"
            );
            break;

          case "auth/too-many-requests":
            alert(
              "試行回数が多すぎます。しばらく時間を置いて再試行してください。"
            );
            break;

          case "auth/unauthorized-domain":
            alert(
              "Googleログインのドメイン設定が未登録です。" +
              "Firebaseコンソールの承認済みドメインを確認してください。"
            );
            break;

          default:
            alert("Googleログインに失敗しました。");
        }
      } else if (error instanceof Error) {
        /*
         * loginToRails内ですでにエラーメッセージを表示しているため、
         * ここではコンソール出力だけでも構いません。
         */
        console.error("Google / Rails login error:", error);
      } else {
        alert("予期しないエラーが発生しました。");
      }
    }
  };

  /* 新規登録 */
  const register = async () => {
    try {
      const userCredential = await createUserWithEmailAndPassword(
        auth,
        email,
        password
      );

      await loginToRails(userCredential.user);

    } catch (error: unknown) {
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
            alert(
              "試行回数が多すぎます。しばらく時間を置いて再試行してください。"
            );
            break;

          default:
            alert("登録に失敗しました。");
        }
      } else if (error instanceof Error) {
        console.error("Register / Rails login error:", error);
      } else {
        alert("予期しないエラーが発生しました。");
      }
    }
  };

  /* ログイン */
  const login = async () => {
    console.log("LOGINED");
    console.log("AUTHMODAL VERSION 2026-08-06-1945");

    try {
      const userCredential = await signInWithEmailAndPassword(
        auth,
        email,
        password
      );

      /* FirebaseのIDトークンをRailsへ送信 */
      await loginToRails(userCredential.user);

    } catch (error: unknown) {
      console.error("GOOGLE LOGIN ERROR =", error);

      if (error instanceof FirebaseError) {
        console.error("GOOGLE ERROR CODE =", error.code);
        console.error("GOOGLE ERROR MESSAGE =", error.message);

        switch (error.code) {
          case "auth/popup-closed-by-user":
            alert(
              "Googleログイン画面が閉じられました。再試行してください。"
            );
            break;

          case "auth/popup-blocked":
            alert(
              "Googleログイン画面がブラウザにブロックされました。" +
              "ariaguma.jpのポップアップを許可してください。"
            );
            break;

          case "auth/cancelled-popup-request":
            alert(
              "Googleログインが複数回実行されました。" +
              "少し待ってから、ボタンを1回だけ押してください。"
            );
            break;

          case "auth/unauthorized-domain":
            alert(
              "ariaguma.jpがFirebaseの承認済みドメインに" +
              "登録されていません。"
            );
            break;

          case "auth/operation-not-allowed":
            alert(
              "Firebase AuthenticationでGoogleログインが" +
              "有効になっていません。"
            );
            break;

          case "auth/network-request-failed":
            alert(
              "Googleとの通信に失敗しました。" +
              "インターネット接続やブラウザ設定を確認してください。"
            );
            break;

          case "auth/too-many-requests":
            alert(
              "試行回数が多すぎます。" +
              "しばらく時間を置いて再試行してください。"
            );
            break;

          default:
            alert(
              `Googleログインに失敗しました。\n` +
              `エラーコード: ${error.code}\n` +
              `内容: ${error.message}`
            );
        }
      } else if (error instanceof Error) {
        console.error("Google / Rails login error:", error);

        alert(
          `ログイン処理に失敗しました。\n${error.message}`
        );
      } else {
        alert("予期しないエラーが発生しました。");
      }
    }
  };

  /* パスワードリセット */
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

  const loginToRails = async (
    firebaseUser: User
  ): Promise<void> => {
    console.log("LOGIN TO RAILS START");

    try {
      const csrfToken =
        document.querySelector<HTMLMetaElement>(
          'meta[name="csrf-token"]'
        )?.content;

      if (!csrfToken) {
        throw new Error(
          "CSRFトークンを取得できませんでした。" +
          "csrf_meta_tagsを確認してください。"
        );
      }

      const idToken =
        await firebaseUser.getIdToken(true);

      const response = await fetch("/firebase_login", {
        method: "POST",
        credentials: "same-origin",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
        },
        body: JSON.stringify({
          id_token: idToken,
        }),
      });

      console.log(
        "Rails login status:",
        response.status
      );

      if (!response.ok) {
        let errorMessage =
          "Railsログインに失敗しました。";

        try {
          const errorData: {
            error?: string | string[];
          } = await response.json();

          if (Array.isArray(errorData.error)) {
            errorMessage =
              errorData.error.join("、");
          } else if (
            typeof errorData.error === "string"
          ) {
            errorMessage =
              errorData.error;
          }
        } catch {
          // JSONではない場合は既定文言を使う
        }

        throw new Error(
          `${errorMessage} ` +
          `ステータスコード: ${response.status}`
        );
      }

      const data: {
        success?: boolean;
        redirect_url?: string;
      } = await response.json();

      console.log(
        "Rails redirect URL:",
        data.redirect_url
      );

      setUser(firebaseUser);
      onClose();

      // Railsから返された元のURLへ移動する
      window.location.href =
        data.redirect_url || "/mypage";

    } catch (error: unknown) {
      console.error(
        "LOGIN TO RAILS ERROR =",
        error
      );

      if (error instanceof Error) {
        alert(error.message);
      } else {
        alert(
          "Railsログイン中に" +
          "予期しないエラーが発生しました。"
        );
      }

      throw error;
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
                height: "30px",
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
