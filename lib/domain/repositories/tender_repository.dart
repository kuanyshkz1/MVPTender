import '../entities/tender.dart';

abstract class TenderRepository {
  Future<List<Tender>> fetchTenders({String searchQuery = ''});
}
