import 'package:flutter/material.dart';
import '../models/field.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Field> fields = [];
  List<Field> filteredFields = [];
  List<Field> highRatedFields = [];
  bool isLoading = false;
  int _currentIndex = 0; //Lưu trạng thái NavBar
  String _sortType = 'none';
  String _sortOrder = 'desc';

  @override
  void initState() {
    super.initState();
    fetchFields();
  }

  void fetchFields() async {
    setState(() {
      isLoading = true;
    });
    List<Field> fetchedFields = await ApiService.getPublicFields();
    setState(() {
      fields = fetchedFields;
      filteredFields = fetchedFields;
      highRatedFields = fetchedFields.where((f) => (f.rating ?? 0) >= 4).toList();
      isLoading = false;
    });
  }

  void _filterFields(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredFields = fields;
      } else {
        filteredFields = fields.where((field) {
          return field.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _sortFields() {
    List<Field> list = [...filteredFields];
    if (_sortType == 'price') {
      list.sort((a, b) => _sortOrder == 'asc'
          ? a.pricePerHour.compareTo(b.pricePerHour)
          : b.pricePerHour.compareTo(a.pricePerHour));
    } else if (_sortType == 'rating') {
      list.sort((a, b) => _sortOrder == 'asc'
          ? (a.rating ?? 0).compareTo(b.rating ?? 0)
          : (b.rating ?? 0).compareTo(a.rating ?? 0));
    }
    setState(() {
      filteredFields = list;
    });
  }

  void navigateToFieldDetails(Field field) {
    Navigator.pushNamed(context, '/fieldDetail', arguments: field);
  }

  @override
  Widget build(BuildContext context) {
    // Nếu đang được nhúng trong MainTabScaffold thì không cần BottomNavigationBar nữa
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amberAccent,
          elevation: 0,
          title: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: _filterFields,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm sân',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Icon(Icons.sort, color: Colors.amber[800]),
                  tooltip: 'Sắp xếp',
                  onSelected: (value) {
                    if (value == 'price_asc') {
                      _sortType = 'price'; _sortOrder = 'asc';
                    } else if (value == 'price_desc') {
                      _sortType = 'price'; _sortOrder = 'desc';
                    } else if (value == 'rating_asc') {
                      _sortType = 'rating'; _sortOrder = 'asc';
                    } else if (value == 'rating_desc') {
                      _sortType = 'rating'; _sortOrder = 'desc';
                    } else {
                      _sortType = 'none';
                    }
                    _sortFields();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'price_asc', child: Text('Giá tăng dần')),
                    PopupMenuItem(value: 'price_desc', child: Text('Giá giảm dần')),
                    PopupMenuItem(value: 'rating_asc', child: Text('Đánh giá tăng dần')),
                    PopupMenuItem(value: 'rating_desc', child: Text('Đánh giá giảm dần')),
                    PopupMenuItem(value: 'none', child: Text('Mặc định')),
                  ],
                ),
              ],
            ),
          ),
          actions: [

            IconButton(
              icon: Icon(Icons.favorite),
              onPressed: () {
                Navigator.pushNamed(context, '/favorites');
              },
            ),
            IconButton(
              icon: Icon(Icons.history),
              onPressed: () {
                Navigator.pushNamed(context, '/bookingHistory');
              },
            ),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
          // Thêm TabBar vào AppBar bằng thuộc tính "bottom"
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50), // điều chỉnh chiều cao của TabBar tùy ý
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Padding 2 lề & padding dọc
              child: Container(
                height:40,
                decoration: BoxDecoration(
                  color: Colors.white, // Màu nền cho toàn bộ thanh TabBar
                  borderRadius: BorderRadius.circular(20), // Bo góc cho Container chứa TabBar
                  border: Border.all(
                    color: Colors.amber, // Border màu amber
                    width: 1.5,           // Độ dày của border
                  ),
                ),
                child: TabBar(
                  indicatorColor: Colors.transparent,
                  dividerColor: Colors.transparent, //loại bỏ đường màu đen
                  indicator: BoxDecoration(
                    color: Colors.amber, // Nền vàng cho tab được chọn
                    borderRadius: BorderRadius.circular(20), // Bo góc cho indicator
                  ),
                  indicatorSize: TabBarIndicatorSize.tab, // Indicator bao phủ toàn bộ tab
                  labelColor: Colors.white,        // Chữ trắng cho tab được chọn
                  unselectedLabelColor: Colors.amber, // Chữ đen cho các tab không chọn
                  tabs: [
                    Tab(text: 'Tất cả sân'),
                    Tab(text: 'Sân đánh giá cao'),
                  ],
                ),
              ),
            ),
          ),

        ),
        // Hiển thị nội dung tùy thuộc vào tab đang chọn
        body: TabBarView(
          children: [
            // Tab "Tất cả sân": danh sách sân công cộng
            isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                  itemCount: filteredFields.length,
                  itemBuilder: (context, index) {
                    Field field = filteredFields[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      child: InkWell(
                        onTap: () => navigateToFieldDetails(field),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // Tính toán chiều rộng cho hình ảnh (1/5 tổng chiều rộng của Card)
                            double imageWidth = constraints.maxWidth / 5;
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Phần hiển thị hình ảnh ở bên trái
                                  Container(
                                    width: imageWidth,
                                    height: imageWidth * 0.75,
                                    // Điều chỉnh tỉ lệ aspect theo mong muốn
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child:
                                          (field.imageUrl?.isEmpty ?? true)
                                              ? Image.asset(
                                                'assets/images/san_bong.png',
                                                fit: BoxFit.cover,
                                              )
                                              : Image.network(
                                                field.imageUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return Image.asset(
                                                    'assets/images/san_bong.png',
                                                    fit: BoxFit.cover,
                                                  );
                                                },
                                              ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Phần nội dung hiển thị thông tin chi tiết của field
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          field.name,
                                          style: const TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          field.address ?? '',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              size: 16,
                                              color: Colors.yellow,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              field.rating != null
                                                  ? (field.rating % 1 == 0
                                                      ? field.rating.toInt().toString()
                                                      : field.rating.toStringAsFixed(1))
                                                  : '0',
                                              style: const TextStyle(
                                                fontFamily: 'Roboto',
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              '${field.pricePerHour.toInt()} VNĐ/giờ',
                                              style: const TextStyle(
                                                fontFamily: 'Roboto',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Icon trailing (nếu muốn hiển thị)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),

            // Tab "Sân đánh giá cao": chỉ hiển thị sân 4 sao trở lên
            isLoading
                ? Center(child: CircularProgressIndicator())
                : highRatedFields.isEmpty
                  ? Center(child: Text('Chưa có sân nào đạt 4 sao trở lên.', style: TextStyle(fontFamily: 'Roboto', fontSize: 16)))
                  : ListView.builder(
                      itemCount: highRatedFields.length,
                      itemBuilder: (context, index) {
                        Field field = highRatedFields[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          child: InkWell(
                            onTap: () => navigateToFieldDetails(field),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                double imageWidth = constraints.maxWidth / 5;
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: imageWidth,
                                        height: imageWidth * 0.75,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8.0),
                                          child:
                                              (field.imageUrl?.isEmpty ?? true)
                                                  ? Image.asset(
                                                    'assets/images/san_bong.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                  : Image.network(
                                                    field.imageUrl!,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Image.asset(
                                                        'assets/images/san_bong.png',
                                                        fit: BoxFit.cover,
                                                      );
                                                    },
                                                  ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              field.name,
                                              style: const TextStyle(
                                                fontFamily: 'Roboto',
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              field.address ?? '',
                                              style: TextStyle(
                                                fontFamily: 'Roboto',
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  size: 16,
                                                  color: Colors.yellow,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  field.rating != null
                                                      ? (field.rating % 1 == 0
                                                          ? field.rating.toInt().toString()
                                                          : field.rating.toStringAsFixed(1))
                                                      : '0',
                                                  style: const TextStyle(
                                                    fontFamily: 'Roboto',
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  '${field.pricePerHour.toInt()} VNĐ/giờ',
                                                  style: const TextStyle(
                                                    fontFamily: 'Roboto',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
          ],
        ),
        bottomNavigationBar: null,
      ),
    );
  }
}
