part of 'http_service.dart';

class NeuralNetworkRequestBuild {
  HttpService httpService = HttpService();
  late Future<TrainedModels> _futureModel;
  late Future<String> _futureDownload;

  Future<Map<String, dynamic>> get response {
    return _futureModel.then((value) {
      return value.toJson();
    });
  }

  Future<TrainedModels> get model {
    return _futureModel;
  }

  Future<String> get downloadModel {
    return _futureDownload;
  }

  void build({required String fileEncoded, required String modelName, required String userToken}) {
    _futureModel = httpService.postModel(
      fileEncoded: fileEncoded,
      modelName: modelName,
      userToken: userToken,
    );
  }

  void sendInput({required String filePath, required String modelName, required String userToken}) {
    _futureModel = httpService.sendInput(
      filePath: filePath,
      modelName: modelName,
      userToken: userToken,
    );
  }

  Future<String> downloadFile({required String fileUrl, required String location}) async {
    return httpService.downloadFile(fileUrl, location);
  }
}
