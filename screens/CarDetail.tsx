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
