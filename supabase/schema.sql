-- KeepJoy Database Schema for Supabase
-- This schema creates all tables with proper foreign keys, indexes, and RLS policies

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- TABLE: declutter_items
-- Stores items that users are decluttering
-- ============================================================================
CREATE TABLE IF NOT EXISTS declutter_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('clothes', 'books', 'papers', 'miscellaneous', 'sentimental', 'beauty')),
  status TEXT NOT NULL CHECK (status IN ('pending', 'keep', 'discard', 'donate', 'recycle', 'resell')),
  photo_path TEXT,
  notes TEXT,
  joy_level INTEGER CHECK (joy_level >= 1 AND joy_level <= 10),
  joy_notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,

  CONSTRAINT declutter_items_user_id_idx UNIQUE (user_id, id)
);

-- Indexes for declutter_items
CREATE INDEX IF NOT EXISTS declutter_items_user_id_idx ON declutter_items(user_id);
CREATE INDEX IF NOT EXISTS declutter_items_status_idx ON declutter_items(status);
CREATE INDEX IF NOT EXISTS declutter_items_created_at_idx ON declutter_items(created_at DESC);

-- RLS Policies for declutter_items
ALTER TABLE declutter_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own declutter items"
  ON declutter_items FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own declutter items"
  ON declutter_items FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own declutter items"
  ON declutter_items FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own declutter items"
  ON declutter_items FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- TABLE: resell_items
-- Stores items that users plan to resell
-- ============================================================================
CREATE TABLE IF NOT EXISTS resell_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  declutter_item_id UUID NOT NULL REFERENCES declutter_items(id) ON DELETE CASCADE,
  status TEXT NOT NULL CHECK (status IN ('toSell', 'listing', 'sold')),
  platform TEXT CHECK (platform IN ('xianyu', 'zhuanzhuan', 'ebay', 'facebookMarketplace', 'craigslist', 'other')),
  selling_price DECIMAL(10, 2),
  sold_price DECIMAL(10, 2),
  sold_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,

  CONSTRAINT resell_items_user_id_idx UNIQUE (user_id, id)
);

-- Indexes for resell_items
CREATE INDEX IF NOT EXISTS resell_items_user_id_idx ON resell_items(user_id);
CREATE INDEX IF NOT EXISTS resell_items_declutter_item_id_idx ON resell_items(declutter_item_id);
CREATE INDEX IF NOT EXISTS resell_items_status_idx ON resell_items(status);

-- RLS Policies for resell_items
ALTER TABLE resell_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own resell items"
  ON resell_items FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own resell items"
  ON resell_items FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own resell items"
  ON resell_items FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own resell items"
  ON resell_items FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- TABLE: deep_cleaning_sessions
-- Stores deep cleaning/organizing sessions
-- ============================================================================
CREATE TABLE IF NOT EXISTS deep_cleaning_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  area TEXT NOT NULL,
  start_time TIMESTAMPTZ NOT NULL,
  before_photo_path TEXT,
  after_photo_path TEXT,
  elapsed_seconds INTEGER,
  items_count INTEGER,
  focus_index INTEGER CHECK (focus_index >= 1 AND focus_index <= 10),
  mood_index INTEGER CHECK (mood_index >= 1 AND mood_index <= 10),
  before_messiness_index DECIMAL(5, 2),
  after_messiness_index DECIMAL(5, 2),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,

  CONSTRAINT deep_cleaning_sessions_user_id_idx UNIQUE (user_id, id)
);

-- Indexes for deep_cleaning_sessions
CREATE INDEX IF NOT EXISTS deep_cleaning_sessions_user_id_idx ON deep_cleaning_sessions(user_id);
CREATE INDEX IF NOT EXISTS deep_cleaning_sessions_start_time_idx ON deep_cleaning_sessions(start_time DESC);
CREATE INDEX IF NOT EXISTS deep_cleaning_sessions_area_idx ON deep_cleaning_sessions(area);

-- RLS Policies for deep_cleaning_sessions
ALTER TABLE deep_cleaning_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own deep cleaning sessions"
  ON deep_cleaning_sessions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own deep cleaning sessions"
  ON deep_cleaning_sessions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own deep cleaning sessions"
  ON deep_cleaning_sessions FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own deep cleaning sessions"
  ON deep_cleaning_sessions FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- TABLE: memories
-- Stores sentimental memories from decluttering
-- ============================================================================
CREATE TABLE IF NOT EXISTS memories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  photo_path TEXT,
  type TEXT NOT NULL CHECK (type IN ('decluttering', 'cleaning', 'custom')),
  item_name TEXT,
  category TEXT,
  notes TEXT,
  sentiment TEXT CHECK (sentiment IN ('childhoodMemory', 'grownTogether', 'missionCompleted')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,

  CONSTRAINT memories_user_id_idx UNIQUE (user_id, id)
);

-- Indexes for memories
CREATE INDEX IF NOT EXISTS memories_user_id_idx ON memories(user_id);
CREATE INDEX IF NOT EXISTS memories_created_at_idx ON memories(created_at DESC);
CREATE INDEX IF NOT EXISTS memories_type_idx ON memories(type);

-- RLS Policies for memories
ALTER TABLE memories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own memories"
  ON memories FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own memories"
  ON memories FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own memories"
  ON memories FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own memories"
  ON memories FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- TABLE: planned_sessions
-- Stores planned decluttering sessions
-- ============================================================================
CREATE TABLE IF NOT EXISTS planned_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  area TEXT NOT NULL,
  scheduled_date DATE NOT NULL,
  scheduled_time TEXT NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,

  CONSTRAINT planned_sessions_user_id_idx UNIQUE (user_id, id)
);

-- Indexes for planned_sessions
CREATE INDEX IF NOT EXISTS planned_sessions_user_id_idx ON planned_sessions(user_id);
CREATE INDEX IF NOT EXISTS planned_sessions_scheduled_date_idx ON planned_sessions(scheduled_date);

-- RLS Policies for planned_sessions
ALTER TABLE planned_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own planned sessions"
  ON planned_sessions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own planned sessions"
  ON planned_sessions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own planned sessions"
  ON planned_sessions FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own planned sessions"
  ON planned_sessions FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- TRIGGERS: Auto-update updated_at timestamp
-- ============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_declutter_items_updated_at BEFORE UPDATE ON declutter_items
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_resell_items_updated_at BEFORE UPDATE ON resell_items
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_deep_cleaning_sessions_updated_at BEFORE UPDATE ON deep_cleaning_sessions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_memories_updated_at BEFORE UPDATE ON memories
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_planned_sessions_updated_at BEFORE UPDATE ON planned_sessions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
