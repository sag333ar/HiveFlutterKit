// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:hive_flutter_kit/core/models/proposal.dart';

// class ProposalListWidget extends StatefulWidget {
//   const ProposalListWidget({super.key});

//   @override
//   State<ProposalListWidget> createState() => _ProposalListWidgetState();
// }

// class _ProposalListWidgetState extends State<ProposalListWidget> {
//   List<Proposal> proposals = [];
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchProposals();
//   }

//   Future<void> _fetchProposals() async {
//     setState(() => isLoading = true);
//     try {
//       final result = await hfk.getProposals(
//         start: [-1],
//         limit: 100,
//         order: 'by_total_votes',
//         orderDirection: 'descending',
//         status: 'votable',
//       );
//       setState(() => proposals = result);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to fetch proposals: $e')),
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   String _formatHbd(String amount, int precision) {
//     final doubleValue = double.tryParse(amount) ?? 0.0;
//     return (doubleValue / (10 ^ precision)).toStringAsFixed(0);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Funded Proposals')),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               padding: const EdgeInsets.all(12),
//               itemCount: proposals.length,
//               itemBuilder: (context, index) {
//                 final p = proposals[index];
//                 final dailyPay = _formatHbd(p.dailyPay.amount, p.dailyPay.precision);
//                 final start = DateTime.parse(p.startDate);
//                 final end = DateTime.parse(p.endDate);
//                 final durationDays = end.difference(start).inDays;
//                 final remainingDays = end.difference(DateTime.now()).inDays;

//                 return Card(
//                   elevation: 4,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   margin: const EdgeInsets.only(bottom: 16),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             const CircleAvatar(radius: 16, child: Icon(Icons.person)),
//                             const SizedBox(width: 8),
//                             Text('by ${p.creator}', style: const TextStyle(fontWeight: FontWeight.bold)),
//                             const Spacer(),
//                             Text('Daily Pay: $dailyPay HBD', style: const TextStyle(fontWeight: FontWeight.w600)),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         Text(
//                           '${p.subject} #${p.proposalId}',
//                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 8),
//                         Row(
//                           children: [
//                             Chip(label: Text(p.status.toUpperCase())),
//                             const SizedBox(width: 8),
//                             const Icon(Icons.calendar_month, size: 16),
//                             const SizedBox(width: 4),
//                             Text('${DateFormat.yMMMd().format(start)} - ${DateFormat.yMMMd().format(end)} ($durationDays days)'),
//                             const SizedBox(width: 4),
//                             GestureDetector(
//                               onTap: () {},
//                               child: Text(
//                                 '/@${p.creator}/${p.permlink}',
//                                 style: const TextStyle(color: Colors.blue),
//                               ),
//                             )
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         const Divider(),
//                         Row(
//                           children: [
//                             const Icon(Icons.favorite_border),
//                             const SizedBox(width: 4),
//                             Expanded(
//                               child: Text('Vote value: ${_formatVote(p.totalVotes)} HP'),
//                             ),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Text('Remaining: $remainingDays Days'),
//                                 Text('Paid: - HBD'), // Placeholder
//                                 Text('To Pay: - HBD'), // Placeholder
//                               ],
//                             )
//                           ],
//                         )
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }

//   String _formatVote(String vote) {
//     final doubleValue = double.tryParse(vote) ?? 0;
//     return NumberFormat.decimalPattern().format(doubleValue / 1000000);
//   }
// }




import 'package:flutter/material.dart';
import 'dart:convert';

class ProposalAsset {
  final String amount;
  final String nai;
  final int precision;

  ProposalAsset({
    required this.amount,
    required this.nai,
    required this.precision,
  });

  factory ProposalAsset.fromJson(Map<String, dynamic> json) => ProposalAsset(
        amount: json['amount'],
        nai: json['nai'],
        precision: json['precision'],
      );

  String get formattedAmount {
    final numAmount = double.parse(amount);
    final divisor = precision > 0 ? 1000 : 1; // Assuming precision 3 means divide by 1000
    return (numAmount / divisor).toStringAsFixed(0);
  }
}

class Proposal {
  final int id;
  final int proposalId;
  final String creator;
  final String receiver;
  final String permlink;
  final String subject;
  final String status;
  final String startDate;
  final String endDate;
  final String totalVotes;
  final ProposalAsset dailyPay;

  Proposal({
    required this.id,
    required this.proposalId,
    required this.creator,
    required this.receiver,
    required this.permlink,
    required this.subject,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.totalVotes,
    required this.dailyPay,
  });

  factory Proposal.fromJson(Map<String, dynamic> json) => Proposal(
        id: json['id'],
        proposalId: json['proposal_id'],
        creator: json['creator'],
        receiver: json['receiver'],
        permlink: json['permlink'],
        subject: json['subject'],
        status: json['status'],
        startDate: json['start_date'],
        endDate: json['end_date'],
        totalVotes: json['total_votes'],
        dailyPay: ProposalAsset.fromJson(json['daily_pay']),
      );

