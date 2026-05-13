import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_button.dart';
import '../../core/providers/user_provider.dart';
import 'package:provider/provider.dart';

class ManualPaymentScreen extends StatefulWidget {
  const ManualPaymentScreen({Key? key}) : super(key: key);

  @override
  _ManualPaymentScreenState createState() => _ManualPaymentScreenState();
}

class _ManualPaymentScreenState extends State<ManualPaymentScreen> {
  final TextEditingController _referenceController = TextEditingController();
  String _selectedMethod = 'InstaPay';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray_50,
      appBar: AppBar(
        title: Text('Manual Payment', style: TextStyleHelper.instance.title20ExtraBoldPlusJakartaSans),
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
            Text(
              'Complete your upgrade',
              style: TextStyleHelper.instance.body16BoldInter,
            ),
            SizedBox(height: 8.h),
            Text(
              'Transfer EGP 150 using one of the methods below and provide the transaction reference for verification.',
              style: TextStyleHelper.instance.body12RegularInter.copyWith(color: Colors.grey),
            ),
            SizedBox(height: 32.h),
            _buildPaymentMethod(
              'InstaPay',
              'Transfer to: likealocal@instapay',
              Icons.account_balance_wallet_outlined,
            ),
            SizedBox(height: 16.h),
            _buildPaymentMethod(
              'Vodafone Cash',
              'Transfer to: 01012345678',
              Icons.phone_android_outlined,
            ),
            SizedBox(height: 40.h),
            Text('Transaction Reference', style: TextStyleHelper.instance.body14BoldInter),
            SizedBox(height: 8.h),
            TextField(
              controller: _referenceController,
              decoration: InputDecoration(
                hintText: 'Enter Reference ID',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.h),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            SizedBox(height: 48.h),
            CustomButton(
              text: 'Submit for Verification',
              onPressed: () => _submitReference(context),
            ),
            SizedBox(height: 24.h),
            Center(
              child: Text(
                'Approvals typically take 1-2 hours.',
                style: TextStyleHelper.instance.label10MediumInter.copyWith(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(String title, String subtitle, IconData icon) {
    bool isSelected = _selectedMethod == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = title),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(20.h),
        decoration: BoxDecoration(
          color: isSelected ? appTheme.midnightPine.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16.h),
          border: Border.all(
            color: isSelected ? appTheme.midnightPine : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? appTheme.midnightPine : Colors.grey, size: 28.h),
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
            if (isSelected)
              Icon(Icons.check_circle, color: appTheme.midnightPine, size: 20.h),
          ],
        ),
      ),
    );
  }

  void _submitReference(BuildContext context) async {
    final refId = _referenceController.text.trim();
    if (refId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a reference ID')),
      );
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('payments').add({
        'userId': user.id,
        'userEmail': user.email,
        'referenceId': refId,
        'method': _selectedMethod,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reference submitted! Waiting for Admin approval.'),
          backgroundColor: Color(0xFF1B3022),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting reference: $e')),
      );
    }
  }
}
