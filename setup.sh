#!/bin/bash

# DUBAI SPARES CIS - Глобальный экспорт проекта (v1.4)
# Скрипт воссоздает структуру папок и все файлы приложения

echo "🚀 Начинаю экспорт проекта DUBAI SPARES CIS..."

# Создание структуры папок
mkdir -p screens

# 1. Конфигурационные файлы
echo "📄 Создаю конфигурационные файлы..."

cat << 'EOF' > metadata.json
{
  "name": "DUBAI SPARES CIS",
  "description": "Мобильное приложение для закупщика автозапчастей в ОАЭ. Оффлайн-режим, упор на фото и скорость работы.",
  "requestFramePermissions": [
    "camera",
    "geolocation"
  ]
}
EOF

cat << 'EOF' > manifest.webmanifest
{
  "name": "DUBAI SPARES CIS",
  "short_name": "DubaiSpares",
  "description": "Mobile app for spare parts procurement in UAE.",
  "start_url": "index.html",
  "display": "standalone",
  "background_color": "#000000",
  "theme_color": "#000000",
  "orientation": "portrait",
  "icons": [
    {
      "src": "https://cdn-icons-png.flaticon.com/512/3202/3202926.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any maskable"
    }
  ]
}
EOF

cat << 'EOF' > package.json
{
  "name": "dubai-spares-cis",
  "version": "1.4.0",
  "private": true,
  "type": "module",
  "dependencies": {
    "react": "^19.2.4",
    "react-dom": "^19.2.4",
    "react-router-dom": "^7.13.0",
    "lucide-react": "^0.563.0"
  },
  "devDependencies": {
    "@types/react": "^19.0.0",
    "@types/react-dom": "^19.0.0",
    "typescript": "^5.0.0",
    "vite": "^5.0.0",
    "@vitejs/plugin-react": "^4.0.0"
  },
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview"
  }
}
EOF

cat << 'EOF' > tsconfig.json
{
  "compilerOptions": {
    "target": "ESNext",
    "useDefineForClassFields": true,
    "lib": ["DOM", "DOM.Iterable", "ESNext"],
    "allowJs": false,
    "skipLibCheck": true,
    "esModuleInterop": false,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "module": "ESNext",
    "moduleResolution": "Node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx"
  },
  "include": ["./**/*.ts", "./**/*.tsx"]
}
EOF

cat << 'EOF' > vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  build: {
    target: 'esnext',
    outDir: 'dist'
  }
});
EOF

cat << 'EOF' > sw.js
const CACHE_NAME = 'spares-v1.4';
const ASSETS = [
  'index.html',
  'manifest.webmanifest',
  'https://cdn.tailwindcss.com',
  'https://esm.sh/react@^19.2.4',
  'https://esm.sh/react-dom@^19.2.4/',
  'https://esm.sh/react-router-dom@^7.13.0',
  'https://esm.sh/lucide-react@^0.563.0'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(ASSETS))
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((response) => {
      return response || fetch(event.request);
    })
  );
});
EOF

# 2. Основные файлы приложения
echo "📄 Создаю основные файлы приложения..."

cat << 'EOF' > index.html
<!DOCTYPE html>
<html lang="ru" class="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
    <meta name="theme-color" content="#000000">
    <link rel="manifest" href="manifest.webmanifest">
    <title>DUBAI SPARES CIS</title>
    <script src="https://cdn.tailwindcss.com"></script>
<script type="importmap">
{
  "imports": {
    "react-dom/": "https://esm.sh/react-dom@^19.2.4/",
    "vite": "https://esm.sh/vite@^7.3.1",
    "react-router-dom": "https://esm.sh/react-router-dom@^7.13.0",
    "lucide-react": "https://esm.sh/lucide-react@^0.563.0",
    "react": "https://esm.sh/react@^19.2.4",
    "react/": "https://esm.sh/react@^19.2.4/",
    "@vitejs/plugin-react": "https://esm.sh/@vitejs/plugin-react@^5.1.3"
  }
}
</script>
</head>
<body class="antialiased">
    <div id="root"></div>
    <script type="module" src="index.tsx"></script>
    <script>
      if ('serviceWorker' in navigator) {
        window.addEventListener('load', () => {
          navigator.serviceWorker.register('sw.js').then(reg => {
            console.log('SW registered');
          }).catch(err => {
            console.log('SW error', err);
          });
        });
      }
    </script>
</body>
</html>
EOF

cat << 'EOF' > index.tsx
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

const rootElement = document.getElementById('root');
if (!rootElement) {
  throw new Error("Could not find root element to mount to");
}

const root = ReactDOM.createRoot(rootElement);
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF

cat << 'EOF' > types.ts
export interface Car {
  id: string;
  make: string;
  model: string;
  year: string;
  vin?: string;
  media?: string[]; 
  createdAt: number;
}

export interface Part {
  id: string;
  carId: string;
  name: string;
  status: 'active' | 'found';
  referenceMedia: string[]; 
}

export interface Offer {
  id: string;
  partId: string;
  media: string[]; 
  costPrice: string; 
  shopName: string;
  phone: string;
  locationText?: string;
  lat?: number;
  lng?: number;
  createdAt: number;
}

export interface Contact {
  id: string;
  name: string;
  phone: string;
  lastLocationText?: string;
  lastLat?: number;
  lastLng?: number;
  lastUsedAt: number;
  makes: string[]; 
  models: string[]; 
  years: string[];
  media?: string[];
}
EOF

cat << 'EOF' > db.ts
import { Car, Part, Offer, Contact } from './types';

const DB_NAME = 'DubaiSparesDB';
const DB_VERSION = 3; 

export class Database {
  private db: IDBDatabase | null = null;

  async init(): Promise<void> {
    return new Promise((resolve, reject) => {
      const request = indexedDB.open(DB_NAME, DB_VERSION);

      request.onupgradeneeded = (event) => {
        const db = (event.target as IDBOpenDBRequest).result;
        if (!db.objectStoreNames.contains('cars')) db.createObjectStore('cars', { keyPath: 'id' });
        if (!db.objectStoreNames.contains('parts')) db.createObjectStore('parts', { keyPath: 'id' });
        if (!db.objectStoreNames.contains('offers')) db.createObjectStore('offers', { keyPath: 'id' });
        if (!db.objectStoreNames.contains('contacts')) db.createObjectStore('contacts', { keyPath: 'phone' });
      };

      request.onsuccess = () => {
        this.db = request.result;
        resolve();
      };

      request.onerror = () => reject(request.error);
    });
  }

  private getStore(name: string, mode: IDBTransactionMode = 'readonly') {
    if (!this.db) throw new Error('База данных не инициализирована');
    return this.db.transaction(name, mode).objectStore(name);
  }

  async getAll<T>(storeName: string): Promise<T[]> {
    return new Promise((resolve, reject) => {
      try {
        const store = this.getStore(storeName);
        const request = store.getAll();
        request.onsuccess = () => resolve(request.result);
        request.onerror = () => reject(request.error);
      } catch (e) { reject(e); }
    });
  }

  async getById<T>(storeName: string, id: string): Promise<T | undefined> {
    return new Promise((resolve, reject) => {
      try {
        const store = this.getStore(storeName);
        const request = store.get(id);
        request.onsuccess = () => resolve(request.result);
        request.onerror = () => reject(request.error);
      } catch (e) { reject(e); }
    });
  }

  async put<T>(storeName: string, data: T): Promise<void> {
    return new Promise((resolve, reject) => {
      try {
        const store = this.getStore(storeName, 'readwrite');
        const request = store.put(data);
        request.onsuccess = () => resolve();
        request.onerror = () => reject(request.error);
      } catch (e) { reject(e); }
    });
  }

  async deleteCar(carId: string): Promise<void> {
    const allParts = await this.getAll<Part>('parts');
    const carParts = allParts.filter(p => p.carId === carId);
    for (const p of carParts) {
      await this.deletePart(p.id);
    }
    await this.delete('cars', carId);
  }

  async deletePart(partId: string): Promise<void> {
    const allOffers = await this.getAll<Offer>('offers');
    const partOffers = allOffers.filter(o => o.partId === partId);
    for (const offer of partOffers) {
      await this.delete('offers', offer.id);
    }
    await this.delete('parts', partId);
  }

  async delete(storeName: string, id: string): Promise<void> {
    return new Promise((resolve, reject) => {
      if (!this.db) return reject('No DB');
      try {
        const transaction = this.db.transaction(storeName, 'readwrite');
        const store = transaction.objectStore(storeName);
        store.delete(id);
        transaction.oncomplete = () => resolve();
        transaction.onerror = () => reject(transaction.error);
      } catch (e) { reject(e); }
    });
  }

  async saveOffer(offer: Offer, car: Car): Promise<void> {
    if (!this.db) throw new Error('DB not ready');
    const cleanPhone = offer.phone.replace(/\D/g, '');
    const sanitizedOffer = { ...offer, phone: cleanPhone };
    
    return new Promise((resolve, reject) => {
      const tx = this.db!.transaction(['offers', 'contacts'], 'readwrite');
      const offerStore = tx.objectStore('offers');
      const contactStore = tx.objectStore('contacts');
      
      offerStore.put(sanitizedOffer);
      
      const getContact = contactStore.get(cleanPhone);
      getContact.onsuccess = () => {
        const existing: Contact | undefined = getContact.result;
        const makes = Array.from(new Set([...(existing?.makes || []), car.make.toUpperCase()]));
        const models = Array.from(new Set([...(existing?.models || []), car.model.toUpperCase()]));
        const years = Array.from(new Set([...(existing?.years || []), car.year.toUpperCase()]));

        const contact: Contact = {
          ...existing,
          id: existing?.id || crypto.randomUUID(),
          name: sanitizedOffer.shopName,
          phone: cleanPhone,
          lastLocationText: sanitizedOffer.locationText || existing?.lastLocationText,
          lastLat: sanitizedOffer.lat || existing?.lastLat,
          lastLng: sanitizedOffer.lng || existing?.lastLng,
          lastUsedAt: Date.now(),
          makes,
          models,
          years
        };
        contactStore.put(contact);
      };

      tx.oncomplete = () => resolve();
      tx.onerror = () => reject(tx.error);
    });
  }
}

