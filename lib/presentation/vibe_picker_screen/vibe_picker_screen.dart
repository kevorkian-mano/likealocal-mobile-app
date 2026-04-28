import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../routes/app_routes.dart';

class VibePickerScreen extends StatefulWidget {
  const VibePickerScreen({Key? key}) : super(key: key);

  @override
  State<VibePickerScreen> createState() => _VibePickerScreenState();
}

class _VibePickerScreenState extends State<VibePickerScreen> {
  final List<Map<String, dynamic>> _vibes = [
    {'name': 'Hidden Cafes', 'icon': Icons.coffee_outlined},
    {'name': 'Street Food', 'icon': Icons.fastfood_outlined},
    {'name': 'Rooftops', 'icon': Icons.apartment_outlined},
    {'name': 'Art & Design', 'icon': Icons.palette_outlined},
    {'name': 'Nightlife', 'icon': Icons.nightlife_outlined},
    {'name': 'History', 'icon': Icons.museum_outlined},
    {'name': 'Parks', 'icon': Icons.nature_people_outlined},
    {'name': 'Budget Gems', 'icon': Icons.savings_outlined},
    {'name': 'Luxury', 'icon': Icons.diamond_outlined},
    {'name': 'Chill Vibes', 'icon': Icons.spa_outlined},
  ];

  final Set<String> _selectedVibes = {};

  Future<void> _saveVibes() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.updateProfile(selectedVibes: _selectedVibes.toList());
    Navigator.of(context).pushReplacementNamed(AppRoutes.preferenceSummaryScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildVibeGrid(),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Personalize Your\nDiscovery',
                style: TextStyleHelper.instance.headline30ExtraBoldOutfit.copyWith(
                  color: const Color(0xFF191C1A),
                  height: 1.1,
                  letterSpacing: -1,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.explorePageWithNotifScreen);
                },
                child: Text(
                  'Skip',
                  style: TextStyleHelper.instance.body14MediumInter.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Select the vibes you enjoy. We\'ll curate your feed based on these choices.',
            style: TextStyleHelper.instance.body14MediumInter.copyWith(
              color: const Color(0xFF4D6353),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    double progress = (_selectedVibes.length / 5).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'AI Curation Strength',
              style: TextStyleHelper.instance.label10BoldInter.copyWith(color: const Color(0xFF1B3022)),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyleHelper.instance.label10BoldInter.copyWith(color: const Color(0xFF1B3022)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1B3022).withOpacity(0.1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 6,
              width: MediaQuery.of(context).size.width * 0.8 * progress,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF3E5641), Color(0xFF1B3022)]),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF1B3022).withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVibeGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: _vibes.length,
      itemBuilder: (context, index) {
        final vibe = _vibes[index];
        final isSelected = _selectedVibes.contains(vibe['name']);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedVibes.remove(vibe['name']);
              } else {
                _selectedVibes.add(vibe['name']);
              }
            });
          },
          child: AnimatedScale(
            scale: isSelected ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1B3022) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? const Color(0xFF1B3022) : const Color(0x33C1C9C1),
                  width: 1.5,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: const Color(0xFF1B3022).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  )
                ] : [],
              ),
              child: Stack(
                children: [
                  if (isSelected)
                    const Positioned(
                      top: 12,
                      right: 12,
                      child: Icon(Icons.check_circle, color: Colors.white, size: 16),
                    ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          vibe['icon'],
                          color: isSelected ? Colors.white : const Color(0xFF3E5641),
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          vibe['name'],
                          style: TextStyleHelper.instance.body14BoldInter.copyWith(
                            color: isSelected ? Colors.white : const Color(0xFF191C1A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    bool canProceed = _selectedVibes.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: GestureDetector(
        onTap: canProceed ? _saveVibes : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            color: canProceed ? const Color(0xFF1B3022) : Colors.grey[300],
            borderRadius: BorderRadius.circular(9999),
            boxShadow: canProceed ? [
              BoxShadow(
                color: const Color(0xFF1B3022).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ] : [],
          ),
          child: Center(
            child: Text(
              'Apply Preferences',
              style: TextStyleHelper.instance.title18SemiBoldInter.copyWith(
                color: canProceed ? Colors.white : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
