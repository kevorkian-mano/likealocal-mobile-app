/// This class is used in the [share_hidden_gem_screen] screen.

// ignore_for_file: must_be_immutable
class ShareHiddenGemModel {
  ShareHiddenGemModel({
    this.selectedCategory,
    this.selectedMediaPath,
    this.isPinAdjusted,
    this.id,
  }) {
    selectedCategory = selectedCategory ?? 'Hidden Dining';
    selectedMediaPath = selectedMediaPath;
    isPinAdjusted = isPinAdjusted ?? false;
    id = id ?? '';
  }

  String? selectedCategory;
  String? selectedMediaPath;
  bool? isPinAdjusted;
  String? id;
}