export const db = new Database();
EOF

cat << 'EOF' > App.tsx
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
EOF

# 3. Экраны приложения
echo "📄 Создаю экраны приложения..."

cat << 'EOF' > screens/Tasks.tsx
import React, { useEffect, useState, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { db } from '../db';
import { Car, Part } from '../types';
import { Plus, Trash2, Car as CarIcon, X, ChevronLeft, ChevronRight } from 'lucide-react';

type CarWithCounts = Car & { partsCount: number };

const CarCard: React.FC<{ 
  car: CarWithCounts; 
  onDelete: (id: string) => void | Promise<void>; 
  onClick: () => void;
  onPhotoClick: (photos: string[]) => void;
}> = ({ car, onDelete, onClick, onPhotoClick }) => {
  const [confirmDelete, setConfirmDelete] = useState(false);

  useEffect(() => {
    if (confirmDelete) {
      const timer = setTimeout(() => setConfirmDelete(false), 3000);
      return () => clearTimeout(timer);
    }
  }, [confirmDelete]);

  const handleDeleteClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (confirmDelete) onDelete(car.id);
    else setConfirmDelete(true);
  };

  const handleImageClick = (e: React.MouseEvent) => {
    if (car.media && car.media.length > 0) {
      e.stopPropagation();
      onPhotoClick(car.media);
    }
  };

  return (
    <div 
      onClick={onClick}
      className={`relative bg-neutral-900/40 border transition-all duration-300 p-4 rounded-[2.5rem] flex items-center gap-4 active-scale shadow-xl animate-fadeIn cursor-pointer ${
        confirmDelete ? 'border-red-500 ring-2 ring-red-500/20' : 'border-white/5'
      }`}
    >
      <div 
        onClick={handleImageClick}
        className="w-20 h-20 rounded-2xl overflow-hidden bg-neutral-950 shrink-0 border border-white/10 relative shadow-inner"
      >
        {car.media && car.media[0] ? (
          <>
            <img src={car.media[0]} className="w-full h-full object-cover" alt="car" />
            {car.media.length > 1 && (
              <div className="absolute bottom-1.5 right-1.5 bg-black/70 backdrop-blur-md px-1.5 py-0.5 rounded text-[8px] font-black text-white border border-white/10">
                +{car.media.length - 1}
              </div>
            )}
          </>
        ) : (
          <div className="w-full h-full flex items-center justify-center text-neutral-800">
            <CarIcon size={36} />
          </div>
        )}
      </div>

      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2 mb-1.5">
          <span className="bg-amber-500 text-black text-[9px] font-black px-1.5 py-0.5 rounded uppercase leading-none shrink-0 shadow-sm">
            {car.year || '—'}
          </span>
          <h3 className="text-lg font-black text-white truncate uppercase tracking-tight leading-none">{car.make} {car.model}</h3>
        </div>
        <div className="flex items-center gap-4">
          <div className="flex flex-col">
            <span className="text-neutral-600 text-[8px] font-black uppercase tracking-[0.15em]">ДЕТАЛИ</span>
            <span className="text-white font-black text-sm leading-none mt-1">{car.partsCount}</span>
          </div>
          {car.vin && (
            <div className="flex flex-col border-l border-white/5 pl-4 min-w-0">
              <span className="text-neutral-600 text-[8px] font-black uppercase tracking-[0.15em]">VIN</span>
              <span className="text-neutral-400 font-mono text-[10px] truncate mt-1 uppercase tracking-tighter">{car.vin}</span>
            </div>
          )}
        </div>
      </div>
      
      <div className="flex items-center gap-1 shrink-0">
        <button 
          onClick={handleDeleteClick}
          className={`relative flex items-center justify-center transition-all duration-300 rounded-2xl h-12 overflow-hidden ${
            confirmDelete ? 'bg-red-600 text-white w-24 px-2' : 'w-12 text-neutral-800 bg-neutral-800/20'
          }`}
        >
          {confirmDelete ? <span className="text-[10px] font-black uppercase tracking-tighter whitespace-nowrap">УДАЛИТЬ?</span> : <Trash2 size={22} />}
        </button>
      </div>
    </div>
  );
};

const Tasks: React.FC = () => {
  const [cars, setCars] = useState<CarWithCounts[]>([]);
  const [gallery, setGallery] = useState<{ photos: string[], index: number } | null>(null);
  const navigate = useNavigate();

  const loadData = useCallback(async () => {
    const allCars = await db.getAll<Car>('cars');
    const allParts = await db.getAll<Part>('parts');
    const data = allCars.map(car => ({
      ...car,
      partsCount: allParts.filter(p => p.carId === car.id).length
    })).sort((a,b) => b.createdAt - a.createdAt);
    setCars(data);
  }, []);

  useEffect(() => { loadData(); }, [loadData]);

  const handleDelete = async (id: string) => {
    await db.deleteCar(id);
    loadData();
  };

  return (
    <div className="flex flex-col h-full bg-black">
      <header className="p-6 pt-safe shrink-0 glass border-b border-white/5 z-20 shadow-2xl">
        <h1 className="text-4xl font-black text-white tracking-tighter leading-none uppercase">Заказы</h1>
        <div className="flex items-center gap-3 mt-3">
            <div className="h-1 w-8 bg-amber-500 rounded-full" />
            <p className="text-neutral-500 font-black text-[11px] uppercase tracking-[0.2em]">Dubai Spares CIS</p>
        </div>
      </header>

      <div className="scroll-container no-scrollbar p-6 space-y-4 pb-40">
        {cars.length === 0 ? (
          <div className="bg-neutral-900/30 rounded-[3.5rem] py-24 px-10 text-center border border-dashed border-white/5 animate-fadeIn">
            <CarIcon size={64} className="mx-auto mb-6 text-neutral-900" />
            <p className="text-neutral-600 font-black uppercase text-[11px] tracking-[0.2em] leading-relaxed max-w-[200px] mx-auto">Нажмите кнопку ПЛЮС чтобы создать первый заказ</p>
          </div>
        ) : (
          cars.map(car => (
            <CarCard key={car.id} car={car} onDelete={handleDelete} onClick={() => navigate(`/car/${car.id}`)} onPhotoClick={(photos) => setGallery({ photos, index: 0 })} />
          ))
        )}
      </div>

      <div 
        className="fixed right-6 z-[90]" 
        style={{ bottom: 'calc(var(--nav-height) + 1.5rem)' }}
      >
        <button 
          onClick={() => navigate('/new')} 
          className="w-18 h-18 bg-amber-500 rounded-[1.75rem] shadow-2xl shadow-amber-500/30 flex items-center justify-center text-black active-scale border-4 border-black transition-all p-4"
        >
          <Plus size={40} strokeWidth={3.5} />
        </button>
      </div>

      {gallery && (
        <div className="fixed inset-0 z-[300] bg-black/98 flex flex-col animate-fadeIn">
          <button onClick={() => setGallery(null)} className="absolute top-safe right-6 p-4 text-white z-[310] active-scale"><X size={36} /></button>
          <div className="flex-1 flex items-center justify-center relative px-4">
            {gallery.photos.length > 1 && (
              <>
                <button onClick={() => setGallery({ ...gallery, index: gallery.index > 0 ? gallery.index - 1 : gallery.photos.length - 1 })} className="absolute left-4 p-4 text-white/50 active-scale"><ChevronLeft size={54} /></button>
                <button onClick={() => setGallery({ ...gallery, index: gallery.index < gallery.photos.length - 1 ? gallery.index + 1 : 0 })} className="absolute right-4 p-4 text-white/50 active-scale shadow-2xl"><ChevronRight size={54} /></button>
              </>
            )}
            <img src={gallery.photos[gallery.index]} className="max-w-full max-h-[85vh] object-contain rounded-3xl shadow-2xl" key={gallery.index} />
          </div>
        </div>
      )}
    </div>
  );
};

export default Tasks;
EOF

