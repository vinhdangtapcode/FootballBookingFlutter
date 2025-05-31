import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/field.dart';
import '../services/api_service.dart';

class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  Field? field;
  DateTime selectedDate = DateTime.now(); // Default to current date
  TimeOfDay startTime = TimeOfDay.now(); // Default to current time
  TimeOfDay endTime = TimeOfDay.now(); // Default to current time
  bool isLoading = false;
  TextEditingController additionalController = TextEditingController();

  List<Map<String, DateTime>> bookedTimes = [];
  String? overlapError;

  double get selectedHours {
    final fromTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      startTime.hour,
      startTime.minute,
    );
    final toTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      endTime.hour,
      endTime.minute,
    );
    final diff = toTime.difference(fromTime).inMinutes / 60.0;
    return diff > 0 ? diff : 0;
  }

  int get totalPrice {
    if (field == null) return 0;
    return (selectedHours * field!.pricePerHour).round();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Field args = ModalRoute.of(context)!.settings.arguments as Field;
    field = args;
    _fetchBookedTimes();
  }

  Future<void> _fetchBookedTimes() async {
    if (field?.id == null) return;
    final times = await ApiService.getBookedTimes(field!.id!);
    setState(() {
      bookedTimes = times;
    });
    _checkOverlap();
  }

  void _checkOverlap() {
    overlapError = null;
    if (selectedDate == null || startTime == null || endTime == null) return;
    final from = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, startTime.hour, startTime.minute);
    final to = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, endTime.hour, endTime.minute);
    if (to.isBefore(from) || to.isAtSameMomentAs(from)) return;
    for (final slot in bookedTimes) {
      final bookedFrom = slot['fromTime']!;
      final bookedTo = slot['toTime']!;
      // Kiểm tra overlap
      if (from.isBefore(bookedTo) && to.isAfter(bookedFrom)) {
        overlapError = 'Sân đã được đặt vào thời điểm này';
        break;
      }
    }
  }

  // Show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _checkOverlap();
    }
  }

  // Show time picker for start time
  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: startTime,
    );
    if (picked != null && picked != startTime) {
      setState(() {
        startTime = picked;
      });
      _checkOverlap();
    }
  }

  // Show time picker for end time
  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: endTime,
    );
    if (picked != null && picked != endTime) {
      setState(() {
        endTime = picked;
      });
      _checkOverlap();
    }
  }

  void _addNotification(String message) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final noti = "[${now.day}/${now.month} ${now.hour}:${now.minute.toString().padLeft(2, '0')}] $message";
    final List<String> notifications = prefs.getStringList('notifications') ?? [];
    notifications.insert(0, noti); // Thêm mới nhất lên đầu
    await prefs.setStringList('notifications', notifications);
  }

  void confirmBooking() async {
    if (field == null) return;
    if (overlapError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(overlapError!), backgroundColor: Colors.red),
      );
      return;
    }

    // Create DateTime from selected date and times
    final fromTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      startTime.hour,
      startTime.minute,
    );

    final toTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      endTime.hour,
      endTime.minute,
    );

    // Kiểm tra hợp lệ
    if (toTime.isBefore(fromTime) || toTime.isAtSameMomentAs(fromTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Giờ kết thúc phải sau giờ bắt đầu!')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      bool success = await ApiService.confirmBookingWithAdditional(
        field!.id!,
        fromTime,
        toTime,
        additionalController.text.trim(),
      );

      setState(() {
        isLoading = false;
      });

      if (success) {
        _addNotification('Đặt sân "${field!.name}" thành công lúc ${fromTime.hour.toString().padLeft(2, '0')}:${fromTime.minute.toString().padLeft(2, '0')} ngày ${fromTime.day}/${fromTime.month}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đặt sân thành công')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đặt sân thất bại')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      final errorMsg = e.toString();
      if (errorMsg.contains('Sân đã được đặt vào thời điểm này')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sân đã được đặt vào thời điểm này'), backgroundColor: Colors.red),
        );
      } else if (errorMsg.contains('overlap') || errorMsg.contains('trùng lịch')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sân đã được đặt vào thời điểm này'), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Có lỗi xảy ra khi đặt sân: $errorMsg'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (field == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Đặt sân ${field!.name}", style: const TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amber,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.sports_soccer, color: Colors.amber[800]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              field!.name,
                              style: const TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.redAccent, size: 18),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              field!.address,
                              style: const TextStyle(fontFamily: 'Roboto', fontSize: 14, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.attach_money, color: Colors.green, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            'Giá: ',
                            style: TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Roboto'),
                          ),
                          Text(
                            '${field!.pricePerHour.toInt()} VNĐ/giờ',
                            style: TextStyle(fontFamily: 'Roboto', color: Colors.black87),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Icon(Icons.calendar_today, color: Colors.amber[800]),
                        title: Text("Ngày đặt sân", style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500)),
                        subtitle: Text(
                          "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                          style: TextStyle(fontFamily: 'Roboto'),
                        ),
                        onTap: () => _selectDate(context),
                        trailing: Icon(Icons.edit_calendar, color: Colors.amber[800]),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.access_time, color: Colors.blueAccent),
                        title: Text("Giờ bắt đầu", style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500)),
                        subtitle: Text(startTime.format(context), style: TextStyle(fontFamily: 'Roboto')),
                        onTap: () => _selectStartTime(context),
                        trailing: Icon(Icons.edit, color: Colors.blueAccent),
                      ),
                      ListTile(
                        leading: Icon(Icons.access_time, color: Colors.deepOrange),
                        title: Text("Giờ kết thúc", style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500)),
                        subtitle: Text(endTime.format(context), style: TextStyle(fontFamily: 'Roboto')),
                        onTap: () => _selectEndTime(context),
                        trailing: Icon(Icons.edit, color: Colors.deepOrange),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TimeBar(
                bookedTimes: bookedTimes,
                selectedDate: selectedDate,
                selectedStart: startTime,
                selectedEnd: endTime,
                openingTime: '06:00',
                closingTime: '22:00',
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: additionalController,
                decoration: InputDecoration(
                  labelText: "Yêu cầu bổ sung (nếu có)",
                  prefixIcon: Icon(Icons.note_add, color: Colors.amber),
                  filled: true,
                  fillColor: Colors.amber[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Card(
                color: Colors.amber[50],
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Số giờ đã chọn', style: TextStyle(fontFamily: 'Roboto', color: Colors.black54)),
                          const SizedBox(height: 4),
                          Text(
                            selectedHours > 0 ? selectedHours.toStringAsFixed(2) : '-',
                            style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold, fontSize: 18, color: Colors.amber[900]),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Tổng tiền', style: TextStyle(fontFamily: 'Roboto', color: Colors.black54)),
                          const SizedBox(height: 4),
                          Text(
                            totalPrice > 0 ? '${totalPrice} VNĐ' : '-',
                            style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green[800]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: isLoading
                    ? CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: confirmBooking,
                          icon: Icon(Icons.check_circle, color: Colors.white),
                          label: Text(
                            "Xác nhận đặt sân",
                            style: TextStyle(fontSize: 16, fontFamily: 'Roboto', fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber[800],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimeBar extends StatelessWidget {
  final List<Map<String, DateTime>> bookedTimes;
  final DateTime selectedDate;
  final TimeOfDay? selectedStart;
  final TimeOfDay? selectedEnd;
  final String? openingTime;
  final String? closingTime;

  TimeBar({
    required this.bookedTimes,
    required this.selectedDate,
    this.selectedStart,
    this.selectedEnd,
    this.openingTime,
    this.closingTime,
  });

  @override
  Widget build(BuildContext context) {
    int openHour = 0;
    int closeHour = 24;
    if (openingTime != null && openingTime!.isNotEmpty) {
      openHour = int.tryParse(openingTime!.split(":")[0]) ?? 0;
    }
    if (closingTime != null && closingTime!.isNotEmpty) {
      closeHour = int.tryParse(closingTime!.split(":")[0]) ?? 24;
      if (closeHour == 0) closeHour = 24;
    }
    List<Widget> slots = [];
    for (int i = openHour; i < closeHour; i++) {
      // Nửa đầu (00-29)
      final slotStart1 = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, i, 0);
      final slotEnd1 = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, i, 30);
      bool isBooked1 = bookedTimes.any((b) => slotStart1.isBefore(b['toTime']!) && slotEnd1.isAfter(b['fromTime']!));
      bool isSelected1 = false;
      if (selectedStart != null && selectedEnd != null) {
        final selStart = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedStart!.hour, selectedStart!.minute);
        final selEnd = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedEnd!.hour, selectedEnd!.minute);
        isSelected1 = slotStart1.isBefore(selEnd) && slotEnd1.isAfter(selStart);
      }
      // Nửa sau (30-59)
      final slotStart2 = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, i, 30);
      final slotEnd2 = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, i + 1, 0);
      bool isBooked2 = bookedTimes.any((b) => slotStart2.isBefore(b['toTime']!) && slotEnd2.isAfter(b['fromTime']!));
      bool isSelected2 = false;
      if (selectedStart != null && selectedEnd != null) {
        final selStart = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedStart!.hour, selectedStart!.minute);
        final selEnd = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedEnd!.hour, selectedEnd!.minute);
        isSelected2 = slotStart2.isBefore(selEnd) && slotEnd2.isAfter(selStart);
      }
      slots.add(
        Column(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 0.5),
                width: 18,
                decoration: BoxDecoration(
                  color: isBooked1
                      ? Colors.red
                      : isSelected1
                          ? Colors.amber
                          : Colors.grey[300],
                  borderRadius: BorderRadius.zero,
                  border: Border.all(color: Colors.white, width: 0.5),
                ),
                child: Center(
                  child: Text(
                    i.toString(),
                    style: TextStyle(fontSize: 10, color: isBooked1 ? Colors.white : Colors.black, fontWeight: isSelected1 ? FontWeight.bold : FontWeight.normal),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 0.5),
                width: 18,
                decoration: BoxDecoration(
                  color: isBooked2
                      ? Colors.red
                      : isSelected2
                          ? Colors.amber
                          : Colors.grey[300],
                  borderRadius: BorderRadius.zero,
                  border: Border.all(color: Colors.white, width: 0.5),
                ),
                child: Center(
                  child: Text(
                    '',
                    style: TextStyle(fontSize: 8),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 36,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: slots,
          ),
        ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 16, height: 8, color: Colors.red),
            SizedBox(width: 4),
            Text('Đã đặt', style: TextStyle(fontSize: 11)),
            SizedBox(width: 12),
            Container(width: 16, height: 8, color: Colors.amber),
            SizedBox(width: 4),
            Text('Bạn chọn', style: TextStyle(fontSize: 11)),
            SizedBox(width: 12),
            Container(width: 16, height: 8, color: Colors.grey[300]),
            SizedBox(width: 4),
            Text('Còn trống', style: TextStyle(fontSize: 11)),
          ],
        ),
      ],
    );
  }
}
