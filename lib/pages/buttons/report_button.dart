import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/user_controller.dart';
import 'package:flutter_application_2/repository/user_repository.dart';
import 'package:flutter_application_2/shared/classes/colour_classes.dart';
import 'package:flutter_application_2/utils/validators.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportButton extends StatefulWidget {
  final String newUserId;
  final String newTagLine;
  final Future<void> Function() onSuccess;
  final String buttonText;
  final bool isToxicity;
  final bool isHonour;
  final Duration cooldownDuration;

  final String
      reportType; // Unique identifier: e.g. "cheater", "toxicity", "honour"
  final int
      resetTrigger; // When this value changes, the widget re-checks its cooldown

  const ReportButton({
    super.key,
    required this.newUserId,
    required this.newTagLine,
    required this.onSuccess,
    required this.isToxicity,
    required this.isHonour,
    required this.buttonText,
    this.cooldownDuration = const Duration(hours: 24),
    required this.reportType,
    this.resetTrigger = 0,
  });

  @override
  ReportButtonState createState() => ReportButtonState();
}

class ReportButtonState extends State<ReportButton> {
  final UserRepository _userRepository = UserRepository();
  bool _canReport = true;
  Duration _remainingTime = Duration.zero;
  Timer? _cooldownTimer;
  int get allowedReports {
    if (widget.reportType.toLowerCase() == "honour") {
      return 1;
    }
    return Get.find<UserController>().isPremium.value ? 2 : 1;
  }

  // Use the reportType parameter to build a unique SharedPreferences key.
  String get _reportKey => "lastReport_${widget.reportType}";

  @override
  void initState() {
    super.initState();
    // ignore: avoid_print
    print("Initializing ReportButton with key: $_reportKey");
    _checkReportAvailability();
  }

  @override
  void didUpdateWidget(covariant ReportButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When resetTrigger changes, force a re-check of the cooldown
    if (widget.resetTrigger != oldWidget.resetTrigger) {
      _checkReportAvailability();
    }
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkReportAvailability() async {
    final prefs = await SharedPreferences.getInstance();

    // ✅ Use a unique key for each report type
    final String countKey = "reportCount_${widget.reportType}";
    final String startKey = "reportStart_${widget.reportType}";

    int reportCount = prefs.getInt(countKey) ?? 0;
    int reportStart = prefs.getInt(startKey) ?? 0; // Start at 0 if missing
    final int now = DateTime.now().millisecondsSinceEpoch;
    final int cooldownMillis = widget.cooldownDuration.inMilliseconds;

    // ✅ Ensure the stored cooldown is only affecting the correct report type
    if (now - reportStart >= cooldownMillis) {
      await prefs.setInt(countKey, 0);
      await prefs.setInt(startKey, now);
      reportCount = 0;
      reportStart = now;
    }

    if (reportCount < allowedReports) {
      setState(() {
        _canReport = true;
        _remainingTime = Duration.zero;
      });
    } else {
      setState(() {
        _canReport = false;
        _remainingTime =
            Duration(milliseconds: cooldownMillis - (now - reportStart));
      });
      _startCooldownTimer();
    }
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds <= 1) {
        timer.cancel();
        setState(() {
          _canReport = true;
          _remainingTime = Duration.zero;
        });
      } else {
        setState(() {
          _remainingTime -= const Duration(seconds: 1);
        });
      }
    });
  }

  Future<void> _updateReportTimestamp() async {
    final prefs = await SharedPreferences.getInstance();

    // ✅ Unique keys per report type
    final String countKey = "reportCount_${widget.reportType}";
    final String startKey = "reportStart_${widget.reportType}";

    final int now = DateTime.now().millisecondsSinceEpoch;
    int reportCount = prefs.getInt(countKey) ?? 0;
    int reportStart = prefs.getInt(startKey) ?? now;
    final int cooldownMillis = widget.cooldownDuration.inMilliseconds;

    // ✅ Reset only if the cooldown for THIS report type has expired
    if (now - reportStart >= cooldownMillis) {
      reportCount = 0;
      reportStart = now;
    }

    reportCount++;
    await prefs.setInt(countKey, reportCount);
    await prefs.setInt(
        startKey, now); // ✅ Only update for this specific report type

    setState(() {
      if (reportCount >= allowedReports) {
        _canReport = false;
        _remainingTime =
            Duration(milliseconds: cooldownMillis - (now - reportStart));
      } else {
        _canReport = true;
        _remainingTime = Duration.zero;
      }
    });
    _startCooldownTimer();
  }

  Future<void> _handleReport() async {
    if (widget.newUserId.isEmpty || widget.newTagLine.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Get.context != null) {
          Get.snackbar(
            "Error",
            "Please enter both Riot ID and Tagline.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      });
      return;
    }
    try {
      bool reportResult = await _userRepository.reportPlayer(
        gameName: widget.newUserId.toLowerCase(),
        tagLine: widget.newTagLine.toLowerCase(),
        isToxicityReport: widget.isToxicity,
        isHonourReport: widget.isHonour,
      );

      if (!reportResult) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && Get.context != null) {
            Get.snackbar(
              "Error",
              "User not found.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        });
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Get.context != null) {
          Get.snackbar(
            "Success",
            widget.isHonour
                ? "Player successfully honoured!"
                : widget.isToxicity
                    ? "Player successfully reported as toxic!"
                    : "Player successfully reported as a cheater!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: CustomColours.buttoncolor,
            colorText: Colors.white,
          );
        }
      });

      await widget.onSuccess();
      await _updateReportTimestamp();

      if (mounted) {
        setState(() {});
      }
    } catch (error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Get.context != null) {
          Get.snackbar(
            "Error",
            error.toString(),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isValid = Validator.validateUsername(widget.newUserId) == null &&
        Validator.validateTagline(widget.newTagLine) == null;
    final Color reportButtonColor =
        isValid ? Color(0xff37d5f8) : Color(0xff525252);

    // Convert remaining time to hours and minutes
    final int hours = _remainingTime.inHours;
    final int minutes =
        (_remainingTime.inMinutes % 60); // Remaining minutes after hours

    return TextButton(
      onPressed: (isValid && _canReport) ? _handleReport : null,
      style: TextButton.styleFrom(
        backgroundColor: reportButtonColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: _canReport
          ? Text(widget.buttonText, style: const TextStyle(fontSize: 16))
          : Text(
              'Wait ${hours}h ${minutes}m',
              style: const TextStyle(fontSize: 16),
            ),
    );
  }
}
