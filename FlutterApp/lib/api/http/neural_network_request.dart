/* Copyright 2024 Ryan Christopher Bahillo. All Rights Reserved.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
=========================================================================*/

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
