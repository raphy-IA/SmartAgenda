-- Architecture Base de Données SmartAgenda AI

-- 1. Table Users (Extension de auth.users si utilisé, sinon table simple pour MVP)
-- Pour le MVP sans Auth complexe, on utilise une table simple, mais on prépare le terrain pour RLS
CREATE TABLE public.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    preferences JSONB DEFAULT '{}'::JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Table Categories
CREATE TABLE public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    color_hex TEXT NOT NULL,
    priority_level INTEGER DEFAULT 5,
    is_default BOOLEAN DEFAULT FALSE
);

-- Données initiales Catégories
INSERT INTO public.categories (name, color_hex, priority_level, is_default) VALUES
('Travail', '#4285F4', 8, TRUE),
('Personnel', '#34A853', 5, FALSE),
('Santé', '#EA4335', 10, FALSE),
('Loisir', '#FBBC05', 3, FALSE);


-- 3. Table Events
CREATE TABLE public.events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID, -- TODO: Ajouter REFERENCES public.users(id) quand auth activé
    title TEXT NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    location TEXT,
    status TEXT DEFAULT 'confirmed', -- confirmed, cancelled
    category_id UUID REFERENCES public.categories(id),
    ai_generated BOOLEAN DEFAULT FALSE,
    metadata JSONB DEFAULT '{}'::JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour performance
CREATE INDEX idx_events_user_id ON public.events(user_id);
CREATE INDEX idx_events_start_time ON public.events(start_time);

-- 4. Sécurité (RLS - Row Level Security)
-- Pour le moment, on autorise tout le monde (accès via clé anonyme) pour le dev
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable all access for anon" ON public.events FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Enable read access for categories" ON public.categories FOR SELECT USING (true);
