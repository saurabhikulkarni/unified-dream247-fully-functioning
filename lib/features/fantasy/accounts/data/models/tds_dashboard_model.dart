import 'package:Dream247/core/utils/model_parsers.dart';

class TdsDashboardModel {
  List<FinancialReport>? financialReport;
  String? tdsFormula;
  String? example;

  TdsDashboardModel({this.financialReport, this.tdsFormula, this.example});

  factory TdsDashboardModel.fromJson(Map<String, dynamic> json) =>
      TdsDashboardModel(
        financialReport: json["financial_report"] == null
            ? []
            : List<FinancialReport>.from(
                json["financial_report"]!.map(
                  (x) => FinancialReport.fromJson(x),
                ),
              ),
        tdsFormula: ModelParsers.toStringParser(json["tds_formula"]),
        example: ModelParsers.toStringParser(json["example"]),
      );
}

class FinancialReport {
  String? financialYear;
  num? tdsAlreadyPaid;
  num? tdsToBeDeducted;
  num? successDeposit;
  num? successWithdraw;
  num? netWin;
  num? openingBalance;
  num? closingBalance;
  bool? tdsStatus;
  String? id;
  DateTime? endDate;
  DateTime? startDate;

  FinancialReport({
    this.financialYear,
    this.tdsAlreadyPaid,
    this.tdsToBeDeducted,
    this.successDeposit,
    this.successWithdraw,
    this.netWin,
    this.openingBalance,
    this.closingBalance,
    this.tdsStatus,
    this.id,
    this.endDate,
    this.startDate,
  });

  factory FinancialReport.fromJson(
    Map<String, dynamic> json,
  ) =>
      FinancialReport(
        financialYear: json["financial_year"],
        tdsAlreadyPaid: ModelParsers.toNumParser(json["tdsAlreadyPaid"]),
        tdsToBeDeducted: ModelParsers.toNumParser(json["tdsToBeDeducted"]),
        successDeposit: ModelParsers.toNumParser(json["successDeposit"]),
        successWithdraw: ModelParsers.toNumParser(json["successWithdraw"]),
        netWin: ModelParsers.toNumParser(json["netWin"]),
        openingBalance: ModelParsers.toNumParser(json["openingBalance"]),
        closingBalance: ModelParsers.toNumParser(json["closingBalance"]),
        tdsStatus: json["tdsStatus"],
        id: json["_id"],
        endDate:
            json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
        startDate: json["startDate"] == null
            ? null
            : DateTime.parse(json["startDate"]),
      );
}
