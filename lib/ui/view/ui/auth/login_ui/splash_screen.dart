
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:flutter/material.dart';

class SplashScreenLogging extends StatelessWidget {
  final String message;
  final VoidCallback? onSyncInBackground;

  const SplashScreenLogging(
      {super.key, this.message = "...", this.onSyncInBackground});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: white,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                message,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: white),
              ),
            ),
            const SizedBox(height: 24),
            // Always show the button for testing
            if (onSyncInBackground != null) ...[
              ElevatedButton(
                onPressed: onSyncInBackground ??
                    () {
                    },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  onSyncInBackground != null
                      ? 'Sync in Background'
                      : 'Sync in Background (null callback)',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
