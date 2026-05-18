import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../core/app_export.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/gems_provider.dart';
import '../../core/providers/chat_provider.dart';
import '../../core/models/user_model.dart';
import '../../core/models/hidden_gem_model.dart';
import '../../core/models/chat_model.dart';
import '../../core/utils/database_seeder.dart';
import '../../widgets/safe_image.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _userSearchQuery = '';
  String _postSearchQuery = '';
  final TextEditingController _userSearchCtrl = TextEditingController();
  final TextEditingController _postSearchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _userSearchCtrl.dispose();
    _postSearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2),
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsersTab(),
          _buildPostsTab(),
          _buildAccountTab(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1B3022),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        'Admin Control Center',
        style: TextStyleHelper.instance.headline30ExtraBoldOutfit.copyWith(
          color: Colors.white,
          fontSize: 20.fSize,
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFFBDB76B),
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        labelStyle: TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w700,
          fontSize: 14.fSize,
        ),
        tabs: const [
          Tab(text: 'Users', icon: Icon(Icons.people_outline)),
          Tab(text: 'Posts & Gems', icon: Icon(Icons.map_outlined)),
          Tab(text: 'Admin Profile', icon: Icon(Icons.admin_panel_settings_outlined)),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 👥 USERS TAB
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildUsersTab() {
    return Column(
      children: [
        _buildUserSearchBar(),
        Expanded(child: _buildUserList()),
      ],
    );
  }

  Widget _buildUserSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: TextField(
        controller: _userSearchCtrl,
        onChanged: (value) => setState(() => _userSearchQuery = value.toLowerCase()),
        decoration: InputDecoration(
          hintText: 'Search users by name or email...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF4D6353)),
          filled: true,
          fillColor: Colors.white,
          hoverColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0x33C1C9C1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF1B3022)),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'default',
      ).collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1B3022)),
          );
        }

        final docs = snapshot.data!.docs;
        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['fullName'] ?? '').toString().toLowerCase();
          final email = (data['email'] ?? '').toString().toLowerCase();
          return name.contains(_userSearchQuery) || email.contains(_userSearchQuery);
        }).toList();

        if (filteredDocs.isEmpty) {
          return const Center(child: Text('No users found matching your search.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final user = UserModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
            return _buildUserCard(user);
          },
        );
      },
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0x191B3022)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: const Color(0xFFE8F2E9),
          backgroundImage: user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null,
          child: user.avatarUrl.isEmpty
              ? const Icon(Icons.person, color: Color(0xFF1B3022))
              : null,
        ),
        title: Text(
          user.fullName,
          style: TextStyleHelper.instance.body14BoldInter.copyWith(
            color: const Color(0xFF1B3022),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.email,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                if (user.isAdmin) _buildBadgeTag('ADMIN', Colors.red),
                if (user.isSuperUser) _buildBadgeTag('SUPER USER', Colors.teal),
                if (user.isPro) _buildBadgeTag('PRO', const Color(0xFFBDB76B)),
                if (user.isBanned) _buildBadgeTag('SUSPENDED', Colors.grey),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF1B3022)),
        onTap: () => _showUserDetailBottomSheet(user),
      ),
    );
  }

  Widget _buildBadgeTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9.fSize,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 📋 USER DETAILS & CONTROLS BOTTOM SHEET
  // ───────────────────────────────────────────────────────────────────────────
  void _showUserDetailBottomSheet(UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Color(0xFFF9F7F2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handlebar
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'Account Intelligence',
                      style: TextStyleHelper.instance.title18SemiBoldInter.copyWith(
                        fontSize: 22.fSize,
                        color: const Color(0xFF1B3022),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // User Info Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0x191B3022)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: const Color(0xFFE8F2E9),
                            backgroundImage: user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null,
                            child: user.avatarUrl.isEmpty
                                ? const Icon(Icons.person, size: 36, color: Color(0xFF1B3022))
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.fullName,
                                  style: TextStyleHelper.instance.body14BoldInter.copyWith(
                                    fontSize: 18.fSize,
                                    color: const Color(0xFF1B3022),
                                  ),
                                ),
                                Text(
                                  user.email,
                                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'UID: ${user.id}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'monospace',
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Stats row
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoStatCard(
                            'Karma Points',
                            '${user.karmaPoints} 💎',
                            Colors.blue[900]!,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoStatCard(
                            'Streak Count',
                            '${user.contributionStreak} 🔥',
                            Colors.orange[900]!,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Bio section
                    Text(
                      'Biography',
                      style: TextStyleHelper.instance.body14BoldInter.copyWith(
                        color: const Color(0xFF1B3022),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0x191B3022)),
                      ),
                      child: Text(
                        user.bio.isNotEmpty ? user.bio : 'No biography provided.',
                        style: TextStyle(
                          fontSize: 13,
                          color: user.bio.isNotEmpty ? Colors.black87 : Colors.grey,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Custom Badges list
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'String Badges list',
                          style: TextStyleHelper.instance.body14BoldInter.copyWith(
                            color: const Color(0xFF1B3022),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF1B3022)),
                          onPressed: () => _showAddBadgeDialog(user, setModalState),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: user.badges.isEmpty
                          ? [
                              Text(
                                'No custom badges awarded yet.',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              )
                            ]
                          : user.badges.map((badge) {
                              return Chip(
                                label: Text(badge),
                                backgroundColor: const Color(0xFFE8F2E9),
                                labelStyle: const TextStyle(
                                  color: Color(0xFF1B3022),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                deleteIcon: const Icon(Icons.close, size: 14, color: Colors.red),
                                onDeleted: () async {
                                  final newBadges = List<String>.from(user.badges)..remove(badge);
                                  await FirebaseFirestore.instanceFor(
                                    app: Firebase.app(),
                                    databaseId: 'default',
                                  ).collection('users').doc(user.id).update({'badges': newBadges});
                                  setModalState(() {
                                    user.badges.remove(badge);
                                  });
                                },
                              );
                            }).toList(),
                    ),
                    const SizedBox(height: 28),

                    // Admin controls
                    Text(
                      'Administrative Operations',
                      style: TextStyleHelper.instance.body14BoldInter.copyWith(
                        color: const Color(0xFF1B3022),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Pro & Super User status toggles
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0x191B3022)),
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text(
                              'Pro Membership',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text('Grants unlimited chat access'),
                            value: user.isPro,
                            activeColor: const Color(0xFF1B3022),
                            onChanged: (val) async {
                              await FirebaseFirestore.instanceFor(
                                app: Firebase.app(),
                                databaseId: 'default',
                              ).collection('users').doc(user.id).update({'isPro': val});
                              setModalState(() {
                                user = user.copyWith(isPro: val);
                              });
                            },
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            title: const Text(
                              'Super User Role',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text('Enable instant review bypass'),
                            value: user.isSuperUser,
                            activeColor: const Color(0xFF1B3022),
                            onChanged: (val) async {
                              await FirebaseFirestore.instanceFor(
                                app: Firebase.app(),
                                databaseId: 'default',
                              ).collection('users').doc(user.id).update({'isSuperUser': val});
                              setModalState(() {
                                user = user.copyWith(isSuperUser: val);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Primary actions: Send Direct Message
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B3022),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => _startAdminChat(user),
                        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                        label: const Text(
                          'Send Direct Message',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Danger actions: Suspend & Delete
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red[900],
                              side: BorderSide(color: Colors.red[900]!.withOpacity(0.3)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () async {
                              final userProvider = Provider.of<UserProvider>(context, listen: false);
                              if (user.isBanned) {
                                await userProvider.unbanUser(user.id);
                              } else {
                                await userProvider.banUser(user.id);
                              }
                              setModalState(() {
                                user = user.copyWith(isBanned: !user.isBanned);
                              });
                            },
                            icon: Icon(user.isBanned ? Icons.check_circle_outline : Icons.block),
                            label: Text(
                              user.isBanned ? 'Lift Suspension' : 'Suspend Account',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: BorderSide(color: Colors.red.withOpacity(0.3)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => _confirmUserDeletion(user),
                            icon: const Icon(Icons.delete_forever),
                            label: const Text(
                              'Delete Account',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoStatCard(String label, String val, Color col) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x191B3022)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            val,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: col,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBadgeDialog(UserModel user, StateSetter setModalState) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Award Custom Badge'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter badge name (e.g., Local Expert)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B3022)),
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                final newBadges = List<String>.from(user.badges)..add(text);
                await FirebaseFirestore.instanceFor(
                  app: Firebase.app(),
                  databaseId: 'default',
                ).collection('users').doc(user.id).update({'badges': newBadges});
                setModalState(() {
                  user.badges.add(text);
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Award', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmUserDeletion(UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Permanent Deletion'),
        content: Text(
          'Are you absolutely sure you want to permanently delete the user account "${user.fullName}"? This process is destructive and cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete Account', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);
      await FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'default',
      ).collection('users').doc(user.id).delete();
      if (mounted) {
        navigator.pop(); // close modal sheet
        messenger.showSnackBar(
          const SnackBar(content: Text('Account permanently deleted.')),
        );
      }
    }
  }

  void _startAdminChat(UserModel targetUser) async {
    final admin = Provider.of<UserProvider>(context, listen: false).user;
    if (admin == null) return;

    if (admin.id == targetUser.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot message yourself.')),
      );
      return;
    }

    try {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await chatProvider.startNewChat(
        admin,
        targetUser.id,
        'Admin Inquiry',
      );

      final chatId = admin.id.compareTo(targetUser.id) < 0
          ? '${admin.id}_${targetUser.id}'
          : '${targetUser.id}_${admin.id}';

      final preview = ChatPreview(
        id: chatId,
        userName: targetUser.fullName,
        userAvatar: targetUser.avatarUrl,
        lastMessage: 'Chat started by Admin',
        lastMessageTime: DateTime.now(),
        relatedGemName: 'Admin Inquiry',
        targetUserId: targetUser.id,
      );

      if (mounted) {
        Navigator.pop(context); // Close bottom sheet
        Navigator.pushNamed(
          context,
          AppRoutes.chatDetailsScreen,
          arguments: preview,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 🗺️ POSTS TAB (GEMS & REVIEWS)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildPostsTab() {
    return Column(
      children: [
        _buildPostSearchBar(),
        Expanded(child: _buildPostList()),
      ],
    );
  }

  Widget _buildPostSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: TextField(
        controller: _postSearchCtrl,
        onChanged: (value) => setState(() => _postSearchQuery = value.toLowerCase()),
        decoration: InputDecoration(
          hintText: 'Search posts by name or category...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF4D6353)),
          filled: true,
          fillColor: Colors.white,
          hoverColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0x33C1C9C1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF1B3022)),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildPostList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'default',
      ).collection('gems').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1B3022)),
          );
        }

        final docs = snapshot.data!.docs;
        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? '').toString().toLowerCase();
          final category = (data['category'] ?? '').toString().toLowerCase();
          return name.contains(_postSearchQuery) || category.contains(_postSearchQuery);
        }).toList();

        if (filteredDocs.isEmpty) {
          return const Center(child: Text('No posts shared on the map.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final gem = HiddenGem.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
            return _buildPostCard(gem);
          },
        );
      },
    );
  }

  Widget _buildPostCard(HiddenGem gem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0x191B3022)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
             ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SafeImage(
                imageUrl: gem.imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder: Container(
                  width: 70,
                  height: 70,
                  color: const Color(0xFFE8F2E9),
                  child: const Icon(Icons.image, color: Color(0xFF1B3022)),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gem.name,
                    style: TextStyleHelper.instance.body14BoldInter.copyWith(
                      color: const Color(0xFF1B3022),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  _buildBadgeTag(gem.category.toUpperCase(), const Color(0xFF3E5641)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${gem.rating.toStringAsFixed(1)} • ',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(
                          gem.status == GemStatus.approved ? 'Approved' : 'Pending Review',
                          style: TextStyle(
                            fontSize: 11,
                            color: gem.status == GemStatus.approved ? Colors.green[800] : Colors.amber[800],
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmPostDeletion(gem),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmPostDeletion(HiddenGem gem) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Post permanently?'),
        content: Text(
          'Are you sure you want to permanently delete the shared place "${gem.name}"? This removes it from everyone\'s map.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete Post', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'default',
      ).collection('gems').doc(gem.id).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${gem.name}" permanently deleted.')),
        );
      }
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 🛡️ ADMIN ACCOUNT & DATA MANAGEMENT TAB
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildAccountTab() {
    final admin = Provider.of<UserProvider>(context).user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Admin details
          Text(
            'Admin Authority Profile',
            style: TextStyleHelper.instance.body14BoldInter.copyWith(
              fontSize: 18.fSize,
              color: const Color(0xFF1B3022),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0x191B3022)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF1B3022),
                  child: Text(
                    admin?.fullName.substring(0, 1).toUpperCase() ?? 'A',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        admin?.fullName ?? 'Administrator',
                        style: TextStyleHelper.instance.body14BoldInter.copyWith(fontSize: 16.fSize),
                      ),
                      Text(
                        admin?.email ?? 'admin@likelocal.com',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      _buildBadgeTag('SUPER ADMINISTRATOR', Colors.red),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Broadcast Banner Option
          Text(
            'System Notification Broadcast',
            style: TextStyleHelper.instance.body14BoldInter.copyWith(
              color: const Color(0xFF1B3022),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0x191B3022)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trigger a dynamic in-app notification banner for every user connected to the database.',
                  style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B3022),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _showBroadcastDialog(),
                    icon: const Icon(Icons.campaign_outlined, color: Colors.white),
                    label: const Text(
                      'Broadcast New Alert',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Database administration (Seed / Reseed)
          Text(
            'Database Master Control',
            style: TextStyleHelper.instance.body14BoldInter.copyWith(
              color: Colors.red[900],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.red.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DANGER ZONE: Performing a database re-seed will wipe all dynamic Firestore records (gems, users, reviews, chats) and repopulate them with fresh, optimized demonstration data.',
                  style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _confirmDatabaseWipeAndSeed(),
                    icon: const Icon(Icons.settings_backup_restore),
                    label: const Text(
                      'Destructive WIPE & RE-SEED',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showBroadcastDialog() {
    final titleCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.campaign_outlined, color: Color(0xFF1B3022)),
            SizedBox(width: 10),
            Text(
              'Broadcast to All Users',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: 'Notification Title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: msgCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B3022)),
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty || msgCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await Provider.of<UserProvider>(
                context,
                listen: false,
              ).broadcastNotification(
                titleCtrl.text.trim(),
                msgCtrl.text.trim(),
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification broadcast sent!'),
                    backgroundColor: Color(0xFF1B3022),
                  ),
                );
              }
            },
            child: const Text('Send', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDatabaseWipeAndSeed() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('WARNING: Destructive Database Wipe'),
        content: const Text(
          'This action is destructive and irreversible. It will wipe all collections (Users, Gems, Chats, Notifications) and reload default demo data. This might take several seconds and will log you out of your current session.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('WIPE & RE-SEED', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);

      // Show blocking loader
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      try {
        await DatabaseSeeder.seed();
        if (mounted) {
          navigator.pop(); // pop loader
          messenger.showSnackBar(
            const SnackBar(content: Text('Database reset and seed complete! Please log in again.')),
          );
          navigator.pushNamedAndRemoveUntil(
            AppRoutes.signInPage,
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          navigator.pop(); // pop loader
          messenger.showSnackBar(
            SnackBar(content: Text('Seed failed: $e')),
          );
        }
      }
    }
  }
}
