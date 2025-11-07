🗨️ Web Chat App

A modern real-time chat web application built using
React (frontend) + Node.js / Express / Socket.IO (backend) + MongoDB (database).
Supports live chatting, message persistence, JWT-based authentication, and light/dark themes.

🚀 Features

✅ Real-time bi-directional messaging using Socket.IO
✅ User authentication (JWT login/register)
✅ MongoDB persistence for all messages
✅ Responsive and minimal UI built with React + Tailwind CSS
✅ Optional light/dark theme toggle
✅ REST API fallback for messages
✅ Plug-and-play local setup — no complex config needed

🧩 Tech Stack
Layer	Technology
Frontend	React + Tailwind CSS + Framer Motion + Lucide Icons
Backend	Node.js + Express + Socket.IO
Database	MongoDB + Mongoose
Auth	JWT (jsonwebtoken + bcrypt)
Realtime	WebSockets (Socket.IO)
Deployment	Docker / Local / Render / Railway compatible
📁 Folder Structure
chat-app/
├─ frontend/
│  ├─ src/
│  │  └─ ChatApp.jsx       # React chat UI
│  ├─ package.json
│  └─ tailwind.config.js
│
├─ backend/
│  ├─ server.js            # Full backend (Express + Socket.IO)
│  ├─ .env
│  └─ package.json
│
└─ README.md

⚙️ Setup Instructions
1️⃣ Clone the project
git clone https://github.com/yourusername/chat-app.git
cd chat-app

2️⃣ Backend setup
cd backend
npm install


Create .env inside backend/:

PORT=4000
MONGO_URI=mongodb://localhost:27017/chatapp
JWT_SECRET=supersecretkey


Run the backend:

node server.js


Your backend runs on → http://localhost:4000

3️⃣ Frontend setup
cd ../frontend
npm install
npm run dev


Your frontend runs on → http://localhost:5173
 (Vite) or http://localhost:3000
 (CRA)

🧠 Usage

Open the frontend in the browser.

Register a new user (POST /api/register) or use login form.

Start chatting — messages will appear in real time across all clients.

Refresh the page — chat history remains stored in MongoDB.

🧵 Socket.IO Events
Event	Direction	Description
send	client → server	Send message { from, text }
message	server → client	Broadcasted to all users when new message saved
🧪 REST API Endpoints
Method	Endpoint	Description
POST	/api/register	Create new user
POST	/api/login	Authenticate existing user
GET	/api/messages	Fetch latest messages
POST	/api/messages	Send message (REST fallback)

Headers: Authorization: Bearer <token>

🧰 Example API Call (Postman)
POST http://localhost:4000/api/messages
Authorization: Bearer <token>
Content-Type: application/json

{
  "text": "Hello world!"
}

🐳 Docker Compose (optional)

You can use Docker to run MongoDB + server together:

version: "3"
services:
  mongo:
    image: mongo
    container_name: chat-mongo
    ports:
      - "27017:27017"

  backend:
    build: ./backend
    ports:
      - "4000:4000"
    environment:
      - MONGO_URI=mongodb://mongo:27017/chatapp
      - JWT_SECRET=supersecret
    depends_on:
      - mongo


Run with:

docker compose up

🎨 UI Preview

Clean, responsive layout with sidebar for conversations, message area, and bottom input box.
Light/dark themes supported.

⚡ Future Enhancements

✅ Chat rooms / group conversations

✅ File attachments & image previews

✅ Typing indicators / read receipts

✅ Online status presence tracking

✅ Push notifications

✅ Admin dashboard
