import 'dart:convert';
import '../../domain/entities/ai_model_info.dart';

class AiModelInfoModel extends AiModelInfo {
  const AiModelInfoModel({
    required super.id,
    required super.name,
    required super.path,
    super.size,
    super.isLoaded,
    super.isDownloading,
    super.downloadProgress,
    super.modelType,
    super.quantization,
    super.hfRepo,
    super.hfFile,
    super.downloadUrl,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AiModelInfoModel.fromDomain(AiModelInfo info) {
    return AiModelInfoModel(
      id: info.id,
      name: info.name,
      path: info.path,
      size: info.size,
      isLoaded: info.isLoaded,
      isDownloading: info.isDownloading,
      downloadProgress: info.downloadProgress,
      modelType: info.modelType,
      quantization: info.quantization,
      hfRepo: info.hfRepo,
      hfFile: info.hfFile,
      downloadUrl: info.downloadUrl,
      createdAt: info.createdAt,
      updatedAt: info.updatedAt,
    );
  }

  factory AiModelInfoModel.fromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return AiModelInfoModel.fromMap(map);
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  factory AiModelInfoModel.fromMap(Map<String, dynamic> map) {
    return AiModelInfoModel(
      id: map['id'] as String,
      name: map['name'] as String,
      path: map['path'] as String,
      size: map['size'] as int? ?? 0,
      isLoaded: (map['isLoaded'] as int? ?? 0) == 1,
      isDownloading: (map['isDownloading'] as int? ?? 0) == 1,
      downloadProgress: (map['downloadProgress'] as num?)?.toDouble() ?? 0.0,
      modelType: AiModelType.values.firstWhere(
        (e) => e.name == map['modelType'],
        orElse: () => AiModelType.biomistral,
      ),
      quantization: map['quantization'] as String? ?? 'Q4_K_M',
      hfRepo: map['hfRepo'] as String? ?? '',
      hfFile: map['hfFile'] as String? ?? '',
      downloadUrl: map['downloadUrl'] as String? ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'size': size,
      'isLoaded': isLoaded ? 1 : 0,
      'isDownloading': isDownloading ? 1 : 0,
      'downloadProgress': downloadProgress,
      'modelType': modelType.name,
      'quantization': quantization,
      'hfRepo': hfRepo,
      'hfFile': hfFile,
      'downloadUrl': downloadUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  AiModelInfo toDomain() {
    return AiModelInfo(
      id: id,
      name: name,
      path: path,
      size: size,
      isLoaded: isLoaded,
      isDownloading: isDownloading,
      downloadProgress: downloadProgress,
      modelType: modelType,
      quantization: quantization,
      hfRepo: hfRepo,
      hfFile: hfFile,
      downloadUrl: downloadUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
