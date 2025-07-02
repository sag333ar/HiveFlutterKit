import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/models/proposal.dart';
import 'package:hive_flutter_kit/hive_flutter_kit.dart';
import 'package:hive_flutter_kit/ux/dhive/proposals/formatDate.dart';
import 'package:hive_flutter_kit/ux/dhive/proposals/pay_calculated.dart';
import 'package:hive_flutter_kit/ux/dhive/proposals/switchCases.dart';

class ProposalsScreen extends StatefulWidget {
  final HiveFlutterKitPlatform hfk;

  // Callback functions
  final Function(String creator)? onTapUserAvatar;
  final Function(String creator)? onTapUsername;
  final Function(String subject, String proposalId)? onTapTitle;
  final Function(String proposalId)? onTapStats;
  final Function(String proposalId)? onTapUpvote;
  final Function(String proposalId, String voteValue)? onTapVoteValue;
  final Function(String proposalId)? onTapSupport;

  const ProposalsScreen({
    Key? key,
    required this.hfk,
    this.onTapUserAvatar,
    this.onTapUsername,
    this.onTapTitle,
    this.onTapStats,
    this.onTapUpvote,
    this.onTapVoteValue,
    this.onTapSupport,
  }) : super(key: key);

  @override
  State<ProposalsScreen> createState() => _ProposalsScreenState();
}

class _ProposalsScreenState extends State<ProposalsScreen> {
  List<Proposal> proposals = [];
  bool isLoading = true;
  String selectedFilter = 'ALL';
  String selectedSort = 'VOTES';
  String error = '';

  final List<String> filters = [
    'ALL',
    'ACTIVE',
    'UPCOMING',
    'BY PEAK PROJECTS',
  ];
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
      // Map filter to correct status
      String status = getStatusFromFilter(selectedFilter);

      // Map sort to correct order parameter
      String order = getOrderFromSort(selectedSort);
      String orderDirection = getOrderDirectionFromSort(selectedSort);

      final result = await widget.hfk.getProposals(
        start: [-1],
        limit: 100,
        order: order,
        orderDirection: orderDirection,
        status: status,
      );

      List<Proposal> sortedProposals = applySorting(result, selectedSort);

      setState(() {
        proposals = sortedProposals;
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
            Expanded(child: _buildProposalsList()),
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
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
                items:
                    sortOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null && newValue != selectedSort) {
                    setState(() {
                      selectedSort = newValue;
                    });
                    loadProposals();
                  }
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
        children:
            filters.map((filter) {
              final isSelected = selectedFilter == filter;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (filter != selectedFilter) {
                      setState(() {
                        selectedFilter = filter;
                      });
                      loadProposals();
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFF14B8A6)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          isSelected
                              ? null
                              : Border.all(color: Colors.grey.shade700),
                    ),
                    child: Text(
                      filter,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey,
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
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
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
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
        child: Text('No proposals found', style: TextStyle(color: Colors.grey)),
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
              GestureDetector(
                onTap: () => widget.onTapUserAvatar?.call(proposal.creator),
                child: CircleAvatar(
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
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => widget.onTapUsername?.call(proposal.creator),
                      child: Text(
                        'by ${proposal.creator}',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      formatDate(proposal.startDate),
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
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap:
                () => widget.onTapTitle?.call(
                  proposal.subject,
                  proposal.proposalId.toString(),
                ),
            child: Text(
              '${proposal.subject} #${proposal.proposalId}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${formatDate(proposal.startDate)} - ${formatDate(proposal.endDate)} '
                    '(${DateTime.parse(proposal.endDate).difference(DateTime.parse(proposal.startDate)).inDays} days)',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                ],
              ),
              GestureDetector(
                onTap:
                    () =>
                        widget.onTapStats?.call(proposal.proposalId.toString()),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile =
                  constraints.maxWidth < 360;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            GestureDetector(
                              onTap:
                                  () => widget.onTapUpvote?.call(
                                    proposal.proposalId.toString(),
                                  ),
                              child: const Icon(
                                Icons.favorite,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ),
                            GestureDetector(
                              onTap:
                                  () => widget.onTapVoteValue?.call(
                                    proposal.proposalId.toString(),
                                    proposal.formattedVotes,
                                  ),
                              child: Text(
                                'Vote value: ${proposal.formattedVotes}',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            if (!isMobile)
                              GestureDetector(
                                onTap:
                                    () => widget.onTapSupport?.call(
                                      proposal.proposalId.toString(),
                                    ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'SUPPORT',
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
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Paid: ${calculatePaid(proposal)} HBD',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'To Pay: ${calculateToPay(proposal)} HBD',
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
                  if (isMobile)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap:
                              () => widget.onTapSupport?.call(
                                proposal.proposalId.toString(),
                              ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'SUPPORT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

}
