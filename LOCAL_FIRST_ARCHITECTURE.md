# KeepJoy Local-First Architecture

## Overview

KeepJoy now uses a **local-first architecture** to ensure data reliability, offline functionality, and fast user experience. All data is stored locally in Hive database first, then synchronized to Supabase cloud in the background.

## Key Benefits

1. **Offline-First**: App works without internet connection
2. **Instant Response**: No waiting for network operations
3. **Data Persistence**: Images and data backed up to cloud
4. **Device Migration**: Users can switch phones without losing data
5. **Bandwidth Efficient**: Images lazy-loaded only when viewed

## Architecture Components

### 1. Local Storage (Hive)

**Location**: `lib/models/hive/` and `lib/services/hive_service.dart`

All data entities have Hive models with sync tracking:
- `MemoryHive` (TypeId: 0) - User memories with photos
- `DeepCleaningSessionHive` (TypeId: 1) - Cleaning sessions with before/after photos
- `DeclutterItemHive` (TypeId: 2) - Items to declutter
- `ResellItemHive` (TypeId: 3) - Items for resale
- `PlannedSessionHive` (TypeId: 4) - Planned cleaning tasks

Each Hive model includes:
- `isDirty: bool` - Marks unsynchronized local changes
- `isDeleted: bool` - Soft delete flag
- `syncedAt: DateTime?` - Last successful sync timestamp

**HiveService** manages all box operations:
```dart
// Save with dirty flag
await HiveService.instance.saveMemory(memoryHive);

// Get all dirty data for sync
final dirtyMemories = HiveService.instance.getDirtyMemories();

// Soft delete (mark as deleted, sync later)
await HiveService.instance.deleteMemory(id);
```

### 2. Cloud Storage (Supabase)

**Location**: `supabase/migrations/202501190001_create_storage_buckets.sql`

Four storage buckets with RLS policies:
- `memories/` - User memory photos (max 10MB)
- `items/` - Declutter item photos (max 5MB)
- `sessions/` - Before/after cleaning photos (max 10MB)
- `profiles/` - User avatar images (max 2MB)

All buckets are:
- Public read (anyone can view)
- User-specific write (only owner can upload/delete)

### 3. Image Compression

**Location**: `lib/services/image_compression_service.dart`

Images are compressed before upload to save bandwidth:
- **Memories**: 2048px max dimension, 85% quality
- **Sessions**: 2048px max dimension, 85% quality
- **Items**: 600px max dimension, 80% quality
- **Avatars**: 512px max dimension, 85% quality

### 4. Sync Engine

**Location**: `lib/services/sync_service.dart`

Bidirectional sync between Hive and Supabase:

#### Upload Flow (Local → Cloud)
1. Get all dirty data from Hive
2. For each dirty item:
   - If local image exists, compress and upload to Storage
   - Upsert data to Supabase database
   - Mark as synced in Hive
3. For deleted items:
   - Delete from Supabase database
   - Remove from Hive

#### Download Flow (Cloud → Local)
1. Fetch all data from Supabase for current user
2. For each remote item:
   - Compare `updatedAt` timestamps (last-write-wins)
   - If remote is newer, save to Hive
   - Mark as synced

#### Sync Triggers
- **Periodic**: Every 5 minutes (configurable)
- **Network Restore**: When connectivity returns
- **Data Changes**: 5 seconds after create/update/delete
- **Manual**: `DataRepository.forceSync()`

#### Conflict Resolution
Last-write-wins based on `updatedAt` timestamp:
```dart
bool _shouldReplaceLocal(DateTime? local, DateTime? remote) {
  if (remote == null) return false;
  if (local == null) return true;
  return remote.isAfter(local);
}
```

### 5. Connectivity Monitoring

**Location**: `lib/services/connectivity_service.dart`

Monitors network state and triggers sync:
- WiFi detection
- Mobile data detection
- Network state changes
- Connectivity stream for UI updates

### 6. Image Lazy Loading

**Location**: `lib/services/image_cache_service.dart` and `lib/widgets/cached_network_image_widget.dart`

Images are downloaded only when viewed:
- Local images returned immediately
- Cloud images cached to disk after first download
- Cache stored in app documents directory
- Preload support for background downloads
- Cache management (size tracking, clear all)

**Usage**:
```dart
CachedNetworkImageWidget(
  imageUrl: memory.photoPath,  // Can be local path or cloud URL
  fit: BoxFit.cover,
  placeholder: CircularProgressIndicator(),
  errorWidget: Icon(Icons.error),
)
```

### 7. Data Repository

**Location**: `lib/services/data_repository.dart`

Refactored to be **local-first**:

#### Before (Cloud-First)
```dart
Future<Memory> createMemory(Memory memory) async {
  // Direct Supabase insert with retry
  final response = await _supabaseClient
    .from('memories')
    .insert(data);
  return Memory.fromJson(response);
}
```

#### After (Local-First)
```dart
Future<Memory> createMemory(Memory memory) async {
  // Save to Hive immediately
  final hive = MemoryHive.fromMemory(memory, isDirty: true);
  await HiveService.instance.saveMemory(hive);

  // Schedule background sync
  Future.delayed(const Duration(seconds: 5), () {
    SyncService.instance.syncAll();
  });

  return memory;
}
```

