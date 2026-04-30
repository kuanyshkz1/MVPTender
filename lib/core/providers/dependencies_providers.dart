import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/notes_repository_impl.dart';
import '../../data/repositories/tender_repository_impl.dart';
import '../../domain/repositories/notes_repository.dart';
import '../../domain/repositories/tender_repository.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

final tenderRepositoryProvider = Provider<TenderRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return TenderRepositoryImpl(dio);
});

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepositoryImpl();
});
