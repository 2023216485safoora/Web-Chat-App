// ChatApp.jsx
// Single-file React + Tailwind chat frontend (default export React component)
// Requirements: React 18+, Tailwind CSS configured, install: framer-motion, lucide-react
// npm i framer-motion lucide-react

import React, { useEffect, useRef, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Send, Paperclip, Moon, Sun, Plus } from "lucide-react";

export default function ChatApp() {
  const [conversations, setConversations] = useState(() => [
    {
      id: "general",
      title: "General",
      last: "Hey — welcome to the chat!",
      messages: [
        { id: 1, from: "bot", text: "Welcome! Start a conversation.", ts: Date.now() - 1000 * 60 * 60 },
      ],
    },
    {
      id: "project",
      title: "Project",
      last: "Let's ship this",
      messages: [
        { id: 1, from: "bot", text: "Project channel ready.", ts: Date.now() - 1000 * 60 * 20 },
      ],
    },
  ]);

  const [activeId, setActiveId] = useState(conversations[0].id);
  const [input, setInput] = useState("");
  const [isDark, setIsDark] = useState(false);
  const [attachment, setAttachment] = useState(null);
  const listRef = useRef(null);

  useEffect(() => {
    document.documentElement.classList.toggle("dark", isDark);
  }, [isDark]);

  const activeConv = conversations.find((c) => c.id === activeId) || conversations[0];

  function handleSend() {
    const text = input.trim();
    if (!text && !attachment) return;
    const newMsg = {
      id: Date.now(),
      from: "me",
      text,
      ts: Date.now(),
      attachment: attachment ? { name: attachment.name, size: attachment.size } : null,
    };

    setConversations((prev) =>
      prev.map((c) => (c.id === activeId ? { ...c, messages: [...c.messages, newMsg], last: text || (attachment && attachment.name) } : c))
    );
    setInput("");
    setAttachment(null);

    // Simple mock bot reply for demo
    setTimeout(() => {
      const botReply = { id: Date.now() + 1, from: "bot", text: "Got it — noted.", ts: Date.now() };
      setConversations((prev) => prev.map((c) => (c.id === activeId ? { ...c, messages: [...c.messages, botReply], last: botReply.text } : c)));
      // scroll
      scrollToBottom();
    }, 600);

    scrollToBottom();
  }

  function scrollToBottom() {
    requestAnimationFrame(() => {
      if (listRef.current) listRef.current.scrollTop = listRef.current.scrollHeight;
    });
  }

  useEffect(() => scrollToBottom(), [activeId]);

  function handleFile(e) {
    const file = e.target.files && e.target.files[0];
    if (file) setAttachment(file);
  }

  function addConversation() {
    const id = `conv-${Date.now()}`;
    const newConv = { id, title: `Chat ${conversations.length + 1}`, last: "", messages: [] };
    setConversations((prev) => [newConv, ...prev]);
    setActiveId(id);
  }

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100">
      <div className="max-w-6xl mx-auto h-screen p-4 grid grid-cols-1 md:grid-cols-4 gap-4">
        {/* Sidebar */}
        <aside className="col-span-1 md:col-span-1 bg-white dark:bg-gray-800 rounded-2xl shadow p-3 flex flex-col">
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-lg font-semibold">Chats</h2>
            <div className="flex items-center gap-2">
              <button
                onClick={() => setIsDark((s) => !s)}
                aria-label="Toggle theme"
                className="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700"
              >
                {isDark ? <Sun size={16} /> : <Moon size={16} />}
              </button>
              <button onClick={addConversation} aria-label="New chat" className="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700">
                <Plus size={16} />
              </button>
            </div>
          </div>

          <div className="flex-1 overflow-auto">
            <ul className="space-y-2">
              {conversations.map((c) => (
                <li key={c.id}>
                  <button
                    onClick={() => setActiveId(c.id)}
                    className={`w-full text-left p-2 rounded-lg flex items-center gap-3 hover:bg-gray-100 dark:hover:bg-gray-700 ${c.id === activeId ? "bg-indigo-50 dark:bg-indigo-800/30" : ""}`}
                  >
                    <div className="w-10 h-10 rounded-full bg-indigo-500 flex items-center justify-center text-white font-bold">{c.title[0]}</div>
                    <div className="flex-1">
                      <div className="flex items-center justify-between">
                        <div className="font-medium">{c.title}</div>
                        <div className="text-xs text-gray-400">{c.messages[c.messages.length - 1] ? formatTs(c.messages[c.messages.length - 1].ts) : ""}</div>
                      </div>
                      <div className="text-sm text-gray-500 dark:text-gray-300 truncate">{c.last}</div>
                    </div>
                  </button>
                </li>
              ))}
            </ul>
          </div>

          <div className="mt-3 text-sm text-gray-500">Built with React + Tailwind • Single-file demo</div>
        </aside>

        {/* Chat area */}
        <main className="col-span-1 md:col-span-3 bg-white dark:bg-gray-800 rounded-2xl shadow flex flex-col overflow-hidden">
          <header className="flex items-center justify-between p-4 border-b border-gray-100 dark:border-gray-700">
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 rounded-full bg-indigo-500 flex items-center justify-center text-white font-bold">{activeConv.title[0]}</div>
              <div>
                <div className="font-semibold">{activeConv.title}</div>
                <div className="text-sm text-gray-500 dark:text-gray-300">Active</div>
              </div>
            </div>
            <div className="text-sm text-gray-500">{new Date().toLocaleString()}</div>
          </header>

          <div className="flex-1 overflow-auto p-6" ref={listRef} id="chat-list">
            <div className="max-w-3xl mx-auto">
              <AnimatePresence initial={false} mode="popLayout">
                {activeConv.messages.map((m) => (
                  <motion.div
                    key={m.id}
                    initial={{ opacity: 0, y: 6 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -6 }}
                    transition={{ duration: 0.18 }}
                    className={`mb-4 flex ${m.from === "me" ? "justify-end" : "justify-start"}`}
                  >
                    <div className={`rounded-2xl p-3 max-w-[70%] ${m.from === "me" ? "bg-indigo-600 text-white" : "bg-gray-100 dark:bg-gray-700 text-gray-900 dark:text-gray-100"}`}>
                      <div className="whitespace-pre-wrap">{m.text}</div>
                      {m.attachment && (
                        <div className="mt-2 text-xs opacity-80">Attachment: {m.attachment.name} • {Math.round((m.attachment.size || 0) / 1024)} KB</div>
                      )}
                      <div className="text-[10px] opacity-60 mt-1 text-right">{new Date(m.ts).toLocaleTimeString()}</div>
                    </div>
                  </motion.div>
                ))}
              </AnimatePresence>
            </div>
          </div>

          <footer className="p-4 border-t border-gray-100 dark:border-gray-700">
            <div className="max-w-3xl mx-auto flex items-end gap-3">
              <label className="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 cursor-pointer">
                <input type="file" className="hidden" onChange={handleFile} />
                <Paperclip size={18} />
              </label>

              <div className="flex-1">
                <textarea
                  value={input}
                  onChange={(e) => setInput(e.target.value)}
                  rows={1}
                  onKeyDown={(e) => {
                    if (e.key === "Enter" && !e.shiftKey) {
                      e.preventDefault();
                      handleSend();
                    }
                  }}
                  placeholder="Type a message... (Shift+Enter for newline)"
                  className="w-full resize-none rounded-xl p-3 border border-gray-200 dark:border-gray-700 bg-transparent outline-none"
                />
                {attachment && (
                  <div className="mt-2 text-xs text-gray-500 dark:text-gray-300">Attached: {attachment.name} • {Math.round(attachment.size / 1024)} KB</div>
                )}
              </div>

              <div className="flex items-center gap-2">
                <button onClick={handleSend} className="p-3 rounded-full bg-indigo-600 text-white hover:opacity-90">
                  <Send size={16} />
                </button>
              </div>
            </div>
          </footer>
        </main>
      </div>
    </div>
  );
}

// Helper: format timestamp small
function formatTs(ts) {
  try {
    const d = new Date(ts);
    return d.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
  } catch (e) {
    return "";
  }
}
