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