cat << 'EOF' > screens/NewOrder.tsx
import React, { useState, useRef, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { db } from '../db';
import { ArrowLeft, Camera, X, Loader2, Plus, Trash2 } from 'lucide-react';

interface PartDraft { id: string; name: string; photos: string[]; }

const NewOrder: React.FC = () => {
  const navigate = useNavigate();
  const fileInputRef = useRef<HTMLInputElement>(null);
  const carPhotoInputRef = useRef<HTMLInputElement>(null);
  
  const modelRef = useRef<HTMLInputElement>(null);
  const yearRef = useRef<HTMLInputElement>(null);
  const vinRef = useRef<HTMLInputElement>(null);
  const partNameRef = useRef<HTMLInputElement>(null);

  const [isProcessing, setIsProcessing] = useState(false);
  const [activePartId, setActivePartId] = useState<string | null>(null);
  const [carForm, setCarForm] = useState({ make: '', model: '', year: '', vin: '' });
  const [carPhotos, setCarPhotos] = useState<string[]>([]);
  const [partNameInput, setPartNameInput] = useState('');
  const [parts, setParts] = useState<PartDraft[]>([]);
  const [confirmDeletePart, setConfirmDeletePart] = useState<string | null>(null);

  useEffect(() => {
    if (confirmDeletePart) {
      const timer = setTimeout(() => setConfirmDeletePart(null), 3000);
      return () => clearTimeout(timer);
    }
  }, [confirmDeletePart]);

  const addPart = () => {
    if (!partNameInput.trim()) return;
    setParts([...parts, { id: crypto.randomUUID(), name: partNameInput.trim().toUpperCase(), photos: [] }]);
    setPartNameInput('');
    setTimeout(() => partNameRef.current?.focus(), 10);
  };

  const handleCapture = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files || []) as File[];
    if (files.length === 0 || !activePartId) return;
    setIsProcessing(true);
    let processed = 0;
    const newPhotos: string[] = [];
    files.forEach(file => {
      const reader = new FileReader();
      reader.onloadend = () => {
        newPhotos.push(reader.result as string);
        if (++processed === files.length) {
          setParts(prev => prev.map(p => p.id === activePartId ? { ...p, photos: [...p.photos, ...newPhotos] } : p));
          setIsProcessing(false);
          setActivePartId(null);
        }
      };
      reader.readAsDataURL(file);
    });
    e.target.value = '';
  };

  const handleCarPhoto = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files || []) as File[];
    if (files.length === 0) return;
    setIsProcessing(true);
    let processed = 0;
    const newPhotos: string[] = [];
    files.forEach(file => {
      const reader = new FileReader();
      reader.onloadend = () => {
        newPhotos.push(reader.result as string);
        if (++processed === files.length) {
          setCarPhotos(prev => [...prev, ...newPhotos]);
          setIsProcessing(false);
        }
      };
      reader.readAsDataURL(file);
    });
    e.target.value = '';
  };

  const handleSave = async () => {
    if (!carForm.make || !carForm.model || parts.length === 0) {
      alert('Заполните данные и добавьте хотя бы одну деталь'); return;
    }
    const carId = crypto.randomUUID();
    await db.put('cars', { ...carForm, id: carId, media: carPhotos, createdAt: Date.now() });
    for (const p of parts) {
      await db.put('parts', { id: crypto.randomUUID(), carId, name: p.name, status: 'active', referenceMedia: p.photos });
    }
    navigate(`/car/${carId}`);
  };

  const inputStyle = "w-full bg-neutral-900 border border-white/5 rounded-2xl px-5 py-4 text-white focus:border-amber-500 outline-none font-bold uppercase transition-all text-base placeholder:text-neutral-700 min-w-0 shadow-inner";
  const labelStyle = "text-neutral-600 text-[10px] font-black uppercase mb-2 block ml-2 tracking-[0.15em]";

  const handleEnter = (e: React.KeyboardEvent, nextRef: React.RefObject<HTMLInputElement>) => {
    if (e.key === 'Enter') {
      e.preventDefault();
      nextRef.current?.focus();
    }
  };

  return (
    <div className="flex flex-col h-full bg-black relative">
      <header className="p-4 glass border-b border-white/10 pt-safe shrink-0 z-[100] shadow-lg flex items-center gap-4">
        <button onClick={() => navigate('/')} className="p-3 bg-neutral-900 rounded-2xl text-neutral-400 border border-white/5 active-scale transition-all shadow-inner"><ArrowLeft size={20} /></button>
        <h1 className="text-lg font-black uppercase tracking-tight">Новый заказ</h1>
      </header>

      <div className="scroll-container no-scrollbar px-5 pt-8 pb-[400px]">
        <div className="space-y-10">
          <section className="space-y-4">
            <label className={labelStyle}>ФОТО АВТОМОБИЛЯ / ТЕХПАСПОРТА</label>
            <div className="flex gap-4 overflow-x-auto no-scrollbar pb-2">
               {carPhotos.map((img, i) => (
                 <div key={i} className="w-32 h-32 rounded-3xl overflow-hidden border border-white/10 shrink-0 relative shadow-2xl">
                   <img src={img} className="w-full h-full object-cover" />
                   <button onClick={() => setCarPhotos(prev => prev.filter((_, idx) => idx !== i))} className="absolute top-2 right-2 w-8 h-8 bg-black/70 backdrop-blur-md rounded-xl text-white active-scale flex items-center justify-center"><X size={16}/></button>
                 </div>
               ))}
               <button onClick={() => carPhotoInputRef.current?.click()} className="w-32 h-32 rounded-3xl border-2 border-dashed border-white/10 flex flex-col items-center justify-center text-neutral-600 bg-neutral-950 active-scale shrink-0 shadow-lg">
                 {isProcessing && !activePartId ? <Loader2 size={32} className="animate-spin text-amber-500" /> : <Camera size={40} />}
                 <span className="text-[9px] font-black mt-3 uppercase tracking-widest">ДОБАВИТЬ</span>
               </button>
            </div>
            <input ref={carPhotoInputRef} type="file" accept="image/*" multiple className="hidden" onChange={handleCarPhoto} />
          </section>

          <section className="space-y-5">
            <label className={labelStyle}>ДАННЫЕ АВТОМОБИЛЯ</label>
            <div className="grid grid-cols-2 gap-4">
              <input type="text" placeholder="МАРКА" className={inputStyle} value={carForm.make} onChange={e => setCarForm({...carForm, make: e.target.value.toUpperCase()})} onKeyDown={(e) => handleEnter(e, modelRef)} />
              <input ref={modelRef} type="text" placeholder="МОДЕЛЬ" className={inputStyle} value={carForm.model} onChange={e => setCarForm({...carForm, model: e.target.value.toUpperCase()})} onKeyDown={(e) => handleEnter(e, yearRef)} />
            </div>
            <div className="grid grid-cols-[100px_1fr] gap-4">
              <input ref={yearRef} type="number" inputMode="numeric" placeholder="ГОД" className={inputStyle} value={carForm.year} onChange={e => setCarForm({...carForm, year: e.target.value})} onKeyDown={(e) => handleEnter(e, vinRef)} />
              <input 
                ref={vinRef} 
                type="text" 
                placeholder="VIN КОД" 
                className={`${inputStyle} font-mono tracking-tight text-base`} 
                value={carForm.vin} 
                autoCapitalize="characters"
                autoCorrect="off"
                spellCheck="false"
                onChange={e => setCarForm({...carForm, vin: e.target.value.toUpperCase()})} 
                onKeyDown={(e) => handleEnter(e, partNameRef)} 
              />
            </div>
          </section>

          <section className="space-y-5">
            <label className={labelStyle}>СПИСОК ДЕТАЛЕЙ</label>
            <div className="flex gap-3">
              <input ref={partNameRef} type="text" placeholder="НАЗВАНИЕ ДЕТАЛИ..." className={inputStyle} value={partNameInput} onChange={e => setPartNameInput(e.target.value)} onKeyDown={e => e.key === 'Enter' && addPart()} />
              <button onClick={addPart} className="bg-amber-500 text-black w-16 h-16 rounded-2xl active-scale flex items-center justify-center shadow-xl shrink-0 border-4 border-black"><Plus size={32} strokeWidth={4} /></button>
            </div>
            <div className="space-y-5">
              {parts.length === 0 && (
                <div className="py-16 text-center bg-neutral-900/10 rounded-[3rem] border border-dashed border-white/5">
                  <p className="text-neutral-700 text-[11px] font-black uppercase tracking-[0.3em]">СПИСОК ПУСТ</p>
                </div>
              )}
              {parts.map(p => (
                <div key={p.id} className="bg-neutral-900/40 border border-white/5 p-6 rounded-[2.5rem] animate-fadeIn shadow-2xl">
                  <div className="flex justify-between items-center mb-5 ml-2">
                    <h4 className="font-black uppercase text-white tracking-tight text-base leading-tight truncate mr-2">{p.name}</h4>
                    <button 
                      onClick={() => {
                        if (confirmDeletePart === p.id) {
                          setParts(prev => prev.filter(item => item.id !== p.id));
                          setConfirmDeletePart(null);
                        } else {
                          setConfirmDeletePart(p.id);
                        }
                      }} 
                      className={`w-12 h-12 flex items-center justify-center transition-all active-scale rounded-xl ${confirmDeletePart === p.id ? 'bg-red-500 text-white' : 'text-neutral-700 bg-neutral-950/50'}`}
                    >
                      {confirmDeletePart === p.id ? <X size={20}/> : <Trash2 size={20}/>}
                    </button>
                  </div>
                  <div className="flex gap-4 overflow-x-auto no-scrollbar pb-1">
                    {p.photos.map((img, i) => (
                      <div key={i} className="w-24 h-24 rounded-2xl overflow-hidden shrink-0 border border-white/10 shadow-lg"><img src={img} className="w-full h-full object-cover" /></div>
                    ))}
                    <button onClick={() => { setActivePartId(p.id); fileInputRef.current?.click(); }} className="w-24 h-24 rounded-2xl border-2 border-dashed border-white/10 flex flex-col items-center justify-center text-neutral-600 bg-neutral-950 active-scale shrink-0 transition-all hover:bg-neutral-900 shadow-inner">
                      {isProcessing && activePartId === p.id ? <Loader2 size={24} className="animate-spin text-amber-500" /> : <Camera size={32} />}
                      <span className="text-[8px] font-black mt-2 uppercase tracking-widest">ФОТО</span>
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </section>
        </div>
      </div>
      
      <input ref={fileInputRef} type="file" accept="image/*" multiple className="hidden" onChange={handleCapture} />
      
      <div className="action-bar-fixed p-6 pt-10">
          <button onClick={handleSave} className="w-full h-18 bg-amber-500 text-black font-black text-xl rounded-2xl shadow-[0_20px_60px_rgba(245,158,11,0.3)] active-scale border-4 border-black uppercase tracking-tight transition-all">
            Создать заказ
          </button>
      </div>
    </div>
  );
};

export default NewOrder;
EOF

cat << 'EOF' > screens/CarDetail.tsx
import React, { useEffect, useState, useRef } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { db } from '../db';
import { Car, Part, Offer } from '../types';
import { ArrowLeft, Plus, Trash2, FileText, CheckCircle2, Share2, X, ChevronLeft, ChevronRight, TrendingUp, ChevronDown, ChevronUp, Camera, Loader2 } from 'lucide-react';

const CarDetail: React.FC = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [car, setCar] = useState<Car | null>(null);
  const [parts, setParts] = useState<(Part & { offers: Offer[] })[]>([]);
  const [isReportMode, setIsReportMode] = useState(false);
  const [isPanelCollapsed, setIsPanelCollapsed] = useState(false);
  const [selectedOffers, setSelectedOffers] = useState<Record<string, string>>({});
  const [markup, setMarkup] = useState(15);
  const [usdRate, setUsdRate] = useState('3.67');
  const [tjsRate, setTjsRate] = useState('2.9');
  const [gallery, setGallery] = useState<{ photos: string[], index: number } | null>(null);
  const [isAddingPart, setIsAddingPart] = useState(false);
  const [newPartName, setNewPartName] = useState('');
  const [newPartPhotos, setNewPartPhotos] = useState<string[]>([]);
  const [isProcessing, setIsProcessing] = useState(false);
  
  const partInputRef = useRef<HTMLInputElement>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const loadData = async () => {
    if (!id) return;
    const carData = await db.getById<Car>('cars', id);
    if (!carData) return;
    setCar(carData);
    const allParts = await db.getAll<Part>('parts');
    const carParts = allParts.filter(p => p.carId === id);
    const allOffers = await db.getAll<Offer>('offers');
    setParts(carParts.map(p => ({ ...p, offers: allOffers.filter(o => o.partId === p.id).sort((a,b) => b.createdAt - a.createdAt) })));
  };

  useEffect(() => { loadData(); }, [id]);

  const handleAddPart = async () => {
    if (!newPartName.trim()) { setIsAddingPart(false); return; }
    await db.put('parts', { 
      id: crypto.randomUUID(), 
      carId: id!, 
      name: newPartName.toUpperCase(), 
      status: 'active', 
      referenceMedia: newPartPhotos 
    });
    setNewPartName('');
    setNewPartPhotos([]);
    setIsAddingPart(false);
    loadData();
  };

  const handleCapture = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files || []) as File[];
    if (files.length === 0) return;
    setIsProcessing(true);
    let processed = 0;
    const newPhotos: string[] = [];
    files.forEach(file => {
      const reader = new FileReader();
      reader.onloadend = () => {
        newPhotos.push(reader.result as string);
        if (++processed === files.length) {
          setNewPartPhotos(prev => [...prev, ...newPhotos]);
          setIsProcessing(false);
        }
      };
      reader.readAsDataURL(file);
    });
    e.target.value = '';
  };

  const calculateFinance = () => {
    const reportParts = parts.filter(p => selectedOffers[p.id]);
    const costPriceTotal = reportParts.reduce((sum, p) => {
      const offer = p.offers.find(o => o.id === selectedOffers[p.id]);
      return sum + (offer ? parseFloat(offer.costPrice) : 0);
    }, 0);
    const finalPriceTotal = Math.ceil(costPriceTotal * (1 + markup / 100));
    const profit = finalPriceTotal - costPriceTotal;
    const uRate = parseFloat(usdRate) || 3.67;
    const tRate = parseFloat(tjsRate) || 2.9;
    const finalUSD = Math.ceil(finalPriceTotal / uRate);
    const finalTJS = Math.ceil(finalPriceTotal * tRate);
    return { costPriceTotal, finalPriceTotal, profit, finalUSD, finalTJS };
  };

  const { finalPriceTotal, profit, finalUSD, finalTJS } = calculateFinance();

  const generateReport = () => {
    const win = window.open('', '_blank'); 
    if (!win || !car) return;
    const reportParts = parts.filter(p => selectedOffers[p.id]);
    const html = `
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OFFER - ${car.make} ${car.model}</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;700;900&display=swap');
        body { font-family: 'Inter', sans-serif; margin: 0; padding: 0; background: #fff; color: #000; line-height: 1.4; }
        .page { max-width: 800px; margin: 0 auto; padding: 40px; }
        .header { display: flex; justify-content: space-between; align-items: flex-end; border-bottom: 4px solid #000; padding-bottom: 20px; margin-bottom: 30px; }
        .brand { font-weight: 900; font-size: 24px; text-transform: uppercase; letter-spacing: -1px; }
        .brand span { color: #f59e0b; }
        .car-info h1 { font-size: 32px; font-weight: 900; margin: 0; text-transform: uppercase; }
        .car-info p { margin: 5px 0 0; font-weight: 700; color: #666; font-size: 14px; text-transform: uppercase; letter-spacing: 1px; }
        .summary { background: #000; color: #fff; padding: 30px; border-radius: 20px; margin-bottom: 40px; }
        .summary-label { font-size: 11px; font-weight: 900; opacity: 0.6; text-transform: uppercase; letter-spacing: 2px; }
        .summary-main { display: flex; justify-content: space-between; align-items: baseline; margin-top: 10px; }
        .summary-value { font-size: 42px; font-weight: 900; color: #f59e0b; }
        .currency-block { display: flex; gap: 30px; margin-top: 20px; border-top: 1px solid rgba(255,255,255,0.1); padding-top: 15px; }
        .cur-item { display: flex; flex-direction: column; }
        .cur-val { font-size: 22px; font-weight: 900; color: #fff; }
        .items-grid { display: grid; grid-template-columns: 1fr; gap: 20px; }
        .part-item { border: 2px solid #f0f0f0; border-radius: 20px; padding: 15px; display: flex; gap: 20px; page-break-inside: avoid; }
        .part-img { width: 150px; height: 150px; border-radius: 12px; object-fit: cover; background: #f9f9f9; flex-shrink: 0; }
        .part-details { flex: 1; display: flex; flex-direction: column; justify-content: center; }
        .part-name { font-size: 18px; font-weight: 900; text-transform: uppercase; margin-bottom: 5px; }
        .part-price { font-size: 24px; font-weight: 900; color: #000; }
        .footer { margin-top: 60px; border-top: 1px solid #eee; padding-top: 20px; font-size: 11px; color: #999; text-align: center; text-transform: uppercase; font-weight: 700; letter-spacing: 1px; }
    </style>
</head>
<body>
    <div class="page">
        <div class="header">
            <div class="car-info">
                <h1>${car.make} ${car.model}</h1>
                <p>Year: ${car.year} ${car.vin ? `• VIN: ${car.vin}` : ''}</p>
            </div>
            <div class="brand">DUBAI<span>SPARES</span></div>
        </div>
        <div class="summary">
            <div class="summary-label">Commercial Offer • Total Cost</div>
            <div class="summary-main">
                <div class="summary-value">${finalPriceTotal.toLocaleString()} AED</div>
                <div style="font-size: 12px; font-weight: 700; text-align: right; opacity: 0.8;">Dubai, UAE • Export Grade</div>
            </div>
            <div class="currency-block">
                <div class="cur-item"><span class="summary-label">USD (Rate: ${usdRate})</span><span class="cur-val">$ ${finalUSD.toLocaleString()}</span></div>
                <div class="cur-item"><span class="summary-label">SOMONI (Rate: ${tjsRate})</span><span class="cur-val">${finalTJS.toLocaleString()} TJS</span></div>
            </div>
        </div>
        <div class="items-grid">
            ${reportParts.map(p => {
                const offer = p.offers.find(o => o.id === selectedOffers[p.id]);
                if (!offer) return '';
                const finalPrice = Math.ceil(parseFloat(offer.costPrice) * (1 + markup / 100));
                return `
                    <div class="part-item">
                        ${offer.media[0] ? `<img src="${offer.media[0]}" class="part-img" />` : '<div class="part-img" style="background: #f0f0f0; display: flex; align-items: center; justify-content: center; font-size: 10px; color: #ccc;">NO PHOTO</div>'}
                        <div class="part-details">
                            <div class="part-name">${p.name}</div>
                            <div class="part-price">${finalPrice.toLocaleString()} AED</div>
                            <div style="font-size: 11px; font-weight: 700; color: #bbb; margin-top: 4px; text-transform: uppercase;">Premium Replacement Parts</div>
                        </div>
                    </div>
                `;
            }).join('')}
        </div>
        <div class="footer">Dubai Spares CIS • Premium Service • Valid for 48 hours • ${new Date().toLocaleDateString('ru-RU')}</div>
    </div>
</body>
</html>`;
    win.document.write(html); 
    win.document.close();
  };

  if (!car) return null;

  return (
    <div className="flex flex-col h-full bg-black relative">
      <header className="p-4 glass border-b border-white/10 pt-safe shrink-0 flex items-center justify-between z-[120] shadow-2xl">
        <div className="flex items-center gap-4">
          <button onClick={() => isReportMode ? setIsReportMode(false) : navigate('/')} className="p-2.5 bg-neutral-900 rounded-xl text-neutral-400 active-scale border border-white/5 shadow-inner transition-all">
            <ArrowLeft size={20} />
          </button>
          <div className="min-w-0">
            <h1 className="text-base font-black uppercase text-white truncate leading-tight">{car.make} {car.model}</h1>
            <p className="text-amber-500 text-[9px] font-black uppercase tracking-widest mt-0.5 opacity-80">{car.year}</p>
          </div>
        </div>
        <button onClick={() => setIsReportMode(!isReportMode)} className={`p-2.5 rounded-xl border active-scale shadow-lg transition-all ${isReportMode ? 'bg-amber-500 text-black border-amber-500' : 'bg-neutral-800 text-neutral-500 border-white/5'}`}>
          {isReportMode ? <X size={20} /> : <FileText size={20} />}
        </button>
      </header>

      <div className={`scroll-container no-scrollbar p-5 space-y-3 ${isReportMode ? 'pb-[850px]' : (isAddingPart ? 'pb-[450px]' : 'pb-[350px]')}`}>
        {car.media && car.media.length > 0 && !isReportMode && (
          <div className="flex gap-3 overflow-x-auto no-scrollbar mb-4">
            {car.media.map((img, i) => (
              <div key={i} onClick={() => setGallery({ photos: car.media || [], index: i })} className="w-32 h-20 rounded-2xl overflow-hidden border border-white/10 shrink-0 shadow-lg bg-neutral-900 active-scale">
                <img src={img} className="w-full h-full object-cover" />
              </div>
            ))}
          </div>
        )}
        
        {parts.map(p => (
          <div key={p.id} className="animate-fadeIn">
            <div onClick={() => !isReportMode && navigate(`/part/${p.id}`)} className={`bg-neutral-900/40 border p-4 rounded-[1.5rem] flex items-center justify-between active-scale transition-all ${isReportMode && !selectedOffers[p.id] ? 'opacity-30 border-white/5' : 'border-white/10'}`}>
              <div className="flex-1 min-w-0 pr-3">
                <h3 className="text-sm font-black text-white uppercase truncate tracking-tight leading-tight">{p.name}</h3>
                <p className="text-neutral-600 text-[8px] font-black uppercase tracking-widest">{p.offers.length} ВАР.</p>
              </div>
              {!isReportMode && <button onClick={async (e) => { e.stopPropagation(); await db.deletePart(p.id); loadData(); }} className="text-neutral-800 active-scale hover:text-red-500 p-1.5"><Trash2 size={16} /></button>}
            </div>
            
            {isReportMode && p.offers.length > 0 && (
              <div className="flex gap-2 overflow-x-auto no-scrollbar py-2 px-1">
                {p.offers.map(offer => (
                  <div key={offer.id} onClick={() => setSelectedOffers(prev => ({ ...prev, [p.id]: prev[p.id] === offer.id ? '' : offer.id }))} className={`w-24 h-32 rounded-2xl overflow-hidden border shrink-0 relative transition-all active-scale ${selectedOffers[p.id] === offer.id ? 'border-amber-500 scale-105 shadow-2xl z-10' : 'border-neutral-800 opacity-40 shadow-inner'}`}>
                    <img src={offer.media[0]} className="w-full h-full object-cover" />
                    <div className="absolute inset-x-0 bottom-0 bg-black/80 backdrop-blur-md p-2 text-center text-[10px] font-black text-white uppercase truncate">{offer.costPrice} AED</div>
                    {selectedOffers[p.id] === offer.id && <div className="absolute top-2 right-2 text-amber-500 bg-black/90 rounded-full p-1 border border-amber-500/50 shadow-2xl"><CheckCircle2 size={16} fill="currentColor" className="text-black" /></div>}
                  </div>
                ))}
              </div>
            )}
          </div>
        ))}
      </div>

      {isReportMode && (
        <div className={`fixed bottom-[var(--nav-height)] left-0 right-0 z-[110] glass border-t border-white/10 p-5 pt-2 animate-modalUp shadow-[0_-40px_80px_rgba(0,0,0,1)] max-w-[448px] mx-auto transition-all duration-300 ${isPanelCollapsed ? 'h-32' : 'h-auto'}`}>
          <button 
            onClick={() => setIsPanelCollapsed(!isPanelCollapsed)}
            className="w-12 h-6 mx-auto mb-2 flex items-center justify-center bg-white/5 rounded-full text-neutral-500 active-scale border border-white/5"
          >
            {isPanelCollapsed ? <ChevronUp size={16} /> : <ChevronDown size={16} />}
          </button>

          <div className={`space-y-4 ${isPanelCollapsed ? 'hidden' : 'block'}`}>
            <div className="flex items-end justify-between px-2">
              <div className="space-y-1">
                <div className="flex items-center gap-2 text-green-500/80">
                  <TrendingUp size={10}/>
                  <span className="text-[9px] font-black uppercase tracking-widest">МАРЖА: +{profit.toLocaleString()} AED ({markup}%)</span>
                </div>
                <div className="text-[10px] font-black text-amber-500 uppercase tracking-[0.2em] mt-2 leading-none">ИТОГО КЛИЕНТУ:</div>
                <div className="text-3xl font-black text-white tracking-tighter leading-none mt-1">{finalPriceTotal.toLocaleString()} <span className="text-amber-500 text-xs">AED</span></div>
              </div>
              <div className="text-right space-y-1">
                  <div className="text-[10px] font-black text-white/40 uppercase tracking-tighter leading-none">$ {finalUSD.toLocaleString()}</div>
                  <div className="text-[10px] font-black text-white/40 uppercase tracking-tighter leading-none">{finalTJS.toLocaleString()} TJS</div>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-3 bg-white/5 p-3 rounded-2xl border border-white/5">
              <div className="space-y-1">
                  <label className="text-[7px] font-black text-neutral-500 uppercase tracking-widest ml-1">AED/USD (Rate)</label>
                  <input type="number" step="0.01" value={usdRate} onChange={e => setUsdRate(e.target.value)} className="w-full bg-black/40 border border-white/5 rounded-xl px-3 py-2 text-[12px] font-black text-white outline-none focus:border-amber-500" />
              </div>
              <div className="space-y-1">
                  <label className="text-[7px] font-black text-neutral-500 uppercase tracking-widest ml-1">TJS/AED (Rate)</label>
                  <input type="number" step="0.01" value={tjsRate} onChange={e => setTjsRate(e.target.value)} className="w-full bg-black/40 border border-white/5 rounded-xl px-3 py-2 text-[12px] font-black text-white outline-none focus:border-amber-500" />
              </div>
            </div>

            <div className="flex gap-1.5 overflow-x-auto no-scrollbar py-1">
              {[10, 15, 20, 30, 50, 100].map(v => (
                <button key={v} onClick={() => setMarkup(v)} className={`flex-1 min-w-[54px] py-2.5 rounded-xl text-[10px] font-black border transition-all active-scale ${markup === v ? 'bg-amber-500 text-black border-amber-500 shadow-xl' : 'text-neutral-500 border-white/5 bg-white/5'}`}>+{v}%</button>
              ))}
            </div>
          </div>

          <div className={`mt-3 flex items-center gap-3`}>
            {isPanelCollapsed && (
              <div className="flex-1 min-w-0">
                <div className="text-[8px] font-black text-amber-500 uppercase tracking-widest">ИТОГО КЛИЕНТУ</div>
                <div className="text-xl font-black text-white leading-none mt-1">{finalPriceTotal.toLocaleString()} AED</div>
              </div>
            )}
            <button 
              disabled={Object.values(selectedOffers).filter(v => v !== '').length === 0} 
              onClick={generateReport} 
              className={`${isPanelCollapsed ? 'flex-1 h-12' : 'w-full h-16'} bg-amber-500 text-black rounded-2xl flex items-center justify-center gap-3 font-black text-lg shadow-2xl active-scale border-4 border-black disabled:opacity-20 uppercase tracking-tight transition-all`}
            >
              <Share2 size={22} strokeWidth={3} /> {isPanelCollapsed ? 'PDF' : 'Сформировать PDF'}
            </button>
          </div>
        </div>
      )}

      {!isReportMode && (
        <div className="action-bar-fixed px-5 pb-safe pt-2 max-w-[448px] mx-auto z-[105]">
            {isAddingPart ? (
              <div className="flex flex-col gap-3 animate-fadeIn bg-black/95 p-4 rounded-[2rem] backdrop-blur-xl border border-white/10 shadow-2xl">
                <div className="flex gap-2 overflow-x-auto no-scrollbar">
                   {newPartPhotos.map((img, i) => (
                     <div key={i} className="w-16 h-16 rounded-xl overflow-hidden shrink-0 border border-white/10 relative shadow-lg">
                       <img src={img} className="w-full h-full object-cover" />
                       <button onClick={() => setNewPartPhotos(p => p.filter((_, idx) => idx !== i))} className="absolute top-0.5 right-0.5 p-1 bg-black/60 rounded-lg text-white"><X size={10}/></button>
                     </div>
                   ))}
                   <button onClick={() => fileInputRef.current?.click()} className="w-16 h-16 rounded-xl border-2 border-dashed border-white/5 flex flex-col items-center justify-center text-neutral-700 bg-neutral-900 active-scale shrink-0">
                     {isProcessing ? <Loader2 size={16} className="animate-spin text-amber-500" /> : <Camera size={20} />}
                   </button>
                </div>
                
                <div className="flex gap-2">
                  <input 
                    ref={partInputRef} 
                    autoFocus 
                    type="text" 
                    placeholder="ИМЯ ДЕТАЛИ..." 
                    className="flex-1 bg-neutral-950 border-2 border-amber-500/30 rounded-2xl px-5 py-4 text-white font-black uppercase shadow-inner text-base outline-none focus:border-amber-500" 
                    value={newPartName} 
                    onChange={e => setNewPartName(e.target.value)} 
                    onKeyDown={e => e.key === 'Enter' && handleAddPart()} 
                  />
                  <button onClick={handleAddPart} className="bg-amber-500 text-black px-6 rounded-2xl font-black uppercase text-xs border-2 border-black active-scale shadow-lg">ОК</button>
                  <button onClick={() => { setIsAddingPart(false); setNewPartPhotos([]); }} className="bg-neutral-900 text-neutral-500 px-4 rounded-2xl border border-white/5 active-scale"><X size={20}/></button>
                </div>
                <input ref={fileInputRef} type="file" accept="image/*" multiple className="hidden" onChange={handleCapture} />
              </div>
            ) : (
              <button onClick={() => { setIsAddingPart(true); setTimeout(() => partInputRef.current?.focus(), 150); }} className="w-full h-16 bg-amber-500 text-black rounded-2xl flex items-center justify-center gap-2 font-black text-lg shadow-2xl active-scale border-4 border-black uppercase tracking-tight transition-all">
                <Plus size={24} strokeWidth={3} /> Новая деталь
              </button>
            )}
        </div>
      )}

      {gallery && (
        <div className="fixed inset-0 z-[300] bg-black/98 flex flex-col animate-fadeIn backdrop-blur-2xl">
          <button onClick={() => setGallery(null)} className="absolute top-safe right-6 p-4 text-white z-[310] active-scale shadow-2xl"><X size={36} /></button>
          <div className="flex-1 flex items-center justify-center relative px-4">
            {gallery.photos.length > 1 && (
              <>
                <button onClick={() => setGallery({ ...gallery, index: gallery.index > 0 ? gallery.index - 1 : gallery.photos.length - 1 })} className="absolute left-4 p-4 text-white/50 active-scale shadow-2xl"><ChevronLeft size={64} /></button>
                <button onClick={() => setGallery({ ...gallery, index: gallery.index < gallery.photos.length - 1 ? gallery.index + 1 : 0 })} className="absolute right-4 p-4 text-white/50 active-scale shadow-2xl"><ChevronRight size={64} /></button>
              </>
            )}
            <img src={gallery.photos[gallery.index]} className="max-w-full max-h-[85vh] object-contain rounded-[2.5rem] shadow-2xl border border-white/5 transition-all" key={gallery.index} />
          </div>
        </div>
      )}
    </div>
  );
};

