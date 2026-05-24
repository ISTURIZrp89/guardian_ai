enum AiModelType {
  biomistral,
  meditron,
  clinicalCamel,
  iiMedical,
  llama3Medical;

  String get displayName {
    switch (this) {
      case AiModelType.biomistral:
        return 'BioMistral';
      case AiModelType.meditron:
        return 'Meditron';
      case AiModelType.clinicalCamel:
        return 'Clinical Camel';
      case AiModelType.iiMedical:
        return 'II-Medical';
      case AiModelType.llama3Medical:
        return 'LlaMA-3.1 Medical';
    }
  }
}

class AiModelInfo {
  final String id;
  final String name;
  final String path;
  final int size;
  final bool isLoaded;
  final bool isDownloading;
  final double downloadProgress;
  final AiModelType modelType;
  final String quantization;
  final String hfRepo;
  final String hfFile;
  final String downloadUrl;
  final String sha256Checksum;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AiModelInfo({
    required this.id,
    required this.name,
    required this.path,
    this.size = 0,
    this.isLoaded = false,
    this.isDownloading = false,
    this.downloadProgress = 0.0,
    this.modelType = AiModelType.biomistral,
    this.quantization = 'Q4_K_M',
    this.hfRepo = '',
    this.hfFile = '',
    this.downloadUrl = '',
    this.sha256Checksum = '',
    this.isPremium = false,
    required this.createdAt,
    required this.updatedAt,
  });

  AiModelInfo copyWith({
    String? id,
    String? name,
    String? path,
    int? size,
    bool? isLoaded,
    bool? isDownloading,
    double? downloadProgress,
    AiModelType? modelType,
    String? quantization,
    String? hfRepo,
    String? hfFile,
    String? downloadUrl,
    String? sha256Checksum,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AiModelInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      size: size ?? this.size,
      isLoaded: isLoaded ?? this.isLoaded,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      modelType: modelType ?? this.modelType,
      quantization: quantization ?? this.quantization,
      hfRepo: hfRepo ?? this.hfRepo,
      hfFile: hfFile ?? this.hfFile,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      sha256Checksum: sha256Checksum ?? this.sha256Checksum,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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
      'sha256Checksum': sha256Checksum,
      'isPremium': isPremium ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AiModelInfo.fromMap(Map<String, dynamic> map) {
    return AiModelInfo(
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
      sha256Checksum: map['sha256Checksum'] as String? ?? '',
      isPremium: (map['isPremium'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
