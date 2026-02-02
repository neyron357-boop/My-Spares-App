import React, { useEffect, useState } from 'react';
import { HashRouter, Routes, Route, Link, useLocation } from 'react-router-dom';
import { PlusCircle, Users, Car as CarIcon } from 'lucide-react';
import { db } from './db';
import Tasks from './screens/Tasks';
import NewOrder from './screens/NewOrder';
import PartDetail from './screens/PartDetail';
import Contacts from './screens/Contacts';
import CarDetail from './screens/CarDetail';

const GlobalStyles = () => (
  <style>{`
    :root {
      --safe-top: env(safe-area-inset-top, 0px);
      --safe-bottom: env(safe-area-inset-bottom, 0px);
      --accent: #f59e0b;
      --nav-height: calc(4.5rem + var(--safe-bottom));
    }
    
    * {
      box-sizing: border-box;
      -webkit-tap-highlight-color: transparent;
      user-select: none;
      -webkit-user-select: none;
      overflow-wrap: break-word;
      word-wrap: break-word;
      word-break: break-word;
    }

    input, textarea {
      user-select: text !important;
      -webkit-user-select: text !important;
      font-size: 16px !important; /* Prevents auto-zoom on iOS */
    }

    body {
      margin: 0;
      padding: 0;
      background: black;
      color: white;
      font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display", "Helvetica Neue", sans-serif;
      overflow: hidden;
      width: 100vw;
      height: 100vh;
      height: 100dvh;
      position: fixed;
      overscroll-behavior: none;
      overflow-x: hidden;
    }

    .app-container {
      display: flex;
      flex-direction: column;
      height: 100vh;
      height: 100dvh;
      width: 100vw;
      max-width: 448px;
      margin: 0 auto;
      overflow: hidden;
      position: relative;
      background: #000;
    }

    .scroll-container {
      flex: 1;
      overflow-y: auto;
      overflow-x: hidden;
      -webkit-overflow-scrolling: touch;
      padding-bottom: var(--nav-height);
    }

    .no-scrollbar::-webkit-scrollbar {
      display: none;
    }

    .pt-safe { padding-top: var(--safe-top); }
    .pb-safe { padding-bottom: var(--safe-bottom); }
    
    .glass {
      background: rgba(10, 10, 10, 0.94);
      backdrop-filter: blur(30px);
      -webkit-backdrop-filter: blur(30px);
    }

    .active-scale:active {
      transform: scale(0.95);
      opacity: 0.7;
      transition: 0.1s;
    }

    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(12px); }
      to { opacity: 1; transform: translateY(0); }
    }
    .animate-fadeIn { animation: fadeIn 0.4s cubic-bezier(0.16, 1, 0.3, 1) forwards; }

    @keyframes modalUp {
      from { transform: translateY(100%); }
      to { transform: translateY(0); }
    }
    .animate-modalUp { animation: modalUp 0.5s cubic-bezier(0.32, 0.72, 0, 1) forwards; }

    .action-bar-fixed {
      position: absolute;
      bottom: var(--nav-height);
      left: 0;
      right: 0;
      z-index: 100;
      pointer-events: none;
      padding-bottom: 1rem;
    }

    .action-bar-fixed > * {
      pointer-events: auto;
    }

    button, a {
      min-height: 48px;
      min-width: 48px;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      transition: transform 0.2s cubic-bezier(0.2, 0.8, 0.2, 1);
    }
  `}</style>
);

const BottomNav = () => {
  const location = useLocation();
  const activeClass = "text-amber-500 scale-110";
  const inactiveClass = "text-neutral-600";
  const path = location.pathname;

  const navItems = [
    { path: '/', icon: CarIcon, label: 'АВТО' },
    { path: '/new', icon: PlusCircle, label: 'НОВЫЙ' },
    { path: '/contacts', icon: Users, label: 'БАЗА' },
  ];

  return (
    <nav className="fixed bottom-0 left-0 right-0 glass border-t border-white/5 pb-safe pt-3 px-10 flex justify-between items-center z-[110] h-[var(--nav-height)] max-w-[448px] mx-auto shadow-[0_-15px_40px_rgba(0,0,0,0.7)]">
      {navItems.map((item) => {
        const isActive = path === item.path || (item.path !== '/' && path.startsWith(item.path));
        return (
          <Link 
            key={item.path}
            to={item.path} 
            className={`flex flex-col items-center gap-1.5 transition-all active-scale ${isActive ? activeClass : inactiveClass}`}
          >
            <item.icon size={26} strokeWidth={isActive ? 2.5 : 2} />
            <span className="text-[10px] font-black uppercase tracking-[0.2em]">{item.label}</span>
          </Link>
        );
      })}
    </nav>
  );
};

const App: React.FC = () => {
  const [ready, setReady] = useState(false);

  useEffect(() => {
    db.init().then(() => setReady(true));
  }, []);

  if (!ready) return (
    <div className="flex flex-col items-center justify-center h-screen bg-black text-amber-500 gap-4">
      <div className="w-12 h-12 border-4 border-amber-500/20 border-t-amber-500 rounded-full animate-spin" />
      <span className="font-black text-sm uppercase tracking-[0.5em] animate-pulse">DUBAI SPARES</span>
    </div>
  );

  return (
    <HashRouter>
      <GlobalStyles />
      <div className="app-container">
        <main className="flex-1 relative w-full overflow-hidden">
          <Routes>
            <Route path="/" element={<Tasks />} />
            <Route path="/new" element={<NewOrder />} />
            <Route path="/car/:id" element={<CarDetail />} />
            <Route path="/part/:id" element={<PartDetail />} />
            <Route path="/contacts" element={<Contacts />} />
          </Routes>
        </main>
        <BottomNav />
      </div>
    </HashRouter>
  );
};

export default App;
