// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/shared/classes/shared_components.dart';
import 'package:flutter_application_2/utils/date_formatter.dart';
import 'package:flutter/services.dart'; // ✅ Required for status bar color
import 'package:flutter_application_2/components/leaderboard_toggle.dart';

class UserDetailPage extends StatefulWidget {
  final LeaderboardModel user;
  final LeaderboardType leaderboardType;

  const UserDetailPage({
    super.key,
    required this.user,
    required this.leaderboardType,
  });

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  late LeaderboardType selectedLeaderboard;
  bool isCheaterExpanded = false;
  bool isToxicityExpanded = false;
  bool isHonourExpanded = false;

  @override
  void initState() {
    super.initState();
    selectedLeaderboard = widget.leaderboardType;
  }

  /// 🟥 **Cheater Report History**
  Widget _buildCheaterReportHistory(LeaderboardModel user) {
    return _buildReportHistory(
      title: "Cheater Report History",
      reports: user.lastCheaterReported,
      label: "Cheater",
      color: Color(0xffe63030),
    );
  }

  /// 🟨 **Toxicity Report History**
  Widget _buildToxicityReportHistory(LeaderboardModel user) {
    return _buildReportHistory(
      title: "Toxicity Report History",
      reports: user.lastToxicityReported,
      label: "Toxicity",
      color: Color(0xffB3FB07),
    );
  }

  /// 🟦 **Honorable Report History**
  Widget _buildHonorableReportHistory(LeaderboardModel user) {
    return _buildReportHistory(
      title: "Honorable Report History",
      reports: user.lastHonourReported,
      label: "Honours",
      color: Color(0xff19f6eb),
    );
  }

  Widget _buildReportHistory({
    required String title,
    required List<String> reports,
    required String label,
    required Color color,
  }) {
    return Card(
      color: const Color(0xff2b3254), // Dark Background
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏆 Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 12),

            // 🟢 Display Report History (If available)
            reports.isNotEmpty
                ? Column(
                    children: reports.map((timestamp) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // 📅 Date & Time
                                Text(
                                  DateFormatter.formatDate(timestamp),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),

                                // 🔴 "Cheater" / 🟡 "Toxicity" / 🟢 "Honorable" Tag
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: color, width: 1),
                                  ),
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            color: Colors.grey,
                            thickness: 0.5,
                            height: 16,
                          ),
                        ],
                      );
                    }).toList(),
                  )
                : const Center(
                    child: Text(
                      "No Reports Yet.",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // 🔥 Allows background blending
      backgroundColor: const Color(0xFF141429), // 🌫 Background
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 🔥 Makes AppBar blend with glow
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          '${widget.user.gameName}#${widget.user.tagLine}',
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),

      body: Stack(
        children: [
          // 🔥 Glowing Background Positioned to Cover AppBar
          Positioned(
            top: -100, // ✅ Moved up to blend into AppBar
            left: 280,
            child: Container(
              width: 150,
              height: 100,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFA54CFF).withOpacity(0.6), // Purple Glow
                    blurRadius: 220,
                    spreadRadius: 70,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -100,
            left: -40,
            child: Container(
              width: 150,
              height: 100,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF37D5F8).withOpacity(0.6), // Blue Glow
                    blurRadius: 220,
                    spreadRadius: 70,
                  ),
                ],
              ),
            ),
          ),

          // 🌟 Main Content (Now Pushed Below AppBar)
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  16, 20, 16, 16), // 🔥 Added top padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (selectedLeaderboard != LeaderboardType.ranked) ...[
                    _buildReportSummary(widget.user),
                    const SizedBox(height: 8),
                    Divider(color: Colors.white.withOpacity(0.2), thickness: 1),
                    const SizedBox(height: 8),
                  ],

                  // ✅ Leaderboard Toggle (Now Below Report Summary)
                  LeaderboardToggle(
                    selectedLeaderboard: selectedLeaderboard,
                    onSelectLeaderboard: (LeaderboardType type) {
                      setState(() {
                        selectedLeaderboard = type;
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  if (selectedLeaderboard == LeaderboardType.ranked) ...[
                    _buildUserStats(widget.user),
                  ] else ...[
                    const SizedBox(height: 16),
                    if (selectedLeaderboard == LeaderboardType.cheater)
                      _buildCheaterReportHistory(widget.user),
                    if (selectedLeaderboard == LeaderboardType.toxicity)
                      _buildToxicityReportHistory(widget.user),
                    if (selectedLeaderboard == LeaderboardType.honour)
                      _buildHonorableReportHistory(widget.user),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats(LeaderboardModel user) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Color.fromRGBO(43, 50, 84, 1),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "Leaderboard Rank: ${user.leaderboardRank}",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              Text(
                "Ranked Rating: ${user.rankedRating ?? 'N/A'}",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              Text(
                "Games Won: ${user.numberOfWins ?? 'N/A'}",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportSummary(LeaderboardModel user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4), // ✅ Small gap
            child: _buildReportBox(
                "Cheating Reports", user.cheaterReports, Colors.red),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4), // ✅ Small gap
            child: _buildReportBox(
                "Toxicity Reports", user.toxicityReports, Color(0xffB3FB07)),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4), // ✅ Small gap
            child: _buildReportBox(
                "Times Honored", user.honourReports, Color(0xff19f6eb)),
          ),
        ),
      ],
    );
  }

  Widget _buildReportBox(String label, int count, Color color) {
    return Expanded(
      child: ClipPath(
        clipper: SoftSharpCornerClipper(), // ✅ Custom Shape Applied
        child: Stack(
          children: [
            // 🔹 Background Fill with Opacity
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.06), // ✅ Matches SVG background
                ),
              ),
            ),
            // 🔹 Border Overlay
            CustomPaint(
              painter: SoftBorderPainter(color), // ✅ Neon Border Applied
              child: Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      count.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Custom Clipper for Border Shape
class SoftSharpCornerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double softSharpRadius = 6;
    double roundedCorner = 12;

    Path path = Path();
    path.moveTo(softSharpRadius, 0);
    path.lineTo(size.width - roundedCorner, 0);
    path.quadraticBezierTo(size.width, 0, size.width, roundedCorner);
    path.lineTo(size.width, size.height - roundedCorner);
    path.lineTo(size.width, size.height - softSharpRadius);
    path.quadraticBezierTo(
        size.width, size.height, size.width - softSharpRadius, size.height);
    path.lineTo(roundedCorner, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - roundedCorner);
    path.lineTo(0, roundedCorner);
    path.quadraticBezierTo(0, 0, softSharpRadius, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ✅ Custom Painter for Neon Border
class SoftBorderPainter extends CustomPainter {
  final Color color;

  SoftBorderPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint borderPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withOpacity(1),
          color.withOpacity(0),
          color.withOpacity(0),
          color.withOpacity(1),
        ],
        stops: [0, 0.15, 0.85, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final Path borderPath = Path();
    borderPath.moveTo(6, 0);
    borderPath.lineTo(size.width - 12, 0);
    borderPath.quadraticBezierTo(size.width, 0, size.width, 12);
    borderPath.lineTo(size.width, size.height - 12);
    borderPath.lineTo(size.width, size.height - 6);
    borderPath.quadraticBezierTo(
        size.width, size.height, size.width - 6, size.height);
    borderPath.lineTo(12, size.height);
    borderPath.quadraticBezierTo(0, size.height, 0, size.height - 12);
    borderPath.lineTo(0, 6);
    borderPath.quadraticBezierTo(0, 0, 6, 0);
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
