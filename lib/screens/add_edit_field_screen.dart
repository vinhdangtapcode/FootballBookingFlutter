import 'package:flutter/material.dart';
import '../models/field.dart';
import '../services/api_service.dart';

class AddEditFieldScreen extends StatefulWidget {
  @override
  _AddEditFieldScreenState createState() => _AddEditFieldScreenState();
}

class _AddEditFieldScreenState extends State<AddEditFieldScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController facilitiesController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController lengthController = TextEditingController();
  TextEditingController widthController = TextEditingController();
  TextEditingController grassTypeController = TextEditingController();
  TextEditingController openingTimeController = TextEditingController();
  TextEditingController closingTimeController = TextEditingController();
  bool available = true;
  bool outdoor = true;
  bool isLoading = false;
  Field? field;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Field? args =
    ModalRoute.of(context)?.settings.arguments as Field?;
    if (args != null) {
      field = args;
      nameController.text = field!.name;
      addressController.text = field!.address;
      typeController.text = field!.type ?? "";
      facilitiesController.text = field!.facilities ?? "";
      priceController.text = field!.pricePerHour.toString();
      lengthController.text = field!.length?.toString() ?? "70";
      widthController.text = field!.width?.toString() ?? "50";
      grassTypeController.text = field!.grassType ?? "";
      openingTimeController.text = field!.openingTime ?? "";
      closingTimeController.text = field!.closingTime ?? "";
      available = field!.available ?? true;
      outdoor = field!.outdoor ?? true;
    } else {
      lengthController.text = "70";
      widthController.text = "50";
    }
  }

  void submit() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      // Đảm bảo openingTime/closingTime đúng định dạng HH:mm:ss
      String opening = openingTimeController.text.trim();
      String closing = closingTimeController.text.trim();
      if (opening.length == 5) opening += ':00';
      if (closing.length == 5) closing += ':00';
      Field newField = Field(
        id: field?.id,
        name: nameController.text,
        address: addressController.text,
        type: typeController.text,
        facilities: facilitiesController.text,
        pricePerHour: double.tryParse(priceController.text) ?? 0.0,
        length: double.tryParse(lengthController.text),
        width: double.tryParse(widthController.text),
        grassType: grassTypeController.text,
        openingTime: opening,
        closingTime: closing,
        available: available,
        outdoor: outdoor,
      );
      if (field == null) {
        // Tạo mới sân
        ApiService.createField(newField).then((success) {
          setState(() {
            isLoading = false;
          });
          if (success) {
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("Field creation failed")));
          }
        });
      } else {
        // Cập nhật sân
        ApiService.updateField(newField).then((success) {
          setState(() {
            isLoading = false;
          });
          if (success) {
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("Field update failed")));
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = field == null ? "Thêm sân mới" : "Chỉnh sửa sân";
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber[800])),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.amber[800]),
      ),
      backgroundColor: Color(0xFFF8F8F8),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Icon(Icons.sports_soccer, color: Colors.amber, size: 60),
                ),
                SizedBox(height: 24),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Tên sân",
                    prefixIcon: Icon(Icons.sports_soccer, color: Colors.green[700]),
                    filled: true,
                    fillColor: Colors.amber[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  validator: (value) => value!.isEmpty ? "Bắt buộc" : null,
                ),
                SizedBox(height: 18),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: "Địa chỉ",
                    prefixIcon: Icon(Icons.location_on, color: Colors.redAccent),
                    filled: true,
                    fillColor: Colors.amber[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  validator: (value) => value!.isEmpty ? "Bắt buộc" : null,
                ),
                SizedBox(height: 18),
                TextFormField(
                  controller: typeController,
                  decoration: InputDecoration(
                    labelText: "Loại sân (5/7/11)",
                    prefixIcon: Icon(Icons.category, color: Colors.blueAccent),
                    filled: true,
                    fillColor: Colors.amber[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                SizedBox(height: 18),
                TextFormField(
                  controller: facilitiesController,
                  decoration: InputDecoration(
                    labelText: "Tiện ích",
                    prefixIcon: Icon(Icons.wifi, color: Colors.teal),
                    filled: true,
                    fillColor: Colors.amber[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                SizedBox(height: 18),
                TextFormField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: "Giá mỗi giờ (VNĐ)",
                    prefixIcon: Icon(Icons.attach_money, color: Colors.deepOrange),
                    filled: true,
                    fillColor: Colors.amber[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? "Bắt buộc" : null,
                ),
                SizedBox(height: 18),
                TextFormField(
                  controller: lengthController,
                  decoration: InputDecoration(
                    labelText: "Chiều dài (m)",
                    prefixIcon: Icon(Icons.straighten, color: Colors.green),
                    filled: true,
                    fillColor: Colors.amber[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 18),
                TextFormField(
                  controller: widthController,
                  decoration: InputDecoration(
                    labelText: "Chiều rộng (m)",
                    prefixIcon: Icon(Icons.straighten, color: Colors.blue),
                    filled: true,
                    fillColor: Colors.amber[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 18),
                DropdownButtonFormField<String>(
                  value: grassTypeController.text.isNotEmpty ? grassTypeController.text : null,
                  items: [
                    DropdownMenuItem(value: 'artificial', child: Text('Cỏ nhân tạo')),
                    DropdownMenuItem(value: 'natural', child: Text('Cỏ tự nhiên')),
                  ],
                  onChanged: (val) {
                    setState(() => grassTypeController.text = val ?? '');
                  },
                  decoration: InputDecoration(
                    labelText: "Loại cỏ",
                    prefixIcon: Icon(Icons.grass, color: Colors.teal),
                    filled: true,
                    fillColor: Colors.amber[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                SizedBox(height: 18),
                TextFormField(
                  controller: openingTimeController,
                  readOnly: true,
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: openingTimeController.text.isNotEmpty
                        ? TimeOfDay(
                            hour: int.tryParse(openingTimeController.text.split(":")[0]) ?? 7,
                            minute: int.tryParse(openingTimeController.text.split(":")[1]) ?? 0)
                        : TimeOfDay(hour: 7, minute: 0),
                    );
                    if (picked != null) {
                      setState(() {
                        openingTimeController.text = picked.format(context);
                        // Lưu lại theo định dạng HH:mm
                        final hour = picked.hour.toString().padLeft(2, '0');
                        final min = picked.minute.toString().padLeft(2, '0');
                        openingTimeController.text = '$hour:$min';
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: "Giờ mở cửa (HH:mm)",
                    prefixIcon: Icon(Icons.access_time, color: Colors.purple),
                    filled: true,
                    fillColor: Colors.amber[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  keyboardType: TextInputType.datetime,
                ),
                SizedBox(height: 18),
                TextFormField(
                  controller: closingTimeController,
                  readOnly: true,
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: closingTimeController.text.isNotEmpty
                        ? TimeOfDay(
                            hour: int.tryParse(closingTimeController.text.split(":")[0]) ?? 22,
                            minute: int.tryParse(closingTimeController.text.split(":")[1]) ?? 0)
                        : TimeOfDay(hour: 22, minute: 0),
                    );
                    if (picked != null) {
                      setState(() {
                        closingTimeController.text = picked.format(context);
                        final hour = picked.hour.toString().padLeft(2, '0');
                        final min = picked.minute.toString().padLeft(2, '0');
                        closingTimeController.text = '$hour:$min';
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: "Giờ đóng cửa (HH:mm)",
                    prefixIcon: Icon(Icons.access_time, color: Colors.deepPurple),
                    filled: true,
                    fillColor: Colors.amber[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  keyboardType: TextInputType.datetime,
                ),
                SizedBox(height: 18),
                SwitchListTile(
                  value: available,
                  onChanged: (val) => setState(() => available = val),
                  title: Text("Có sẵn để đặt?", style: TextStyle(fontWeight: FontWeight.w500)),
                  secondary: Icon(Icons.check_circle, color: Colors.green),
                  activeColor: Colors.amber,
                ),
                SwitchListTile(
                  value: outdoor,
                  onChanged: (val) => setState(() => outdoor = val),
                  title: Text("Sân ngoài trời?", style: TextStyle(fontWeight: FontWeight.w500)),
                  secondary: Icon(Icons.wb_sunny, color: Colors.orange),
                  activeColor: Colors.amber,
                ),
                SizedBox(height: 32),
                isLoading
                    ? Center(child: CircularProgressIndicator(color: Colors.amber))
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: submit,
                          icon: Icon(field == null ? Icons.add : Icons.save, color: Colors.white),
                          label: Text(field == null ? "Thêm sân" : "Lưu thay đổi"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                      ),
                SizedBox(height: 12),
                if (field != null)
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.cancel, color: Colors.amber),
                    label: Text("Hủy"),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.amber, width: 2),
                      foregroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
