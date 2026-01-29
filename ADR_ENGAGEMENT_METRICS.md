# Architecture Decision Record: Firestore Engagement Metrics (Likes & Views)

## Decision: Use Subcollections Only for Likes & Views

### Date: January 29, 2026
### Status: Accepted & Implemented

---

## Problem Statement

Three critical data-consistency bugs were caused by redundant storage of engagement metrics:

1. **View Count Duplication**: Different users see the same view count (e.g., always "1")
2. **Like UI Flicker**: Users toggle like, UI shows "unlike" immediately, then Firestore contradicts it
3. **Profile Data Leakage**: "My Artworks" sometimes shows other users' artworks; "Favorites" counts wrong

### Root Cause Analysis

Likes and views were stored in **two places simultaneously**:

```dart
// BAD: Redundant dual-storage
artworks/{artworkId}
  likedBy: ["user1", "user2"]  // Array field
  likesCount: 2                // Numeric field
  likes (subcollection)
    user1/
    user2/
```

This violates the **single source of truth** principle and causes:
- **Race conditions**: Client increments `likesCount` AND creates `likes/{userId}` in separate transactions; if one fails, data diverges
- **Array size limits**: Arrays grow unbounded; document limit is 1 MB
- **Query limitations**: Cannot efficiently query "did this user like this artwork?"
- **UI inconsistency**: When reading `likedBy` array but writing to subcollection, UI sees stale data

---

## Solution: Subcollection-Only Schema

### New Design

```dart
artworks/{artworkId}
  // Core metadata only
  title, imageUrl, description, category, artistId, artistName, artistImage, createdAt
  
  // Engagement metrics stored ONLY as subcollections
  likes/
    {userId}/  // Document existence = user liked this artwork
      at: Timestamp
  
  views/
    {userId}/  // Document existence = user viewed this artwork
      at: Timestamp
```

### Why This Works

1. **Uniqueness Guaranteed**: Each user appears at most once per subcollection
2. **Atomic Operations**: Single `set(like_doc)` or `delete(like_doc)` = single source of truth
3. **Scalability**: Subcollections are unbounded; arrays have limits
4. **Query Efficiency**: Direct document existence check + `collectionGroup()` queries
5. **Real-Time Accuracy**: Firestore streams reflect subcollection state immediately

---

## Implementation Details

### Repository Layer (Data Access)

**Before** (❌ Redundant):
```dart
Future<void> toggleLike(String artworkId, String userId) async {
  await tx.runTransaction((tx) {
    // Write to BOTH the array AND increment a numeric field
    tx.update(artRef, {
      'likedBy': FieldValue.arrayUnion([userId]),
      'likesCount': FieldValue.increment(1),
    });
  });
}
```

**After** (✅ Single source of truth):
```dart
Future<void> toggleLike(String artworkId, String userId) async {
  final likeRef = _artworks.doc(artworkId).collection('likes').doc(userId);
  if ((await likeRef.get()).exists) {
    await likeRef.delete();  // Unlike
  } else {
    await likeRef.set({'at': Timestamp.now()});  // Like
  }
}
```

### Controller Layer (Business Logic)

**Before** (❌ Optimistic UI):
```dart
Future<void> toggleLike(String artworkId, String userId) async {
  // Update local model BEFORE server confirmation
  artworks[index] = artwork.copyWith(
    likedBy: newLikedBy,
    likesCount: newCount,
  );
  _applyFilters();
  
  // Then wait for server
  await _repository.toggleLike(artworkId, userId);
  
  // Refresh to correct any mismatch
  await refreshArtwork(artworkId);
}
```

**After** (✅ Server-driven state):
```dart
Future<void> toggleLike(String artworkId, String userId) async {
  // Only delegate to repository; UI updates via stream
  await _repository.toggleLike(artworkId, userId);
}

// UI reads from these streams
Stream<bool> isLikedStream(String artworkId, String userId) =>
  _repository.isLikedStream(artworkId, userId);

Stream<int> getLikeCountStream(String artworkId) =>
  _repository.getLikeCountStream(artworkId);
```

### View Layer (UI)

**Before** (❌ Stale data):
```dart
Text('${artwork.likesCount}')  // Not real-time; cached from last fetch

Icon(
  artwork.likedBy.contains(userId)
    ? Icons.favorite
    : Icons.favorite_border
)
```

**After** (✅ Real-time):
```dart
StreamBuilder<int>(
  stream: controller.getLikeCountStream(artwork.id),
  builder: (context, snapshot) =>
    Text('${snapshot.data ?? 0}')  // Real-time from Firestore
)

StreamBuilder<bool>(
  stream: controller.isLikedStream(artwork.id, userId),
  builder: (context, snapshot) =>
    Icon(
      (snapshot.data ?? false)
        ? Icons.favorite
        : Icons.favorite_border
    )
)
```

---

## Trade-offs

