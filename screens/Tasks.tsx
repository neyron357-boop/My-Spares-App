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
