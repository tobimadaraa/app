// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_application_2/shared/classes/shared_components.dart';

class LeaderboardToggle extends StatelessWidget {
  final LeaderboardType selectedLeaderboard;
  final Function(LeaderboardType) onSelectLeaderboard;

  const LeaderboardToggle({
    super.key,
    required this.selectedLeaderboard,
    required this.onSelectLeaderboard,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(child: _buildToggleButton("Ranked", LeaderboardType.ranked)),
        Expanded(child: _buildToggleButton("Cheater", LeaderboardType.cheater)),
        Expanded(
            child: _buildToggleButton("Toxicity", LeaderboardType.toxicity)),
        Expanded(child: _buildToggleButton("Honours", LeaderboardType.honour)),
      ],
    );
  }

  /// **🔹 Custom Toggle Button**
  Widget _buildToggleButton(String text, LeaderboardType type) {
    final bool isSelected = (type == selectedLeaderboard);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: 104,
        height: 48,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            /// **🔹 Button Background**
            ClipPath(
              clipper: SoftSharpCornerClipper(), // ✅ Updated Clipper
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(
                          0x0F37D5F8) // Selected: 6% opacity of #37D5F8
                      : const Color(0x0FFFFFFF), // Unselected: 6% opacity white
                ),
                child: ElevatedButton(
                  onPressed: () => onSelectLeaderboard(type),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: Center(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Kanit',
                        color: isSelected
                            ? const Color(0xFF37D5F8)
                            : Colors.white.withAlpha(225),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            /// **🔹 Border Overlay**
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: SoftBorderPainter(isSelected),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// **✅ Clipper with Softened Sharp Corners**
class SoftSharpCornerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double softSharpRadius = 6; // ✅ Slightly rounded instead of full square
    double roundedCorner = 12; // ✅ Normal rounded corners

    Path path = Path();

    // **🔹 Top-Left (Softened Sharp)**
    path.moveTo(softSharpRadius, 0);
    path.lineTo(size.width - roundedCorner, 0);

    // **🔹 Top-Right (Rounded)**
    path.quadraticBezierTo(size.width, 0, size.width, roundedCorner);
    path.lineTo(size.width, size.height - roundedCorner);

    // **🔹 Bottom-Right (Softened Sharp)**
    path.lineTo(size.width, size.height - softSharpRadius);
    path.quadraticBezierTo(
        size.width, size.height, size.width - softSharpRadius, size.height);
    path.lineTo(roundedCorner, size.height);

    // **🔹 Bottom-Left (Rounded)**
    path.quadraticBezierTo(0, size.height, 0, size.height - roundedCorner);
    path.lineTo(0, roundedCorner);

    path.quadraticBezierTo(0, 0, softSharpRadius, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// **🔹 Custom Painter for Softer Borders**
class SoftBorderPainter extends CustomPainter {
  final bool isSelected;

  SoftBorderPainter(this.isSelected);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint borderPaint = Paint()
      ..shader = LinearGradient(
        colors: isSelected
            ? [
                const Color(0xFF37D5F8), // ✅ Selected: Glowing cyan border
                const Color(0x0037D5F8), // ✅ Fade Out
                const Color(0x0037D5F8), // ✅ Fade Out
                const Color(0xFF37D5F8), // ✅ Selected: Glowing cyan border
              ]
            : [
                Colors.white, // ✅ Unselected: White border
                Colors.white.withOpacity(0), // ✅ Fade Out
                Colors.white.withOpacity(0), // ✅ Fade Out
                Colors.white, // ✅ Unselected: White border
              ],
        stops: [0.0, 0.15, 0.85, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 1 // ✅ Slightly thicker to match the Figma SVG
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final Path borderPath = Path();

    // **✅ Top Border (Softened Sharp & Rounded)**
    borderPath.moveTo(6, 0); // Softened sharp top-left
    borderPath.lineTo(size.width - 12, 0);
    borderPath.quadraticBezierTo(size.width, 0, size.width, 12);

    // **✅ Right Side (Straight Down)**
    borderPath.lineTo(size.width, size.height - 12);

    // **✅ Bottom Border (Softened Sharp & Rounded)**
    borderPath.lineTo(
        size.width, size.height - 6); // Softened sharp bottom-right
    borderPath.quadraticBezierTo(
        size.width, size.height, size.width - 6, size.height);
    borderPath.lineTo(12, size.height);
    borderPath.quadraticBezierTo(0, size.height, 0, size.height - 12);

    // **✅ Left Side (Straight Up)**
    borderPath.lineTo(0, 6); // Softened sharp top-left transition
    borderPath.quadraticBezierTo(0, 0, 6, 0);

    // **🎨 Draw Border**
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
