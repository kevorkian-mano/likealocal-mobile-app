import 'package:provider/provider.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/user_provider.dart';
import '../../theme/text_style_helper.dart';
import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final TextEditingController _bioController = TextEditingController();

  Future<void> _editBio(BuildContext context, UserProvider userProvider) async {
    _bioController.text = userProvider.user?.bio ?? '';
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Bio', style: TextStyleHelper.instance.title18SemiBold),
        content: TextField(
          controller: _bioController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Tell the community about yourself...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await userProvider.updateProfile(bio: _bioController.text);
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Color(0xFF1B3022), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final user = userProvider.user;
            if (userProvider.isLoading) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF1B3022)));
            }
            if (user == null) {
              return const Center(child: Text('Please log in to view your profile.'));
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
                  _buildProCard(user),
                  const SizedBox(height: 24),
                  _buildSectionHeader('MY EXPLORATION', 'New Map'),
                  _buildListRow(
                    title: 'Personalized Maps',
                    subtitle: '${user.karmaPoints ~/ 50} curated collections',
                    leadingColor: const Color(0x7FD3E8DB),
                    icon: Icons.layers_outlined,
                  ),
                  _buildToggleRow(
                    title: 'Direct Messaging',
                    subtitle: 'Allow travelers to chat with you',
                    value: true,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('BADGES & ACHIEVEMENTS', 'Details'),
                  _buildListRow(
                    title: user.isSuperUser ? 'Local Legend' : 'Newcomer',
                    subtitle: user.isSuperUser ? 'Unlocked at 500 Karma' : 'Reach 500 Karma to level up',
                    leadingColor: const Color(0x7FDCEAE2),
                    icon: Icons.verified_outlined,
                  ),
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
				border: Border(
					bottom: BorderSide(color: Color(0x33C2C9C2), width: 1),
				),
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
							Navigator.of(context, rootNavigator: true)
									.pushNamed(AppRoutes.settingsPage);
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

	Widget _buildProfileHeader(BuildContext context, UserProvider userProvider, UserModel user) {
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
                      child: Image.network(user.avatarUrl, fit: BoxFit.cover, width: 102, height: 102),
                    )
                  : const Icon(Icons.person, color: Color(0xFF1B3022), size: 64),
							),
						),
						GestureDetector(
              onTap: () {
                // Implementation for FR1-11 Avatar Update would go here
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF1B3022),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
              ),
            ),
					],
				),
				const SizedBox(height: 12),
				Text(
					user.fullName,
					style: TextStyleHelper.instance.title20BoldPlusJakartaSans,
				),
				if (user.isSuperUser) ...[
					const SizedBox(height: 10),
					Container(
						padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
						decoration: BoxDecoration(
							color: const Color(0xFFFFD700).withOpacity(0.18),
							borderRadius: BorderRadius.circular(9999),
							border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.35)),
						),
						child: Text(
							'Local Legend',
							style: TextStyleHelper.instance.body12BoldInter.copyWith(color: const Color(0xFF1B3022)),
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
                    Text('PRO MEMBER', style: TextStyleHelper.instance.title18SemiBold.copyWith(color: Colors.white)),
                    Text('Full Access Unlocked', style: TextStyleHelper.instance.body12MediumInter.copyWith(color: Colors.white.withOpacity(0.9))),
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
										style: TextStyleHelper.instance.body14BoldInter.copyWith(color: Colors.white),
									),
									const SizedBox(height: 4),
									Text(
										'Unlock unlimited pins and offline maps.',
										style: TextStyleHelper.instance.body12MediumInter.copyWith(color: Colors.white.withOpacity(0.8)),
									),
								],
							),
						),
						GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.pricingPage),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  'Upgrade',
                  style: TextStyleHelper.instance.body12MediumInter.copyWith(color: const Color(0xFF1B3022)),
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
					_StatItem(label: 'TIPS SHARED', value: '${user.karmaPoints ~/ 10}'),
					_StatItem(
            label: 'KARMA POINTS', 
            value: user.karmaPoints > 1000 ? '${(user.karmaPoints / 1000).toStringAsFixed(1)}k' : '${user.karmaPoints}', 
            valueColor: const Color(0xFF4C6354),
            hasGlow: user.isSuperUser,
          ),
				],
			),
		);
	}

	Widget _buildSectionHeader(String title, String action) {
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
          Text(
            action,
            style: TextStyleHelper.instance.body12MediumInter.copyWith(
              color: const Color(0xFF1B3022),
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
	}) {
		return Container(
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
								Text(
									title,
									style: TextStyleHelper.instance.body14BoldInter,
								),
								const SizedBox(height: 4),
								Text(
									subtitle,
									style: TextStyleHelper.instance.body12MediumInter.copyWith(color: const Color(0xFF424942)),
								),
							],
						),
					),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
				],
			),
		);
	}

	Widget _buildToggleRow({
		required String title,
		required String subtitle,
		required bool value,
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
            child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF1B3022), size: 20),
					),
					const SizedBox(width: 16),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(
									title,
									style: TextStyleHelper.instance.body14BoldInter,
								),
								const SizedBox(height: 4),
								Text(
									subtitle,
									style: TextStyleHelper.instance.body12MediumInter.copyWith(color: const Color(0xFF424942)),
								),
							],
						),
					),
					Switch(
						value: value,
						onChanged: (_) {},
						activeColor: const Color(0xFF1B3022),
					),
				],
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
							Navigator.of(context, rootNavigator: true)
								.pushNamedAndRemoveUntil(AppRoutes.onboardingScreen, (route) => false);
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
                  style: TextStyleHelper.instance.title16RegularInter.copyWith(color: const Color(0xFF1B3022)),
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
                  title: Text('Delete Account?', style: TextStyleHelper.instance.title18SemiBold),
                  content: Text('This action is permanent and will delete all your shared gems and karma points.', style: TextStyleHelper.instance.body14MediumInter),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () async {
                        await userProvider.deleteAccount();
                        Navigator.of(context, rootNavigator: true)
                          .pushNamedAndRemoveUntil(AppRoutes.onboardingScreen, (route) => false);
                      }, 
                      child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
						},
						child: Text(
							'Delete Account Permanently',
							style: TextStyleHelper.instance.body12MediumInter.copyWith(color: Colors.red[800]),
						),
					),
				],
			),
		);
	}
}

class _StatItem extends StatelessWidget {
	const _StatItem({
		required this.label,
		required this.value,
		this.valueColor,
    this.hasGlow = false,
	});

	final String label;
	final String value;
	final Color? valueColor;
  final bool hasGlow;

	@override
	Widget build(BuildContext context) {
		return Column(
			children: [
        Text(
          value,
          style: TextStyleHelper.instance.title20BoldOutfit.copyWith(
            color: valueColor ?? const Color(0xFF1B3022),
            shadows: hasGlow ? [
              Shadow(color: const Color(0xFFFFD700).withOpacity(0.5), blurRadius: 10),
            ] : null,
          ),
        ),
				const SizedBox(height: 4),
				Text(
					label,
					style: TextStyleHelper.instance.body12MediumInter.copyWith(color: const Color(0xFF424942)),
				),
			],
		);
	}
}














