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
