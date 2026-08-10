import { useState } from "react";
import {
  sendPasswordResetEmail,
  updateProfile,
  verifyBeforeUpdateEmail,
} from "firebase/auth";
import { auth } from "./firebase";

export default function Profile() {
  const [newName, setNewName] = useState("");
  const [newEmail, setNewEmail] = useState("");

  const updateUserName = async () => {
    const user = auth.currentUser;

    if (!user) {
      alert("ログインしてください。");
      return;
    }

    if (!newName.trim()) {
      alert("新しい名前を入力してください。");
      return;
    }

    await updateProfile(user, {
      displayName: newName,
    });
    console.log(user.displayName);

    const token = await user.getIdToken();

    const response = await fetch("/api/profile", {
      method: "PATCH",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
        "X-CSRF-Token":
          document.querySelector<HTMLMetaElement>(
            'meta[name="csrf-token"]'
          )?.content || "",
      },
      body: JSON.stringify({
        name: newName,
      }),
    });

    if (!response.ok) {
      alert("Rails側の名前変更に失敗しました。");
      return;
    }
    window.location.href = window.location.origin + "/mypage";
  };

  const changeEmail = async () => {
    const user = auth.currentUser;

    if (!user) {
      alert("ログインしてください。");
      return;
    }

    if (!newEmail.trim()) {
      alert("新しいメールアドレスを入力してください。");
      return;
    }

    await verifyBeforeUpdateEmail(user, newEmail, {
      url: "https://ariaguma.jp/mypage",
      handleCodeInApp: false,
    });

    alert("新しいメールアドレスに確認メールを送信しました。");
  };

  const resetPassword = async () => {
    const user = auth.currentUser;

    if (!user || !user.email) {
      alert("メールアドレスが確認できません。");
      return;
    }

    await sendPasswordResetEmail(auth, user.email, {
      url: "https://ariaguma.jp/mypage",
    });

    alert("パスワード再設定メールを送信しました。");
  };

  return (
    <div
      style={{
        backgroundColor: "#ffffff",
        padding: "20px",
        borderRadius: "10px",
      }}
    >
      <div className="mb-3">
        <input
          className="form-control mx-auto d-block text-start"
          style={{
            width: "100%",
            maxWidth: "400px",
            boxSizing: "border-box",
            height: "40px",
            backgroundColor: "#ffffff",
            color: "#000000",
            border: "1px solid #bfeeee",
            fontSize: "12px",
            borderRadius: "10px",
          }}
          type="text"
          value={newName}
          onChange={(e) => setNewName(e.target.value)}
          placeholder="新しい名前"
        />

        <button
          style={{
            width: "100%",
            maxWidth: "400px",
            boxSizing: "border-box",
            height: "40px",
            backgroundColor: "#dff7f7",
            color: "#001a59",
            fontSize: "12px",
            outline: "none",
            boxShadow: "none",
            border: "1px solid #dff7f7",
            borderRadius: "999px",
          }}
          type="button"
          onClick={updateUserName}
          className="btn rounded-pill mx-auto d-block mt-2"
        >
          名前を変更
        </button>
      </div>

      <div className="mb-3 text-start">
        <input
          className="form-control mx-auto d-block text-start"
          style={{
            width: "100%",
            maxWidth: "400px",
            boxSizing: "border-box",
            height: "40px",
            backgroundColor: "#ffffff",
            color: "#000000",
            border: "1px solid #bfeeee",
            fontSize: "12px",
            borderRadius: "10px",
          }}
          type="email"
          value={newEmail}
          onChange={(e) => setNewEmail(e.target.value)}
          placeholder="新しいEMAIL"
        />

        <button
          style={{
            width: "100%",
            maxWidth: "400px",
            boxSizing: "border-box",
            height: "40px",
            backgroundColor: "#dff7f7",
            color: "#001a59",
            fontSize: "12px",
            outline: "none",
            boxShadow: "none",
            border: "1px solid #dff7f7",
            borderRadius: "999px",
          }}
          type="button"
          onClick={changeEmail}
          className="btn rounded-pill mx-auto d-block mt-2"
        >
          メールアドレス変更確認メールを送信
        </button>
      </div>

      <button
        style={{
          width: "100%",
          maxWidth: "400px",
          boxSizing: "border-box",
          height: "40px",
          backgroundColor: "#dff7f7",
          color: "#001a59",
          fontSize: "12px",
          outline: "none",
          boxShadow: "none",
          border: "1px solid #dff7f7",
          borderRadius: "999px",
        }}
        type="button"
        onClick={resetPassword}
        className="btn rounded-pill mx-auto d-block mt-2"
      >
        パスワード再設定メールを送信
      </button>

      <br />
    </div>
  );
}