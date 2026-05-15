import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/user_provider.dart';
import '../../routes/app_routes.dart';

class SettingsPage extends StatelessWidget {
	const SettingsPage({super.key});

	static Widget builder(BuildContext context) {
		return const SettingsPage();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFFF7FBF2),
			body: SafeArea(
				child: ListView(
					padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
					children: [
						_buildTopBar(context),
						const SizedBox(height: 24),
						_buildSectionTitle('ACCOUNT'),
						_buildCard(
							children: [
								_buildRowItem(
									icon: Icons.person_outline,
									title: 'Personal Information',
									subtitle: 'Update your details and avatar',
									onTap: () => _showPersonalInformationDialog(context),
								),
								_buildDivider(),
								_buildRowItem(
									icon: Icons.verified_user_outlined,
									title: 'Trust & Verification',
									subtitle: 'Manage identity documents',
									onTap: () => _showTrustVerificationDialog(context),
								),
							],
						),
						const SizedBox(height: 24),
						_buildSectionTitle('PREFERENCES'),
						_buildCard(
							children: [
								_buildRowItem(
									icon: Icons.language_outlined,
									title: 'Language',
									subtitle: 'English (United Kingdom)',
									onTap: () => _showLanguageDialog(context),
								),
								_buildDivider(),
								_buildRowItem(
									icon: Icons.notifications_none,
									title: 'Push Notifications',
									subtitle: 'Configure your alerts',
									onTap: () {},
								),
							],
						),
						const SizedBox(height: 24),
						_buildSectionTitle('PRIVACY & MESSAGING'),
						Consumer<UserProvider>(
							builder: (context, userProvider, child) {
								final user = userProvider.user;
								return _buildCard(
									children: [
										_buildToggleItem(
											icon: Icons.chat_bubble_outline,
											title: 'Accept Messages',
											subtitle: 'Allow others to message you about gems',
											value: user?.acceptsMessages ?? true,
											onChanged: (val) => userProvider.updateProfile(acceptsMessages: val),
										),
										_buildDivider(),
										_buildToggleItem(
											icon: Icons.do_not_disturb_on_outlined,
											title: 'Do Not Disturb',
											subtitle: 'Mute messages during scheduled hours',
											value: user?.isDndEnabled ?? false,
											onChanged: (val) => userProvider.updateProfile(isDndEnabled: val),
										),
									],
								);
							},
						),
						const SizedBox(height: 24),
						_buildSectionTitle('NOTIFICATIONS'),
						_buildCard(
							children: [
								_buildToggleItem(
									icon: Icons.notifications_none,
									title: 'Push Notifications',
									subtitle: 'Messages, booking updates',
									value: true,
									onChanged: (val) {},
								),
								_buildDivider(),
								_buildToggleItem(
									icon: Icons.mail_outline,
									title: 'Email Newsletters',
									subtitle: 'Weekly local curation & tips',
									value: false,
									onChanged: (val) {},
								),
								_buildDivider(),
								_buildRowItem(
									icon: Icons.settings_suggest_outlined,
									title: 'Notification Categories',
									subtitle: 'Customize what alerts you receive',
									onTap: () => Navigator.pushNamed(context, AppRoutes.notificationSettingsScreen),
								),
							],
						),
						const SizedBox(height: 24),
						_buildSectionTitle('SUPPORT'),
						_buildCard(
							children: [
								_buildRowItem(
									icon: Icons.help_outline,
									title: 'Help Center',
									subtitle: null,
									onTap: () {},
								),
								_buildDivider(),
								_buildRowItem(
									icon: Icons.privacy_tip_outlined,
									title: 'Terms & Privacy Policy',
									subtitle: null,
									onTap: () {},
								),
							],
						),
					],
				),
			),
		);
	}

	Widget _buildTopBar(BuildContext context) {
		return Row(
			children: [
				IconButton(
					onPressed: () {
						Navigator.maybePop(context);
					},
					icon: const Icon(Icons.arrow_back, color: Color(0xFF1B3022)),
				),
				const SizedBox(width: 4),
				const Text(
					'Settings',
					style: TextStyle(
						color: Color(0xFF1B3022),
						fontSize: 20,
						fontFamily: 'Plus Jakarta Sans',
						fontWeight: FontWeight.w700,
						height: 1.4,
						letterSpacing: -0.5,
					),
				),
				const Spacer(),
				GestureDetector(
					onTap: () {
						Navigator.pushNamed(context, AppRoutes.userProfilePage);
					},
					child: Container(
						width: 40,
						height: 40,
						decoration: const BoxDecoration(
							color: Color(0xFF000000),
							shape: BoxShape.circle,
						),
						child: const Icon(
							Icons.person,
							color: Colors.white,
							size: 24,
						),
					),
				),
			],
		);
	}

	Widget _buildSectionTitle(String title) {
		return Padding(
			padding: const EdgeInsets.only(left: 8, bottom: 8),
			child: Text(
				title,
				style: const TextStyle(
					color: Color(0xFF4F6354),
					fontSize: 12,
					fontFamily: 'Inter',
					fontWeight: FontWeight.w600,
					height: 1.33,
					letterSpacing: 1.2,
				),
			),
		);
	}

	Widget _buildCard({required List<Widget> children}) {
		return Container(
			decoration: BoxDecoration(
				color: const Color(0xFFF0F4EC),
				borderRadius: BorderRadius.circular(32),
				border: Border.all(color: const Color(0x33C2C9BF)),
				boxShadow: const [
					BoxShadow(
						color: Color(0x0C000000),
						blurRadius: 2,
						offset: Offset(0, 1),
					),
				],
			),
			child: Column(children: children),
		);
	}

	Widget _buildRowItem({
		required IconData icon,
		required String title,
		String? subtitle,
		required VoidCallback onTap,
	}) {
		return InkWell(
			onTap: onTap,
			child: Padding(
				padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
				child: Row(
					children: [
						_buildIconBubble(icon),
						const SizedBox(width: 16),
						Expanded(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										title,
										style: const TextStyle(
											color: Color(0xFF191D19),
											fontSize: 16,
											fontFamily: 'Plus Jakarta Sans',
											fontWeight: FontWeight.w600,
											height: 1.5,
										),
									),
									if (subtitle != null) ...[
										const SizedBox(height: 4),
										Text(
											subtitle,
											style: const TextStyle(
												color: Color(0xFF424941),
												fontSize: 12,
												fontFamily: 'Inter',
												fontWeight: FontWeight.w400,
												height: 1.33,
											),
										),
									],
								],
							),
						),
						const Icon(Icons.chevron_right, color: Color(0xFF4F6354)),
					],
				),
			),
		);
	}

	Widget _buildToggleItem({
		required IconData icon,
		required String title,
		required String subtitle,
		required bool value,
		required ValueChanged<bool> onChanged,
	}) {
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
			child: Row(
				children: [
					_buildIconBubble(icon),
					const SizedBox(width: 16),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(
									title,
									style: const TextStyle(
										color: Color(0xFF191D19),
										fontSize: 16,
										fontFamily: 'Plus Jakarta Sans',
										fontWeight: FontWeight.w600,
										height: 1.5,
									),
								),
								const SizedBox(height: 4),
								Text(
									subtitle,
									style: const TextStyle(
										color: Color(0xFF424941),
										fontSize: 12,
										fontFamily: 'Inter',
										fontWeight: FontWeight.w400,
										height: 1.33,
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

	Widget _buildDivider() {
		return const Divider(height: 1, color: Color(0x4CC2C9BF));
	}

	Widget _buildIconBubble(IconData icon) {
		return Container(
			width: 40,
			height: 40,
			decoration: BoxDecoration(
				color: const Color(0x191B3022),
				borderRadius: BorderRadius.circular(9999),
			),
			child: Icon(icon, color: const Color(0xFF1B3022), size: 20),
		);
	}

  void _showPersonalInformationDialog(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user == null) return;

    final nameController = TextEditingController(text: user.fullName);
    final bioController = TextEditingController(text: user.bio);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Bio', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await userProvider.updateProfile(
                fullName: nameController.text.trim(),
                bio: bioController.text.trim(),
              );
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B3022)),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTrustVerificationDialog(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trust & Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.email_outlined, color: user?.isEmailVerified == true ? Colors.green : Colors.grey),
              title: const Text('Email Verification'),
              trailing: Text(user?.isEmailVerified == true ? 'Verified' : 'Pending'),
            ),
            ListTile(
              leading: const Icon(Icons.badge_outlined, color: Colors.grey),
              title: const Text('Identity Document'),
              trailing: const Text('Not Submitted'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID verification feature coming soon!')));
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Language'),
        children: [
          SimpleDialogOption(onPressed: () => Navigator.pop(context), child: const Text('English (United Kingdom)')),
          SimpleDialogOption(onPressed: () => Navigator.pop(context), child: const Text('Arabic (Egypt)')),
          SimpleDialogOption(onPressed: () => Navigator.pop(context), child: const Text('French (France)')),
        ],
      ),
    );
  }
}
