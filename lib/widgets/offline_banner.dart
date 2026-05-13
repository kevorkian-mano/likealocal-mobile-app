import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/connectivity_provider.dart';
import '../core/providers/gems_provider.dart';
import '../core/app_export.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivity, child) {
        if (connectivity.isOnline) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.h),
          decoration: BoxDecoration(
            color: Colors.amber.shade700,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.cloud_off, color: Colors.white, size: 20.h),
              SizedBox(width: 12.h),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Operating Offline',
                      style: TextStyleHelper.instance.body14BoldInter.copyWith(color: Colors.white),
                    ),
                    Consumer<GemsProvider>(
                      builder: (context, gems, _) {
                        if (gems.isSyncing) {
                          return Row(
                            children: [
                              SizedBox(
                                width: 10.h,
                                height: 10.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 6.h),
                              Text(
                                'Syncing data...',
                                style: TextStyleHelper.instance.body12RegularInter.copyWith(color: Colors.white),
                              ),
                            ],
                          );
                        }
                        return Text(
                          'Some features like AI and maps are limited.',
                          style: TextStyleHelper.instance.body12RegularInter.copyWith(color: Colors.white.withOpacity(0.9)),
                        );
                      },
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Offline Mode'),
                      content: Text(
                        'You are currently offline. You can still view cached gems and save new ones, which will sync automatically once you are back online.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Got it'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  'INFO',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