export default CarDetail;
EOF

cat << 'EOF' > screens/PartDetail.tsx
import React, { useEffect, useState, useRef } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { db } from '../db';
import { Part, Car, Offer } from '../types';
import { ArrowLeft, Phone, MessageSquare, Camera, X, Package, ChevronLeft, ChevronRight, Loader2, Eye, EyeOff, Trash2, Plus, MapPin, Navigation, Info } from 'lucide-react';

const OfferCard = ({ offer, clientMode, finalPrice, onDelete, onGalleryOpen }: any) => {
  return (
    <div className={`bg-neutral-900/40 border rounded-[2.5rem] overflow-hidden shadow-2xl animate-fadeIn transition-all border-white/5`}>
      <div className="p-6">
        <div className="flex justify-between items-start mb-4">
          <div className="min-w-0 pr-4">
            <h4 className="text-xl font-black text-white uppercase truncate leading-none mb-1.5">{clientMode ? 'ВАРИАНТ ПОСТАВКИ' : offer.shopName}</h4>
            {!clientMode && <p className="text-neutral-500 text-[10px] font-black uppercase tracking-widest">{offer.phone}</p>}
          </div>
          <div className="text-right">
            <span className="text-2xl font-black text-amber-500 tracking-tighter leading-none">{clientMode ? finalPrice : offer.costPrice} AED</span>
          </div>
        </div>

        {!clientMode && offer.locationText && (
          <div className="flex items-center gap-3 mb-4 bg-black/40 px-4 py-3 rounded-2xl border border-white/5">
            <MapPin size={14} className="text-amber-500 shrink-0" />
            <span className="text-[11px] text-neutral-300 font-bold uppercase truncate flex-1">{offer.locationText}</span>
            {offer.lat && offer.lng && (
              <a 
                href={`https://www.google.com/maps?q=${offer.lat},${offer.lng}`} 
                target="_blank" 
                className="w-8 h-8 flex items-center justify-center bg-amber-500 text-black rounded-lg active-scale"
              >
                <Navigation size={16} />
              </a>
            )}
          </div>
        )}

        <div className="flex gap-3 overflow-x-auto no-scrollbar mb-4">
          {offer.media.map((img: string, i: number) => (
            <div key={i} onClick={() => onGalleryOpen(offer.media, i)} className="w-32 h-32 rounded-3xl overflow-hidden border border-white/10 shrink-0 shadow-xl active-scale">
              <img src={img} className="w-full h-full object-cover" />
            </div>
          ))}
        </div>

        {!clientMode && (
          <div className="flex items-center justify-between border-t border-white/5 pt-5">
            <div className="flex gap-2">
              <a href={`tel:${offer.phone}`} className="p-3.5 bg-neutral-800 rounded-2xl text-amber-500 active-scale border border-white/5 shadow-lg"><Phone size={20} /></a>
              <a href={`https://wa.me/${offer.phone}`} target="_blank" className="p-3.5 bg-neutral-800 rounded-2xl text-green-500 active-scale border border-white/5 shadow-lg"><MessageSquare size={20} /></a>
            </div>
            <button 
              onClick={(e) => { e.stopPropagation(); onDelete(offer.id); }} 
              className="w-12 h-12 flex items-center justify-center text-neutral-700 active-scale hover:text-red-500 transition-colors"
            >
              <Trash2 size={22} />
            </button>
          </div>
        )}
      </div>
    </div>
  );
};

