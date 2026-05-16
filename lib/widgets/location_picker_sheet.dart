import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

Future<String?> showLocationPickerSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: kWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: kBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.location_on_outlined, color: kBlue),
                SizedBox(width: 8),
                Text(
                  'Pick location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              child: const Center(
                child: Text(
                  'Gulshan-e-Iqbal, Block 4\n(Karachi area)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kTextMuted, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.pop(ctx, 'Gulshan-e-Iqbal, Block 4, Karachi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBlue,
                  foregroundColor: kWhite,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Confirm location',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
