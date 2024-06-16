import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SettingsPage extends StatefulWidget {
  final Map<String, String>? selectedAreaCode;

  const SettingsPage({Key? key, this.selectedAreaCode}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, String>? _selectedAreaCode;
  List<Map<String, String>> areaCodes = [];
  bool isLoadingAreaCodes = true;

  @override
  void initState() {
    super.initState();
    _selectedAreaCode = widget.selectedAreaCode;
    _fetchAreaCodes();
  }

  Future<void> _fetchAreaCodes() async {
    try {
      List<Map<String, String>> fetchedAreaCodes = await fetchAreaCodes();
      setState(() {
        areaCodes = fetchedAreaCodes;
        isLoadingAreaCodes = false;
      });
    } catch (error) {
      setState(() {
        isLoadingAreaCodes = false;
      });
    }
  }

  Future<List<Map<String, String>>> fetchAreaCodes() async {
    final response =
        await http.get(Uri.parse('http://213.218.240.102/getkodedaerah'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> areaCodesJson = data['Kode Daerah'];
      List<Map<String, String>> areaCodes =
          areaCodesJson.map<Map<String, String>>((code) {
        return {
          'kode': code['kode']?.toString() ?? '',
          'nama': code['nama_daerah']?.toString() ?? '',
        };
      }).toList();
      return areaCodes;
    } else {
      throw Exception('Gagal memuat kode daerah');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan',
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 251, 255, 255))),
        backgroundColor: Color.fromARGB(255, 227, 48, 111),
      ),
      body: isLoadingAreaCodes
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: areaCodes.length,
              itemBuilder: (context, index) {
                final areaCode = areaCodes[index];
                return ListTile(
                  title: Text('${areaCode['kode']} - ${areaCode['nama']}'),
                  trailing: _selectedAreaCode != null &&
                          _selectedAreaCode!['kode'] == areaCode['kode']
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedAreaCode = areaCode;
                    });
                    Navigator.pop(context, areaCode);
                  },
                );
              },
            ),
    );
  }
}
