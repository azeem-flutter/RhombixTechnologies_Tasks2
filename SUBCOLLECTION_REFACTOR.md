# Firestore Data Consistency Refactor: Likes & Views Subcollections

## Summary

This refactor **eliminates redundant storage** of likes and views by moving them from document fields to **subcollections only**. This fixes three critical data-consistency bugs:

1. **Duplicate view counts** across users
2. **UI flicker and race conditions** with like toggles
3. **Incorrect profile queries** showing artworks from other users

## Why This Was Necessary

### The Problem
Previously, likes and views were stored **redundantly** in two places:

```
# Bad: Dual storage (BEFORE)
artworks/{artworkId}
  ├─ likes (subcollection with user docs)
  ├─ views (subcollection with user docs)
  ├─ likedBy: ["user1", "user2", ...]  ❌ REDUNDANT
  ├─ viewedBy: ["user1", "user2", ...] ❌ REDUNDANT
  ├─ likesCount: 2                      ❌ REDUNDANT
  └─ views: 5                           ❌ REDUNDANT
```

### Why Redundancy Is Dangerous

1. **Race Conditions**: Client can toggle a like AND increment likesCount in separate transactions, causing desynchronization if one fails.
2. **UI Flicker**: If you read likes from the array field but write to the subcollection, the UI sees stale data briefly.
3. **Array Size Limits**: Arrays grow unbounded; Firestore documents are limited to 1 MB, risking data loss.
4. **Query Limitations**: You cannot query by array element efficiently; you must fetch entire document to check if user liked it.
5. **Profile Query Bug**: Query `where likedBy arrayContains userId` counts artworks liked BY user, not likes ON user's artworks.

## The Solution

### New Schema (AFTER)

```
artworks/{artworkId}
  ├─ title, imageUrl, description, category
  ├─ artistId, artistName, artistImage
  ├─ createdAt
  ├─ likes (subcollection)
  │  └─ {userId} (doc) { at: Timestamp }
  └─ views (subcollection)
     └─ {userId} (doc) { at: Timestamp }
```

**Key Points**:
- No `likedBy`, `viewedBy`, `likesCount`, or `views` fields on the artwork document.
- Count of likes/views is derived from **subcollection document count**.
- Each user appears **at most once** in the subcollection, preventing duplicates.
- Single atomic operation (create/delete doc) = single source of truth.

## Changes Made

### 1. ArtworkModel (`lib/app/models/artwork_model.dart`)

**Removed**:
- `List<String> likedBy`
- `List<String> viewedBy`
- `int likesCount`
- `int views`

**Result**: Model now only stores core artwork metadata, not engagement metrics.

### 2. FirestoreArtworkRepository (`lib/app/repositories/artwork_repository.dart`)

#### toggleLike()
**Before**: 
```dart
tx.set(likeRef, {'at': Timestamp.now()});
tx.update(artRef, {'likesCount': FieldValue.increment(1)}); // ❌ REDUNDANT
```

**After**:
```dart
// Toggle is idempotent: create or delete the like doc ONLY
await likeRef.delete(); // or set if doesn't exist
// No field updates needed
```

#### incrementViewOnce()
**Before**:
```dart
tx.set(viewRef, {'at': Timestamp.now()});
tx.update(artRef, {'views': FieldValue.increment(1)}); // ❌ REDUNDANT
```

**After**:
```dart
// View tracking is idempotent per user
await viewRef.set({'at': Timestamp.now()});
// No field updates needed
```

#### New Stream Methods
```dart
/// Get real-time like count (subcollection doc count)
Stream<int> getLikeCountStream(String artworkId)

/// Get real-time view count (subcollection doc count)
Stream<int> getViewCountStream(String artworkId)

/// Get whether user has liked this artwork
Stream<bool> isLikedStream(String artworkId, String userId)
```

### 3. ArtworkController (`lib/app/controllers/artwork_controller.dart`)

#### toggleLike()
**Before**: Optimistic UI updates + field writes
```dart
// ❌ Optimistic UI updates model, THEN write to server
artworks[index] = artwork.copyWith(likedBy: likedBy, likesCount: newLikes);
await _repository.toggleLike(artworkId, userId);
```

**After**: Server-driven state only
```dart
// ✅ Call repository (writes subcollection doc only)
await _repository.toggleLike(artworkId, userId);
// UI updates via stream subscription in view
```

#### New Methods
```dart
/// Get like count stream for a specific artwork
Stream<int> getLikeCountStream(String artworkId)

/// Get view count stream for a specific artwork
Stream<int> getViewCountStream(String artworkId)

/// Get whether current user liked this artwork
Stream<bool> isLikedStream(String artworkId, String userId)
```

### 4. ProfileController (`lib/app/controllers/profile_controller.dart`)

#### "My Artworks" Binding
**Before**: 
```dart
// ✅ Already fixed with strict artistId filter
userArtworks.bindStream(
  _firestore
      .collection('artworks')
      .where('artistId', isEqualTo: userId)
      .snapshots()
      ...
)
```

