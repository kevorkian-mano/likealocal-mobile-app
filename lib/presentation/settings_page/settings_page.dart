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
									onTap: () {},
								),
								_buildDivider(),
								_buildRowItem(
									icon: Icons.verified_user_outlined,
									title: 'Trust & Verification',
									subtitle: 'Manage identity documents',
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
}
