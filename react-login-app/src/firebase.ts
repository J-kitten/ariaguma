import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";

const firebaseConfig = {
  apiKey: "AIzaSyAWZcI80IV7KVjV2nrEGA1LDafJBPPKuRE",
  authDomain: "ariagumareact.firebaseapp.com",
  projectId: "ariagumareact",
  storageBucket: "ariagumareact.firebasestorage.app",
  messagingSenderId: "166892170081",
  appId: "1:166892170081:web:f93107f84a90d94bdaf320",
  measurementId: "G-B0TG0QHJW0"
};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
