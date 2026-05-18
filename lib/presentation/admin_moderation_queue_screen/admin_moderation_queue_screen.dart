import '../../core/providers/gems_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../widgets/safe_image.dart';
import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../core/models/hidden_gem_model.dart';

class AdminModerationQueueScreen extends StatelessWidget {
  const AdminModerationQueueScreen({super.key});

  static Widget builder(BuildContext context) {
    return const AdminModerationQueueScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F7F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF1B3022)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Moderation Queue',
          style: TextStyleHelper.instance.title18SemiBoldInter.copyWith(
            color: Color(0xFF1B3022),
          ),
        ),
      ),
      body: Consumer<GemsProvider>(
        builder: (context, gemsProvider, child) {
          final pendingGems = gemsProvider.pendingGems;

          if (pendingGems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.checklist_rtl, size: 64, color: Color(0x331B3022)),
                  SizedBox(height: 16),
                  Text(
                    'Queue is empty!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B3022),
                    ),
                  ),
                  Text(
                    'Great job keeping the map clean.',
                    style: TextStyle(color: Color(0xFF4D6353)),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(20),
            itemCount: pendingGems.length,
            separatorBuilder: (context, index) => SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildModerationCard(
                context,
                pendingGems[index],
                gemsProvider,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildModerationCard(
    BuildContext context,
    HiddenGem gem,
    GemsProvider gemsProvider,
  ) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0x33C1C9C1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'gem_${gem.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SafeImage(
                          imageUrl: gem.imageUrl,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          placeholder: Container(
                            width: 90,
                            height: 90,
                            color: const Color(0xFFE8F2E9),
                            child: const Icon(Icons.image, color: Color(0xFF1B3022)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gem.name,
                            style: TextStyleHelper.instance.title16RegularInter
                                .copyWith(color: const Color(0xFF191C1A)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Vibe: ${gem.vibe}',
                            style: TextStyleHelper.instance.label10MediumInter
                                .copyWith(color: const Color(0xFF4D6353)),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.placeDetailsScreen,
                                arguments: gem,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F4F1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Full Preview',
                                style: TextStyleHelper
                                    .instance
                                    .body12MediumInter
                                    .copyWith(color: const Color(0xFF1B3022)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0x19C1C9C1)),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, _) {
                    final isAdmin = userProvider.user?.isAdmin == true;
                    if (isAdmin) {
                      return Row(
                        children: [
                          Expanded(
                            child: _buildActionBtn(
                              label: 'Reject',
                              color: const Color(0xFFBEAFA7),
                              icon: Icons.close,
                              onPressed: () => _confirmAction(
                                context,
                                'Reject',
                                () => gemsProvider.rejectGem(gem.id),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildActionBtn(
                              label: 'Approve',
                              color: const Color(0xFF1B3022),
                              icon: Icons.check,
                              onPressed: () => _confirmAction(
                                context,
                                'Approve',
                                () => gemsProvider.approveGem(
                                  gem.id,
                                  gem.contributorId,
                                ),
                              ),
                              isPrimary: true,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0x111B3022),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.hourglass_empty,
                              size: 16,
                              color: Color(0xFF1B3022),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Pending Moderation Review',
                              style: TextStyleHelper.instance.body12MediumInter.copyWith(
                                color: const Color(0xFF1B3022),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

  }

  void _confirmAction(
    BuildContext context,
    String action,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '$action Gem?',
          style: TextStyleHelper.instance.title18SemiBold,
        ),
        content: Text(
          'Are you sure you want to $action this contribution to the public map?',
          style: TextStyleHelper.instance.body14MediumInter,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gem ${action}ed successfully'),
                  backgroundColor: action == 'Approve'
                      ? const Color(0xFF1B3022)
                      : Colors.red[800],
                ),
              );
            },
            child: Text(
              'Confirm',
              style: TextStyle(
                color: action == 'Approve'
                    ? const Color(0xFF1B3022)
                    : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isPrimary ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(9999),
        border: isPrimary ? null : Border.all(color: color),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(9999),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isPrimary ? Colors.white : color, size: 16),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
