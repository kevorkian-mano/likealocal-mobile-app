import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/user_model.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray_50,
      appBar: AppBar(
        title: Text(
          'Local Legends',
          style: TextStyleHelper.instance.title20ExtraBoldPlusJakartaSans,
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('karmaPoints', descending: true)
            .limit(20)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: appTheme.midnightPine),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No legends yet. Start contributing!'));
          }

          final users = snapshot.data!.docs
              .map(
                (d) =>
                    UserModel.fromMap(d.data() as Map<String, dynamic>, d.id),
              )
              .toList();

          return Column(
            children: [
              _buildTopThree(users.take(3).toList()),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32.h),
                    ),
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.h,
                      vertical: 24.h,
                    ),
                    itemCount: users.length > 3 ? users.length - 3 : 0,
                    separatorBuilder: (context, index) =>
                        Divider(color: Colors.grey.shade100, height: 32.h),
                    itemBuilder: (context, index) {
                      final user = users[index + 3];
                      return _buildLeaderboardTile(user, index + 4);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopThree(List<UserModel> topUsers) {
    if (topUsers.isEmpty) return SizedBox.shrink();
    return Container(
      padding: EdgeInsets.fromLTRB(24.h, 32.h, 24.h, 40.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (topUsers.length > 1) _buildPodiumItem(topUsers[1], 2, 120.h),
          _buildPodiumItem(topUsers[0], 1, 160.h),
          if (topUsers.length > 2) _buildPodiumItem(topUsers[2], 3, 100.h),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(UserModel user, int rank, double height) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: EdgeInsets.all(rank == 1 ? 4.h : 2.h),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: rank == 1
                    ? LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
                      )
                    : null,
                color: rank == 1 ? null : Colors.grey.shade300,
              ),
              child: CircleAvatar(
                radius: rank == 1 ? 40.h : 30.h,
                backgroundImage: user.avatarUrl.isNotEmpty
                    ? NetworkImage(user.avatarUrl)
                    : null,
                child: user.avatarUrl.isEmpty
                    ? Icon(Icons.person, size: 30.h)
                    : null,
              ),
            ),
            Container(
              padding: EdgeInsets.all(6.h),
              decoration: BoxDecoration(
                color: rank == 1 ? Color(0xFFFFD700) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Text(
                rank.toString(),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          user.fullName.split(' ')[0],
          style: TextStyleHelper.instance.body12BoldInter,
        ),
        Text(
          '${user.karmaPoints} KP',
          style: TextStyleHelper.instance.label10MediumInter.copyWith(
            color: appTheme.midnightPine,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile(UserModel user, int rank) {
    return Row(
      children: [
        SizedBox(
          width: 32.h,
          child: Text(
            rank.toString(),
            style: TextStyleHelper.instance.body14BoldInter.copyWith(
              color: Colors.grey,
            ),
          ),
        ),
        CircleAvatar(
          radius: 20.h,
          backgroundImage: user.avatarUrl.isNotEmpty
              ? NetworkImage(user.avatarUrl)
              : null,
          child: user.avatarUrl.isEmpty ? Icon(Icons.person, size: 16.h) : null,
        ),
        SizedBox(width: 16.h),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName,
                style: TextStyleHelper.instance.body14BoldInter,
              ),
              if (user.isSuperUser)
                Text(
                  'Local Legend',
                  style: TextStyleHelper.instance.label10MediumInter.copyWith(
                    color: Color(0xFFB8860B),
                  ),
                ),
            ],
          ),
        ),
        Text(
          '${user.karmaPoints} KP',
          style: TextStyleHelper.instance.body14BoldInter.copyWith(
            color: appTheme.midnightPine,
          ),
        ),
      ],
    );
  }
}
