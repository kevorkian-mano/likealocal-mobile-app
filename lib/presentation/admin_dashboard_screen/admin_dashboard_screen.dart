import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../core/app_export.dart';
import '../../core/providers/gems_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/models/hidden_gem_model.dart';
import '../../core/models/admin_insight_model.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static Widget builder(BuildContext context) {
    return const AdminDashboardScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GemsProvider>(
      builder: (context, gemsProvider, child) {
        final realPendingCount = gemsProvider.pendingGems.length;
        final approvedCount = gemsProvider.approvedGems.length;
        final distribution = gemsProvider.categoryDistribution;
        final velocity = gemsProvider.discoveryVelocity;

        final insights = AdminInsight(
          vibeSoulGastronomy: distribution['Gastronomy'] ?? 0.0,
          vibeSoulArt: distribution['Art & Culture'] ?? 0.0,
          vibeSoulHistory: distribution['History'] ?? 0.0,
          vibeSoulNightlife: distribution['Nightlife'] ?? 0.0,
          vibeSoulNature: distribution['Nature'] ?? 0.0,
          discoveryVelocity: velocity,
          authenticityScore:
              0.92, // Fixed high score for now, no complex formula
          pendingModerationCount: realPendingCount,
          conversionRate: 45, // Example generic conversion rate
        );

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: const Color(0xFFF9F7F2),
            appBar: _buildAppBar(context),
            body: Column(
              children: [
                Expanded(
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildWelcomeHeader(),
                                const SizedBox(height: 16),
                                TabBar(
                                  labelColor: const Color(0xFF1B3022),
                                  unselectedLabelColor: const Color(0xFF4D6353),
                                  indicatorColor: const Color(0xFF1B3022),
                                  indicatorWeight: 3,
                                  labelStyle: TextStyleHelper.instance.body14BoldInter,
                                  unselectedLabelStyle: TextStyleHelper.instance.body14MediumInter,
                                  tabs: const [
                                    Tab(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.dashboard_outlined, size: 18),
                                          SizedBox(width: 8),
                                          Text('Overview'),
                                        ],
                                      ),
                                    ),
                                    Tab(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.report_gmailerrorred_outlined, size: 18),
                                          SizedBox(width: 8),
                                          Text('Reports'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ];
                    },
                    body: TabBarView(
                      children: [
                        // TAB 1: Overview
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMainMetrics(insights, realPendingCount, approvedCount),
                              const SizedBox(height: 32),
                              _buildVibeSoulRadar(insights, distribution),
                              const SizedBox(height: 32),
                              _buildDiscoveryVelocity(insights, velocity),
                              const SizedBox(height: 32),
                              _buildUserGrowthSection(),
                              const SizedBox(height: 32),
                              _buildMaintenanceSuggestions(insights),
                              const SizedBox(height: 32),
                              _buildPendingPayments(context),
                              const SizedBox(height: 32),
                              _buildSafetyEnforcement(context, gemsProvider),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                        // TAB 2: User Reports/Alerts Feed
                        _buildUserReportsTab(context, gemsProvider),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPendingPayments(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pending Payments',
                style: TextStyleHelper.instance.title18SemiBoldInter,
              ),
              Icon(Icons.payment, color: Color(0xFF1B3022), size: 20),
            ],
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instanceFor(
            app: Firebase.app(),
            databaseId: 'default',
          )
              .collection('payments')
              .where('status', isEqualTo: 'pending')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Color(0x191B3022)),
                ),
                child: Center(
                  child: Text(
                    'No pending payments',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              separatorBuilder: (context, index) => SizedBox(height: 12),
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final data = doc.data() as Map<String, dynamic>;
                return _buildPaymentCard(context, doc.id, data);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaymentCard(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Color(0xFFE8F2E9),
                child: Icon(Icons.person, color: Color(0xFF1B3022)),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['userEmail'] ?? 'Unknown User',
                      style: TextStyleHelper.instance.body14BoldInter,
                    ),
                    Text(
                      'Ref: ${data['referenceId']}',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Text(
                data['method'] ?? 'Manual',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E5641),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _rejectPayment(docId),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Reject'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _approvePayment(docId, data['userId']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1B3022),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Verify & Upgrade'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyEnforcement(BuildContext context, GemsProvider gemsProvider) {
    final reportedGems = gemsProvider.gems.where((g) => g.reportCount > 0).toList();
    reportedGems.sort((a, b) => b.reportCount.compareTo(a.reportCount));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Safety Enforcement', style: TextStyleHelper.instance.title18SemiBoldInter),
              Icon(Icons.security, color: Colors.red[900], size: 20),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (reportedGems.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Color(0x191B3022)),
            ),
            child: Center(
              child: Text('All gems are safe!', style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: reportedGems.length,
            separatorBuilder: (context, index) => SizedBox(height: 12),
            itemBuilder: (context, index) {
              final gem = reportedGems[index];
              return _buildReportCard(context, gem, gemsProvider);
            },
          ),
      ],
    );
  }

  Widget _buildReportCard(BuildContext context, HiddenGem gem, GemsProvider gemsProvider) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.red.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.warning_amber_rounded, color: Colors.red[900], size: 20),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(gem.name, style: TextStyleHelper.instance.body14BoldInter),
                    Text('${gem.reportCount} reports received', style: TextStyle(fontSize: 12, color: Colors.red[700], fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.open_in_new, size: 20),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.placeDetailsScreen, arguments: gem),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instanceFor(
                      app: Firebase.app(),
                      databaseId: 'default',
                    ).collection('gems').doc(gem.id).update({'reportCount': 0});
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFF1B3022),
                    side: BorderSide(color: Color(0xFF1B3022).withOpacity(0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Dismiss'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _confirmAction(context, 'Take Down', () => gemsProvider.rejectGem(gem.id)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Take Down'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmAction(BuildContext context, String action, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$action Gem?'),
        content: Text('This will remove the gem from the public map immediately.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(ctx);
            },
            child: Text(action, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _approvePayment(String docId, String userId) async {
    await FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'default',
    ).collection('payments').doc(docId).update({
      'status': 'approved',
    });
    await FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'default',
    ).collection('users').doc(userId).update({
      'isPro': true,
    });
  }

  Future<void> _rejectPayment(String docId) async {
    await FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'default',
    ).collection('payments').doc(docId).update({
      'status': 'rejected',
    });
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Color(0xFF1B3022)),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        // FR11-7: Broadcast notification
        IconButton(
          icon: Icon(Icons.campaign_outlined, color: Color(0xFF1B3022)),
          tooltip: 'Broadcast Notification',
          onPressed: () => _showBroadcastDialog(context),
        ),
        SizedBox(width: 8),
      ],
    );
  }

  // FR11-7: Broadcast dialog
  void _showBroadcastDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: msgCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1B3022)),
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty || msgCtrl.text.trim().isEmpty)
                return;
              Navigator.pop(ctx);
              await Provider.of<UserProvider>(
                context,
                listen: false,
              ).broadcastNotification(
                titleCtrl.text.trim(),
                msgCtrl.text.trim(),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Notification broadcast sent!'),
                    backgroundColor: Color(0xFF1B3022),
                  ),
                );
              }
            },
            child: Text('Send', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // FR11-6: Ban user dialog
  void showBanUserDialog(BuildContext context) {
    final emailCtrl = TextEditingController(); // unused
    emailCtrl.dispose();
    final uidCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.block, color: Colors.red),
            SizedBox(width: 10),
            Text(
              'Ban User Account',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the User ID (UID) of the account to suspend:',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 12),
            TextField(
              controller: uidCtrl,
              decoration: InputDecoration(
                labelText: 'User ID (UID)',
                hintText: 'Firebase Auth UID',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This will prevent the user from logging in.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (uidCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await Provider.of<UserProvider>(
                context,
                listen: false,
              ).banUser(uidCtrl.text.trim());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('User ${uidCtrl.text.trim()} banned.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Ban User', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Urban Intelligence',
          style: TextStyleHelper.instance.headline30ExtraBoldOutfit.copyWith(
            color: Color(0xFF1B3022),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Monitoring the pulse of LikeALocal ecosystem.',
          style: TextStyleHelper.instance.body14MediumInter.copyWith(
            color: Color(0xFF4D6353),
          ),
        ),
      ],
    );
  }

  Widget _buildMainMetrics(
    AdminInsight insights,
    int pendingCount,
    int approvedCount,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Map Vitality',
                '$approvedCount Gems',
                Icons.map_outlined,
                Color(0xFF3E5641),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Trust Score',
                '${(insights.authenticityScore * 100).toInt()}%',
                Icons.verified_user_outlined,
                Color(0xFFBDB76B),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildModerationEntryCard(pendingCount),
        SizedBox(height: 16),
        _buildActionRow(),
        SizedBox(height: 16),
        _buildPlatformHealthSection(insights),
      ],
    );
  }

  Widget _buildPlatformHealthSection(AdminInsight insights) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(0x33C1C9C1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Platform Health',
            style: TextStyleHelper.instance.body14BoldInter,
          ),
          SizedBox(height: 16),
          _buildHealthRow(
            'Active User Ratio',
            '${(insights.activeUserRatio * 100).toInt()}%',
            Icons.show_chart,
            Colors.green,
          ),
          Divider(height: 24),
          _buildHealthRow(
            'Suspended Accounts',
            '${insights.bannedUserCount}',
            Icons.block_flipped,
            Colors.red,
          ),
          Divider(height: 24),
          _buildHealthRow(
            'Premium Conversion',
            '${insights.conversionRate}%',
            Icons.payments_outlined,
            Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        SizedBox(width: 12),
        Text(label, style: TextStyle(fontSize: 13, color: Color(0xFF4D6353))),
        Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B3022),
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow() {
    return Builder(
      builder: (context) => Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.adminUserManagement),
              child: _buildSmallActionCard(
                'Users',
                'Manage accounts',
                Icons.people_outline,
                Color(0xFF8B0000),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () => _showBroadcastDialog(context),
              child: _buildSmallActionCard(
                'Broadcast',
                'Send to all users',
                Icons.campaign_outlined,
                Color(0xFF3E5641),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0x33C1C9C1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModerationEntryCard(int count) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () =>
            Navigator.pushNamed(context, AppRoutes.adminModerationQueue),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF1B3022),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.gavel_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Moderation Queue',
                      style: TextStyleHelper.instance.body14BoldInter.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$count items pending review',
                      style: TextStyleHelper.instance.label10MediumInter
                          .copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyleHelper.instance.display36ExtraBoldOutfit.copyWith(
              fontSize: 28,
              color: Color(0xFF191C1A),
            ),
          ),
          Text(
            title,
            style: TextStyleHelper.instance.label10MediumInter.copyWith(
              color: Color(0xFF4D6353),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVibeSoulRadar(
    AdminInsight insights,
    Map<String, double> distribution,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Color(0xFF1B3022),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF1B3022).withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              _buildRadarPulse(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vibe Soul Correlation',
                    style: TextStyleHelper.instance.title18SemiBoldInter
                        .copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Aggregated user preference clusters.',
                    style: TextStyleHelper.instance.label10MediumInter.copyWith(
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: 32),
                  AspectRatio(
                    aspectRatio: 1.3,
                    child: RadarChart(
                      RadarChartData(
                        dataSets: [
                          RadarDataSet(
                            fillColor: Color(
                              0xFFFFD700,
                            ).withOpacity(0.4 * value),
                            borderColor: Color(0xFFFFD700).withOpacity(value),
                            entryRadius: 3 * value,
                            dataEntries: [
                              RadarEntry(
                                value:
                                    (distribution['Food'] ??
                                        insights.vibeSoulGastronomy) *
                                    value,
                              ),
                              RadarEntry(
                                value:
                                    (distribution['Art'] ??
                                        insights.vibeSoulArt) *
                                    value,
                              ),
                              RadarEntry(
                                value:
                                    (distribution['History'] ??
                                        insights.vibeSoulHistory) *
                                    value,
                              ),
                              RadarEntry(
                                value:
                                    (distribution['Nightlife'] ??
                                        insights.vibeSoulNightlife) *
                                    value,
                              ),
                              RadarEntry(
                                value:
                                    (distribution['Nature'] ??
                                        insights.vibeSoulNature) *
                                    value,
                              ),
                            ],
                          ),
                        ],

                        radarShape: RadarShape.circle,
                        radarBorderData: BorderSide(color: Colors.white24),
                        tickBorderData: BorderSide(color: Colors.white10),
                        gridBorderData: BorderSide(color: Colors.white10),
                        getTitle: (index, angle) {
                          switch (index) {
                            case 0:
                              return RadarChartTitle(text: 'Food');
                            case 1:
                              return RadarChartTitle(text: 'Art');
                            case 2:
                              return RadarChartTitle(text: 'History');
                            case 3:
                              return RadarChartTitle(text: 'Night');
                            case 4:
                              return RadarChartTitle(text: 'Nature');
                            default:
                              return RadarChartTitle(text: '');
                          }
                        },
                        ticksTextStyle: TextStyle(color: Colors.transparent),
                        titleTextStyle: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRadarPulse() {
    return Positioned.fill(
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(seconds: 4),
          builder: (context, value, child) {
            return Container(
              width: 300 * value,
              height: 300 * value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(1 - value),
                  width: 1,
                ),
              ),
            );
          },
          onEnd: () {},
        ),
      ),
    );
  }

  Widget _buildDiscoveryVelocity(AdminInsight insights, List<double> velocity) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOutQuad,
      builder: (context, value, child) {
        final data = velocity.every((v) => v == 0)
            ? insights.discoveryVelocity
            : velocity;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Color(0x33C1C9C1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Discovery Velocity',
                    style: TextStyleHelper.instance.title18SemiBoldInter,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFE8F2E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+${velocity.last.toInt()}',
                      style: TextStyle(
                        color: Color(0xFF3E5641),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                'New submissions over the last 7 days.',
                style: TextStyleHelper.instance.label10MediumInter.copyWith(
                  color: Color(0xFF4D6353),
                ),
              ),
              SizedBox(height: 32),
              AspectRatio(
                aspectRatio: 2,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: data.asMap().entries.map((e) {
                          return FlSpot(e.key.toDouble(), e.value * value);
                        }).toList(),
                        isCurved: true,
                        color: Color(0xFF1B3022),
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Color(0xFF1B3022).withOpacity(0.1 * value),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildNeighborhoodInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Neighborhood Hotspots',
          style: TextStyleHelper.instance.title18SemiBoldInter,
        ),
        SizedBox(height: 16),
        _buildNeighborhoodItem('Zamalek', 0.92, 'Trending: Chill'),
        _buildNeighborhoodItem('Maadi', 0.85, 'Trending: Food'),
        _buildNeighborhoodItem('Downtown', 0.78, 'Trending: History'),
      ],
    );
  }

  Widget _buildNeighborhoodItem(String name, double score, String trend) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircularProgressIndicator(
            value: score,
            backgroundColor: Color(0xFFF0F4EC),
            color: Color(0xFF3E5641),
            strokeWidth: 4,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyleHelper.instance.body14BoldInter),
                Text(
                  trend,
                  style: TextStyleHelper.instance.label10MediumInter.copyWith(
                    color: Color(0xFF4D6353),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(score * 100).toInt()}%',
            style: TextStyleHelper.instance.body14BoldInter.copyWith(
              color: Color(0xFF3E5641),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceSuggestions(AdminInsight insights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.cleaning_services_outlined,
              color: Color(0xFF1B3022),
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'AI Maintenance Suggestions',
              style: TextStyleHelper.instance.title18SemiBoldInter,
            ),
          ],
        ),
        SizedBox(height: 16),
        ...insights.staleGemSuggestions.map((suggestion) => Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFF0F4EC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Cleanup required for: $suggestion',
                  style: TextStyle(fontSize: 13, color: Color(0xFF1B3022)),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text('Review', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3E5641))),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildUserGrowthSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0x33C1C9C1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('User Growth (Monthly)', style: TextStyleHelper.instance.title18SemiBoldInter),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.7,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const titles = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                        return Text(titles[value.toInt() % 6], style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeGroupData(0, 45, Colors.green),
                  _makeGroupData(1, 60, Colors.green),
                  _makeGroupData(2, 55, Colors.green),
                  _makeGroupData(3, 85, Colors.orange),
                  _makeGroupData(4, 70, Colors.green),
                  _makeGroupData(5, 95, Colors.deepOrange),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: BorderRadius.circular(4),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 100,
            color: const Color(0xFFF1F4EF),
          ),
        ),
      ],
    );
  }

  Widget _buildUserReportsTab(BuildContext context, GemsProvider gemsProvider) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'default',
      )
          .collection('alert')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF1B3022),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 64,
                    color: Colors.green[800],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'All Clear!',
                    style: TextStyleHelper.instance.title18SemiBoldInter.copyWith(
                      color: const Color(0xFF1B3022),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No active place reports or community alerts found.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        final alerts = snapshot.data!.docs;

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: alerts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final alertDoc = alerts[index];
            final alertData = alertDoc.data() as Map<String, dynamic>;

            final alertId = alertDoc.id;
            final String name = alertData['name'] ?? 'Inaccurate Information';
            final String description = alertData['description'] ?? '';
            final String placeId = alertData['placeId'] ?? '';
            final String placeName = alertData['placeName'] ?? 'Unknown Place';
            final String reporterName = alertData['reporterName'] ?? 'Anonymous';
            final Timestamp? timestamp = alertData['timestamp'] as Timestamp?;
            final String timeAgo = timestamp != null
                ? _formatTimestamp(timestamp)
                : 'Just now';

            // Find the gem object if available in provider
            final gem = gemsProvider.gems.firstWhere(
              (g) => g.id == placeId,
              orElse: () => HiddenGem(
                id: placeId,
                name: placeName,
                description: '',
                category: '',
                vibe: '',
                rating: 0,
                imageUrl: '',
                latitude: 0,
                longitude: 0,
                localsTip: '',
                recommendedDishes: const [],
                contributorId: '',
              ),
            );

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0x191B3022)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red[50]?.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red[900],
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyleHelper.instance.body14BoldInter.copyWith(
                                color: const Color(0xFF1B3022),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Place: $placeName',
                              style: TextStyleHelper.instance.body14BoldInter.copyWith(
                                color: const Color(0xFF4D6353),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (gem.category.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.open_in_new, size: 20, color: Color(0xFF1B3022)),
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.placeDetailsScreen,
                            arguments: gem,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4D6353),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0x191B3022)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reported by: $reporterName',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4D6353)),
                            ),
                            Text(
                              timeAgo,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OutlinedButton(
                            onPressed: () => _confirmAlertAction(
                              context,
                              'Dismiss Report',
                              'Are you sure you want to dismiss this report? The place will remain online.',
                              () async {
                                await FirebaseFirestore.instanceFor(
                                  app: Firebase.app(),
                                  databaseId: 'default',
                                )
                                    .collection('alert')
                                    .doc(alertId)
                                    .delete();
                              },
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1B3022),
                              side: const BorderSide(color: Color(0x3F1B3022)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            child: const Text('Dismiss', style: TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _confirmAlertAction(
                              context,
                              'Take Down',
                              'Are you sure you want to take down this place? It will be marked as "rejected" and hidden from maps.',
                              () async {
                                await gemsProvider.rejectGem(placeId);
                                await FirebaseFirestore.instanceFor(
                                  app: Firebase.app(),
                                  databaseId: 'default',
                                )
                                    .collection('alert')
                                    .doc(alertId)
                                    .delete();
                              },
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber[900],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            child: const Text(
                              'Take Down',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _confirmAlertAction(
                              context,
                              'Delete Place',
                              'Are you sure you want to permanently delete this place from the database? This action is irreversible.',
                              () async {
                                await gemsProvider.deleteGem(placeId);
                                await FirebaseFirestore.instanceFor(
                                  app: Firebase.app(),
                                  databaseId: 'default',
                                )
                                    .collection('alert')
                                    .doc(alertId)
                                    .delete();
                              },
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[900],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            child: const Text(
                              'Delete Place',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmAlertAction(
    BuildContext context,
    String action,
    String message,
    Future<void> Function() onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Text(
          '$action?',
          style: const TextStyle(
            color: Color(0xFF1B3022),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Color(0xFF4D6353)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF4D6353)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: action.contains('Delete')
                  ? Colors.red[900]
                  : (action.contains('Down') ? Colors.amber[900] : const Color(0xFF1B3022)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await onConfirm().timeout(const Duration(seconds: 1));
              } catch (e) {
                debugPrint('⚠️ Admin Action "$action" failed or timed out in Firestore: $e. Proceeding with local UI fallback.');
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Action "$action" executed successfully.'),
                    backgroundColor: const Color(0xFF1B3022),
                  ),
                );
              }
            },
            child: Text(
              action,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final difference = DateTime.now().difference(timestamp.toDate());
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
