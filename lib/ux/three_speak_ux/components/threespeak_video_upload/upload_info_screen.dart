import 'dart:convert';
import 'package:hive_flutter_kit/core/models/login_model.dart';
import 'package:hive_flutter_kit/core/three_speak_core/video_ops.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/threespeak_video_upload/components/beneficaries_tile.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/threespeak_video_upload/my_videos_screen.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class UploadInfoScreen extends StatefulWidget {
  final String videoId;
  final String thumbnail;
  final String token;
  final String owner;

  const UploadInfoScreen({
    super.key,
    required this.videoId,
    required this.thumbnail,
    required this.token,
    required this.owner,
  });

  @override
  State<UploadInfoScreen> createState() => _UploadInfoScreenState();
}

class _UploadInfoScreenState extends State<UploadInfoScreen> {
  bool isNSFW = false;
  bool isPowerEnabled = false;
  double powerLevel = 0.5;
  bool showMenu = false;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<BeneficiariesJson> selectedBeneficiaries = [];
  DateTime? _scheduledDateTime;

  Future<void> _pickScheduleDateTime() async {
    final DateTime now = DateTime.now();
    final DateTime minAllowedTime = now.add(const Duration(hours: 1));
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: minAllowedTime,
      firstDate: minAllowedTime,
      lastDate: now.add(const Duration(days: 31)),
    );
    if (picked != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
          hour: minAllowedTime.hour,
          minute: minAllowedTime.minute,
        ),
      );
      if (pickedTime != null) {
        final scheduled = DateTime(
          picked.year,
          picked.month,
          picked.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        if (scheduled.isBefore(minAllowedTime)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please pick a time at least 1 hour from now."),
            ),
          );
          return;
        }
        setState(() {
          _scheduledDateTime = scheduled;
        });
        _showScheduleConfirmationDialog();
      }
    }
  }

  void _showScheduleConfirmationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Schedule'),
            content: Text(
              'Publish video at:\n${DateFormat.yMMMd().add_jm().format(_scheduledDateTime!)}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Pick Again'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _uploadVideoInfo(scheduledDate: _scheduledDateTime);
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
    );
  }

  Future<void> _uploadVideoInfo({DateTime? scheduledDate}) async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final tags = tagsController.text.trim();
    final isNsfwContent = isNSFW;
    var bene =
        selectedBeneficiaries
            .map((e) => e.copyWith(account: e.account.toLowerCase()))
            .toList()
          ..sort(
            (a, b) =>
                a.account.toLowerCase().compareTo(b.account.toLowerCase()),
          );

    final body = {
      'videoId': widget.videoId,
      'title': title,
      'description':
          '$description\n\n<br/><sub>Uploaded using 3Speak Mobile App</sub>',
      'isNsfwContent': isNsfwContent,
      'tags': tags,
      'thumbnail': widget.thumbnail,
      'beneficiaries': json.encode(bene.map((e) => e.toJson()).toList()),
      if (scheduledDate != null)
        'scheduledPublishTime': scheduledDate.toUtc().toIso8601String(),
      if (isPowerEnabled) 'rewardPowerup': true,
    };

    try {
      final response = await http.post(
        Uri.parse('https://studio.3speak.tv/mobile/api/update_info'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${widget.token}',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video info updated successfully!')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyVideosScreen(token: widget.token),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${response.statusCode} ${response.body}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Upload your video'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.check, color: Colors.green),
                SizedBox(width: 8),
                Expanded(child: Text('Upload Complete')),
                Icon(Icons.keyboard_arrow_down),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: titleController,
              maxLength: 150,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: tagsController,
              maxLength: 150,
              decoration: const InputDecoration(
                labelText: 'Tags',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Select Community:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Icon(Icons.keyboard_arrow_down),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Checkbox(
                  value: isNSFW,
                  onChanged: (value) {
                    setState(() => isNSFW = value!);
                  },
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "You should check this option if your content is ",
                        ),
                        TextSpan(
                          text: "NSFW",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isPowerEnabled ? '100% power' : '50% power'),
                Switch(
                  value: isPowerEnabled,
                  onChanged: (value) {
                    setState(() {
                      isPowerEnabled = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            BeneficiariesTile(
              userName: widget.owner ?? '',
              beneficiaries: selectedBeneficiaries,
              onChanged: (newList) {
                setState(() {
                  selectedBeneficiaries = newList;
                });
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: const [
                Icon(Icons.language),
                SizedBox(width: 8),
                Text("Set Language Filter"),
                Spacer(),
                Text("English", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),

      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          if (showMenu)
            Positioned(
              bottom: 80,
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildMenuOption(
                    label: 'Publish Now',
                    icon: Icons.publish,
                    onTap: () {
                      setState(() => showMenu = false);
                      _uploadVideoInfo();
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildMenuOption(
                    label: 'Schedule Publish',
                    icon: Icons.schedule,
                    onTap: () {
                      setState(() => showMenu = false);
                      _pickScheduleDateTime();
                    },
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.deepPurple,
                    onPressed: () => setState(() => showMenu = false),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          if (!showMenu)
            FloatingActionButton(
              backgroundColor: Colors.deepPurple,
              onPressed: () => setState(() => showMenu = true),
              child: const Icon(Icons.upload),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuOption({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[600],
            foregroundColor: Colors.white,
          ),
          child: Text(label),
        ),
        const SizedBox(width: 8),
        FloatingActionButton(
          heroTag: label,
          backgroundColor: Colors.white,
          mini: true,
          onPressed: onTap,
          child: Icon(icon),
        ),
      ],
    );
  }
}
