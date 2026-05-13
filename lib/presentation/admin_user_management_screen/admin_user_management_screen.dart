import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../core/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/user_model.dart';

class AdminUserManagementScreen extends StatelessWidget {
  const AdminUserManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray_50,
      appBar: AppBar(
        title: Text('User Management', style: TextStyleHelper.instance.title18SemiBoldInter),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: appTheme.midnightPine));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users found.'));
          }

          final users = snapshot.data!.docs
              .map((d) => UserModel.fromMap(d.data() as Map<String, dynamic>, d.id))
              .toList();

          return ListView.separated(
            padding: EdgeInsets.all(20.h),
            itemCount: users.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final user = users[index];
              return _buildUserTile(context, user);
            },
          );
        },
      ),
    );
  }

  Widget _buildUserTile(BuildContext context, UserModel user) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.h),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.h,
            backgroundImage: user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null,
            child: user.avatarUrl.isEmpty ? Icon(Icons.person) : null,
          ),
          SizedBox(width: 16.h),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.fullName, style: TextStyleHelper.instance.body14BoldInter),
                Text(user.email, style: TextStyleHelper.instance.label10MediumInter.copyWith(color: Colors.grey)),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    _buildBadge(user.isPro ? 'PRO' : 'FREE', user.isPro ? Colors.amber : Colors.grey),
                    SizedBox(width: 4.h),
                    if (user.isSuperUser) _buildBadge('SUPER', Colors.blue),
                    if (user.isAdmin) _buildBadge('ADMIN', Colors.purple),
                    if (user.isBanned) _buildBadge('BANNED', Colors.red),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (val) async {
              if (val == 'ban') {
                await userProvider.banUser(user.id);
              } else if (val == 'unban') {
                await userProvider.unbanUser(user.id);
              }
            },
            itemBuilder: (context) => [
              if (!user.isBanned)
                const PopupMenuItem(value: 'ban', child: Text('Ban User', style: TextStyle(color: Colors.red))),
              if (user.isBanned)
                const PopupMenuItem(value: 'unban', child: Text('Unban User')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.h, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.h),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold)),
    );
  }
}
