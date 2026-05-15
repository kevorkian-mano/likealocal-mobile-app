/// This class is used in the [share_hidden_gem_screen] screen.

// ignore_for_file: must_be_immutable
class ShareHiddenGemModel {
  ShareHiddenGemModel({
    this.selectedCategory,
    this.selectedMediaPaths = const [],
    this.isPinAdjusted,
    this.id,
  }) {
    selectedCategory = selectedCategory ?? 'Hidden Dining';
    isPinAdjusted = isPinAdjusted ?? false;
    id = id ?? '';
  }

  String? selectedCategory;
  List<String> selectedMediaPaths;
  bool? isPinAdjusted;
  String? id;
}
