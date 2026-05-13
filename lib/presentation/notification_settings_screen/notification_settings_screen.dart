import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../core/providers/user_provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();

  static Widget builder(BuildContext context) {
    return const NotificationSettingsScreen();
  }
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _proximityAlerts = true;
  bool _chatNotifications = true;
  bool _weeklySummary = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray_50,
      appBar: AppBar(
        title: Text(
          'Notification Settings',
          style: TextStyleHelper.instance.title20ExtraBoldPlusJakartaSans,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customize your alerts',
              style: TextStyleHelper.instance.body16BoldInter,
            ),
            SizedBox(height: 24.h),
            _buildSettingTile(
              title: 'Proximity Alerts',
              subtitle: 'Get notified when you are near a saved gem.',
              value: _proximityAlerts,
              onChanged: (val) => setState(() => _proximityAlerts = val),
              icon: Icons.location_on_outlined,
            ),
            Divider(height: 32.h),
            _buildSettingTile(
              title: 'Chat & Comments',
              subtitle: 'Receive notifications for new messages.',
              value: _chatNotifications,
              onChanged: (val) => setState(() => _chatNotifications = val),
              icon: Icons.chat_bubble_outline,
            ),
            Divider(height: 32.h),
            _buildSettingTile(
              title: 'Weekly Summary',
              subtitle: 'Weekly stats for Super Users.',
              value: _weeklySummary,
              onChanged: (val) => setState(() => _weeklySummary = val),
              icon: Icons.analytics_outlined,
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Save logic would go here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Settings saved successfully!')),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appTheme.gray_900_01,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.h)),
                ),
                child: Text('Save Preferences', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.h),
          decoration: BoxDecoration(
            color: appTheme.colorCCFBFD.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10.h),
          ),
          child: Icon(icon, color: appTheme.gray_900_01, size: 24.h),
        ),
        SizedBox(width: 16.h),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyleHelper.instance.body14BoldInter),
              Text(subtitle, style: TextStyleHelper.instance.body12RegularInter.copyWith(color: Colors.grey)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: appTheme.gray_900_01,
        ),
      ],
    );
  }
}
