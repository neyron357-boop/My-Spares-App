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

  const handleEnter = (e: React.KeyboardEvent, nextRef: React.RefObject<HTMLInputElement | null>) => {
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
//hi
