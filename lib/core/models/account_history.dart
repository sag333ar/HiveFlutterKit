class AccountHistoryOp {
  final int? index;
  final OperationDetail? detail;

  AccountHistoryOp({
    this.index,
    this.detail,
  });

  factory AccountHistoryOp.fromJson(dynamic json) {
    if (json is List && json.length == 2) {
      return AccountHistoryOp(
        index: json[0] is int ? json[0] : null,
        detail: json[1] is Map<String, dynamic>
            ? OperationDetail.fromJson(json[1])
            : null,
      );
    }
    return AccountHistoryOp(); // fallback
  }
}

class OperationDetail {
  final String? trxId;
  final int? block;
  final int? opInTrx;
  final String? timestamp;
  final String? trxInBlock;
  final bool? virtualOp;
  final List<dynamic>? op;

  OperationDetail({
    this.trxId,
    this.block,
    this.opInTrx,
    this.timestamp,
    this.trxInBlock,
    this.virtualOp,
    this.op,
  });

  factory OperationDetail.fromJson(Map<String, dynamic> json) {
    return OperationDetail(
      trxId: json['trx_id'] as String?,
      block: json['block'] is int ? json['block'] : null,
      opInTrx: json['op_in_trx'] is int ? json['op_in_trx'] : null,
      timestamp: json['timestamp'] as String?,
      trxInBlock: json['trx_in_block']?.toString(),
      virtualOp: json['virtual_op'] is bool ? json['virtual_op'] : null,
      op: json['op'] is List ? json['op'] : null,
    );
  }
}
