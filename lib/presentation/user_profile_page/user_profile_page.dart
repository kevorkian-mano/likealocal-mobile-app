import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';

class UserProfilePage extends StatelessWidget {
	const UserProfilePage({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFFF8FAF8),
			body: SafeArea(
				child: SingleChildScrollView(
					padding: const EdgeInsets.only(bottom: 24),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.stretch,
						children: [
							_buildTopBar(context),
							const SizedBox(height: 16),
							_buildProfileHeader(),
							const SizedBox(height: 16),
							_buildStatsRow(),
							const SizedBox(height: 16),
							_buildProCard(),
							const SizedBox(height: 16),
							_buildSectionHeader('MY ACTIVE MAPS', 'New Map'),
							_buildListRow(
								title: 'Hidden Gems Added',
								subtitle: '12 active pins',
								leadingColor: const Color(0x7FD3E8DB),
							),
							_buildToggleRow(
								title: 'Allow Direct Chats',
								subtitle: 'Travelers can message you',
								value: true,
							),
							const SizedBox(height: 16),
							_buildSectionHeader('LATEST CONTRIBUTIONS', 'View All'),
							_buildListRow(
								title: 'Secret Alfama Viewpoint',
								subtitle: '1d ago',
								leadingColor: const Color(0x7FDCEAE2),
							),
							const SizedBox(height: 16),
							_buildLogoutSection(context),
						],
					),
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

	Widget _buildProfileHeader() {
		return Column(
			children: [
				Stack(
					alignment: Alignment.bottomCenter,
					children: [
						Container(
							width: 102,
							height: 102,
							decoration: BoxDecoration(
								border: Border.all(color: const Color(0x331B3022), width: 4),
								borderRadius: BorderRadius.circular(9999),
							),
							child: const Center(
								child: Icon(
									Icons.person,
									color: Color(0xFF1B3022),
									size: 64,
								),
							),
						),
						Positioned(
							bottom: -6,
							child: Container(
								padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
								decoration: BoxDecoration(
									color: const Color(0xFF1B3022),
									borderRadius: BorderRadius.circular(9999),
									border: Border.all(color: const Color(0xFFF8FAF8), width: 2),
									boxShadow: const [
										BoxShadow(
											color: Color(0x19000000),
											blurRadius: 6,
											offset: Offset(0, 4),
											spreadRadius: -1,
										),
									],
								),
								child: const Text(
									'SUPER USER',
									style: TextStyle(
										color: Colors.white,
										fontSize: 10,
										fontFamily: 'Inter',
										fontWeight: FontWeight.w700,
										height: 1.5,
										letterSpacing: -0.5,
									),
								),
							),
						),
					],
				),
				const SizedBox(height: 12),
				const Text(
					'Manuel Youssef',
					style: TextStyle(
						color: Color(0xFF191C1A),
						fontSize: 20,
						fontFamily: 'Plus Jakarta Sans',
						fontWeight: FontWeight.w700,
						height: 1.4,
					),
				),
				const SizedBox(height: 4),
				const Text(
					'Cairo, Egypt',
					style: TextStyle(
						color: Color(0xFF424942),
						fontSize: 14,
						fontFamily: 'Inter',
						fontWeight: FontWeight.w400,
						height: 1.43,
					),
				),
			],
		);
	}

	Widget _buildStatsRow() {
		return Container(
			padding: const EdgeInsets.symmetric(vertical: 16),
			decoration: const BoxDecoration(
				border: Border(
					top: BorderSide(color: Color(0x33C2C9C2), width: 1),
					bottom: BorderSide(color: Color(0x33C2C9C2), width: 1),
				),
			),
			child: const Row(
				mainAxisAlignment: MainAxisAlignment.spaceEvenly,
				children: [
					_StatItem(label: 'TIPS SHARED', value: '124'),
					_StatItem(label: 'KARMA POINTS', value: '2.8k', valueColor: Color(0xFF4C6354)),
				],
			),
		);
	}

	Widget _buildProCard() {
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
						const Expanded(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										'Pro Travel Planner',
										style: TextStyle(
											color: Colors.white,
											fontSize: 14,
											fontFamily: 'Plus Jakarta Sans',
											fontWeight: FontWeight.w700,
											height: 1.43,
										),
									),
									SizedBox(height: 4),
									Text(
										'Unlock unlimited pins and offline maps.',
										style: TextStyle(
											color: Colors.white,
											fontSize: 11,
											fontFamily: 'Inter',
											fontWeight: FontWeight.w400,
											height: 1.5,
										),
									),
								],
							),
						),
						Container(
							padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
							decoration: BoxDecoration(
								color: Colors.white,
								borderRadius: BorderRadius.circular(9999),
								boxShadow: const [
									BoxShadow(
										color: Color(0x0C000000),
										blurRadius: 2,
										offset: Offset(0, 1),
									),
								],
							),
							child: const Text(
								'Upgrade',
								style: TextStyle(
									color: Color(0xFF1B3022),
									fontSize: 12,
									fontFamily: 'Inter',
									fontWeight: FontWeight.w700,
									height: 1.33,
								),
							),
						),
					],
				),
			),
		);
	}

	Widget _buildSectionHeader(String title, String action) {
		return Container(
			padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
			color: const Color(0xFFF1F4F1),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				children: [
					Text(
						title,
						style: const TextStyle(
							color: Color(0xFF424942),
							fontSize: 12,
							fontFamily: 'Plus Jakarta Sans',
							fontWeight: FontWeight.w700,
							height: 1.33,
							letterSpacing: 1.2,
						),
					),
					Text(
						action,
						style: const TextStyle(
							color: Color(0xFF1B3022),
							fontSize: 12,
							fontFamily: 'Inter',
							fontWeight: FontWeight.w700,
							height: 1.33,
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
	}) {
		return Container(
			padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
			decoration: const BoxDecoration(
				border: Border(
					bottom: BorderSide(color: Color(0x19C2C9C2), width: 1),
				),
			),
			child: Row(
				children: [
					Container(
						width: 40,
						height: 40,
						decoration: BoxDecoration(
							color: leadingColor,
							borderRadius: BorderRadius.circular(16),
						),
					),
					const SizedBox(width: 12),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(
									title,
									style: const TextStyle(
										color: Color(0xFF191C1A),
										fontSize: 14,
										fontFamily: 'Inter',
										fontWeight: FontWeight.w600,
										height: 1.43,
									),
								),
								const SizedBox(height: 2),
								Text(
									subtitle,
									style: const TextStyle(
										color: Color(0xFF424942),
										fontSize: 12,
										fontFamily: 'Inter',
										fontWeight: FontWeight.w400,
										height: 1.33,
									),
								),
							],
						),
					),
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
			padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
			child: Row(
				children: [
					Container(
						width: 40,
						height: 40,
						decoration: BoxDecoration(
							borderRadius: BorderRadius.circular(9999),
							border: Border.all(color: const Color(0xFFE2E6E2)),
						),
					),
					const SizedBox(width: 12),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(
									title,
									style: const TextStyle(
										color: Color(0xFF191C1A),
										fontSize: 14,
										fontFamily: 'Inter',
										fontWeight: FontWeight.w600,
										height: 1.43,
									),
								),
								const SizedBox(height: 2),
								Text(
									subtitle,
									style: const TextStyle(
										color: Color(0xFF424942),
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
						onChanged: (_) {},
						activeColor: const Color(0xFF1B3022),
					),
				],
			),
		);
	}

	Widget _buildLogoutSection(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 24),
			child: Column(
				children: [
					GestureDetector(
						onTap: () {
							Navigator.of(
									context,
									rootNavigator: true,
								)
								.pushNamedAndRemoveUntil(
									AppRoutes.onboardingScreen,
									(route) => false,
								);
						},
						child: Container(
							padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
							decoration: BoxDecoration(
								color: const Color(0xFFEDEEF0),
								borderRadius: BorderRadius.circular(9999),
							),
							child: const Text(
								'Log Out',
								style: TextStyle(
									color: Color(0xFF1B3022),
									fontSize: 16,
									fontFamily: 'Inter',
									fontWeight: FontWeight.w700,
									height: 1.5,
								),
							),
						),
					),
					const SizedBox(height: 12),
					const Opacity(
						opacity: 0.5,
						child: Text(
							'VERSION 2.4.1',
							style: TextStyle(
								color: Color(0xFF424942),
								fontSize: 10,
								fontFamily: 'Inter',
								fontWeight: FontWeight.w500,
								height: 1.5,
								letterSpacing: 1,
							),
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
	});

	final String label;
	final String value;
	final Color? valueColor;

	@override
	Widget build(BuildContext context) {
		return Column(
			children: [
				Text(
					value,
					style: TextStyle(
						color: valueColor ?? const Color(0xFF1B3022),
						fontSize: 18,
						fontFamily: 'Inter',
						fontWeight: FontWeight.w700,
						height: 1.56,
					),
				),
				const SizedBox(height: 2),
				Text(
					label,
					style: const TextStyle(
						color: Color(0xFF424942),
						fontSize: 10,
						fontFamily: 'Inter',
						fontWeight: FontWeight.w400,
						height: 1.5,
						letterSpacing: 0.5,
					),
				),
			],
		);
	}
}
