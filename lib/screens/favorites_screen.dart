import 'package:flutter/material.dart';
import '../models/field.dart';
import '../services/api_service.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Field> favoriteFields = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  void fetchFavorites() async {
    setState(() {
      isLoading = true;
    });
    List<Field> favorites = await ApiService.getFavorites();
    setState(() {
      favoriteFields = favorites;
      isLoading = false;
    });
  }

  void removeFavorite(int fieldId) async {
    await ApiService.removeFavorite(fieldId);
    fetchFavorites();
  }

  Widget buildFavoriteItem(Field field) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/fieldDetail', arguments: field);
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        color: Colors.amber[50],
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.amber[100],
                radius: 32,
                child: Icon(Icons.sports_soccer, color: Colors.amber[800], size: 64),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      field.name,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.amber[800],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.amberAccent, size: 18),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            field.address,
                            style: TextStyle(color: Colors.amber[800], fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red[400]),
                onPressed: () {
                  removeFavorite(field.id!);
                },
                tooltip: 'Xóa khỏi yêu thích',
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sân yêu thích", style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.yellow,
        elevation: 0,
      ),
      backgroundColor: Colors.amber[50],
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.yellow))
          : favoriteFields.isEmpty
              ? Center(
                  child: Text(
                    "Bạn chưa có sân yêu thích nào!",
                    style: TextStyle(fontSize: 18, color: Colors.yellow, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  itemCount: favoriteFields.length,
                  itemBuilder: (context, index) {
                    return buildFavoriteItem(favoriteFields[index]);
                  },
                ),
    );
  }
}
