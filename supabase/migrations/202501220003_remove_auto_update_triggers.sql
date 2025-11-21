-- Remove automatic updated_at triggers
-- The client will manage updated_at timestamps for proper sync conflict resolution

DROP TRIGGER IF EXISTS update_declutter_items_updated_at ON declutter_items;
DROP TRIGGER IF EXISTS update_resell_items_updated_at ON resell_items;
DROP TRIGGER IF EXISTS update_deep_cleaning_sessions_updated_at ON deep_cleaning_sessions;
DROP TRIGGER IF EXISTS update_memories_updated_at ON memories;
DROP TRIGGER IF EXISTS update_planned_sessions_updated_at ON planned_sessions;

-- Note: We keep the function in case we need it later
-- DROP FUNCTION IF EXISTS update_updated_at_column();
