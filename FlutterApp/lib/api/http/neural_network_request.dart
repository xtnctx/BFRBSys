part of 'http_service.dart';

class NeuralNetworkRequestBuild {
  HttpService httpService = HttpService();
  late Future<TrainedModels> _futureModel;

  Future<Map<String, dynamic>> get response {
    return _futureModel.then((value) {
      return value.toJson();
    });
  }

  Future<TrainedModels> get model {
    return _futureModel;
  }

  void build({
    required String fileEncoded,
    required String modelName,
    required String userToken,
  }) {
    _futureModel = httpService.postModel(
      fileEncoded: fileEncoded,
      modelName: modelName,
      userToken: userToken,
    );
  }

  void sendInput({
    required String filePath,
    required String modelName,
    required String userToken,
  }) {
    _futureModel = httpService.sendInput(
      filePath: filePath,
      modelName: modelName,
      userToken: userToken,
    );
  }
}
