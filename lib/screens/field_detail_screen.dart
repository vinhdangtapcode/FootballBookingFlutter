import 'package:flutter/material.dart';
import '../models/field.dart';
import '../services/api_service.dart';

class FieldDetailScreen extends StatefulWidget {
  @override
  _FieldDetailScreenState createState() => _FieldDetailScreenState();
}

class _FieldDetailScreenState extends State<FieldDetailScreen> {
  Field? field;
  bool isFavorite = false;
  bool favLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Field args = ModalRoute.of(context)!.settings.arguments as Field;
    field = args;
    checkFavorite();
  }

  Future<void> checkFavorite() async {
    if (field?.id == null) return;
    final favs = await ApiService.getFavorites();
    setState(() {
      isFavorite = favs.any((f) => f.id == field!.id);
    });
  }

  Future<void> toggleFavorite() async {
    if (field?.id == null) return;
    setState(() { favLoading = true; });
    if (isFavorite) {
      await ApiService.removeFavorite(field!.id!);
    } else {
      await ApiService.addFavorite(field!.id!);
    }
    await checkFavorite();
    setState(() { favLoading = false; });
  }

  void bookField() {
    Navigator.pushNamed(context, '/booking', arguments: field);
  }

  void viewRatings() {
    Navigator.pushNamed(context, '/ratings', arguments: field);
  }

  @override
  Widget build(BuildContext context) {
    if (field == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Field Details")),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          field!.name,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.amber,
        elevation: 0,
        actions: [
          IconButton(
            icon: favLoading
                ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                : Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.redAccent,
                  ),
            onPressed: favLoading ? null : toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner image
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                image: DecorationImage(
                  image: (field!.imageUrl?.isNotEmpty ?? false)
                      ? NetworkImage(field!.imageUrl!)
                      : const AssetImage('assets/images/san_bong.png') as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: GestureDetector(
                      onTap: viewRatings,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.yellow, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              field!.rating != null
                                  ? (field!.rating % 1 == 0
                                      ? field!.rating.toInt().toString()
                                      : field!.rating.toStringAsFixed(1))
                                  : '0',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Card with info
            Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên chủ sân
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text('Chủ sân: ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
                          Text(
                            field!.owner?.ownerName ?? '-',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              field!.address,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.category, color: Colors.blueAccent),
                          const SizedBox(width: 8),
                          Text('Loại sân: ', style: TextStyle(fontWeight: FontWeight.w500)),
                          Text(field!.type ?? '-', style: TextStyle(color: Colors.black87)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.attach_money, color: Colors.deepOrange),
                          const SizedBox(width: 8),
                          Text('Giá: ', style: TextStyle(fontWeight: FontWeight.w500)),
                          Text('${field!.pricePerHour.toInt()} VNĐ/giờ', style: TextStyle(color: Colors.black87)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.purple),
                          const SizedBox(width: 8),
                          Text('Giờ mở cửa: ', style: TextStyle(fontWeight: FontWeight.w500)),
                          Text(
                            (field!.openingTime != null && field!.openingTime!.isNotEmpty && field!.openingTime != 'null')
                                ? field!.openingTime!.substring(0, 5)
                                : '-',
                            style: TextStyle(color: Colors.black87),
                          ),
                          const SizedBox(width: 16),
                          Text('Giờ đóng cửa: ', style: TextStyle(fontWeight: FontWeight.w500)),
                          Text(
                            (field!.closingTime != null && field!.closingTime!.isNotEmpty && field!.closingTime != 'null')
                                ? field!.closingTime!.substring(0, 5)
                                : '-',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.grass, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text('Loại cỏ: ', style: TextStyle(fontWeight: FontWeight.w500)),
                          Text(
                            field!.grassType == 'artificial'
                                ? 'Nhân tạo'
                                : field!.grassType == 'natural'
                                    ? 'Tự nhiên'
                                    : (field!.grassType ?? '-'),
                            style: TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.wifi, color: Colors.blueGrey),
                          const SizedBox(width: 8),
                          Text('Tiện ích: ', style: TextStyle(fontWeight: FontWeight.w500)),
                          Expanded(child: Text('${field!.facilities ?? '-'}', style: TextStyle(color: Colors.black87))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: bookField,
                      icon: const Icon(Icons.calendar_month),
                      label: const Text("Đặt sân"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: viewRatings,
                      icon: const Icon(Icons.star, color: Colors.amber),
                      label: const Text("Xem đánh giá"),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.amber, width: 2),
                        foregroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF8F8F8),
    );
  }
}
