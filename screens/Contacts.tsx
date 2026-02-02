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
