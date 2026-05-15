/// This class is used in the [share_hidden_gem_screen] screen.
library;

// ignore_for_file: must_be_immutable
class ShareHiddenGemModel {
  ShareHiddenGemModel({
    this.selectedCategory,
    List<String>? selectedMediaPaths,
    this.isPinAdjusted,
    this.id,
  }) {
    this.selectedMediaPaths = selectedMediaPaths ?? [];
    selectedCategory = selectedCategory ?? 'Hidden Dining';
    isPinAdjusted = isPinAdjusted ?? false;
    id = id ?? '';
  }

  String? selectedCategory;
  List<String> selectedMediaPaths = [];
  bool? isPinAdjusted;
  String? id;
}
