class BeneficiaryModel {
    final String account;
    final int weight;

    BeneficiaryModel({
        required this.account,
        required this.weight,
    });

    BeneficiaryModel copyWith({
        String? account,
        int? weight,
    }) => 
        BeneficiaryModel(
            account: account ?? this.account,
            weight: weight ?? this.weight,
        );

    factory BeneficiaryModel.fromJson(Map<String, dynamic> json) => BeneficiaryModel(
        account: json["account"],
        weight: json["weight"],
    );

}