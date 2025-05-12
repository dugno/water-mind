import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:water_mind/gen/assets.gen.dart';

/// Model đại diện cho một ngôn ngữ
class LanguageModel {
  /// Mã ngôn ngữ (ví dụ: 'en', 'vi')
  final String code;

  /// Tên hiển thị của ngôn ngữ
  final String name;

  /// Viết tắt của ngôn ngữ
  final String abbreviation;

  /// Đường dẫn đến hình ảnh cờ quốc gia
  final String imagePath;

  /// Constructor
  const LanguageModel({
    required this.code,
    required this.name,
    required this.abbreviation,
    required this.imagePath,
  });

  /// Tạo LanguageModel từ JSON
  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    // Lấy tên file hình ảnh từ đường dẫn trong JSON
    final imagePath = json['image'] as String;
    final fileName = imagePath.split('/').last;
    
    // Tạo đường dẫn đầy đủ sử dụng flutter_gen
    final fullImagePath = _getFullImagePath(fileName);
    
    return LanguageModel(
      code: json['id'] as String,
      name: json['name'] as String,
      abbreviation: json['abbreviation'] as String,
      imagePath: fullImagePath,
    );
  }
  
  /// Lấy đường dẫn đầy đủ của hình ảnh từ tên file
  static String _getFullImagePath(String fileName) {
    const languageImages = $AssetsImagesLanguageGen();
    
    // Mapping từ tên file đến đường dẫn đầy đủ
    switch (fileName) {
      case 'united_kingdom.png':
        return languageImages.unitedKingdom.path;
      case 'vietnam.png':
        return languageImages.vietnam.path;
      case 'japan.png':
        return languageImages.japan.path;
      case 'china.png':
        return languageImages.china.path;
      case 'romania.png':
        return languageImages.romania.path;
      case 'spain.png':
        return languageImages.spain.path;
      case 'france.png':
        return languageImages.france.path;
      case 'russia.png':
        return languageImages.russia.path;
      case 'portugal.png':
        return languageImages.portugal.path;
      case 'indonesia.png':
        return languageImages.indonesia.path;
      case 'germany.png':
        return languageImages.germany.path;
      case 'turkey.png':
        return languageImages.turkey.path;
      case 'korea_south.png':
        return languageImages.koreaSouth.path;
      case 'thailand.png':
        return languageImages.thailand.path;
      case 'italy.png':
        return languageImages.italy.path;
      case 'india.png':
        return languageImages.india.path;
      default:
        return languageImages.unitedKingdom.path; // Fallback
    }
  }
}

/// Class quản lý danh sách ngôn ngữ
class LanguageManager {
  static List<LanguageModel>? _languages;
  
  /// Lấy danh sách tất cả các ngôn ngữ được hỗ trợ
  static Future<List<LanguageModel>> getSupportedLanguages() async {
    if (_languages != null) {
      return _languages!;
    }
    
    try {
      // Đọc file languages.json
      final jsonString = await rootBundle.loadString('assets/data/languages.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      
      // Parse JSON thành danh sách LanguageModel
      _languages = jsonList
          .map((item) => LanguageModel.fromJson(item as Map<String, dynamic>))
          .toList();
      
      return _languages!;
    } catch (e) {
      // Fallback nếu có lỗi
      const languageImages = $AssetsImagesLanguageGen();
      
      _languages = [
        LanguageModel(
          code: 'en',
          name: 'English',
          abbreviation: 'EN',
          imagePath: languageImages.unitedKingdom.path,
        ),
        LanguageModel(
          code: 'vi',
          name: 'Tiếng Việt',
          abbreviation: 'VI',
          imagePath: languageImages.vietnam.path,
        ),
      ];
      
      return _languages!;
    }
  }
  
  /// Lấy thông tin ngôn ngữ theo mã ngôn ngữ
  static Future<LanguageModel?> getLanguageByCode(String code) async {
    final languages = await getSupportedLanguages();
    try {
      return languages.firstWhere((lang) => lang.code == code);
    } catch (e) {
      // Trả về null nếu không tìm thấy
      return null;
    }
  }
  
  /// Lấy tên ngôn ngữ theo mã ngôn ngữ
  static Future<String> getLanguageName(String code) async {
    final language = await getLanguageByCode(code);
    return language?.name ?? 'Unknown';
  }
  
  /// Lấy đường dẫn hình ảnh cờ quốc gia theo mã ngôn ngữ
  static Future<String> getLanguageFlagPath(String code) async {
    final language = await getLanguageByCode(code);
    return language?.imagePath ?? '';
  }
  
  /// Lấy index của ngôn ngữ trong danh sách theo mã ngôn ngữ
  static Future<int> getLanguageIndex(String code) async {
    final languages = await getSupportedLanguages();
    final index = languages.indexWhere((lang) => lang.code == code);
    return index >= 0 ? index : 0;
  }
}
