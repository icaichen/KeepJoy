-- Create resell_items table
-- This table tracks items being resold from the declutter process

CREATE TABLE IF NOT EXISTS public.resell_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  declutter_item_id UUID NOT NULL REFERENCES public.declutter_items(id) ON DELETE CASCADE,
  status TEXT NOT NULL CHECK (status IN ('toSell', 'listing', 'sold')),
  platform TEXT CHECK (platform IN ('xianyu', 'zhuanzhuan', 'ebay', 'facebookMarketplace', 'craigslist', 'other')),
  selling_price NUMERIC,
  sold_price NUMERIC,
  sold_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ,
  device_id TEXT
);

-- Create indexes
CREATE INDEX IF NOT EXISTS resell_items_user_id_idx ON public.resell_items(user_id);
CREATE INDEX IF NOT EXISTS resell_items_declutter_item_id_idx ON public.resell_items(declutter_item_id);
CREATE INDEX IF NOT EXISTS resell_items_status_idx ON public.resell_items(status);
CREATE INDEX IF NOT EXISTS resell_items_deleted_at_idx ON public.resell_items(deleted_at);

-- Enable RLS
ALTER TABLE public.resell_items ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their own resell items" ON public.resell_items;
DROP POLICY IF EXISTS "Users can insert their own resell items" ON public.resell_items;
DROP POLICY IF EXISTS "Users can update their own resell items" ON public.resell_items;
DROP POLICY IF EXISTS "Users can delete their own resell items" ON public.resell_items;

-- Create RLS policies
CREATE POLICY "Users can view their own resell items"
  ON public.resell_items FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own resell items"
  ON public.resell_items FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own resell items"
  ON public.resell_items FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own resell items"
  ON public.resell_items FOR DELETE
  USING (auth.uid() = user_id);

-- Create trigger for auto-updating updated_at
DROP TRIGGER IF EXISTS update_resell_items_updated_at ON public.resell_items;
CREATE TRIGGER update_resell_items_updated_at
  BEFORE UPDATE ON public.resell_items
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