All methods now:
- **Read** from Hive (fast, offline-capable)
- **Write** to Hive first (instant response)
- **Schedule sync** 5 seconds later (batch changes)

## Data Flow Examples

### Creating a Memory

1. User takes photo → Saved to local app directory
2. User fills in details → Calls `DataRepository.createMemory()`
3. DataRepository saves to Hive with `isDirty: true`
4. User sees memory immediately in timeline
5. 5 seconds later, SyncService triggers:
   - Compresses image (2048px, 85%)
   - Uploads to `memories/` bucket
   - Inserts record to `memories` table with cloud URL
   - Marks Hive record as synced

### Switching Devices

**Old Device:**
- All data synced to cloud
- Images stored in Supabase Storage

**New Device:**
1. User logs in
2. SyncService downloads all data from cloud
3. Hive populated with all memories/items/sessions
4. Images lazy-loaded when user views them
5. Downloaded images cached locally

### Offline Usage

1. User creates/edits data → Saved to Hive with `isDirty: true`
2. User sees all local data immediately
3. Sync fails silently (no network)
4. When connectivity returns:
   - ConnectivityService detects network
   - SyncService automatically triggers
   - All dirty data uploaded

## Initialization Flow

**Location**: `lib/main.dart`

```dart
void main() async {
  // 1. Initialize Hive local database
  await HiveService.instance.init();

  // 2. Initialize connectivity monitoring
  await ConnectivityService.instance.init();

  // 3. Initialize Supabase
  await AuthService.initialize();

  // 4. If logged in, initialize sync service
  if (currentUserId != null) {
    await SyncService.instance.init();

    // 5. Trigger initial sync after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      SyncService.instance.syncAll();
    });
  }
}
```

## Monitoring Sync Status

```dart
// Listen to sync status changes
DataRepository().syncStatusStream.listen((status) {
  switch (status) {
    case SyncStatus.idle:
      // No sync in progress
      break;
    case SyncStatus.syncing:
      // Sync in progress, show indicator
      break;
    case SyncStatus.success:
      // Last sync successful
      break;
    case SyncStatus.error:
      // Sync failed, will retry
      break;
  }
});

// Get current status
final currentStatus = DataRepository().syncStatus;

// Force immediate sync
await DataRepository().forceSync();
```

## Cache Management

```dart
// Get cache size
final sizeBytes = await ImageCacheService.instance.getCacheSize();
final sizeFormatted = await ImageCacheService.instance.getCacheSizeFormatted();

// Preload images in background
await ImageCacheService.instance.preloadImages([url1, url2, url3]);

// Clear all cached images
await ImageCacheService.instance.clearCache();
```

## Setup Checklist

- [x] Phase 1: Basic Infrastructure
  - Image compression service
  - Storage service with retry logic
  - Supabase storage buckets SQL migration

- [x] Phase 2: Hive Local Database
  - Hive models for all entities
  - HiveService with CRUD operations
  - Generated type adapters

- [x] Phase 3: Sync Engine
  - ConnectivityService for network monitoring
  - SyncService with bidirectional sync
  - Periodic and event-triggered sync

- [x] Phase 4: Data Layer Refactoring
  - DataRepository refactored to local-first
  - All reads from Hive
  - All writes to Hive + delayed sync

- [x] Phase 5: Image Lazy Loading
  - ImageCacheService for smart caching
  - CachedNetworkImageWidget for UI

- [ ] **TODO: Run SQL Migration**
  - Execute `supabase/migrations/202501190001_create_storage_buckets.sql` in Supabase Dashboard
  - This creates the storage buckets and RLS policies

## Troubleshooting

### Images not syncing?
1. Check connectivity: `ConnectivityService.instance.isConnected`
2. Check sync status: `DataRepository().syncStatus`
3. Force sync: `await DataRepository().forceSync()`
4. Check Hive dirty data: `HiveService.instance.getDirtyMemories()`

### Old images still showing after delete?
- Images are soft-deleted (marked in Hive)
- Sync will propagate deletion to cloud
- Local cache persists until cleared

### Running out of storage?
```dart
// Check cache size
final size = await ImageCacheService.instance.getCacheSizeFormatted();

// Clear cache (will re-download when needed)
await ImageCacheService.instance.clearCache();
```

## Performance Considerations

1. **Sync Delay**: 5-second delay batches rapid changes (e.g., editing same item multiple times)
2. **Periodic Sync**: 5-minute interval balances freshness and battery usage
3. **Image Compression**: Reduces bandwidth and storage (2048px for memories, 600px for items)
4. **Lazy Loading**: Only download images when viewing, not all at once
5. **Cache Persistence**: Downloaded images cached to disk to avoid re-downloading

## Security

1. **Row Level Security**: Supabase RLS ensures users only access their own data
2. **Storage Policies**: Users can only upload/delete their own images
3. **Public Read**: Anyone can view images if they have the URL (consider adding auth if needed)

## Future Enhancements

1. **Selective Sync**: Sync only specific data types
2. **WiFi-Only Mode**: User preference to only sync on WiFi
3. **Conflict UI**: Show conflicts to user for manual resolution
4. **Delta Sync**: Only sync changed fields, not entire records
5. **Image Quality Settings**: Let users choose compression level
