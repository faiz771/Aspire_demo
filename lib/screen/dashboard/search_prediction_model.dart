class PredictionModel {
  String? description;
  String? placeId;
  String? reference;
  List<String>? types;

  PredictionModel({this.description, this.placeId, this.reference, this.types});

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    return PredictionModel(
      description: json['description'],
      placeId: json['place_id'],
      reference: json['reference'],
      types:
          json['types'] != null ? new List<String>.from(json['types']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['place_id'] = this.placeId;
    data['reference'] = this.reference;
    if (this.types != null) {
      data['types'] = this.types;
    }
    return data;
  }
}


class GoogleMapSearchModel {
  List<PredictionModel>? predictions;
  String? status;

  GoogleMapSearchModel({this.predictions, this.status});

  factory GoogleMapSearchModel.fromJson(Map<String, dynamic> json) {
    return GoogleMapSearchModel(
      predictions: json['predictions'] != null ? (json['predictions'] as List).map((i) => PredictionModel.fromJson(i)).toList() : null,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.predictions != null) {
      data['predictions'] = this.predictions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}