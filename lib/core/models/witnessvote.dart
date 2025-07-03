class WitnessVotesData {
  final List<String>? witnessVotes;
  final int? witnessesVotedFor;

  WitnessVotesData({this.witnessVotes, this.witnessesVotedFor});

  factory WitnessVotesData.fromJson(Map<String, dynamic> json) {
    return WitnessVotesData(
      witnessVotes:
          (json['witness_votes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList(),
      witnessesVotedFor: json['witnesses_voted_for'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'witness_votes': witnessVotes,
      'witnesses_voted_for': witnessesVotedFor,
    };
  }

  factory WitnessVotesData.empty() {
    return WitnessVotesData(witnessVotes: [], witnessesVotedFor: 0);
  }
}
