// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:bliitz/services/actions_services.dart';
import 'package:bliitz/utils/_index.dart' show Adapt;
import 'package:bliitz/utils/check_internet.dart';
import 'package:bliitz/widgets/custom_loader.dart';
import 'package:flutter/material.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key, required this.reportedUserId});
  final String reportedUserId;
  @override
  // ignore: library_private_types_in_public_api
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String? _selectedReason;
  final List<String> _reasons = [
    "Violence, hate or exploitation",
    "Nudity and sexual content",
    "Frauds and scams",
    "Misinformation",
    "Graphic content"
  ];

  handleForm() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select the reason for reporting')));
    } else {
      bool isConnected = await ConnectivityHelper.isConnected();
      if (!isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: const Color(0xE601DE27).withOpacity(.5),
            content: const Text('No internet connection')));

        return;
      }
      Future<bool> uploaded = ActionServicesImpl().reportAccount(
          reportedUserId: widget.reportedUserId,
          issueMessage: _selectedReason!);

      FocusScope.of(context).unfocus();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: const AlertDialog(
              backgroundColor: Colors.transparent,
              content: EqualizerLoader(color: Color(0xE601DE27))),
        ),
      );
      if (await uploaded) {
        Navigator.pop(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Your report has been received')));
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('An Error Ocurred')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: Adapt.px(80),
                    width: Adapt.px(80),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.08),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(100.0),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white60,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Why are you reporting this account?",
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white.withOpacity(0.9),
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: _reasons.map((reason) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedReason = reason;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        reason,
                        style: TextStyle(
                          fontFamily: 'Questrial',
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          letterSpacing: 0.25,
                          height: 1.5,
                          decorationColor: Colors.white.withOpacity(0.75),
                        ),
                      ),
                      Radio<String>(
                        value: reason,
                        groupValue: _selectedReason,
                        onChanged: (value) {
                          setState(() {
                            _selectedReason = value;
                          });
                        },
                        activeColor: const Color(0xCC01DE27),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: handleForm,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xCC01DE27),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: Text(
                    'Report',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Questrial',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 0.5,
                      height: 1.2,
                      decorationColor: Colors.white.withOpacity(0.75),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
