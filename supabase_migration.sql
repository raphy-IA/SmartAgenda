-- Migration pour ajouter les colonnes manquantes (si nécessaire)
-- A exécuter dans l'éditeur SQL de Supabase

DO $$ 
BEGIN 
    -- Ajouter 'status' si manquant
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='events' AND column_name='status') THEN
        ALTER TABLE public.events ADD COLUMN status TEXT DEFAULT 'confirmed';
    END IF;

    -- Ajouter 'metadata' si manquant
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='events' AND column_name='metadata') THEN
        ALTER TABLE public.events ADD COLUMN metadata JSONB DEFAULT '{}'::JSONB;
    END IF;
END $$;

-- Table des Profils Utilisateurs (Anti-Burnout & Énergie)
CREATE TABLE IF NOT EXISTS public.user_profiles (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    chronotype TEXT DEFAULT 'neutre' CHECK (chronotype IN ('matin', 'soir', 'neutre')),
    freeze_mode BOOLEAN DEFAULT false,
    work_capacity_limit INT DEFAULT 10,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS (Row Level Security)
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Les utilisateurs peuvent voir leur propre profil" 
ON public.user_profiles FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Les utilisateurs peuvent modifier leur propre profil" 
ON public.user_profiles FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Les utilisateurs peuvent insérer leur propre profil" 
ON public.user_profiles FOR INSERT WITH CHECK (auth.uid() = user_id);
