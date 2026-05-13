
import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/gems_provider.dart';
import '../../core/services/ai_service.dart';
import 'package:provider/provider.dart';

class PremiumDashboardScreen extends StatefulWidget {
  const PremiumDashboardScreen({Key? key}) : super(key: key);

  @override
  _PremiumDashboardScreenState createState() => _PremiumDashboardScreenState();
}

class _PremiumDashboardScreenState extends State<PremiumDashboardScreen> {
  String _itinerary = '';
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final isPremium = user?.isPro == true || user?.isSuperUser == true;

    return Scaffold(
      backgroundColor: appTheme.gray_50,
      appBar: AppBar(
        title: Text('Nomad Premium', style: TextStyleHelper.instance.title20ExtraBoldPlusJakartaSans),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(isPremium),
            SizedBox(height: 32.h),
            Text('AI AI Itinerary (FR10-4)', style: TextStyleHelper.instance.body16BoldInter),
            SizedBox(height: 12.h),
            _buildItineraryCard(isPremium, user),
            SizedBox(height: 32.h),
            Text('Offline Maps (FR10-5)', style: TextStyleHelper.instance.body16BoldInter),
            SizedBox(height: 12.h),
            _buildOfflineMapCard(isPremium),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(bool isPremium) {
    return Container(
      padding: EdgeInsets.all(20.h),
      decoration: BoxDecoration(
        color: isPremium ? appTheme.midnightPine : Colors.white,
        borderRadius: BorderRadius.circular(24.h),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isPremium ? Icons.verified : Icons.lock_outline,
            color: isPremium ? Colors.white : Colors.grey,
            size: 32.h,
          ),
          SizedBox(width: 16.h),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPremium ? 'Premium Nomad Active' : 'Premium Disabled',
                  style: TextStyleHelper.instance.body14BoldInter.copyWith(
                    color: isPremium ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  isPremium ? 'Enjoy all exclusive features.' : 'Upgrade to unlock these features.',
                  style: TextStyleHelper.instance.body12RegularInter.copyWith(
                    color: isPremium ? Colors.white70 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (!isPremium)
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.pricingPage),
              child: Text('UPGRADE', style: TextStyle(color: appTheme.midnightPine, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildItineraryCard(bool isPremium, user) {
    return Container(
      padding: EdgeInsets.all(20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.h),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          if (_itinerary.isEmpty) ...[
            Icon(Icons.auto_awesome_outlined, color: appTheme.midnightPine, size: 48.h),
            SizedBox(height: 16.h),
            Text(
              'Generate a custom daily itinerary based on your vibes and nearby gems.',
              textAlign: TextAlign.center,
              style: TextStyleHelper.instance.body12RegularInter.copyWith(color: Colors.grey),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: !isPremium || _isGenerating ? null : _generateAIItinerary,
              style: ElevatedButton.styleFrom(
                backgroundColor: appTheme.midnightPine,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: _isGenerating 
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Generate with Gemini', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ] else ...[
            Text('Your Personal Itinerary', style: TextStyleHelper.instance.body14BoldInter),
            SizedBox(height: 12.h),
            Text(
              _itinerary,
              style: TextStyleHelper.instance.body12RegularInter.copyWith(height: 1.5),
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: _generateAIItinerary,
              child: Text('Regenerate', style: TextStyle(color: appTheme.midnightPine)),
            ),
          ],
        ],
      ),
    );
  }

  Map<String, double> _downloadProgress = {};

  Widget _buildOfflineMapCard(bool isPremium) {
    return Container(
      padding: EdgeInsets.all(20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.h),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildMapDownloadRow('Zamalek & Downtown Cairo', '24 MB', isPremium),
          Divider(height: 32.h),
          _buildMapDownloadRow('Maadi & Heliopolis', '35 MB', isPremium),
        ],
      ),
    );
  }

  Widget _buildMapDownloadRow(String title, String size, bool isPremium) {
    double progress = _downloadProgress[title] ?? 0.0;
    bool isDownloaded = progress >= 1.0;
    bool isDownloading = progress > 0.0 && progress < 1.0;

    return Row(
      children: [
        Icon(
          isDownloaded ? Icons.offline_pin : Icons.download_for_offline_outlined,
          color: isDownloaded ? Colors.green : appTheme.midnightPine,
          size: 32.h,
        ),
        SizedBox(width: 16.h),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyleHelper.instance.body14BoldInter),
              if (isDownloading)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    color: appTheme.midnightPine,
                    minHeight: 4,
                  ),
                )
              else
                Text(
                  isDownloaded ? 'Downloaded • Available Offline' : '$size • Recommended for you',
                  style: TextStyleHelper.instance.label10MediumInter.copyWith(color: Colors.grey),
                ),
            ],
          ),
        ),
        IconButton(
          onPressed: !isPremium || isDownloading || isDownloaded ? null : () => _simulateDownload(title),
          icon: Icon(
            isDownloaded ? Icons.check_circle : Icons.download,
            color: isDownloaded ? Colors.green : (isPremium ? appTheme.midnightPine : Colors.grey),
          ),
        ),
      ],
    );
  }

  void _simulateDownload(String title) async {
    for (double i = 0.0; i <= 1.0; i += 0.1) {
      if (!mounted) return;
      setState(() {
        _downloadProgress[title] = i;
      });
      await Future.delayed(const Duration(milliseconds: 300));
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title is now available offline!'),
        backgroundColor: const Color(0xFF1B3022),
      ),
    );
  }

  void _generateAIItinerary() async {
    setState(() => _isGenerating = true);
    final gemsProvider = Provider.of<GemsProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    final vibes = userProvider.user?.selectedVibes ?? ['Culture', 'Adventure'];
    final gemNames = gemsProvider.approvedGems.take(5).map((g) => g.name).toList();

    try {
      final result = await AIService.generateItinerary(vibes, gemNames);
      setState(() {
        _itinerary = result;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
