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
