# Local-First Implementation Summary

## What Changed?

KeepJoy is now **local-first**. All data is saved to your device immediately, then synchronized to the cloud in the background. Users can now switch devices without losing their memories!

## Quick Reference

### Key Files Created

| File | Purpose |
|------|---------|
| `lib/models/hive/*.dart` | Local database models (5 entities) |
| `lib/services/hive_service.dart` | Local database operations |
| `lib/services/sync_service.dart` | Cloud synchronization engine |
| `lib/services/connectivity_service.dart` | Network monitoring |
| `lib/services/image_cache_service.dart` | Smart image caching |
| `lib/widgets/cached_network_image_widget.dart` | Lazy-loading image widget |
| `supabase/migrations/202501190001_create_storage_buckets.sql` | Cloud storage setup |

### Files Modified

| File | Change |
|------|--------|
| `lib/services/data_repository.dart` | Complete rewrite: Cloud-first → Local-first |
| `lib/main.dart` | Added Hive, connectivity, and sync initialization |
| `pubspec.yaml` | Added dependencies: hive, connectivity_plus, image |

## How It Works

```
User Action → Save to Hive (instant) → Schedule Sync (5s delay) → Upload to Cloud
                  ↓
            Show in UI immediately
```

### Data Flow

1. **Create/Update**: Write to Hive → Mark as dirty → Trigger sync
2. **Read**: Always from Hive (fast, offline-capable)
3. **Delete**: Soft delete in Hive → Sync deletion to cloud
4. **Sync**: Upload dirty data → Download remote changes → Resolve conflicts

### Image Handling

- **Local images**: Compressed and uploaded during sync
- **Cloud images**: Lazy-loaded when viewed, cached to disk
- **Compression**: Memories (2048px, 85%), Items (600px, 80%)

## Important Notes

### ⚠️ TODO: Run SQL Migration

You need to execute the SQL migration in Supabase Dashboard:

1. Go to Supabase Dashboard → SQL Editor
2. Run: `supabase/migrations/202501190001_create_storage_buckets.sql`
3. This creates 4 storage buckets: memories, items, sessions, profiles

### Sync Behavior

- **Automatic**: Every 5 minutes + when network returns
- **Delayed**: 5 seconds after data changes (batches rapid edits)
- **Manual**: `await DataRepository().forceSync()`
- **Conflict Resolution**: Last-write-wins based on `updatedAt`

### Offline Usage

- ✅ Create/edit/delete data offline
- ✅ View all local data
- ✅ Sync when connectivity returns
- ❌ Cloud images won't download (shows placeholder)

## Testing Checklist

- [ ] Create memory offline → Goes online → Syncs successfully
- [ ] Create memory on Device A → Login on Device B → Memory appears
- [ ] Edit memory → Wait 5 seconds → Check Supabase (should update)
- [ ] Delete memory → Check Supabase (should delete)
- [ ] View memory with cloud image → Downloads and caches
- [ ] Go offline → View cached image → Still works

## Monitoring

### Sync Status

```dart
// Listen to sync changes
DataRepository().syncStatusStream.listen((status) {
  print('Sync status: $status'); // idle, syncing, success, error
});

// Force sync
await DataRepository().forceSync();
```

### Cache Management

```dart
// Check cache size
final size = await ImageCacheService.instance.getCacheSizeFormatted();

// Clear cache
await ImageCacheService.instance.clearCache();
```

### Debug Logs

Look for these emoji indicators in logs:
- 💾 Local save
- ☁️ Cloud sync
- ⬆️ Upload
- ⬇️ Download
- ✅ Success
- ❌ Error
- 🌐 Connectivity
- 📦 Cache hit
- 🗑️ Delete

## Performance Tips

1. **Batch Changes**: Multiple edits within 5 seconds = single sync
2. **Lazy Loading**: Images only downloaded when viewed
3. **Cache Persistence**: Downloaded images cached to disk
4. **Offline First**: App never waits for network

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Images not syncing | Check `ConnectivityService.instance.isConnected` |
| Sync stuck | Call `DataRepository().forceSync()` |
| Old data showing | Check `DataRepository().syncStatus` |
| Storage full | Call `ImageCacheService.instance.clearCache()` |

## Architecture Overview

```
┌─────────────────────────────────────────────┐
│              User Interface                 │
└──────────────────┬──────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────┐
│          DataRepository                     │
│  (Local-First: Read/Write to Hive)         │
└───────────────┬─────────────────────────────┘
                │
      ┌─────────┴─────────┐
      ↓                   ↓
┌─────────────┐    ┌──────────────┐
│ HiveService │    │ SyncService  │
│  (Local DB) │    │  (Background)│
└─────────────┘    └──────┬───────┘
                          │
                 ┌────────┴────────┐
                 ↓                 ↓
        ┌────────────────┐  ┌─────────────┐
        │ StorageService │  │  Supabase   │
        │ (Images)       │  │  (Database) │
        └────────────────┘  └─────────────┘
```

## Next Steps

1. Run the SQL migration in Supabase Dashboard
2. Test the sync flow on a real device
3. Test device migration (login on different device)
4. Monitor sync logs and performance
5. Consider adding sync indicator in UI

---

For detailed documentation, see [LOCAL_FIRST_ARCHITECTURE.md](LOCAL_FIRST_ARCHITECTURE.md)
