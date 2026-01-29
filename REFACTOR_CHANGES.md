# Firestore Data Consistency Refactor - Implementation Summary

## Status: ✅ COMPLETE

All redundant fields (`likedBy`, `viewedBy`, `likesCount`, `views`) have been removed from:
- ArtworkModel
- Firestore writes
- UI rendering (now using Firestore streams)

## Files Modified

### 1. Data Model
**File**: `lib/app/models/artwork_model.dart`
- **Removed**: `likedBy`, `viewedBy`, `likesCount`, `views` fields
- **Impact**: Model now only stores core artwork metadata (title, description, artist info, createdAt)
- **Why**: Engagement metrics are now derived from subcollections, not stored as fields

### 2. Repository Layer
**File**: `lib/app/repositories/artwork_repository.dart`
- **Removed**: All writes to redundant fields in Firestore
- **Added**: Three new stream methods:
  - `getLikeCountStream(artworkId)` → real-time count of likes
  - `getViewCountStream(artworkId)` → real-time count of views
  - `isLikedStream(artworkId, userId)` → real-time boolean of user's like state
- **Updated**: `toggleLike()` and `incrementViewOnce()` now write only to subcollections
- **Why**: Single source of truth prevents race conditions and inconsistency

### 3. Artwork Controller
**File**: `lib/app/controllers/artwork_controller.dart`
- **Removed**: Optimistic UI updates (local model changes before server confirmation)
- **Removed**: `refreshArtwork()` method (no longer needed with real-time streams)
- **Updated**: `toggleLike()` - now simply delegates to repository, no optimistic updates
- **Added**: Three public stream methods matching repository (exposed to views)
- **Why**: UI now driven entirely by Firestore streams, eliminating flicker and race conditions

### 4. Profile Controller
**File**: `lib/app/controllers/profile_controller.dart`
- **Updated**: "My Artworks" binding - already using strict `artistId == currentUserId` filter
- **Removed**: Client-side aggregation of likes
- **Added**: `_bindUserFavorites()` - uses `collectionGroup('likes')` to find artworks liked by user
- **Why**: Proper collectionGroup query is the only correct way to find favorites

### 5. Artwork Details Screen
**File**: `lib/app/views/artwork_details_screen.dart`
- **Removed**: Direct reads from `artwork.likedBy`, `artwork.views`
- **Updated**: Like count → `StreamBuilder<int>` reading from `getLikeCountStream()`
- **Updated**: View count → `StreamBuilder<int>` reading from `getViewCountStream()`
- **Updated**: Like button state → `StreamBuilder<bool>` reading from `isLikedStream()`
- **Why**: Real-time updates from Firestore without stale data or flickering

### 6. Home Screen
**File**: `lib/app/views/home_screen.dart`
- **Removed**: Direct read from `artwork.likedBy.contains(userId)`
- **Updated**: Like state → `StreamBuilder<bool>` with `isLikedStream()`
- **Added**: Import for `error_service.dart`
- **Why**: Consistent, real-time like state across all views

### 7. Search Screen
**File**: `lib/app/views/search_screen.dart`
- **Removed**: Direct read from `artwork.likedBy.contains(userId)`
- **Updated**: Like state → `StreamBuilder<bool>` with `isLikedStream()`
- **Added**: Import for `error_service.dart`
- **Why**: Consistent, real-time like state across all views

### 8. Favorites Screen
**File**: `lib/app/views/favorites_screen.dart`
- **Removed**: Client-side filtering by `artwork.likedBy.contains(userId)`
- **Updated**: Grid now iterates all artworks but wraps each in `StreamBuilder<bool>`
- **Updated**: Only renders card if `isLiked` stream returns true
- **Removed**: Unused `user_service` import
- **Why**: Proper real-time filtering; future can implement dedicated collectionGroup query

## Firestore Schema Changes

### Before (Redundant)
```
artworks/{artworkId}
  ├─ title, imageUrl, description, etc.
  ├─ likedBy: ["user1", "user2"]              ❌ REDUNDANT
  ├─ viewedBy: ["user1", "user2"]             ❌ REDUNDANT
  ├─ likesCount: 2                            ❌ REDUNDANT
  ├─ views: 5                                 ❌ REDUNDANT
  ├─ likes (subcollection)
  │  └─ {userId} { at: Timestamp }            ✅ TRUTH
  └─ views (subcollection)
     └─ {userId} { at: Timestamp }            ✅ TRUTH
```

### After (Single Source of Truth)
```
artworks/{artworkId}
  ├─ title, imageUrl, description, category
  ├─ artistId, artistName, artistImage
  ├─ createdAt
  ├─ likes (subcollection)
  │  └─ {userId} { at: Timestamp }            ✅ TRUTH
  └─ views (subcollection)
     └─ {userId} { at: Timestamp }            ✅ TRUTH
```

## Behavior Changes

| Feature | Before | After |
|---------|--------|-------|
| **View Counting** | Array-based; possible duplicates | One doc per user; atomic increment |
| **Like Toggling** | Optimistic UI → flicker → server refresh | Real-time stream updates |
| **Like State UI** | Read from `likedBy` array | Read from `isLikedStream()` |
| **View Count UI** | Read from `views` field | Read from `getViewCountStream()` |
| **Profile Favorites** | Wrong query (likedBy arrayContains) | Correct collectionGroup query |
| **My Artworks** | Correct filter (artistId) | Still correct, stream-bound |

## Testing Recommendations

1. **View Uniqueness**
   - Open artwork detail as User A → views increments to 1
   - Open again as User A → views stays at 1 (idempotent)
   - Open as User B → views increments to 2

2. **Like State Persistence**
   - Like artwork → heart fills immediately (via stream)
   - Unlike → heart empties immediately (via stream)
   - Refresh page → like state correct (stream source of truth)

3. **Profile Correctness**
   - User A uploads artwork
   - User B likes it
   - User A's profile shows 1 favorite (on their artwork)
   - User B's profile shows 1 favorite (artwork they liked)

4. **No Data Leakage**
   - User A's "My Artworks" never shows User B's artworks
   - User A's "Favorites" only shows artworks they liked
   - User B's "Favorites" doesn't include User A's "My Artworks"

## Migration Notes

- **No data loss**: Old documents with redundant fields will still load (backward compatible)
- **No immediate cleanup needed**: New artworks use clean schema automatically
- **Optional**: Delete old fields from existing docs using Cloud Function (recommended for storage optimization)

## Anti-Patterns Fixed

✅ **Dual-source consistency** → Single subcollection source  
✅ **Optimistic UI flicker** → Real-time streams  
✅ **Array-based uniqueness** → Document existence check  
✅ **Wrong profile queries** → collectionGroup queries  
✅ **Client-side aggregation** → Subcollection doc count  

---

**Next Steps (Optional)**:
1. Add Cloud Functions to maintain `likesCount` field for efficient sorting
2. Add security rules to validate likes/views operations
3. Run migration script to clean up old redundant fields
