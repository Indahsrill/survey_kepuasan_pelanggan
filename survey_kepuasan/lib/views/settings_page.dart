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
  List<Map<String, String>> filteredAreaCodes = [];
  bool isLoadingAreaCodes = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedAreaCode = widget.selectedAreaCode;
    _fetchAreaCodes();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAreaCodes() async {
    try {
      List<Map<String, String>> fetchedAreaCodes = await fetchAreaCodes();
      setState(() {
        areaCodes = fetchedAreaCodes;
        filteredAreaCodes = fetchedAreaCodes;
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

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      filteredAreaCodes = areaCodes
          .where((areaCode) =>
              areaCode['kode']!.contains(_searchQuery) ||
              areaCode['nama']!
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    });
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
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari kode atau nama daerah',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredAreaCodes.length,
                    itemBuilder: (context, index) {
                      final areaCode = filteredAreaCodes[index];
                      return ListTile(
                        title:
                            Text('${areaCode['kode']} - ${areaCode['nama']}'),
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
                ),
              ],
            ),
    );
  }
}
