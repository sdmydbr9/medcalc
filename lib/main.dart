import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fraction/fraction.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'calculate_anaesthesia.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(MyApp());
}

class Medication {
  final String name;
  final String species;
  final double bodyWeight;

  Medication({
    required this.name,
    required this.species,
    required this.bodyWeight,
  });
}

class MedicationDetails {
  final String type;
  final String name;
  final double concentration;
  final String unit;

  MedicationDetails({
    required this.type,
    required this.name,
    required this.concentration,
    required this.unit,
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NeumorphicApp(
      title: 'Medication App',
      theme: NeumorphicThemeData(
        baseColor: Color(0xFFEAEAEA),
        accentColor: Colors.black,
        lightSource: LightSource.topLeft,
        depth: 6,
      ),
      routes: {
        '/': (context) => MyHomePage(title: 'Medication Calculator'),
        '/calculateAnesthesia': (context) => CalculateAnaesthesiaPage(),
      },
      initialRoute: '/',
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({required this.title});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController speciesController = TextEditingController();
  final TextEditingController bodyWeightController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  String result = '';
  Medication? selectedMedication;

  Future<void> calculateMedication() async {
    if (selectedMedication != null) {
      final String name = selectedMedication!.name;
      final String species = speciesController.text;
      final double bodyWeight =
          double.tryParse(bodyWeightController.text) ?? 0.0;

      final apiURL =
          'http://34.30.172.181/medical/api.php?name=$name&species=$species';

      final response = await http.get(Uri.parse(apiURL));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final dosage = data['dosage'][0];
        final doseRate = dosage['dosage'];
        final medicationDetails = dosage['medication_details'];

        List<String> medicationDetailsText = [];

        for (var medication in medicationDetails) {
          final concentration =
              double.tryParse(medication['concentration']) ?? 0.0;
          final medicationType = medication['type'];
          final medicationName =
              '${medicationType} ${medication['name']} ${medication['concentration']}${medication['unit']}';

          if (medicationType.toLowerCase() == 'tab') {
            final tabletCount =
                calculateTabletCount(doseRate, bodyWeight, concentration);
            medicationDetailsText
                .add('Medication: $medicationName\nTablet Count: $tabletCount');
          } else {
            final calculatedDose =
                double.parse(doseRate) * bodyWeight / concentration;
            medicationDetailsText.add(
                'Medication: $medicationName\nCalculated Dose: $calculatedDose ${medication['unit']}');
          }
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medication Calculation Result',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Color.fromARGB(255, 216, 235, 185),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 214, 135, 135),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8.0),
                          Text(
                            'Medication: $name',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Species: $species',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'Dose Rate: $doseRate mg/kg',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'Body Weight: $bodyWeight kg',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 16.0),
                          Expanded(
                            child: ListView.separated(
                              physics: ClampingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: medicationDetailsText.length,
                              separatorBuilder: (context, index) => Divider(
                                color: Colors.grey,
                                thickness: 1.0,
                              ),
                              itemBuilder: (context, index) {
                                final backgroundColor =
                                    _getBackgroundColor(index);
                                final medicationDetails =
                                    medicationDetailsText[index].split('\n');
                                final medicationText =
                                    medicationDetails[0].split(': ')[1];
                                final tabletCountText =
                                    medicationDetails[1].split(': ')[1];
                                return ListTile(
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Name: ',
                                            style: TextStyle(fontSize: 16.0),
                                          ),
                                          Expanded(
                                            child: Text(
                                              medicationText,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0,
                                                backgroundColor:
                                                    backgroundColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8.0),
                                      Row(
                                        children: [
                                          Text(
                                            'Tab Count: ',
                                            style: TextStyle(fontSize: 16.0),
                                          ),
                                          Expanded(
                                            child: Text(
                                              tabletCountText,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0,
                                                backgroundColor:
                                                    backgroundColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    }
  }

  Color _getBackgroundColor(int index) {
    List<Color> backgroundColors = [
      Color.fromARGB(255, 229, 231, 194),
      Color.fromARGB(255, 231, 171, 148),
      Color.fromARGB(255, 183, 231, 171),
      Color.fromARGB(255, 178, 219, 238),
    ];

    return backgroundColors[index % backgroundColors.length];
  }

  String calculateTabletCount(
      String doseRate, double bodyWeight, double concentration) {
    if (doseRate.contains('-')) {
      final doseRange = doseRate.split('-');
      final minDose = double.parse(doseRange[0]);
      final maxDose = double.parse(doseRange[1]);
      final tabletCountMin =
          Fraction((minDose * bodyWeight).toInt(), concentration.toInt())
              .reduce();
      final tabletCountMax =
          Fraction((maxDose * bodyWeight).toInt(), concentration.toInt())
              .reduce();
      return _formatTabletCount(tabletCountMin) +
          ' to ' +
          _formatTabletCount(tabletCountMax) +
          ' tab';
    } else {
      final dose = double.parse(doseRate);
      final tabletCount =
          Fraction((dose * bodyWeight).toInt(), concentration.toInt()).reduce();
      return _formatTabletCount(tabletCount) + ' tab';
    }
  }

  String _formatTabletCount(Fraction fraction) {
    if (fraction.numerator % fraction.denominator == 0) {
      return (fraction.numerator ~/ fraction.denominator).toString();
    } else {
      return '${fraction.numerator}/${fraction.denominator}';
    }
  }

  Future<List<Medication>> fetchMedications(String query) async {
    String url = 'http://34.30.172.181/medical/api.php?medication=true';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final medications = data['medications'] ?? [];

      List<Medication> medicationList = medications
          .map<Medication>((medication) => Medication(
                name: medication['name'],
                species: '',
                bodyWeight: 0,
              ))
          .toList();

      return medicationList
          .where((medication) =>
              medication.name.toLowerCase().startsWith(query.toLowerCase()))
          .toList();
    } else {
      return [];
    }
  }

  Future<List<String>> fetchSpecies(String query) async {
    String url =
        'http://34.30.172.181/medical/api.php?name=${selectedMedication?.name}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final dosage = data['dosage'][0] as List<dynamic>;
      final speciesList = dosage
          .map<String>((species) => species['species'].toString())
          .where((species) =>
              species.toLowerCase().startsWith(query.toLowerCase()))
          .toList();

      return speciesList;
    } else {
      return [];
    }
  }

  Future<List<String>> fetchSpeciesSuggestions(String query) async {
    String url =
        'http://34.30.172.181/medical/api.php?name=${selectedMedication?.name}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final dosage = data['dosage'][0] as List<dynamic>;
      final speciesList = dosage
          .map<String>((species) => species['species'].toString())
          .where((species) =>
              species.toLowerCase().startsWith(query.toLowerCase()))
          .toList();

      return speciesList;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeumorphicAppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TypeAheadFormField<Medication>(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Medication',
                  ),
                ),
                suggestionsCallback: (pattern) async {
                  return await fetchMedications(pattern);
                },
                itemBuilder: (context, Medication medication) {
                  return ListTile(
                    title: Text(medication.name),
                  );
                },
                onSuggestionSelected: (Medication medication) {
                  nameController.text = medication.name;
                  selectedMedication = medication;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a medication';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TypeAheadFormField<String>(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: speciesController,
                  decoration: InputDecoration(
                    labelText: 'Species',
                  ),
                ),
                suggestionsCallback: (pattern) async {
                  return await fetchSpeciesSuggestions(pattern);
                },
                itemBuilder: (context, String suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                onSuggestionSelected: (String suggestion) {
                  speciesController.text = suggestion;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a species';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: bodyWeightController,
                decoration: InputDecoration(
                  labelText: 'Body Weight (kg)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the body weight';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              NeumorphicButton(
                onPressed: calculateMedication,
                child: Text('Calculate'),
              ),
              SizedBox(height: 16),
              NeumorphicButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/calculateAnesthesia');
                },
                child: Text('Anaesthesia'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
