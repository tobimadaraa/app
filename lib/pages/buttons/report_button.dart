import 'dart:async';
import 'package:flutter/material.dart';
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

  const ReportButton({
    super.key,
    required this.newUserId,
    required this.newTagLine,
    required this.onSuccess,
    required this.isToxicity,
    required this.isHonour,
    required this.buttonText,
  });

  @override
  ReportButtonState createState() => ReportButtonState();
}

class ReportButtonState extends State<ReportButton> {
  final UserRepository _userRepository = UserRepository();
  bool _canReport = true; // Controls whether the button is active
  Duration _remainingTime = Duration.zero;
  Timer? _cooldownTimer;

  // Global key based solely on report type (Step 2)
  String get _reportKey {
    String type;
    if (widget.isHonour) {
      type = "honour";
    } else if (widget.isToxicity) {
      type = "toxicity";
    } else {
      type = "cheater";
    }
    // Now the key doesn't depend on newUserId or newTagLine.
    return "lastReport_$type";
  }

  @override
  void initState() {
    super.initState();
    _checkReportAvailability();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkReportAvailability() async {
    final prefs = await SharedPreferences.getInstance();
    final int lastReport = prefs.getInt(_reportKey) ?? 0;
    final int now = DateTime.now().millisecondsSinceEpoch;
    const oneDayMillis = 24 * 60 * 60 * 1000; // 24 hours in milliseconds

    final int elapsed = now - lastReport;
    if (elapsed < oneDayMillis) {
      setState(() {
        _canReport = false;
        _remainingTime = Duration(milliseconds: oneDayMillis - elapsed);
      });
      _startCooldownTimer();
    } else {
      setState(() {
        _canReport = true;
        _remainingTime = Duration.zero;
      });
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
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        });
      }
    });
  }

  Future<void> _updateReportTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final int now = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt(_reportKey, now);
    setState(() {
      _canReport = false;
      _remainingTime = const Duration(hours: 24);
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
    final Color? reportButtonColor =
        isValid ? CustomColours.buttoncolor : Colors.grey.shade200;

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
              'Wait ${_remainingTime.inHours}h ${_remainingTime.inMinutes.remainder(60)}m',
              style: const TextStyle(fontSize: 16),
            ),
    );
  }
}
