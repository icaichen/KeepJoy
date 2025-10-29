import 'package:flutter/material.dart';

enum DeclutterCategory {
  clothes('Clothes', '衣物'),
  books('Books', '书籍'),
  papers('Papers', '文件'),
  miscellaneous('Miscellaneous', '杂项'),
  sentimental('Sentimental', '情感纪念品'),
  beauty('Beauty', '美妆用品');

  const DeclutterCategory(this.english, this.chinese);
  final String english;
  final String chinese;

  String label(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode.toLowerCase().startsWith('zh')) {
      return chinese;
    }
    return english;
  }
}

enum DeclutterStatus {
  pending('To declutter', '待整理'),
  keep('Kept', '保留'),
  discard('Discarded', '丢弃'),
  donate('Donated', '捐赠'),
  recycle('Recycled', '回收'),
  resell('Resell', '转售');

  const DeclutterStatus(this.english, this.chinese);
  final String english;
  final String chinese;

  String label(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode.toLowerCase().startsWith('zh')) {
      return chinese;
    }
    return english;
  }
}

class DeclutterItem {
  DeclutterItem({
    required this.id,
    required this.name,
    required this.category,
    required this.createdAt,
    required this.status,
    this.photoPath,
    this.notes,
    this.joyLevel,
    this.joyNotes,
  });

  final String id;
  final String name;
  final DeclutterCategory category;
  final DateTime createdAt;
  final DeclutterStatus status;
  final String? photoPath;
  final String? notes;
  final int? joyLevel; // Joy Index: 1-10 (怦然心动指数)
  final String? joyNotes; // Why it sparks joy (为什么带来快乐)
}
