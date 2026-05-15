import 'package:provider/provider.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/user_provider.dart';
import '../../theme/text_style_helper.dart';
import '../../core/providers/gems_provider.dart';
import '../../core/models/hidden_gem_model.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/services/media_service.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_bottom_nav_bar.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final TextEditingController _bioController = TextEditingController();

  Future<void> _updateAvatar(
    BuildContext context,
    UserProvider userProvider,
    String userId,
  ) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image != null) {
      try {
        final String downloadUrl = await MediaService().uploadProfilePicture(
          File(image.path),
          userId,
        );
        await userProvider.updateProfile(avatarUrl: downloadUrl);
        if (context.mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated!')),
          );
      } catch (e) {
        if (context.mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  Future<void> _editBio(BuildContext context, UserProvider userProvider) async {
    _bioController.text = userProvider.user?.bio ?? '';
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Bio',
          style: TextStyleHelper.instance.title18SemiBold,
        ),
        content: TextField(
          controller: _bioController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Tell the community about yourself...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await userProvider.updateProfile(bio: _bioController.text);
              Navigator.pop(context);
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color(0xFF1B3022),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editName(
    BuildContext context,
    UserProvider userProvider,
  ) async {
    final TextEditingController nameController = TextEditingController(
      text: userProvider.user?.fullName ?? '',
    );
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Name',
          style: TextStyleHelper.instance.title18SemiBold,
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'Enter your full name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              await userProvider.updateProfile(
                fullName: nameController.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color(0xFF1B3022),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      bottomNavigationBar: const AppBottomNavBar(selectedIndex: 4),
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final user = userProvider.user;
            if (userProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF1B3022)),
              );
            }
            if (user == null) {
              return const Center(
                child: Text('Please log in to view your profile.'),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTopBar(context),
                  const SizedBox(height: 24),
                  _buildProfileHeader(context, userProvider, user),
                  const SizedBox(height: 16),
                  _buildStatsRow(user),
                  const SizedBox(height: 16),
                  _buildBadgeGallery(user),
                  const SizedBox(height: 16),
                  _buildProCard(user),
                  const SizedBox(height: 24),
                  _buildSectionHeader('MY SAVED PINS', 'View Map', onTap: () => Navigator.pushNamed(context, AppRoutes.mapsPage)),
                  _buildSavedPinsList(context, user),
                  const SizedBox(height: 8),
                  _buildListRow(
                    title: 'Saved Places',
                    subtitle: user.savedGems.isEmpty
                        ? 'No places saved yet'
                        : '${user.savedGems.length} place${user.savedGems.length == 1 ? '' : 's'} saved',
                    leadingColor: const Color(0x7FD3E8DB),
                    icon: Icons.push_pin_outlined,
                    onTap: () => _showSavedGemsSheet(context, user),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('MY EXPLORATION', 'Explore'),
                  _buildListRow(
                    title: 'Nomad Premium',
                    subtitle: user.isPro
                        ? 'Manage your features'
                        : 'Unlock AI & Offline maps',
                    leadingColor: const Color(0xFFE8F2E9),
                    icon: Icons.star_border_rounded,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.premiumDashboard,
                    ),
                  ),
                  _buildListRow(
                    title: 'Local Legends',
                    subtitle: 'View the community leaderboard',
                    leadingColor: const Color(0xFFF9F7F2),
                    icon: Icons.emoji_events_outlined,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.leaderboardScreen,
                    ),
                  ),
                  if (user.isSuperUser)
                    _buildListRow(
                      title: 'Impact Dashboard',
                      subtitle: 'Analyze your local influence',
                      leadingColor: const Color(0xFFF0F4EC),
                      icon: Icons.analytics_outlined,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.superUserDashboard,
                      ),
                    ),
                  _buildToggleRow(
                    title: 'Direct Messaging',
                    subtitle: 'Allow travelers to chat with you',
                    value: user.acceptsMessages,
                    onChanged: (val) =>
                        userProvider.updateProfile(acceptsMessages: val),
                  ),
                  _buildToggleRow(
                    title: 'Do Not Disturb',
                    subtitle: 'Auto-decline messages during rest hours',
                    value: user.isDndEnabled,
                    onChanged: (val) =>
                        userProvider.updateProfile(isDndEnabled: val),
                  ),
                  if (user.isDndEnabled)
                    _buildDndHoursRow(context, userProvider, user),
                  const SizedBox(height: 24),
                  _buildSectionHeader('MY CONTRIBUTIONS', 'Manage'),
                  _buildMyContributionsList(context),
                  const SizedBox(height: 32),
                  _buildLogoutSection(context, userProvider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAF8),
        border: Border(bottom: BorderSide(color: Color(0x33C2C9C2), width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.maybePop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              size: 20,
              color: Color(0xFF191C1A),
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'Profile',
            style: TextStyle(
              color: Color(0xFF191C1A),
              fontSize: 18,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.56,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamed(AppRoutes.settingsPage);
            },
            icon: const Icon(
              Icons.settings,
              size: 20,
              color: Color(0xFF191C1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    UserProvider userProvider,
    UserModel user,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 102,
              height: 102,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0x331B3022), width: 4),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Center(
                child: user.avatarUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(9999),
                        child: Image.network(
                          user.avatarUrl,
                          fit: BoxFit.cover,
                          width: 102,
                          height: 102,
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        color: Color(0xFF1B3022),
                        size: 64,
                      ),
              ),
            ),
            GestureDetector(
              onTap: () => _updateAvatar(context, userProvider, user.id),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF1B3022),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _editName(context, userProvider),
          child: Text(
            user.fullName,
            style: TextStyleHelper.instance.title20BoldPlusJakartaSans,
          ),
        ),
        if (user.isSuperUser) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.18),
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(
                color: const Color(0xFFFFD700).withOpacity(0.35),
              ),
            ),
            child: Text(
              'Local Legend',
              style: TextStyleHelper.instance.body12BoldInter.copyWith(
                color: const Color(0xFF1B3022),
              ),
            ),
          ),
        ],
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => _editBio(context, userProvider),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              user.bio.isNotEmpty ? user.bio : 'Tap to add bio...',
              textAlign: TextAlign.center,
              style: TextStyleHelper.instance.body14MediumInter.copyWith(
                color: const Color(0xFF424942),
                decoration: TextDecoration.underline,
                decorationColor: Colors.grey.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProCard(UserModel user) {
    if (user.isPro) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFB8860B), Color(0xFFFFD700)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PRO MEMBER',
                      style: TextStyleHelper.instance.title18SemiBold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Full Access Unlocked',
                      style: TextStyleHelper.instance.body12MediumInter
                          .copyWith(color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(0.0, 0.5),
            end: Alignment(1.0, 0.5),
            colors: [Color(0xFF1B3022), Color(0xFF2C4C3B)],
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 15,
              offset: Offset(0, 10),
              spreadRadius: -3,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pro Travel Planner',
                    style: TextStyleHelper.instance.body14BoldInter.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Unlock unlimited pins and offline maps.',
                    style: TextStyleHelper.instance.body12MediumInter.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.pricingPage),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  'Upgrade',
                  style: TextStyleHelper.instance.body12MediumInter.copyWith(
                    color: const Color(0xFF1B3022),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(UserModel user) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
          bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(label: 'GEMS SHARED', value: '${user.karmaPoints ~/ 10}'),
          _StatItem(
            label: 'STREAK',
            value: '${user.contributionStreak}D',
            valueColor: Colors.orange[800],
            icon: Icons.local_fire_department,
          ),
          _StatItem(
            label: 'KARMA',
            value: user.karmaPoints > 1000
                ? '${(user.karmaPoints / 1000).toStringAsFixed(1)}k'
                : '${user.karmaPoints}',
            valueColor: const Color(0xFF4C6354),
            hasGlow: user.isSuperUser,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeGallery(UserModel user) {
    if (user.badges.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'Start contributing to earn badges!',
          style: TextStyleHelper.instance.body14MediumInter.copyWith(
            color: Colors.grey,
          ),
        ),
      );
    }
    return SizedBox(
      height: 100,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: user.badges.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final badge = user.badges[index];
          return _BadgeIcon(badgeId: badge);
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyleHelper.instance.body12MediumInter.copyWith(
              color: const Color(0xFF424942),
              letterSpacing: 1.2,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              action,
              style: TextStyleHelper.instance.body12MediumInter.copyWith(
                color: const Color(0xFF1B3022),
                decoration: onTap != null ? TextDecoration.underline : null,
                decorationColor: const Color(0xFF1B3022),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListRow({
    required String title,
    required String subtitle,
    required Color leadingColor,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: leadingColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: const Color(0xFF1B3022), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyleHelper.instance.body14BoldInter),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyleHelper.instance.body12MediumInter.copyWith(
                      color: const Color(0xFF424942),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: Color(0xFF1B3022),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyleHelper.instance.body14BoldInter),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyleHelper.instance.body12MediumInter.copyWith(
                    color: const Color(0xFF424942),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF1B3022),
          ),
        ],
      ),
    );
  }

  Widget _buildDndHoursRow(
    BuildContext context,
    UserProvider userProvider,
    UserModel user,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.schedule, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            'Rest Hours: ',
            style: TextStyleHelper.instance.body12MediumInter.copyWith(
              color: Colors.grey,
            ),
          ),
          TextButton(
            onPressed: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: user.dndStartHour, minute: 0),
              );
              if (time != null)
                userProvider.updateProfile(dndStartHour: time.hour);
            },
            child: Text(
              '${user.dndStartHour}:00',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Text(' to '),
          TextButton(
            onPressed: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: user.dndEndHour, minute: 0),
              );
              if (time != null)
                userProvider.updateProfile(dndEndHour: time.hour);
            },
            child: Text(
              '${user.dndEndHour}:00',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // FR3-5: Real saved gems list from Firestore
  Widget _buildSavedPinsList(BuildContext context, UserModel user) {
    if (user.savedGems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'No saved places yet. Explore and pin your favorites!',
          style: TextStyleHelper.instance.body14MediumInter.copyWith(
            color: Colors.grey,
          ),
        ),
      );
    }

    return Consumer<GemsProvider>(
      builder: (context, gemsProvider, _) {
        final savedGems = gemsProvider.gems
            .where((g) => user.savedGems.contains(g.id))
            .toList();

        if (savedGems.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Loading saved places...',
              style: TextStyleHelper.instance.body14MediumInter.copyWith(
                color: Colors.grey,
              ),
            ),
          );
        }

        return SizedBox(
          height: 110,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: savedGems.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final gem = savedGems[index];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.placeDetailsScreen,
                  arguments: gem,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFFD7E8DE),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: gem.imageUrl.isNotEmpty
                            ? Image.network(
                                gem.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.image_not_supported,
                                  color: Color(0xFF1B3022),
                                ),
                              )
                            : const Icon(
                                Icons.place,
                                color: Color(0xFF1B3022),
                                size: 32,
                              ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 80,
                      child: Text(
                        gem.name,
                        style: TextStyleHelper.instance.label10BoldInter,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showSavedGemsSheet(BuildContext context, UserModel user) {
    final gemsProvider = Provider.of<GemsProvider>(context, listen: false);
    final savedGems = gemsProvider.gems
        .where((g) => user.savedGems.contains(g.id))
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Saved Places',
                    style: TextStyleHelper.instance.title18SemiBold,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7E8DE),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${savedGems.length} saved',
                      style: TextStyleHelper.instance.body12MediumInter.copyWith(
                        color: const Color(0xFF1B3022),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: savedGems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.push_pin_outlined,
                            size: 64,
                            color: Color(0xFF1B3022),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No saved places yet',
                            style: TextStyleHelper.instance.title18SemiBold,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the pin icon on any hidden gem to save it here',
                            style: TextStyleHelper.instance.body14MediumInter
                                .copyWith(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: savedGems.length,
                      itemBuilder: (context, index) {
                        final gem = savedGems[index];
                        return ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(
                              context,
                              AppRoutes.placeDetailsScreen,
                              arguments: gem,
                            );
                          },
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: gem.imageUrl.isNotEmpty
                                ? Image.network(
                                    gem.imageUrl,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 56,
                                      height: 56,
                                      color: const Color(0xFFD7E8DE),
                                      child: const Icon(
                                        Icons.place,
                                        color: Color(0xFF1B3022),
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 56,
                                    height: 56,
                                    color: const Color(0xFFD7E8DE),
                                    child: const Icon(
                                      Icons.place,
                                      color: Color(0xFF1B3022),
                                    ),
                                  ),
                          ),
                          title: Text(
                            gem.name,
                            style: TextStyleHelper.instance.body14BoldInter,
                          ),
                          subtitle: Text(
                            gem.category,
                            style: TextStyleHelper.instance.body12MediumInter
                                .copyWith(color: Colors.grey[600]),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Color(0xFFFFD700),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                gem.rating.toStringAsFixed(1),
                                style: TextStyleHelper.instance.body12MediumInter,
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context, UserProvider userProvider) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              await userProvider.signOut();
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamedAndRemoveUntil(
                AppRoutes.onboardingScreen,
                (route) => false,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFEDEEF0),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Center(
                child: Text(
                  'Log Out',
                  style: TextStyleHelper.instance.title16RegularInter.copyWith(
                    color: const Color(0xFF1B3022),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Delete Account?',
                    style: TextStyleHelper.instance.title18SemiBold,
                  ),
                  content: Text(
                    'This action is permanent and will delete all your shared gems and karma points.',
                    style: TextStyleHelper.instance.body14MediumInter,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await userProvider.deleteAccount();
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushNamedAndRemoveUntil(
                          AppRoutes.onboardingScreen,
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: Text(
              'Delete Account Permanently',
              style: TextStyleHelper.instance.body12MediumInter.copyWith(
                color: Colors.red[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyContributionsList(BuildContext context) {
    return Consumer<GemsProvider>(
      builder: (context, gemsProvider, child) {
        final userId = Provider.of<UserProvider>(
          context,
          listen: false,
        ).user?.id;
        final myGems = gemsProvider.gems
            .where((g) => g.contributorId == userId)
            .toList();

        if (myGems.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'No contributions yet. Share a hidden gem to earn karma!',
              style: TextStyleHelper.instance.body14MediumInter,
              textAlign: TextAlign.center,
            ),
          );
        }

        return SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: myGems.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final gem = myGems[index];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.placeDetailsScreen,
                  arguments: gem,
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: NetworkImage(gem.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: _buildStatusIcon(gem.status),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 80,
                      child: Text(
                        gem.name,
                        style: TextStyleHelper.instance.label10BoldInter,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(GemStatus status) {
    IconData icon;
    Color color;
    switch (status) {
      case GemStatus.approved:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case GemStatus.pending:
        icon = Icons.access_time_filled;
        color = Colors.orange;
        break;
      case GemStatus.rejected:
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case GemStatus.draft:
        icon = Icons.edit_document;
        color = Colors.grey;
        break;
    }
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    this.valueColor,
    this.hasGlow = false,
    this.icon,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool hasGlow;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: valueColor, size: 20),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: TextStyleHelper.instance.title20BoldOutfit.copyWith(
                color: valueColor ?? const Color(0xFF1B3022),
                shadows: hasGlow
                    ? [
                        Shadow(
                          color: const Color(0xFFFFD700).withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyleHelper.instance.body12MediumInter.copyWith(
            color: const Color(0xFF424942),
          ),
        ),
      ],
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final String badgeId;
  const _BadgeIcon({required this.badgeId});

  @override
  Widget build(BuildContext context) {
    String label = badgeId.replaceAll('_', ' ').toUpperCase();
    IconData icon = Icons.emoji_events;
    Color color = const Color(0xFF1B3022);

    if (badgeId.contains('streak')) {
      icon = Icons.bolt;
      color = Colors.orange[700]!;
    } else if (badgeId.contains('rising')) {
      icon = Icons.trending_up;
      color = Colors.blue[700]!;
    } else if (badgeId.contains('legend')) {
      icon = Icons.workspace_premium;
      color = Colors.purple[700]!;
    }

    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyleHelper.instance.label10BoldInter.copyWith(
            fontSize: 8,
          ),
        ),
      ],
    );
  }
}

