import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;

import 'calculate_anaesthesia.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medication Dosage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        '/calculateAnesthesia': (context) => CalculateAnesthesiaPage(),
      },
    );
  }
}

class Medication {
  final String name;

  Medication(this.name);
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  TextEditingController _medicationController = TextEditingController();
  String? _selectedSpecies;
  TextEditingController _speciesController = TextEditingController();
  TextEditingController _bodyWeightController = TextEditingController();

  List<dynamic> _dosageList = [];

  Future<List<Medication>> fetchMedications(String query) async {
    String url = 'http://35.238.111.196/medical/api.php?medication=true';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final medications = data['medications'] ?? [];

      List<Medication> medicationList = medications
          .map<Medication>((medication) => Medication(medication['name']))
          .toList();

      return medicationList
          .where((medication) =>
              medication.name.toLowerCase().startsWith(query.toLowerCase()))
          .toList();
    } else {
      return [];
    }
  }

  Future<void> fetchData() async {
    String url = 'http://35.238.111.196/medical/api.php';
    Map<String, String> queryParams = {
      'name': _medicationController.text,
      'species': _selectedSpecies ?? '',
    };

    Uri uri = Uri.parse(url).replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      setState(() {
        final data = json.decode(response.body);
        final dosageList = data['dosage'] as List<dynamic>;

        _dosageList = dosageList.map((dosage) {
          final species = dosage['species'] ?? '';
          final dose = dosage['dosage'] ?? '';
          final unit = dosage['unit'] ?? '';
          final category = dosage['category'] ?? '';
          final bodyWeight = double.tryParse(_bodyWeightController.text) ?? 0;

          // Calculate the dosage based on body weight
          String calculatedDosage = '';
          if (bodyWeight > 0) {
            final parts = dose.split('-');
            if (parts.length == 1) {
              final singleDosage = double.tryParse(parts[0]) ?? 0;

              final calcDosage = (singleDosage * bodyWeight).toStringAsFixed(2);
              calculatedDosage = '$calcDosage $unit';
            } else if (parts.length == 2) {
              final minDosage = double.tryParse(parts[0]) ?? 0;
              final maxDosage = double.tryParse(parts[1]) ?? 0;

              final minCalcDosage = (minDosage * bodyWeight).toStringAsFixed(2);
              final maxCalcDosage = (maxDosage * bodyWeight).toStringAsFixed(2);
              calculatedDosage = '$minCalcDosage-$maxCalcDosage $unit';
            }
          }

          return {
            'species': species,
            'dosage': calculatedDosage,
            'unit': unit,
            'category': category,
          };
        }).toList();
      });
    } else {
      setState(() {
        _dosageList = [];
      });
    }
  }

  AnimationController? _animationController;
  bool _isShowingResult = false;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medication Dosage'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Name:',
                    style: TextStyle(fontSize: 16),
                  ),
                  TypeAheadFormField<Medication>(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _medicationController,
                      decoration: InputDecoration(
                        hintText: 'Enter medication name',
                      ),
                    ),
                    suggestionsCallback: (pattern) => fetchMedications(pattern),
                    itemBuilder: (context, Medication medication) => ListTile(
                      title: Text(medication.name),
                    ),
                    onSuggestionSelected: (Medication medication) {
                      _medicationController.text = medication.name;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a medication name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Species:',
                    style: TextStyle(fontSize: 16),
                  ),
                  DropdownButton<String>(
                    value: _selectedSpecies,
                    items: <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                        value: 'dogs',
                        child: Text('dogs'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'cats',
                        child: Text('cats'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'cattle',
                        child: Text('cattle'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'sheep/goat',
                        child: Text('sheep/goat'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'rabbits',
                        child: Text('rabbits'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'avian',
                        child: Text('avian'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'pigs',
                        child: Text('pigs'),
                      ),
                    ],
                    onChanged: (String? value) {
                      setState(() {
                        _selectedSpecies = value;
                        _speciesController.text = value ?? '';
                      });
                    },
                    hint: Text('Select species'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Body Weight (kg):',
                    style: TextStyle(fontSize: 16),
                  ),
                  TextFormField(
                    controller: _bodyWeightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter body weight in kg',
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      fetchData().then((_) {
                        setState(() {
                          _isShowingResult = true;
                          _animationController?.forward();
                        });
                      });
                    },
                    child: Text('Get Dosage'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/calculateAnesthesia');
                    },
                    child: Text('Anaesthesia'),
                  ),
                ],
              ),
            ),
            if (_isShowingResult)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isShowingResult = false;
                    _animationController?.reverse();
                  });
                },
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ScaleTransition(
                          scale: CurvedAnimation(
                            parent: _animationController!,
                            curve: Curves.easeInOut,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isShowingResult = false;
                                          _animationController?.reverse();
                                        });
                                      },
                                      child: Text(
                                        'Close',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Dosage Results',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _dosageList.length,
                                  itemBuilder: (context, index) {
                                    final dosageItem = _dosageList[index];
                                    final species = dosageItem['species'];
                                    final dosage = dosageItem['dosage'];
                                    final unit = dosageItem['unit'];
                                    final category = dosageItem['category'];

                                    return ListTile(
                                      title: Text(
                                        'Species: $species',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Dosage: $dosage $unit'),
                                          Text('Category: $category'),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
