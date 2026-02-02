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
