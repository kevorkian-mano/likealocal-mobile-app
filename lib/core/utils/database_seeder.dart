import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// DatabaseSeeder — seeds ALL Firestore collections with realistic demo data.
/// Safe to call multiple times: skips any collection that already has data.
/// Call: await DatabaseSeeder.seed();
/// ─────────────────────────────────────────────────────────────────────────────
class DatabaseSeeder {
  static final FirebaseFirestore _db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'default',
  );

  // We will populate these with real Auth UIDs generated dynamically
  static late String _eyadId;
  static late String _manuelId;
  static late String _chantalId;
  static late String _ebramId;
  static late String _youstinaId;

  static Future<void> seed() async {
    print('🌱 Starting database seed...');

    // 0. Clear old data completely (Destructive Wipe)
    await _clearDatabase();

    // 1. Create real Auth users
    await _seedAuthUsers();

    // 2. Seed Firestore with the actual generated UIDs
    await _seedUsers();
    await _seedGems();
    await _seedReviews();
    await _seedChats();
    await _seedNotifications();
    print('✅ Database seed complete!');
  }

  // ── 0. FIREBASE AUTH ───────────────────────────────────────────────────────
  static Future<void> _seedAuthUsers() async {
    final usersToSeed = [
      {'email': 'eyad.elmaleh@student.giu-uni.de', 'pwd': 'Password123!'},
      {'email': 'manuel.kevorkian@student.giu-uni.de', 'pwd': 'Password123!'},
      {'email': 'chantal.andrawes@student.giu-uni.de', 'pwd': 'Password123!'},
      {'email': 'ebram.attia@student.giu-uni.de', 'pwd': 'Password123!'},
      {'email': 'youstina.boutrous@student.giu-uni.de', 'pwd': 'Password123!'},
    ];

    print('Creating Auth Users via secondary Firebase app...');
    // Use a secondary FirebaseApp so we don't log out the user running the app
    FirebaseApp tempApp;
    try {
      tempApp = Firebase.app('SeederApp');
    } catch (e) {
      tempApp = await Firebase.initializeApp(
        name: 'SeederApp',
        options: Firebase.app().options,
      );
    }

    final tempAuth = FirebaseAuth.instanceFor(app: tempApp);
    final List<String> generatedUids = [];

    for (var u in usersToSeed) {
      try {
        final cred = await tempAuth.createUserWithEmailAndPassword(
          email: u['email']!,
          password: u['pwd']!,
        );
        generatedUids.add(cred.user!.uid);
        print('Created ${u['email']} -> ${cred.user!.uid}');
      } catch (e) {
        if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
          // If they exist, we must sign in to get their UID
          final cred = await tempAuth.signInWithEmailAndPassword(
            email: u['email']!,
            password: u['pwd']!,
          );
          generatedUids.add(cred.user!.uid);
          print('Found existing ${u['email']} -> ${cred.user!.uid}');
        } else {
          print('Error seeding auth for ${u['email']}: $e');
          rethrow; // Rethrow to halt if unexpected
        }
      }
    }

    // Assign to static variables
    _eyadId = generatedUids[0];
    _manuelId = generatedUids[1];
    _chantalId = generatedUids[2];
    _ebramId = generatedUids[3];
    _youstinaId = generatedUids[4];

    await tempAuth.signOut();
    // Intentionally keep tempApp alive or delete it (deleting can cause issues if reused quickly, so we leave it)
  }

  // ── 1. USERS ───────────────────────────────────────────────────────────────
  static Future<void> _seedUsers() async {
    final col = _db.collection('users');
    final existing = await col.limit(1).get();
    if (existing.docs.isNotEmpty) {
      print('ℹ️  Users already seeded.');
      return;
    }

    final users = [
      {
        'id': _eyadId,
        'fullName': 'Eyad Ahmed',
        'email': 'eyad.elmaleh@student.giu-uni.de',
        'avatarUrl':
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150',
        'bio':
            'P24 | City explorer & food photographer. I find the places Google Maps never will.',
        'selectedVibes': [
          'Hidden Cafes',
          'Street Food',
          'Art & Design',
          'Rooftops',
        ],
        'karmaPoints': 850,
        'isSuperUser': true,
        'isAdmin': true,
        'isPro': true,
        'chatsStartedToday': 0,
        'lastContributionTime': null,
        'lastChatResetDate': null,
        'blockedUsers': [],
        'isBanned': false,
        'acceptsMessages': true,
        'isDndEnabled': false,
        'dndStartHour': 22,
        'dndEndHour': 8,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': _manuelId,
        'fullName': 'Manuel Youssef',
        'email': 'manuel.kevorkian@student.giu-uni.de',
        'avatarUrl':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150',
        'bio':
            'P21 | Rising Local Legend. Jazz lover, wine snob, terrible dancer.',
        'selectedVibes': ['Nightlife', 'Hidden Cafes', 'History', 'Luxury'],
        'karmaPoints': 620,
        'isSuperUser': true,
        'isAdmin': false,
        'isPro': true,
        'chatsStartedToday': 1,
        'lastContributionTime': null,
        'lastChatResetDate': null,
        'blockedUsers': [],
        'isBanned': false,
        'acceptsMessages': true,
        'isDndEnabled': false,
        'dndStartHour': 22,
        'dndEndHour': 8,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': _chantalId,
        'fullName': 'Chantal Sheriff',
        'email': 'chantal.andrawes@student.giu-uni.de',
        'avatarUrl':
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=150',
        'bio':
            'P21 | Pro explorer. Weekend market hunter. I live for the find. 🌿',
        'selectedVibes': [
          'Local Markets',
          'Nature Spots',
          'Budget Gems',
          'Art & Design',
        ],
        'karmaPoints': 210,
        'isSuperUser': false,
        'isAdmin': false,
        'isPro': true,
        'chatsStartedToday': 0,
        'lastContributionTime': null,
        'lastChatResetDate': null,
        'blockedUsers': [],
        'isBanned': false,
        'acceptsMessages': true,
        'isDndEnabled': false,
        'dndStartHour': 22,
        'dndEndHour': 8,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': _ebramId,
        'fullName': 'Ebram Nageh',
        'email': 'ebram.attia@student.giu-uni.de',
        'avatarUrl':
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=150',
        'bio':
            'P25 | Just arrived in Lisbon. Here to learn the city like a local.',
        'selectedVibes': ['Street Food', 'Parks', 'Budget Gems'],
        'karmaPoints': 500,
        'isSuperUser': true,
        'isAdmin': false,
        'isPro': false,
        'chatsStartedToday': 2,
        'lastContributionTime': null,
        'lastChatResetDate': null,
        'blockedUsers': [],
        'isBanned': false,
        'acceptsMessages': true,
        'isDndEnabled': false,
        'dndStartHour': 22,
        'dndEndHour': 8,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': _youstinaId,
        'fullName': 'Youstina Raouf',
        'email': 'youstina.boutrous@student.giu-uni.de',
        'avatarUrl':
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=150',
        'bio': 'P21 | Finding the best hidden spots in the city.',
        'selectedVibes': ['Hidden Cafes', 'Art & Design', 'Luxury'],
        'karmaPoints': 100,
        'isSuperUser': false,
        'isAdmin': false,
        'isPro': false,
        'chatsStartedToday': 0,
        'lastContributionTime': null,
        'lastChatResetDate': null,
        'blockedUsers': [],
        'isBanned': false,
        'acceptsMessages': true,
        'isDndEnabled': false,
        'dndStartHour': 22,
        'dndEndHour': 8,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    final batch = _db.batch();
    final ids = [_eyadId, _manuelId, _chantalId, _ebramId, _youstinaId];
    for (int i = 0; i < users.length; i++) {
      batch.set(col.doc(ids[i]), users[i]);
    }
    await batch.commit();
    print('✅ ${users.length} users seeded.');
  }

  // ── 2. HIDDEN GEMS ─────────────────────────────────────────────────────────
  static Future<void> _seedGems() async {
    final col = _db.collection('gems');
    final existing = await col.limit(1).get();
    if (existing.docs.isNotEmpty) {
      print('ℹ️  Gems already seeded.');
      return;
    }

    final gems = [
      {
        'name': 'The Secret Rooftop at Bairro Alto',
        'description':
            'A hidden rooftop bar tucked above a vinyl record shop. Only locals know the unmarked door. The sunset views over the Tagus are breathtaking.',
        'category': 'Rooftops',
        'vibe': 'Romantic',
        'rating': 4.8,
        'imageUrl':
            'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?auto=format&fit=crop&w=800&q=80',
        'latitude': 38.7139,
        'longitude': -9.1434,
        'localsTip':
            'Go after 7pm on weekdays. Ask the record shop owner for the "terrace key".',
        'recommendedDishes': ['Sangria Branca', 'Petiscos Board'],
        'isPremium': false,
        'isTrending': true,
        'contributorId': _eyadId,
        'status': 'approved',
        'contributorIsSuperUser': true,
        'views': 234,
        'saves': 87,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Mercado da Ribeira Back Stalls',
        'description':
            'The real gems are the back stalls where local fishmongers sell grilled sardines at half the price of the tourist-facing Time Out Market.',
        'category': 'Street Food',
        'vibe': 'Local Favorite',
        'rating': 4.6,
        'imageUrl':
            'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80',
        'latitude': 38.7063,
        'longitude': -9.1455,
        'localsTip':
            'Arrive before 11am for the freshest catch. Cash only at most stalls.',
        'recommendedDishes': ['Grilled Sardines', 'Bifanas', 'Ginjinha'],
        'isPremium': false,
        'isTrending': false,
        'contributorId': _eyadId,
        'status': 'approved',
        'contributorIsSuperUser': true,
        'views': 189,
        'saves': 54,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Livraria do Simão – Underground Bookshop',
        'description':
            'A basement bookshop in Alfama with over 50,000 used books. The owner will personally recommend a book based on your mood.',
        'category': 'Cultural Sites',
        'vibe': 'Artsy',
        'rating': 4.9,
        'imageUrl':
            'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?auto=format&fit=crop&w=800&q=80',
        'latitude': 38.7141,
        'longitude': -9.1329,
        'localsTip':
            'Ring the bell — the door looks closed but it\'s always open.',
        'recommendedDishes': [],
        'isPremium': true,
        'isTrending': true,
        'contributorId': _manuelId,
        'status': 'approved',
        'contributorIsSuperUser': true,
        'views': 312,
        'saves': 143,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Café Tati – Hidden Jazz Cellar',
        'description':
            'Street level it\'s a normal café, but descend the spiral stairs on Friday nights for live jazz in a candle-lit stone cellar.',
        'category': 'Hidden Dining',
        'vibe': 'Nightlife',
        'rating': 4.7,
        'imageUrl':
            'https://images.unsplash.com/photo-1415201364774-f6f0bb35f28f?auto=format&fit=crop&w=800&q=80',
        'latitude': 38.7198,
        'longitude': -9.1401,
        'localsTip':
            'Friday nights only. No reservation needed but arrive by 9pm.',
        'recommendedDishes': [
          'Pastel de Nata',
          'Medronho Spirit',
          'Queijo da Serra',
        ],
        'isPremium': false,
        'isTrending': false,
        'contributorId': _manuelId,
        'status': 'approved',
        'contributorIsSuperUser': true,
        'views': 156,
        'saves': 72,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Parque da Bela Vista Secret Trail',
        'description':
            'A hidden trail behind the amphitheatre leads to a sunrise viewpoint that overlooks all of Lisbon. Unknown to tourists.',
        'category': 'Nature Spots',
        'vibe': 'Adventure',
        'rating': 4.5,
        'imageUrl':
            'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=800&q=80',
        'latitude': 38.7378,
        'longitude': -9.1354,
        'localsTip':
            'Best at 6am in summer. Locals gather there for sunrise yoga.',
        'recommendedDishes': [],
        'isPremium': false,
        'isTrending': false,
        'contributorId': _chantalId,
        'status': 'approved',
        'contributorIsSuperUser': false,
        'views': 98,
        'saves': 41,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Tasca do Chico – No Menu Fado',
        'description':
            'The smallest Fado house in Lisbon. Only 20 seats. No printed menu — the waiter tells you what\'s available. The owner performs every night.',
        'category': 'Hidden Dining',
        'vibe': 'Cultural',
        'rating': 4.9,
        'imageUrl':
            'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=800&q=80',
        'latitude': 38.7101,
        'longitude': -9.1467,
        'localsTip': 'Reservation essential — call 2 weeks in advance.',
        'recommendedDishes': [
          'Bacalhau com Natas',
          'Caldo Verde',
          'Pasteis de Feijão',
        ],
        'isPremium': true,
        'isTrending': true,
        'contributorId': _chantalId,
        'status': 'approved',
        'contributorIsSuperUser': false,
        'views': 421,
        'saves': 198,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'LX Factory Sunday Inner Courtyard',
        'description':
            'The inner courtyard hosts a smaller artisan market with local ceramics, vintage prints, and live music. Most tourists miss it entirely.',
        'category': 'Local Markets',
        'vibe': 'Chill',
        'rating': 4.4,
        'imageUrl':
            'https://images.unsplash.com/photo-1488459716781-31db52582fe9?auto=format&fit=crop&w=800&q=80',
        'latitude': 38.7037,
        'longitude': -9.1771,
        'localsTip': 'Sundays 10am–3pm only. Enter through the far-left gate.',
        'recommendedDishes': ['Artisan Coffee', 'Local Pastries'],
        'isPremium': false,
        'isTrending': false,
        'contributorId': _ebramId,
        'status': 'approved',
        'contributorIsSuperUser': true,
        'views': 134,
        'saves': 59,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Palácio Chiado Wine Vault',
        'description':
            'Below the elegant Palácio Chiado lies a 19th-century wine vault converted into an intimate tasting bar. Not listed anywhere online.',
        'category': 'Hidden Dining',
        'vibe': 'Luxury',
        'rating': 4.8,
        'imageUrl':
            'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?auto=format&fit=crop&w=800&q=80',
        'latitude': 38.7113,
        'longitude': -9.1399,
        'localsTip':
            'Ask the maître d\' for "the vault experience". Available for walk-ins after 8pm.',
        'recommendedDishes': [
          'Alentejo Wine Flight',
          'Iberian Ham Board',
          'Truffled Croquettes',
        ],
        'isPremium': true,
        'isTrending': true,
        'contributorId': _ebramId,
        'status': 'approved',
        'contributorIsSuperUser': true,
        'views': 287,
        'saves': 112,
        'createdAt': FieldValue.serverTimestamp(),
      },
      // ── Pending gems (in moderation queue) ───────────────────────────────
      {
        'name': 'Rooftop Cinema at Príncipe Real',
        'description':
            'An unofficial rooftop cinema that runs on Saturday nights in summer. BYO blanket. Films are always in original language.',
        'category': 'Rooftops',
        'vibe': 'Chill',
        'rating': 0.0,
        'imageUrl':
            'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=800&q=80',
        'latitude': 38.7167,
        'longitude': -9.1497,
        'localsTip': 'Follow @cinemadetelhado on Instagram for the schedule.',
        'recommendedDishes': [],
        'isPremium': false,
        'isTrending': false,
        'contributorId': _youstinaId,
        'status': 'pending',
        'contributorIsSuperUser': false,
        'views': 0,
        'saves': 0,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Tasca da Esquina Lunch Special',
        'description':
            'A neighborhood restaurant that serves a 3-course lunch for €7 to locals only (tourists get the full menu). You need to ask in Portuguese.',
        'category': 'Hidden Dining',
        'vibe': 'Budget',
        'rating': 0.0,
        'imageUrl':
            'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80',
        'latitude': 38.7215,
        'longitude': -9.1388,
        'localsTip':
            'Say "o menu do dia, por favor" and smile. Works every time.',
        'recommendedDishes': ['Prato do Dia', 'Sopa do Dia'],
        'isPremium': false,
        'isTrending': false,
        'contributorId': _youstinaId,
        'status': 'pending',
        'contributorIsSuperUser': false,
        'views': 0,
        'saves': 0,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    final batch = _db.batch();
    for (final gem in gems) {
      final docRef = col.doc();
      gem['id'] = docRef.id;
      batch.set(docRef, gem);
    }
    await batch.commit();
    print(
      '✅ ${gems.length} gems seeded (${gems.where((g) => g['status'] == 'approved').length} approved, ${gems.where((g) => g['status'] == 'pending').length} pending).',
    );
  }

  // ── 3. CHATS ───────────────────────────────────────────────────────────────
  static Future<void> _seedChats() async {
    final col = _db.collection('chats');
    final existing = await col.limit(1).get();
    if (existing.docs.isNotEmpty) {
      print('ℹ️  Chats already seeded.');
      return;
    }

    // Chat 1: youstinaId asking manuelId about the Jazz Cellar
    final chat1Ref = col.doc();
    await chat1Ref.set({
      'id': chat1Ref.id,
      'participants': [_youstinaId, _manuelId],
      'participantNames': {
        _youstinaId: 'Youstina Raouf',
        _manuelId: 'Manuel Youssef',
      },
      'participantAvatars': {
        _youstinaId:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=150',
        _manuelId:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150',
      },
      'lastMessage': 'The entrance is right behind the blue door on Rua Nova.',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount': {_youstinaId: 1, _manuelId: 0},
      'relatedGemName': 'Café Tati – Hidden Jazz Cellar',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Messages for chat 1
    final msgs1 = [
      {
        'senderId': _youstinaId,
        'text':
            'Hey! I saw your post about the Jazz Cellar. How do I find the entrance?',
        'timestamp': FieldValue.serverTimestamp(),
        'readBy': [_youstinaId],
      },
      {
        'senderId': _manuelId,
        'text': 'Great question! It\'s a bit tricky for first-timers.',
        'timestamp': FieldValue.serverTimestamp(),
        'readBy': [_youstinaId, _manuelId],
      },
      {
        'senderId': _manuelId,
        'text':
            'The entrance is right behind the blue door on Rua Nova. Look for the vinyl records in the window.',
        'timestamp': FieldValue.serverTimestamp(),
        'readBy': [_manuelId],
      },
    ];
    final msgBatch1 = _db.batch();
    for (final msg in msgs1) {
      final msgRef = chat1Ref.collection('messages').doc();
      msg['id'] = msgRef.id;
      msgBatch1.set(msgRef, msg);
    }
    await msgBatch1.commit();

    // Chat 2: youstinaId asking chantalId about the market
    final chat2Ref = col.doc();
    await chat2Ref.set({
      'id': chat2Ref.id,
      'participants': [_youstinaId, _chantalId],
      'participantNames': {
        _youstinaId: 'Youstina Raouf',
        _chantalId: 'Chantal Sheriff',
      },
      'participantAvatars': {
        _youstinaId:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=150',
        _chantalId:
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=150',
      },
      'lastMessage': 'Definitely try the stuffed vine leaves from stall 14!',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount': {_youstinaId: 0, _chantalId: 0},
      'relatedGemName': 'LX Factory Sunday Inner Courtyard',
      'createdAt': FieldValue.serverTimestamp(),
    });

    final msgs2 = [
      {
        'senderId': _youstinaId,
        'text': 'Is the LX Factory market worth going to this Sunday?',
        'timestamp': FieldValue.serverTimestamp(),
        'readBy': [_youstinaId, _chantalId],
      },
      {
        'senderId': _chantalId,
        'text':
            'Absolutely! Go through the far-left gate for the hidden courtyard section.',
        'timestamp': FieldValue.serverTimestamp(),
        'readBy': [_youstinaId, _chantalId],
      },
      {
        'senderId': _chantalId,
        'text': 'Definitely try the stuffed vine leaves from stall 14!',
        'timestamp': FieldValue.serverTimestamp(),
        'readBy': [_youstinaId, _chantalId],
      },
    ];
    final msgBatch2 = _db.batch();
    for (final msg in msgs2) {
      final msgRef = chat2Ref.collection('messages').doc();
      msg['id'] = msgRef.id;
      msgBatch2.set(msgRef, msg);
    }
    await msgBatch2.commit();

    print('✅ 2 chats seeded with messages.');
  }

  // ── 4. REVIEWS ─────────────────────────────────────────────────────────────
  static Future<void> _seedReviews() async {
    final gemsSnap = await _db
        .collection('gems')
        .where('status', isEqualTo: 'approved')
        .get();
    if (gemsSnap.docs.isEmpty) return;

    final batch = _db.batch();
    int reviewCount = 0;

    for (final gemDoc in gemsSnap.docs) {
      // Add a couple of reviews to each approved gem
      final review1Ref = gemDoc.reference.collection('reviews').doc();
      batch.set(review1Ref, {
        'id': review1Ref.id,
        'userId': _chantalId,
        'rating': 4.0,
        'reviewText':
            'Great place, totally hidden and the vibes are unmatched!',
        'createdAt': FieldValue.serverTimestamp(),
      });

      final review2Ref = gemDoc.reference.collection('reviews').doc();
      batch.set(review2Ref, {
        'id': review2Ref.id,
        'userId': _ebramId,
        'rating': 5.0,
        'reviewText': 'One of the best spots I have found on this app.',
        'createdAt': FieldValue.serverTimestamp(),
      });
      reviewCount += 2;
    }
    await batch.commit();
    print('✅ $reviewCount reviews seeded.');
  }

  // ── 5. NOTIFICATIONS ───────────────────────────────────────────────────────
  static Future<void> _seedNotifications() async {
    final col = _db.collection('notifications');
    await col.add({
      'title': 'Welcome to LikeALocal Phase 7!',
      'message':
          'All systems are now live. Explore super user recommendations and earn your Local Legend badge.',
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
      'createdBy': _eyadId,
    });
    print('✅ 1 admin notification seeded.');
  }

  // ── 99. CLEAR DB ───────────────────────────────────────────────────────────
  static Future<void> _clearDatabase() async {
    print('🧹 Clearing existing database collections...');

    // 1. Users
    final users = await _db.collection('users').get();
    for (final doc in users.docs) {
      await doc.reference.delete();
    }

    // 2. Notifications
    final notifs = await _db.collection('notifications').get();
    for (final doc in notifs.docs) {
      await doc.reference.delete();
    }

    // 3. Gems & Reviews
    final gems = await _db.collection('gems').get();
    for (final doc in gems.docs) {
      final reviews = await doc.reference.collection('reviews').get();
      for (final r in reviews.docs) {
        await r.reference.delete();
      }
      await doc.reference.delete();
    }

    // 4. Chats & Messages
    final chats = await _db.collection('chats').get();
    for (final doc in chats.docs) {
      final msgs = await doc.reference.collection('messages').get();
      for (final m in msgs.docs) {
        await m.reference.delete();
      }
      await doc.reference.delete();
    }

    print('🧹 Database cleared.');
  }
}
