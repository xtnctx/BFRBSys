class Item {
  final int id;
  final String name;

  Item({required this.id, required this.name});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class TrainedModels {
  final int id;
  final String modelName;

  TrainedModels({required this.id, required this.modelName});

  factory TrainedModels.fromJson(Map<String, dynamic> json) {
    return TrainedModels(
      id: json['id'],
      modelName: json['model_name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'model_name': modelName,
      };
}