#### "Favorites" (Artworks Liked BY Current User)
**Before** (WRONG): 
```dart
// ❌ Counted likes ON user's artworks
favoritesCount = artworks where artistId == currentUser
  .sum(likesCount)
```

**After** (CORRECT):
```dart
// ✅ Find all likes by this user using collectionGroup
collectionGroup('likes')
  .where(FieldPath.documentId, isEqualTo: userId)
  .snapshots()
  // Resolve artwork IDs from like doc parents
  // Sum count of artworks
```

### 5. View Layers

#### artwork_details_screen.dart
**Before**: Read from model fields
```dart
// ❌ Stale data from last fetch
'${artwork.likesCount}', // Not real-time
'${artwork.views}',      // Not real-time
artwork.likedBy.contains(userId) // Not real-time
```

**After**: Stream-driven (real-time)
```dart
// ✅ Real-time from Firestore
StreamBuilder<int>(
  stream: artworkController.getLikeCountStream(artwork.id),
  builder: (context, snapshot) => Text('${snapshot.data ?? 0}')
)

StreamBuilder<bool>(
  stream: artworkController.isLikedStream(artwork.id, userId),
  builder: (context, snapshot) {
    final isLiked = snapshot.data ?? false;
    return Icon(isLiked ? Icons.favorite : Icons.favorite_border);
  }
)
```

#### home_screen.dart, search_screen.dart
**Before**: Direct model access
```dart
// ❌ Stale
isLiked: artwork.likedBy.contains(userId)
```

**After**: Stream-driven
```dart
// ✅ Real-time
StreamBuilder<bool>(
  stream: controller.isLikedStream(artwork.id, userId),
  builder: (context, snapshot) =>
    ArtworkCard(isLiked: snapshot.data ?? false, ...)
)
```

## Benefits

| Aspect | Before | After |
|--------|--------|-------|
| **Consistency** | Dual-storage race conditions | Single source of truth |
| **View Uniqueness** | Array duplicates possible | One doc per user = guaranteed unique |
| **Like UI State** | Optimistic → flicker | Real-time via Firestore stream |
| **Profile Queries** | Wrong (likedBy arrayContains) | Correct (collectionGroup) |
| **Performance** | Large arrays in docs | Small docs, indexed queries |
| **Scalability** | Array size limits (1 MB) | Unbounded subcollection |

## Migration Guide

### For Existing Data
1. **No immediate action required**. Old documents with `likedBy`, `viewedBy`, etc. will still load.
2. **Optional cleanup**: Use a Cloud Function to delete redundant fields from old docs:
   ```dart
   // Remove old fields
   await artworksRef.doc(artworkId).update({
     'likedBy': FieldValue.delete(),
     'viewedBy': FieldValue.delete(),
     'likesCount': FieldValue.delete(),
     'views': FieldValue.delete(),
   });
   ```

### For New Artworks
- ArtworkModel no longer accepts these fields → toMap() won't write them.
- All new uploads will use subcollection-only schema automatically.

## Testing Checklist

- [ ] Upload an artwork; view count should be 0
- [ ] Open details as different user → view count increments to 1
- [ ] Open again as same user → view count stays at 1 (idempotent)
- [ ] Like artwork → UI updates in real-time via stream
- [ ] Unlike artwork → UI updates in real-time via stream
- [ ] Open home/search → like heart toggles reflect real-time state
- [ ] Profile shows "My Artworks" with strict artistId filter
- [ ] Profile shows "Favorites" (artworks liked by user) correctly
- [ ] No artworks from other users appear in favorites

## Firestore Security Rules

Recommend adding rules to prevent abuse:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /artworks/{artworkId} {
      allow read;
      allow write: if false; // Only via Cloud Functions
      
      match /likes/{userId} {
        allow read;
        allow create, delete: if request.auth.uid == userId;
      }
      
      match /views/{userId} {
        allow read;
        allow create, delete: if request.auth.uid == userId;
      }
    }
  }
}
```

## Anti-Patterns Removed

1. ✅ **Redundant field + subcollection sync** → Subcollection only
2. ✅ **Optimistic UI updates** → Server-driven Firestore streams
3. ✅ **Array-based uniqueness checks** → Subcollection doc existence
4. ✅ **Client-side likes aggregation** → collectionGroup query
5. ✅ **Views in build() method** → Idempotent call in initState()

## Future Improvements

### Option 1: Cloud Function Aggregates
For high-traffic artworks, use a Cloud Function to maintain a `likesCount` field (for sorting) while keeping subcollection as source of truth.

### Option 2: Caching Layer
Add a cache in `ArtworkController` to avoid re-querying the same subcollection counts repeatedly.

### Option 3: Real-time Favorites List
Implement `_bindUserFavorites()` in ProfileController to show a real-time list of artworks the user has liked (using collectionGroup).
