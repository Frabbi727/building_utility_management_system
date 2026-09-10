import 'package:get/get.dart';
import '../../core/storage/local_cache_service.dart';
import '../domain/entities/flat_entity.dart';

class FlatContextService extends GetxService {
  final LocalCacheService cacheService;
  static const String activeFlatKey = 'active_flat_id';

  final Rx<FlatEntity?> selectedFlat = Rx<FlatEntity?>(null);
  final RxList<FlatEntity> availableFlats = <FlatEntity>[].obs;

  FlatContextService({required this.cacheService});

  void initializeFlats(List<FlatEntity> flats) {
    availableFlats.assignAll(flats);
    if (flats.isEmpty) {
      selectedFlat.value = null;
      return;
    }

    final cachedId = cacheService.getInt(activeFlatKey);
    final matched = flats.firstWhereOrNull((f) => f.id == cachedId);

    if (matched != null) {
      selectedFlat.value = matched;
    } else {
      selectFlat(flats.first);
    }
  }

  void selectFlat(FlatEntity flat) {
    selectedFlat.value = flat;
    cacheService.putInt(activeFlatKey, flat.id);
  }

  int? get activeFlatId => selectedFlat.value?.id;
  bool get hasSelectedFlat => selectedFlat.value != null;

  void clear() {
    selectedFlat.value = null;
    availableFlats.clear();
    cacheService.delete(activeFlatKey);
  }
}