const PartDetail: React.FC = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [part, setPart] = useState<Part | null>(null);
  const [car, setCar] = useState<Car | null>(null);
  const [offers, setOffers] = useState<Offer[]>([]);
  const [showAddModal, setShowAddModal] = useState(false);
  const [galleryMedia, setGalleryMedia] = useState<string[] | null>(null);
  const [galleryIndex, setGalleryIndex] = useState(0);
  const [clientMode, setClientMode] = useState(false);
  const [markup, setMarkup] = useState(15);
  const [newOffer, setNewOffer] = useState({ media: [] as string[], costPrice: '', shopName: '', phone: '', locationText: '', lat: undefined as number | undefined, lng: undefined as number | undefined });
  const [isProcessing, setIsProcessing] = useState(false);
  const [isLocating, setIsLocating] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const shopNameRef = useRef<HTMLInputElement>(null);
  const phoneRef = useRef<HTMLInputElement>(null);
  const addressRef = useRef<HTMLInputElement>(null);
  const priceRef = useRef<HTMLInputElement>(null);

  const loadData = async () => {
    if (!id) return;
    const allParts = await db.getAll<Part>('parts');
    const p = allParts.find(x => x.id === id);
    if (!p) return;
    setPart(p);
    const carData = await db.getById<Car>('cars', p.carId);
    setCar(carData || null);
    const allOffers = await db.getAll<Offer>('offers');
    setOffers(allOffers.filter(o => o.partId === id).sort((a,b) => b.createdAt - a.createdAt));
  };

  useEffect(() => { loadData(); }, [id]);

  const handleLocate = () => {
    setIsLocating(true);
    navigator.geolocation.getCurrentPosition((pos) => {
      const locString = `${pos.coords.latitude.toFixed(5)}, ${pos.coords.longitude.toFixed(5)}`;
      setNewOffer(prev => ({ 
        ...prev, 
        lat: pos.coords.latitude, 
        lng: pos.coords.longitude, 
        locationText: locString 
      }));
      setIsLocating(false);
    }, () => { 
      alert('Ошибка GPS. Проверьте разрешения.'); 
      setIsLocating(false); 
    }, { timeout: 10000, enableHighAccuracy: true });
  };

  const handleSave = async () => {
    if (!newOffer.shopName || !newOffer.costPrice) {
      alert('Укажите магазин и цену');
      return;
    }
    const offerId = crypto.randomUUID();
    const offer: Offer = { 
      id: offerId, 
      partId: id!, 
      ...newOffer, 
      createdAt: Date.now() 
    };
    await db.saveOffer(offer, car!);
    setShowAddModal(false);
    setNewOffer({ media: [], costPrice: '', shopName: '', phone: '', locationText: '', lat: undefined, lng: undefined });
    loadData();
  };

  const handleEnter = (e: React.KeyboardEvent, nextRef: React.RefObject<HTMLInputElement>) => {
    if (e.key === 'Enter') {
      e.preventDefault();
      nextRef.current?.focus();
    }
  };

  if (!part || !car) return null;

  return (
    <div className="flex flex-col h-full bg-black relative">
      <header className="p-4 glass border-b border-white/10 pt-safe shrink-0 flex items-center justify-between z-20 shadow-2xl">
        <div className="flex items-center gap-4">
          <button onClick={() => navigate(`/car/${car.id}`)} className="p-2.5 bg-neutral-900 rounded-xl text-neutral-400 active-scale border border-white/5 shadow-inner"><ArrowLeft size={20} /></button>
          <div className="min-w-0">
            <h1 className="text-base font-black uppercase text-white truncate tracking-tight">{part.name}</h1>
            <p className="text-[9px] text-amber-500 font-black uppercase tracking-widest">{car.make} {car.model}</p>
          </div>
        </div>
        <button onClick={() => setClientMode(!clientMode)} className={`p-2.5 rounded-xl border transition-all active-scale shadow-lg ${clientMode ? 'bg-amber-500 text-black border-amber-500' : 'bg-neutral-800 text-neutral-500 border-white/5'}`}>{clientMode ? <EyeOff size={20} /> : <Eye size={20} />}</button>
      </header>

      <div className="scroll-container no-scrollbar p-5 space-y-6 pb-[400px]">
        <div className="space-y-3">
          <div className="flex items-center gap-2 ml-2"><Info size={12} className="text-amber-500" /><span className="text-[10px] font-black uppercase text-neutral-500 tracking-widest">ОБРАЗЕЦ ДЕТАЛИ</span></div>
          <div className="flex gap-3 overflow-x-auto no-scrollbar pb-2">
            {part.referenceMedia.length > 0 ? part.referenceMedia.map((img, i) => (
              <div key={i} onClick={() => { setGalleryMedia(part.referenceMedia); setGalleryIndex(i); }} className="w-24 h-24 rounded-2xl overflow-hidden border border-white/10 shrink-0 opacity-80 active-scale shadow-xl"><img src={img} className="w-full h-full object-cover" /></div>
            )) : (
              <div className="w-full py-8 text-center bg-neutral-900/20 rounded-2xl border border-dashed border-white/5 text-neutral-700 text-[10px] font-black uppercase tracking-widest">Фото образца нет</div>
            )}
          </div>
        </div>

        {clientMode && (
          <div className="p-5 bg-amber-500/5 border border-amber-500/20 rounded-[2rem] flex flex-col gap-3 shadow-inner">
            <span className="text-[10px] font-black text-amber-500 uppercase tracking-[0.2em] ml-2">ВЫБОР НАЦЕНКИ</span>
            <div className="flex gap-2">
              {[10, 15, 20, 30].map(v => (<button key={v} onClick={() => setMarkup(v)} className={`flex-1 py-3 rounded-xl text-[10px] font-black border transition-all active-scale ${markup === v ? 'bg-amber-500 text-black border-amber-500 shadow-xl' : 'text-amber-500/50 border-amber-500/10 bg-black'}`}>+{v}%</button>))}
            </div>
          </div>
        )}

        <div className="space-y-5">
          {offers.length === 0 ? (
            <div className="text-center py-16">
              <Package size={56} className="mx-auto text-neutral-900 mb-4" />
              <p className="text-neutral-700 text-[10px] font-black uppercase tracking-[0.3em] leading-relaxed">Цены не найдены</p>
            </div>
          ) : (
            offers.map(offer => (
              <OfferCard 
                key={offer.id} 
                offer={offer} 
                clientMode={clientMode} 
                finalPrice={Math.ceil((parseFloat(offer.costPrice) || 0) * (1 + markup/100))} 
                onDelete={async (id: string) => { await db.delete('offers', id); loadData(); }} 
                onGalleryOpen={(m: string[], i: number) => { setGalleryMedia(m); setGalleryIndex(i); }} 
              />
            ))
          )}
        </div>
      </div>

      <div className="action-bar-fixed !bg-transparent">
          <div className="px-5 pb-safe">
            <button onClick={() => setShowAddModal(true)} className="w-full h-16 bg-amber-500 text-black rounded-2xl flex items-center justify-center gap-2 font-black text-lg shadow-2xl active-scale border-4 border-black uppercase tracking-tight">
                <Plus size={24} strokeWidth={3} /> Добавить цену
            </button>
          </div>
      </div>

      {showAddModal && (
        <div className="fixed inset-0 z-[200] flex flex-col bg-black animate-modalUp">
          <header className="p-4 glass border-b border-white/10 pt-safe shrink-0 flex items-center justify-between shadow-2xl">
            <button onClick={() => setShowAddModal(false)} className="p-2.5 bg-neutral-900 rounded-xl text-neutral-400 border border-white/5 active-scale transition-all"><X size={20} /></button>
            <h2 className="text-sm font-black uppercase tracking-widest text-amber-500">Добавление цены</h2>
            <div className="w-10"/>
          </header>
          <div className="flex-1 overflow-y-auto no-scrollbar p-6 space-y-7 pb-40">
            <section className="space-y-3">
              <label className="text-[10px] font-black text-neutral-600 uppercase tracking-widest ml-2">ДАННЫЕ ПОСТАВЩИКА</label>
              <input 
                ref={shopNameRef}
                autoFocus
                type="text" 
                placeholder="НАЗВАНИЕ МАГАЗИНА" 
                className="w-full bg-neutral-900 border border-white/5 rounded-2xl p-5 text-white uppercase font-black outline-none focus:border-amber-500 shadow-inner text-base" 
                value={newOffer.shopName} 
                onChange={e => setNewOffer({...newOffer, shopName: e.target.value})} 
                onKeyDown={(e) => handleEnter(e, phoneRef)}
              />
              <input 
                ref={phoneRef}
                type="tel" 
                inputMode="tel" 
                placeholder="ТЕЛЕФОН" 
                className="w-full bg-neutral-900 border border-white/5 rounded-2xl p-5 text-white font-black outline-none focus:border-amber-500 shadow-inner text-base" 
                value={newOffer.phone} 
                onChange={e => setNewOffer({...newOffer, phone: e.target.value.replace(/\D/g,'')})} 
                onKeyDown={(e) => handleEnter(e, addressRef)}
              />
            </section>
            
            <section className="space-y-3">
              <label className="text-[10px] font-black text-neutral-600 uppercase tracking-widest ml-2">МЕСТОПОЛОЖЕНИЕ</label>
              <div className="flex gap-2">
                <input 
                  ref={addressRef}
                  type="text" 
                  placeholder="АДРЕС ИЛИ КООРДИНАТЫ" 
                  className="flex-1 bg-neutral-900 border border-white/5 rounded-2xl p-5 text-white uppercase font-black outline-none focus:border-amber-500 shadow-inner text-base" 
                  value={newOffer.locationText} 
                  onChange={e => setNewOffer({...newOffer, locationText: e.target.value})} 
                  onKeyDown={(e) => handleEnter(e, priceRef)}
                />
                <button onClick={handleLocate} className="w-16 bg-neutral-800 rounded-2xl text-amber-500 active-scale border border-white/5 flex items-center justify-center shadow-lg transition-all">{isLocating ? <Loader2 className="animate-spin" /> : <MapPin />}</button>
              </div>
            </section>

            <section className="space-y-3">
              <label className="text-[10px] font-black text-neutral-600 uppercase tracking-widest ml-2">СТОИМОСТЬ В AED</label>
              <input 
                ref={priceRef}
                type="number" 
                inputMode="numeric" 
                placeholder="0" 
                className="w-full bg-neutral-900 border border-white/5 rounded-3xl p-8 text-white font-black text-5xl text-center outline-none focus:border-amber-500 shadow-2xl" 
                value={newOffer.costPrice} 
                onChange={e => setNewOffer({...newOffer, costPrice: e.target.value})} 
                onKeyDown={(e) => { if(e.key === 'Enter') handleSave(); }}
              />
            </section>

            <section className="space-y-3">
              <label className="text-[10px] font-black text-neutral-600 uppercase tracking-widest ml-2">ФОТОГРАФИИ</label>
              <div className="flex gap-3 overflow-x-auto no-scrollbar pb-6">
                {newOffer.media.map((img, i) => (
                  <div key={i} className="w-28 h-28 rounded-3xl overflow-hidden relative border border-white/10 shrink-0 shadow-xl">
                    <img src={img} className="w-full h-full object-cover" />
                    <button onClick={() => setNewOffer({...newOffer, media: newOffer.media.filter((_, idx) => idx !== i)})} className="absolute top-2 right-2 p-1.5 bg-black/70 backdrop-blur-md rounded-xl text-white active-scale"><X size={16} /></button>
                  </div>
                ))}
                <button onClick={() => fileInputRef.current?.click()} className="w-28 h-28 rounded-3xl border-2 border-dashed border-white/10 flex flex-col items-center justify-center text-neutral-600 bg-neutral-950 active-scale shrink-0 shadow-lg hover:bg-neutral-900 transition-colors">
                  {isProcessing ? <Loader2 className="animate-spin text-amber-500" /> : <>
                    <Camera size={28} />
                    <span className="text-[8px] font-black mt-2 uppercase tracking-widest">ДОБАВИТЬ</span>
                  </>}
                </button>
              </div>
            </section>
          </div>
          <div className="p-6 pb-safe bg-black border-t border-white/5 shadow-inner">
            <button onClick={handleSave} className="w-full h-18 bg-amber-500 text-black font-black text-xl rounded-2xl border-4 border-black uppercase active-scale shadow-2xl tracking-tighter transition-all">Сохранить вариант</button>
          </div>
          <input ref={fileInputRef} type="file" accept="image/*" multiple className="hidden" onChange={(e) => {
            const files = Array.from(e.target.files || []) as File[]; 
            setIsProcessing(true);
            let processed = 0; 
            const newPhotos: string[] = [];
            if (files.length === 0) { setIsProcessing(false); return; }
            files.forEach(f => {
              const r = new FileReader(); 
              r.onloadend = () => { 
                newPhotos.push(r.result as string); 
                if (++processed === files.length) { 
                  setNewOffer(p => ({...p, media: [...p.media, ...newPhotos]})); 
                  setIsProcessing(false); 
                }
              };
              r.readAsDataURL(f);
            });
          }} />
        </div>
      )}

      {galleryMedia && (
        <div className="fixed inset-0 z-[300] bg-black/98 flex flex-col animate-fadeIn backdrop-blur-xl">
          <button onClick={() => setGalleryMedia(null)} className="absolute top-safe right-6 p-4 text-white z-[310] active-scale shadow-2xl"><X size={36} /></button>
          <div className="flex-1 flex items-center justify-center relative px-4">
            {galleryMedia.length > 1 && (
              <>
                <button onClick={() => setGalleryIndex(p => p > 0 ? p - 1 : galleryMedia.length - 1)} className="absolute left-4 p-4 text-white/50 active-scale shadow-2xl"><ChevronLeft size={64} /></button>
                <button onClick={() => setGalleryIndex(p => p < galleryMedia.length - 1 ? p + 1 : 0)} className="absolute right-4 p-4 text-white/50 active-scale shadow-2xl"><ChevronRight size={64} /></button>
              </>
            )}
            <img src={galleryMedia[galleryIndex]} className="max-w-full max-h-[85vh] object-contain rounded-[2rem] shadow-2xl border border-white/5 transition-all" key={galleryIndex} />
          </div>
        </div>
      )}
    </div>
  );
};

