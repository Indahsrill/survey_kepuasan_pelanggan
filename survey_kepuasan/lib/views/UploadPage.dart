import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'settings_page.dart'; // Import the SettingsPage
import 'package:animated_text_kit/animated_text_kit.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({Key? key}) : super(key: key);

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _imageFile;
  String message = "";
  bool onLoading = false;
  final ImagePicker _picker = ImagePicker();
  Map<String, String>? selectedAreaCode;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getImageCamera() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> upload(File imageFile) async {
    DateTime now = DateTime.now();
    String formatWaktu = DateFormat('yyyyMMddHHmmss').format(now);
    String? kodeDaerah = selectedAreaCode?['kode'];
    int length = await imageFile.length();
    Uri uri = Uri.parse("http://213.218.240.102/uploadfile");

    if (kodeDaerah == null || kodeDaerah.isEmpty) {
      setState(() {
        message = "Silakan pilih kode daerah";
      });
      return;
    }

    var stream = http.ByteStream(imageFile.openRead().cast());
    var request = http.MultipartRequest("POST", uri);
    var multipartFile = http.MultipartFile(
      "file",
      stream,
      length,
      filename:
          '$kodeDaerah$formatWaktu.jpg', // Menggunakan kode daerah dan waktu
    );

    request.files.add(multipartFile);
    request.fields['kode'] = kodeDaerah; // Tambahkan parameter kode
    setState(() {
      onLoading = true;
      message = "Mengunggah...";
    });
    try {
      var response = await request.send().timeout(const Duration(seconds: 50));
      if (response.statusCode == 200) {
        setState(() {
          message = "Survey Berhasil Diunggah, Terima Kasih!";
          onLoading = false;
        });
        Future.delayed(Duration(seconds: 3), () {
          setState(() {
            message = "";
          });
        });
        _showUploadResultDialog(true);
      } else {
        setState(() {
          message = "Gagal Mengunggah Survey, Silakan Ulangi";
          onLoading = false;
        });
        Future.delayed(Duration(seconds: 3), () {
          setState(() {
            message = "";
          });
        });
        _showUploadResultDialog(false);
      }
    } catch (error) {
      setState(() {
        message = error.toString();
        onLoading = false;
      });
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          message = "";
        });
      });
      _showUploadResultDialog(false);
    }
  }

  void _openSettings() async {
    final selectedCode = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(selectedAreaCode: selectedAreaCode),
      ),
    );

    if (selectedCode != null) {
      setState(() {
        selectedAreaCode = selectedCode;
      });
    }
  }

  void _showUploadResultDialog(bool success) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dialog from being dismissed by tapping outside
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pop();
        }); // Close the dialog after 2 seconds

        return AlertDialog(
          content: success
              ? Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 100,
                )
              : Icon(
                  Icons.cancel_outlined,
                  color: Colors.red,
                  size: 100,
                ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedTextKit(
          animatedTexts: [
            TyperAnimatedText(
              'Survey Kepuasan Pelayanan Kemenag',
              textStyle: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 251, 255, 255),
              ),
              speed: const Duration(milliseconds: 100),
            ),
          ],
          isRepeatingAnimation: true,
          totalRepeatCount: 10000,
        ),
        backgroundColor: Color.fromARGB(255, 227, 48, 111),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              size: 30,
              color: Colors.white,
            ),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Kota/Kabupaten: ",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: Color.fromARGB(255, 50, 50, 50),
                        ),
                      ),
                      Text(
                        selectedAreaCode != null
                            ? '${selectedAreaCode!['kode']} - ${selectedAreaCode!['nama']}'
                            : 'Belum dipilih',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 50, 50, 50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 500),
                        child: message.isNotEmpty
                            ? Text(
                                message,
                                key: Key(message),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                ),
                              )
                            : SizedBox.shrink(),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Color.fromARGB(255, 23, 26, 30), width: 3),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "📝Langkah-langkah:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "1️⃣ Pilih ikon kamera",
                              style: TextStyle(fontSize: 23),
                            ),
                            Text(
                              "2️⃣ Arahkan kamera ke wajah Anda dan ambil gambar",
                              style: TextStyle(fontSize: 23),
                            ),
                            Text(
                              "3️⃣ Setelah gambar sesuai, klik 'Kirim' untuk mengirimkan survey",
                              style: TextStyle(fontSize: 23),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 80), // Spasi untuk menjaga keselarasan
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 500),
                        child: _imageFile == null
                            ? Container(
                                key: Key('camera_icon'),
                                width: 300,
                                height: 300,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.camera_alt,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                  onPressed: getImageCamera,
                                ),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 227, 48, 111),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              )
                            : Container(
                                key: Key('captured_image'),
                                width: 400,
                                height: 400,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey, width: 2),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      SizedBox(height: 16),
                      if (_imageFile != null)
                        ElevatedButton(
                          onPressed: () async {
                            if (_imageFile != null) {
                              await upload(_imageFile!);
                              setState(() {
                                _imageFile = null;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Color.fromARGB(255, 53, 165, 57),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 24),
                          ),
                          child: Text(
                            "Kirim Survey",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      SizedBox(height: _imageFile != null ? 8 : 0),
                      if (_imageFile != null)
                        ElevatedButton(
                          onPressed: getImageCamera,
                          style: ElevatedButton.styleFrom(
                            primary: Color.fromARGB(255, 159, 13, 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 24),
                          ),
                          child: Text(
                            "Foto Ulang",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Align(
              alignment: Alignment.center,
              child: const Text(
                '© LPPM UIN Sunan Gunung Djati Bandung 2024',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 50, 50, 50),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
