// like_backend.dart
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class LikeBackend extends GetxController {
  final Box<String> _box;
  final RxList<String> likePdf = <String>[].obs;

  LikeBackend(this._box); // Constructor injection

  @override
  void onInit() {
    super.onInit();
    likePdf.assignAll(_box.values.toList());
  }

  Future<void> toggleFavorite(String filePath) async {
    if (likePdf.contains(filePath)) {
      likePdf.remove(filePath);
      await _box.clear();
      for (final path in likePdf) {
        await _box.add(path);
      }
    } else {
      likePdf.add(filePath);
      await _box.add(filePath);
    }
  }

  bool isFavorite(String filePath) => likePdf.contains(filePath);
}
