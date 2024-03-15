import { getAuth, signInWithEmailAndPassword,createUserWithEmailAndPassword } from "firebase/auth";
import {addDoc,collection, getFirestore} from 'firebase/firestore';
import {initializeApp} from 'firebase/app';
import express from 'express';

const firebaseConfig = {
  apiKey: "AIzaSyAocxBUBdG8MuMl7Z7owoX6S6PXax8vYZQ",
  authDomain: "capstone-c2358.firebaseapp.com",
  projectId: "capstone-c2358",
  storageBucket: "capstone-c2358.appspot.com",
  messagingSenderId: "452182758120",
  appId: "1:452182758120:web:30f72007059d6fdf4c6f5d",
  measurementId: "G-ST9TF7PNY3"
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

const auth = getAuth(app);

const router = express.Router();

// 회원가입
router.post("/signup", async (req, res) => {
  
  const {
    email,
    password,
    name,
    studentId,
    faculty,
    department,
    club,
    phone,
    agreeForm,
  } = req.body;

  console.log(req.body);

  

  try {
    // 이미 가입된 이메일인지 확인
    // const existingUser = await auth().getUserByEmail(email);
    // if (existingUser) {
    //   // 이미 가입된 이메일인 경우 오류 응답
    //   console.error("Email already in use", error);
    //   return res.status(400).json({ error: "Email already in use" });
    // }

    createUserWithEmailAndPassword(auth, email, password)
      .then((userCredential) => {
        // Signed in
        const user = userCredential.user;
        console.log(user);
        // ...
      })
      .catch((error) => {
        const errorCode = error.code;
        const errorMessage = error.message;
        // ..
      });
    const user_doc = await addDoc(collection(db, "/users"), {
      
      email : email , 
      agreeForm : agreeForm ,
      club : club ,
      name : name ,
      phone : phone ,
      studentId : studentId ,
      faculty : faculty ,
      department : department

    })

    console.log("signup success");

    
    
    

    

    // 회원가입 성공 시 응답
    res.status(201).json({ message: "User created successfully" });
  } catch (error) {
    // 오류 발생시 오류 응답
    console.error("Error creating user", error);
    res.status(500).json({ error: "Failed to create user" });
  }
});

// // 로그인
// router.post("/signin", async (req, res) => {
//   const { email, password } = req.body;
//   console.log(req.body);

//   try {
//     // Firebase를 이용하여 이메일과 비밀번호로 로그인
//     const userCredential = await admin.auth().signInWithEmailAndPassword(email, password);
//     const user = userCredential.user;
//     // 로그인 성공 시 사용자 정보 반환
//     res
//       .status(200)
//       .json({ message: "Signin successful", uid: user.uid, email: user.email });
//   } catch (error) {
//     // 로그인 실패 시 오류 응답
//     console.error("Error signing in", error);
//     res.status(401).json({ error: "Signin failed" });
//   }
// });

// // 로그아웃
// router.post("/signout", (req, res) => {
//   signOut(auth) // Use the signOut function
//     .then(() => {
//       // 로그아웃 성공 시 응답
//       res.status(200).json({ message: "Singout successful" });
//     })
//     .catch((error) => {
//       // 로그아웃 실패 시 오류 응답
//       console.error("Error Signing out:", error);
//       res.status(500).json({ error: "Signout failed" });
//     });
// });

// // 프로필 수정
// router.post("/profile/update", async (req, res) => {
//   const { uid, name, studentId, faculty, department, club, phone, agreeForm } =
//     req.body;

//   try {
//     // Firebase Firestore에서 사용자의 문서를 가져옴
//     const userDoc = await firebase
//       .firestore()
//       .collection("users")
//       .doc(uid)
//       .get();
//     if (!userDoc.exists) {
//       // 사용자 문서가 존재하지 않는 경우 오류 응답
//       return res.status(404).json({ error: "User not found" });
//     }

//     // 사용자 문서를 업데이트
//     await firebase.firestore().collection("users").doc(uid).update({
//       name: name,
//       studentId: studentId,
//       faculty: faculty,
//       department: department,
//       club: club,
//       email: email,
//       phone: phone,
//       agreeForm: agreeForm,
//     });

//     // 업데이트된 사용자 정보 반환
//     res.status(200).json({ message: "Profile updated successfully" });
//   } catch (error) {
//     // 오류 발생 시 오류 응답
//     console.error("Error updating profile", error);
//     res.status(500).json({ error: "Failed to update profile" });
//   }
// });

// // 프로필 조회
// router.get("/profile/:uid", async (req, res) => {
//   const uid = req.params.uid;

//   try {
//     // Firebase Firestore에서 해당 사용자의 문서를 가져옴
//     const userDoc = await firebase
//       .firestore()
//       .collection("users")
//       .doc(uid)
//       .get();
//     if (!userDoc.exists) {
//       // 사용자 문서가 존재하지 않는 경우 오류 응답
//       return res.status(404).json({ error: "User not found" });
//     }

//     // 사용자 정보 반환
//     const userData = userDoc.data();
//     res.status(200).json(userData);
//   } catch (error) {
//     // 오류 발생 시 오류 응답
//     console.error("Error fetching profile", error);
//     res.status(500).json({ error: "Failed to fetch profile" });
//   }
// });


export default router;
