
  import 'package:hive_flutter_kit/core/models/proposal.dart';

String getStatusFromFilter(String filter) {
    switch (filter) {
      case 'ACTIVE':
        return 'active';
      case 'UPCOMING':
        return 'inactive';
      case 'BY PEAK PROJECTS':
        return 'all';
      case 'ALL':
      default:
        return 'votable';
    }
  }

  String getOrderFromSort(String sort) {
    switch (sort) {
      case 'VOTES':
        return 'by_total_votes';
      case 'DAILY PAY':
        return 'by_total_votes';
      case 'END DATE':
        return 'by_total_votes'; 
      default:
        return 'by_total_votes';
    }
  }

  String getOrderDirectionFromSort(String sort) {
    switch (sort) {
      case 'END DATE':
        return 'ascending'; 
      default:
        return 'descending';
    }
  }

  List<Proposal> applySorting(List<Proposal> proposalList, String sort) {
    List<Proposal> sortedList = List.from(proposalList);

    switch (sort) {
      case 'VOTES':
        sortedList.sort((a, b) => b.totalVotes.compareTo(a.totalVotes));
        break;
      case 'DAILY PAY':
        sortedList.sort((a, b) {
          double aDailyPay = double.parse(a.dailyPay.amount) / 1000;
          double bDailyPay = double.parse(b.dailyPay.amount) / 1000;
          return bDailyPay.compareTo(aDailyPay);
        });
        break;
      case 'END DATE':
        sortedList.sort((a, b) {
          DateTime aEndDate = DateTime.parse(a.endDate);
          DateTime bEndDate = DateTime.parse(b.endDate);
          return aEndDate.compareTo(bEndDate);
        });
        break;
    }

    return sortedList;
  }