export default PartDetail;
EOF

cat << 'EOF' > screens/Contacts.tsx
import React, { useEffect, useState, useRef } from 'react';
import { db } from '../db';
import { Contact } from '../types';
import { Phone, MessageSquare, MapPin, Search, Users, Trash2, Navigation, Camera, X, Loader2, ChevronLeft, ChevronRight, Calendar, Tag, ShieldCheck } from 'lucide-react';

const ContactCard: React.FC<{ 
  contact: Contact; 
  onDelete: (phone: string) => void;
  onUpdate: () => void;
  onGalleryOpen: (photos: string[], index: number) => void;
}> = ({ contact, onDelete, onUpdate, onGalleryOpen }) => {
  const [confirmDelete, setConfirmDelete] = useState(false);
  const [isUploading, setIsUploading] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  useEffect(() => { 
    if (confirmDelete) { 
      const t = setTimeout(() => setConfirmDelete(false), 3000); 
      return () => clearTimeout(t); 
    } 
  }, [confirmDelete]);

  const handlePhotoUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files || []) as File[];
    if (files.length === 0) return;

    setIsUploading(true);
    let processed = 0;
    const newPhotos: string[] = [];

    files.forEach(file => {
      const reader = new FileReader();
      reader.onloadend = async () => {
        newPhotos.push(reader.result as string);
        if (++processed === files.length) {
          const updatedContact = {
            ...contact,
            media: [...(contact.media || []), ...newPhotos]
          };
          await db.put('contacts', updatedContact);
          setIsUploading(false);
          onUpdate();
        }
      };
      reader.readAsDataURL(file);
    });
  };

  const removePhoto = async (e: React.MouseEvent, index: number) => {
    e.stopPropagation();
    const updatedMedia = (contact.media || []).filter((_, i) => i !== index);
    const updatedContact = { ...contact, media: updatedMedia };
    await db.put('contacts', updatedContact);
    onUpdate();
  };

  return (
    <div className={`bg-neutral-900/60 border p-6 rounded-[2.5rem] flex flex-col gap-6 shadow-2xl relative animate-fadeIn transition-all ${confirmDelete ? 'border-red-500 ring-2 ring-red-500/10' : 'border-white/5'}`}>
      <div className="flex items-start justify-between relative z-10">
        <div className="min-w-0 pr-4">
          <div className="flex items-center gap-2 mb-1">
             <h3 className="text-2xl font-black text-white uppercase truncate leading-none tracking-tighter">{contact.name}</h3>
             {contact.makes.length > 3 && <ShieldCheck size={16} className="text-amber-500 shrink-0" />}
          </div>
          <div className="flex items-center gap-3">
            <span className="text-neutral-500 text-xs font-black tracking-widest">{contact.phone}</span>
            <button onClick={() => confirmDelete ? onDelete(contact.phone) : setConfirmDelete(true)} className="text-neutral-800 p-1 active-scale transition-colors hover:text-red-500">
              {confirmDelete ? <span className="text-red-500 text-[10px] font-black uppercase tracking-tighter">УДАЛИТЬ?</span> : <Trash2 size={16} />}
            </button>
          </div>
        </div>
        <div className="flex gap-2.5">
          <a href={`tel:${contact.phone}`} className="w-14 h-14 bg-neutral-800 rounded-2xl flex items-center justify-center text-amber-500 active-scale shadow-xl border border-white/5"><Phone size={24} /></a>
          <a href={`https://wa.me/${contact.phone}`} target="_blank" className="w-14 h-14 bg-neutral-800 rounded-2xl flex items-center justify-center text-green-500 active-scale shadow-xl border border-white/5"><MessageSquare size={24} /></a>
        </div>
      </div>

      <div className="space-y-3">
        <div className="flex items-center justify-between px-2">
           <p className="text-neutral-600 text-[9px] font-black uppercase tracking-widest">ГАЛЕРЕЯ / ВИЗИТКИ</p>
           <button onClick={() => fileInputRef.current?.click()} className="text-amber-500 active-scale p-1">
             {isUploading ? <Loader2 size={18} className="animate-spin" /> : <Camera size={18} />}
           </button>
        </div>
        <div className="flex gap-3 overflow-x-auto no-scrollbar pb-1 min-h-[80px]">
          {contact.media && contact.media.map((img, i) => (
            <div key={i} onClick={() => onGalleryOpen(contact.media!, i)} className="w-20 h-20 rounded-xl overflow-hidden shrink-0 border border-white/10 relative shadow-lg active-scale">
              <img src={img} className="w-full h-full object-cover" />
              <button onClick={(e) => removePhoto(e, i)} className="absolute top-1 right-1 p-1 bg-black/60 rounded-lg text-white shadow-lg"><X size={10} /></button>
            </div>
          ))}
          {!contact.media?.length && !isUploading && (
            <div onClick={() => fileInputRef.current?.click()} className="w-20 h-20 rounded-xl border-2 border-dashed border-white/5 flex items-center justify-center text-neutral-800 active-scale shadow-inner transition-colors hover:bg-neutral-900"><Camera size={24} /></div>
          )}
        </div>
        <input ref={fileInputRef} type="file" accept="image/*" multiple className="hidden" onChange={handlePhotoUpload} />
      </div>

      <div className="relative z-10 space-y-6 bg-black/20 p-4 rounded-3xl border border-white/5">
        <div className="space-y-4">
           <div>
             <p className="text-neutral-700 text-[9px] font-black uppercase tracking-[0.2em] mb-2.5 flex items-center gap-2"><Tag size={12} className="text-amber-500" /> ПРОФИЛЬНЫЕ МАРКИ</p>
             <div className="flex flex-wrap gap-2">
               {contact.makes.slice(0, 12).map(m => (<span key={m} className="bg-amber-500/10 text-amber-500 text-[10px] font-black px-3 py-1.5 rounded-xl border border-amber-500/10 uppercase tracking-tighter shadow-sm">{m}</span>))}
             </div>
           </div>
           
           <div className="grid grid-cols-2 gap-6 pt-2 border-t border-white/5">
             <div className="min-w-0">
               <p className="text-neutral-700 text-[9px] font-black uppercase tracking-[0.2em] mb-2.5 flex items-center gap-2"><Users size={12} className="text-neutral-500" /> МОДЕЛИ</p>
               <div className="flex flex-col gap-1.5">
                 {contact.models.slice(0, 4).map(m => (<span key={m} className="text-white text-[11px] font-bold uppercase truncate leading-none">/ {m}</span>))}
                 {contact.models.length > 4 && <span className="text-neutral-700 text-[9px] font-black pl-3">+ ЕЩЁ {contact.models.length - 4}</span>}
               </div>
             </div>
             <div>
               <p className="text-neutral-700 text-[9px] font-black uppercase tracking-[0.2em] mb-2.5 flex items-center gap-2"><Calendar size={12} className="text-neutral-500" /> ГОДА</p>
               <div className="flex flex-wrap gap-2">
                 {contact.years.sort((a,b) => parseInt(b)-parseInt(a)).slice(0, 6).map(y => (<span key={y} className="text-white/50 text-[10px] font-black tracking-tighter bg-white/5 px-2 py-1 rounded-lg">{y}</span>))}
               </div>
             </div>
           </div>
        </div>

        <div className="flex items-center gap-4 border-t border-white/5 pt-5">
          <div className="flex-1 min-w-0">
              <p className="text-neutral-600 text-[9px] font-black uppercase tracking-[0.2em] mb-1.5 flex items-center gap-2"><MapPin size={12} className="text-amber-500" /> ЛОКАЦИЯ ПОСЛЕДНЕГО ОРДЕРА</p>
              <p className="text-white text-xs font-bold uppercase truncate">{contact.lastLocationText || "НЕ УКАЗАНА"}</p>
          </div>
          {contact.lastLat && contact.lastLng && (
            <a href={`https://www.google.com/maps?q=${contact.lastLat},${contact.lastLng}`} target="_blank" className="p-4 bg-neutral-800 rounded-2xl text-amber-500 active-scale shadow-xl border border-white/5"><Navigation size={22} /></a>
          )}
        </div>
      </div>
    </div>
  );
};

