import '../models/lost_item.dart';
import 'database_helper.dart';

class LostItemService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<void> addLostItem(LostItem item) async {
    final db = await _databaseHelper.database;

    await db.insert('lost_items', {
      'id': item.id,
      'title': item.title,
      'category': item.category.name,
      'description': item.description,
      'location': item.location,
      'dateLost': item.dateLost.toIso8601String(),
      'imageUrl': item.imageUrl,
      'status': item.status.name,
      'contactInfo': item.contactInfo,
      'ownerId': item.ownerId,
    });
  }

  Future<List<LostItem>> getLostItems() async {
    final db = await _databaseHelper.database;

    final List<Map<String, dynamic>> maps = await db.query('lost_items');

    return maps.map((map) {
      return LostItem(
        id: map['id'],
        title: map['title'],
        category: ItemCategory.values.firstWhere(
          (category) => category.name == map['category'],
        ),
        description: map['description'],
        location: map['location'],
        dateLost: DateTime.parse(map['dateLost']),
        imageUrl: map['imageUrl'],
        status: ItemStatus.values.firstWhere(
          (status) => status.name == map['status'],
        ),
        contactInfo: map['contactInfo'],
        ownerId: map['ownerId'],
      );
    }).toList();
  }

  Map<String, int> getStatistics(List<LostItem> items) {
    int lostCount = 0;
    int foundCount = 0;
    int returnedCount = 0;

    for (final item in items) {
      switch (item.status) {
        case ItemStatus.lost:
          lostCount++;
          break;

        case ItemStatus.found:
          foundCount++;
          break;

        case ItemStatus.returned:
          returnedCount++;
          break;
      }
    }

    return {
      'total': items.length,
      'lost': lostCount,
      'found': foundCount,
      'returned': returnedCount,
    };
  }

  Future<void> deleteLostItem(String id) async {
    final db = await _databaseHelper.database;

    await db.delete('lost_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateLostItem(LostItem item) async {
    final db = await _databaseHelper.database;

    await db.update(
      'lost_items',
      {
        'title': item.title,
        'category': item.category.name,
        'description': item.description,
        'location': item.location,
        'dateLost': item.dateLost.toIso8601String(),
        'imageUrl': item.imageUrl,
        'status': item.status.name,
        'contactInfo': item.contactInfo,
        'ownerId': item.ownerId,
      },
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }
}