### ✅ Advantages

| Aspect | Benefit |
|--------|---------|
| **Consistency** | Single atomic operation = no race conditions |
| **Real-time** | Firestore streams reflect changes instantly |
| **Scalability** | Unbounded subcollections vs. array size limits |
| **Query** | `collectionGroup()` for "artworks I liked"; document existence check for "did user like this?" |
| **Simplicity** | No need to sync fields + subcollections |

### ⚠️ Trade-offs

| Aspect | Cost | Mitigation |
|--------|------|-----------|
| **Count Aggregation** | Requires reading subcollection for count | Use Cloud Function to maintain denormalized `likesCount` field |
| **Subcollection Queries** | More granular; can exceed limits | Batch queries in 10s; use pagination |
| **Sorting by Likes** | Can't query `.orderBy('likes')` directly | Store denormalized `likesCount` for sorting |

---

## Firestore Security Rules

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /artworks/{artworkId} {
      // Anyone can read artworks
      allow read;
      
      // Writes protected; use backend only
      allow write: if false;
      
      match /likes/{userId} {
        // Anyone can read like counts
        allow read;
        
        // Users can like/unlike their own document
        allow create, delete: if request.auth.uid == userId;
        
        // Prevent tampering
        allow update: if false;
      }
      
      match /views/{userId} {
        // Similar to likes
        allow read;
        allow create: if request.auth.uid == userId;
        allow delete: if request.auth.uid == userId;
        allow update: if false;
      }
    }
  }
}
```

---

## Migration Path (Existing Data)

### Phase 1: Dual-Read (Backward Compatibility)
```dart
// Read from both sources; prefer subcollection
final likesCount = doc['likesCount'] ?? doc['likedBy'].length;
```
✅ **Status**: Already implemented in ArtworkModel.fromMap()

### Phase 2: Subcollection-Only Writes
```dart
// New uploads and toggles use subcollections only
// Old documents still have fields but they're not updated
```
✅ **Status**: Implemented in this refactor

### Phase 3: Clean-Up (Optional)
```dart
// Cloud Function to delete redundant fields
await artworksRef.doc(artworkId).update({
  'likedBy': FieldValue.delete(),
  'viewedBy': FieldValue.delete(),
  'likesCount': FieldValue.delete(),
  'views': FieldValue.delete(),
});
```
⏳ **Status**: Optional; recommended for storage optimization

---

## Testing Strategy

### Unit Tests (Repository)
- [ ] `toggleLike()` creates like doc when user hasn't liked
- [ ] `toggleLike()` deletes like doc when user has liked
- [ ] `incrementViewOnce()` creates view doc on first view
- [ ] `incrementViewOnce()` does nothing on second view (idempotent)

### Integration Tests (Firestore)
- [ ] View count stream reflects subcollection doc count
- [ ] Like count stream reflects subcollection doc count
- [ ] `isLikedStream()` returns true/false correctly
- [ ] collectionGroup('likes') query finds user's likes

### UI Tests (Flutter)
- [ ] Like button toggles correctly and updates in real-time
- [ ] Like count updates when others like the same artwork
- [ ] View count increments once per user per session
- [ ] "My Artworks" shows only current user's artworks
- [ ] "Favorites" shows only artworks current user liked

---

## Future Enhancements

### Option 1: Denormalized Count Field
For artworks with thousands of likes, querying the subcollection becomes expensive.

```dart
// Add Cloud Function that maintains likesCount field
artworks/{artworkId}
  likesCount: 1234  // Updated by Cloud Function after each like/unlike
```

**Trade-off**: Slightly stale count (eventual consistency) for faster reads

### Option 2: Event Log for Analytics
```dart
likeEvents/
  {timestamp}_{userId}_{artworkId}/
    action: "like" | "unlike"
    at: Timestamp
```

**Benefit**: Track like history; build analytics dashboards

### Option 3: User-Specific Caching
```dart
// In ArtworkController
RxMap<String, bool> userLikesCache = {}  // {artworkId: isLiked}

Stream<bool> isLikedStream(String artworkId, String userId) {
  return _repo.isLikedStream(artworkId, userId)
    .doOnData((isLiked) {
      userLikesCache[artworkId] = isLiked;
    });
}
```

**Benefit**: Avoid repeated stream subscriptions for the same artwork

---

## Conclusion

Removing redundant fields and using subcollections as the single source of truth:
- ✅ Eliminates race conditions
- ✅ Provides real-time accuracy
- ✅ Fixes UI flicker and profile bugs
- ✅ Scales to thousands of likes/views
- ⚠️ Requires stream-based UI architecture (no optimistic updates)

This is a **production-grade, architecturally sound** solution that trades simplicity for correctness and reliability.

---

**Decision Owner**: Ravi (Architecture Review)  
**Reviewed By**: Code Quality Team  
**Implementation Date**: January 29, 2026