const Contacts: React.FC = () => {
  const [contacts, setContacts] = useState<Contact[]>([]);
  const [search, setSearch] = useState('');
  const [gallery, setGallery] = useState<{ photos: string[], index: number } | null>(null);

  const loadData = async () => { 
    const data = await db.getAll<Contact>('contacts'); 
    setContacts(data.sort((a, b) => b.lastUsedAt - a.lastUsedAt)); 
  };

  useEffect(() => { loadData(); }, []);

  const filtered = contacts.filter(c => 
    c.name.toLowerCase().includes(search.toLowerCase()) || 
    c.phone.includes(search) || 
    c.makes.some(m => m.toLowerCase().includes(search.toLowerCase())) ||
    c.models.some(m => m.toLowerCase().includes(search.toLowerCase()))
  );

  return (
    <div className="flex flex-col h-full bg-black">
      <header className="p-6 pt-safe shrink-0 glass border-b border-white/5 z-20 shadow-2xl">
        <h1 className="text-5xl font-black text-white tracking-tighter uppercase leading-none">База</h1>
        <p className="text-neutral-600 font-black text-[10px] uppercase tracking-[0.3em] mt-3 ml-1 flex items-center gap-3">
          <div className="w-8 h-1 bg-amber-500 rounded-full" />
          РЕЕСТР ПОСТАВЩИКОВ ОАЭ
        </p>
      </header>
      <div className="scroll-container no-scrollbar p-6 space-y-6">
        <div className="relative animate-fadeIn">
          <Search className="absolute left-6 top-1/2 -translate-y-1/2 text-neutral-700" size={24} />
          <input 
            type="text" 
            placeholder="ПОИСК ПО БАЗЕ..." 
            className="w-full bg-neutral-950 border-2 border-neutral-900 rounded-3xl pl-16 pr-6 py-6 text-white focus:border-amber-500 outline-none font-black placeholder:text-neutral-800 uppercase transition-all shadow-inner text-base" 
            value={search} 
            onChange={e => setSearch(e.target.value)} 
          />
        </div>
        <div className="flex flex-col gap-6">
          {filtered.length === 0 ? (
            <div className="text-center py-32 animate-fadeIn opacity-20">
              <Users size={84} className="mx-auto mb-6 text-white" />
              <p className="font-black uppercase tracking-[0.5em] text-sm">База пуста</p>
            </div>
          ) : (
            filtered.map(c => (
              <ContactCard 
                key={c.phone} 
                contact={c} 
                onUpdate={loadData}
                onDelete={async (p) => { await db.delete('contacts', p); loadData(); }} 
                onGalleryOpen={(photos, index) => setGallery({ photos, index })}
              />
            ))
          )}
        </div>
      </div>

      {gallery && (
        <div className="fixed inset-0 z-[300] bg-black/98 flex flex-col animate-fadeIn backdrop-blur-3xl">
          <button onClick={() => setGallery(null)} className="absolute top-safe right-6 p-4 text-white z-[310] active-scale shadow-2xl"><X size={36} /></button>
          <div className="flex-1 flex items-center justify-center relative px-4">
            {gallery.photos.length > 1 && (
              <>
                <button onClick={() => setGallery({ ...gallery, index: gallery.index > 0 ? gallery.index - 1 : gallery.photos.length - 1 })} className="absolute left-4 p-4 text-white/50 active-scale shadow-2xl"><ChevronLeft size={64} /></button>
                <button onClick={() => setGallery({ ...gallery, index: gallery.index < gallery.photos.length - 1 ? gallery.index + 1 : 0 })} className="absolute right-4 p-4 text-white/50 active-scale shadow-2xl"><ChevronRight size={64} /></button>
              </>
            )}
            <img src={gallery.photos[gallery.index]} className="max-w-full max-h-[85vh] object-contain rounded-[2.5rem] shadow-2xl border border-white/5 transition-all" key={gallery.index} />
          </div>
        </div>
      )}
    </div>
  );
};

export default Contacts;
EOF

echo "✅ Проект успешно экспортирован!"
echo "💡 Для запуска выполните: npm install && npm run dev"
chmod +x setup.sh 2>/dev/null || true