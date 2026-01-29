# Quick Reference: Subcollection Refactor Checklist

## What Changed
✅ All redundant fields removed: `likedBy`, `viewedBy`, `likesCount`, `views`  
✅ Subcollections are now the single source of truth  
✅ UI driven by real-time Firestore streams, not cached model fields  
✅ Profile queries fixed to use proper collectionGroup and artistId filters  

---

## Firestore Interaction (For Frontend)

### Creating a Like
```dart
// User clicks heart
artworkController.toggleLike(artworkId, userId);

// What happens:
// 1. Repository checks: does likes/{userId} doc exist?
// 2. If yes → delete it (unlike)
// 3. If no → create it (like)
// 4. Firestore stream emits the new state
// 5. UI StreamBuilder<bool> receives update
// 6. Heart icon changes immediately
```

### Recording a View
```dart
// When artwork details screen opens
artworkController.incrementViewOnce(artworkId, userId);

// What happens:
// 1. Repository checks: does views/{userId} doc exist?
// 2. If no → create it (idempotent; only counts once per user)
// 3. If yes → do nothing (user already viewed)
// 4. Firestore stream emits updated view count
// 5. UI StreamBuilder<int> receives new count
```

### Reading Like State
```dart
// In UI (home_screen, search_screen, etc.)
StreamBuilder<bool>(
  stream: controller.isLikedStream(artworkId, userId),
  builder: (context, snapshot) {
    final isLiked = snapshot.data ?? false;
    return Icon(isLiked ? Icons.favorite : Icons.favorite_border);
  }
)
```

### Reading Like Count
```dart
StreamBuilder<int>(
  stream: controller.getLikeCountStream(artworkId),
  builder: (context, snapshot) {
    final count = snapshot.data ?? 0;
    return Text('$count Likes');
  }
)
```

### Reading View Count
```dart
StreamBuilder<int>(
  stream: controller.getViewCountStream(artworkId),
  builder: (context, snapshot) {
    final count = snapshot.data ?? 0;
    return Text('$count Views');
  }
)
```

---

## Profile Screen (Correct Behavior)

### "My Artworks"
```dart
// Filter: artworks where artistId == currentUser.id
// Real-time: bindStream updates list automatically
// Expected: Only shows current user's artworks
```

### "Favorites" (Artworks I Liked)
```dart
// Query: collectionGroup('likes') where documentId == currentUserId
// Resolves: Get artwork IDs from parent references
// Expected: Shows artworks that current user has liked
```

### Correct: "Likes on My Artworks" (Total Favorites Users Gave Me)
```dart
// This is shown as: favoritesCount = sum of likes across my artworks
// Query: Get all my artworks, sum their like counts
// Expected: Increases when someone likes my artwork
```

---

## Common Mistakes to Avoid ❌

### ❌ Reading from Model Fields
```dart
// WRONG: Model fields are not real-time
Text('${artwork.likesCount}')  // Stale!
Text('${artwork.views}')       // Stale!

Icon(artwork.likedBy.contains(userId) ? ... : ...)  // Stale!
```

### ✅ Use Streams Instead
```dart
// RIGHT: Real-time from Firestore
StreamBuilder<int>(stream: controller.getLikeCountStream(...))
StreamBuilder<int>(stream: controller.getViewCountStream(...))
StreamBuilder<bool>(stream: controller.isLikedStream(...))
```

### ❌ Optimistic UI Updates
```dart
// WRONG: Update local model before server confirms
artworks[index] = artwork.copyWith(likesCount: newCount);

// Then call server (may contradict UI if fails)
await controller.toggleLike(...);
```

### ✅ Server-Driven Updates
```dart
// RIGHT: Just call the method
await controller.toggleLike(...);

// UI updates automatically via stream
// When Firestore changes → stream emits → UI rebuilds
```

### ❌ Client-Side Filtering for Favorites
```dart
// WRONG: Check if user is in likedBy array
artworks.where((art) => art.likedBy.contains(userId))

// Problem: Doesn't scale; misses stale data
```

### ✅ Firestore Query
```dart
// RIGHT: collectionGroup query
collectionGroup('likes').where(documentId == userId)

// Plus: Real-time, scalable, accurate
```

---

## Debugging

### "View count not incrementing?"
1. Check: Is `incrementViewOnce()` called **once** in `initState()`, not in `build()`?
2. Check: Firestore contains `artworks/{id}/views/{userId}` doc?
3. Check: `StreamBuilder` in UI connected to `getViewCountStream()`?

### "Like button flickering?"
1. Check: Are you using `StreamBuilder<bool>` for like state?
2. Check: Repository `toggleLike()` only writes to subcollection (not fields)?
3. Check: Controller `toggleLike()` doesn't do optimistic updates?

### "Profile shows wrong favorites count?"
1. Check: `favoritesCount` updated from `_bindUserFavorites()` stream?
2. Check: Query uses `collectionGroup('likes')`?
3. Check: Filter is `where(documentId == currentUserId)`?

### "My Artworks showing other users' artworks?"
1. Check: Query has `where('artistId', isEqualTo: userId)`?
2. Check: Binding called in `_bindUserArtworks()` with correct userId?
3. Check: Binding recreated when `authController.currentUser` changes?

---

## File Map

```
lib/
├── models/
│   └── artwork_model.dart              (Removed: likedBy, viewedBy, likesCount, views)
├── repositories/
│   └── artwork_repository.dart         (Added: stream methods; removed field writes)
├── controllers/
│   ├── artwork_controller.dart         (Added: stream methods; removed optimistic updates)
│   └── profile_controller.dart         (Added: _bindUserFavorites; fixed bindings)
└── views/
    ├── artwork_details_screen.dart     (StreamBuilder for likes/views)
    ├── home_screen.dart                (StreamBuilder for like state)
    ├── search_screen.dart              (StreamBuilder for like state)
    └── favorites_screen.dart           (StreamBuilder for filtering)
```

---

## Before & After

| Scenario | Before | After |
|----------|--------|-------|
| **User A views artwork** | views field increments; User B sees same count | views/{userId} created; count accurate per user |
| **User B likes artwork** | likedBy array + likesCount both updated (race condition risk) | likes/{userId} created; count streams new value |
| **UI toggles like** | Optimistic update flickers if server slow | Stream updates when Firestore changes |
| **Profile "My Artworks"** | Correct (artistId filter) | Still correct (now stream-bound) |
| **Profile "Favorites"** | Wrong (counted likes on my artworks, not artworks I liked) | Correct (collectionGroup query) |

---

## Deployment Steps

1. **Before deploying**:
   - [ ] Test view counting works (one per user)
   - [ ] Test like toggle is smooth (no flicker)
   - [ ] Test profile shows correct artworks/favorites
   - [ ] Run `dart analyze` (should have only info/warnings)

2. **Deploy**:
   - [ ] Push changes to main
   - [ ] Run Flutter build
   - [ ] Upload to TestFlight/Play Store

3. **Post-deployment** (Optional):
   - [ ] Run Cloud Function to clean up old fields
   - [ ] Monitor Firestore reads/writes (should be reduced)

---

## Questions?

- **"Why can't I use `artworks.where(likedBy.contains(...))`?"** → Because that field no longer exists. Use `isLikedStream()` instead.
- **"Why is my like count showing 0?"** → Check that `likes/{userId}` docs exist in Firestore.
- **"Why do I need StreamBuilder?"** → Because model fields are stale. Streams are real-time.
- **"Can I still use optimistic UI?"** → Not recommended. Server-driven streams prevent bugs.

