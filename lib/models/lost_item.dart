enum ItemCategory { electronics, documents, clothing, keys, bags, other }

enum ItemStatus { lost, found, returned }

class LostItem {
  final String id;
  final String title;
  final ItemCategory category;
  final String description;
  final String location;
  final DateTime dateLost;
  final String? imageUrl;
  final ItemStatus status;
  final String contactInfo;
  final String ownerId;

  LostItem({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.location,
    required this.dateLost,
    this.imageUrl,
    required this.status,
    required this.contactInfo,
    required this.ownerId,
  });
}