  int get remainingDays {
    final endDateTime = DateTime.parse(endDate);
    final now = DateTime.now();
    return endDateTime.difference(now).inDays;
  }

  String get formattedVotes {
    final votes = BigInt.parse(totalVotes);
    if (votes > BigInt.from(1000000000000)) {
      return '${(votes / BigInt.from(1000000000000)).toString().split('.')[0]} HP';
    } else if (votes > BigInt.from(1000000000)) {
      return '${(votes / BigInt.from(1000000000)).toString().split('.')[0]}B HP';
    } else if (votes > BigInt.from(1000000)) {
      return '${(votes / BigInt.from(1000000)).toString().split('.')[0]}M HP';
    }
    return '$votes HP';
  }
}

class ProposalsDashboard extends StatefulWidget {
  final Future<List<Proposal>> Function({
    List<dynamic> start,
    int limit,
    String order,
    String orderDirection,
    String status,
  }) getProposals;

  const ProposalsDashboard({
    Key? key,
    required this.getProposals,
  }) : super(key: key);

  @override
  State<ProposalsDashboard> createState() => _ProposalsDashboardState();
}

class _ProposalsDashboardState extends State<ProposalsDashboard> {
  List<Proposal> proposals = [];
  bool isLoading = true;
  String selectedFilter = 'ALL';
  String selectedSort = 'VOTES';
  String error = '';

  final List<String> filters = ['ALL', 'ACTIVE', 'UPCOMING', 'BY PEAK PROJECTS'];
  final List<String> sortOptions = ['VOTES', 'DAILY PAY', 'END DATE'];

  @override
  void initState() {
    super.initState();
    loadProposals();
  }

  Future<void> loadProposals() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final result = await widget.getProposals(
        start: [-1],
        limit: 100,
        order: 'by_total_votes',
        orderDirection: 'descending',
        status: 'votable',
      );
      
      setState(() {
        proposals = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error loading proposals: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterTabs(),
            _buildFundedProposalsHeader(),
            Expanded(
              child: _buildProposalsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Proposals',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              const Text(
                'SORT:',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: selectedSort,
                dropdownColor: const Color(0xFF2A2A2A),
                style: const TextStyle(color: Colors.white),
                underline: Container(),
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                items: sortOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSort = newValue!;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedFilter = filter;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF14B8A6) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected ? null : Border.all(color: Colors.grey.shade700),
                ),
                child: Text(
                  filter,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFundedProposalsHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Funded proposals',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'The proposals listed below have enough support to receive funding in the next round.',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProposalsList() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF14B8A6)),
        ),
      );
    }

    if (error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              error,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loadProposals,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14B8A6),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (proposals.isEmpty) {
      return const Center(
        child: Text(
          'No proposals found',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadProposals,
      backgroundColor: const Color(0xFF2A2A2A),
      color: const Color(0xFF14B8A6),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: proposals.length,
        itemBuilder: (context, index) {
          return _buildProposalCard(proposals[index]);
        },
      ),
    );
  }

  Widget _buildProposalCard(Proposal proposal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF14B8A6),
                child: Text(
                  proposal.creator.substring(0, 2).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'by ${proposal.creator}',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatDate(proposal.startDate),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Daily Pay: ${proposal.dailyPay.formattedAmount} HBD',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Remaining: ${proposal.remainingDays} Days',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${proposal.subject} #${proposal.proposalId}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  proposal.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.calendar_today,
                size: 12,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 4),
              Text(
                '${_formatDate(proposal.startDate)} - ${_formatDate(proposal.endDate)} (365 days)',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  // Handle stats tap
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'STATS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.favorite,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                'Vote value: ${proposal.formattedVotes}',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Paid: ${_calculatePaid(proposal)} HBD',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'To Pay: ${_calculateToPay(proposal)} HBD',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _calculatePaid(Proposal proposal) {
    // Calculate based on start date and daily pay
    final startDate = DateTime.parse(proposal.startDate);
    final now = DateTime.now();
    final daysPassed = now.difference(startDate).inDays;
    final dailyAmount = double.parse(proposal.dailyPay.amount) / 1000;
    return (daysPassed * dailyAmount).toStringAsFixed(0);
  }

  String _calculateToPay(Proposal proposal) {
    // Calculate remaining amount to be paid
    final remainingDays = proposal.remainingDays;
    final dailyAmount = double.parse(proposal.dailyPay.amount) / 1000;
    return (remainingDays * dailyAmount).toStringAsFixed(0);
  }
}

// Usage example:
class ProposalsScreen extends StatelessWidget {
  final dynamic hfk; // Your HFK instance

  const ProposalsScreen({Key? key, required this.hfk}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProposalsDashboard(
      getProposals: ({
        List<dynamic> start = const [-1],
        int limit = 500,
        String order = 'by_total_votes',
        String orderDirection = 'descending',
        String status = 'votable',
      }) async {
        return await hfk.getProposals(
          start: start,
          limit: limit,
          order: order,
          orderDirection: orderDirection,
          status: status,
        );
      },
    );
  }
}
