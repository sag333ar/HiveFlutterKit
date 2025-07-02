import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RewardsTable extends StatelessWidget {
  final List<Map<String, dynamic>> authorRewardsData;
  final Map<String, String> totals;
  final bool isMobileView;

  const RewardsTable({
    super.key,
    required this.authorRewardsData,
    required this.totals,
    required this.isMobileView,
  });

  // Function to open the Hive link
  void _launchURL(String title) async {
    final Uri url = Uri.parse("https://hive.blog/$title");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final surfaceColor =
        isDarkMode ? Colors.black54 : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final headingColor = isDarkMode ? Colors.white70 : Colors.black;
    final borderColor = isDarkMode
        ? Colors.white
        : Colors.grey;

    final double fontSize =
        isMobileView ? 12 : 14; // Adjust font size for mobile view

    Widget dataTable = DataTable(
      headingRowColor: MaterialStateProperty.all(surfaceColor),
      dataRowColor: MaterialStateProperty.all(surfaceColor),
      border: TableBorder.all(color: borderColor),
      columns: [
          DataColumn(
            label: Text(
              'Type',
              style: TextStyle(
                color: headingColor,
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
          ),
        DataColumn(
          label: Text(
            isMobileView ? 'Link' : 'Title',
            style: TextStyle(
              color: headingColor,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ),
          DataColumn(
            label: Text(
              'Created Date',
              style: TextStyle(
                color: headingColor,
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
          ),
        DataColumn(
          label: Text(
            'Payout In',
            style: TextStyle(
              color: headingColor,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Post Reward',
            style: TextStyle(
              color: headingColor,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ),
      ],
      rows: [
        ...authorRewardsData.map(
          (reward) => DataRow(
            cells: [
                DataCell(
                  Text(
                    reward['type'],
                    style: TextStyle(color: textColor, fontSize: fontSize),
                  ),
                ),
              DataCell(
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isMobileView ? double.infinity : 550,
                  ),
                  child: GestureDetector(
                    onTap: () => _launchURL(reward['title']),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        isMobileView ? 'Link' : reward['title'],
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontSize: fontSize,
                        ),
                        overflow: TextOverflow.visible,
                        maxLines: null,
                      ),
                    ),
                  ),
                ),
              ),
                DataCell(
                  Text(
                    reward['createdDate'],
                    style: TextStyle(color: textColor, fontSize: fontSize),
                  ),
                ),
              DataCell(
                Text(
                  reward['payoutIn'],
                  style: TextStyle(color: textColor, fontSize: fontSize),
                ),
              ),
              DataCell(
                Text(
                  reward['postReward'],
                  style: TextStyle(color: textColor, fontSize: fontSize),
                ),
              ),
            ],
          ),
        ),
        DataRow(
          color: WidgetStateProperty.all(surfaceColor),
          cells: [
              DataCell(
                Text(
                  'Total',
                  style: TextStyle(
                    color: headingColor,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                  ),
                ),
              ),
            const DataCell(Text('')), 
              const DataCell(Text('')), // Empty cell for Created Date
            const DataCell(Text('')), // Empty cell for Payout In
            DataCell(
              Text(
                totals['postReward']!,
                style: TextStyle(
                  color: headingColor,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                ),
              ),
            ),
          ],
        ),
      ],
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: dataTable,
    );
  }
}
