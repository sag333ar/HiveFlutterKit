class GetQrStringModel {
  final String? qrString;

  GetQrStringModel({this.qrString});

  factory GetQrStringModel.fromJson(Map<String, dynamic> json) {
    return GetQrStringModel(
      qrString: json['qrString'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qrString': qrString,
    };
  }
}
