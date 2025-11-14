-- Adds JSONB column to store localized item names
ALTER TABLE IF EXISTS public.declutter_items
  ADD COLUMN IF NOT EXISTS name_localizations JSONB;
