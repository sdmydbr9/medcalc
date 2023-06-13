import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CalculateAnesthesiaPage extends StatefulWidget {
  @override
  _CalculateAnesthesiaPageState createState() =>
      _CalculateAnesthesiaPageState();
}

class _CalculateAnesthesiaPageState extends State<CalculateAnesthesiaPage> {
  TextEditingController _bodyWeightController = TextEditingController();
  String _atropineResult = '';
  String _ketamineResult = '';
  String _xylazineResult = '';
  String _diazepamResult = '';
  bool _showResults = false;
  bool _showDisclaimer = true;

  @override
  void dispose() {
    _bodyWeightController.dispose();
    super.dispose();
  }

  void _calculate() {
    double bw = double.tryParse(_bodyWeightController.text) ?? 0.0;

    double atropine = bw * 0.02 / 0.6;
    double ketamine = bw * 7 / 50;
    double xylazine = bw * 0.5 / 20;
    double diazepam = bw * 0.5 / 5;

    setState(() {
      _atropineResult = atropine.toStringAsFixed(2);
      _ketamineResult = ketamine.toStringAsFixed(2);
      _xylazineResult = xylazine.toStringAsFixed(2);
      _diazepamResult = diazepam.toStringAsFixed(2);
      _showResults = true;
      _showDisclaimer = false;
    });

    _showResultDialog();
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Anesthesia Calculation Results'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildResultItem('Atropine sulphate', _atropineResult),
              _buildResultItem('Ketamine', _ketamineResult),
              _buildResultItem('Xylazine', _xylazineResult),
              _buildResultItem('Diazepam', _diazepamResult),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _showResults = false;
                  _showDisclaimer = true;
                  _bodyWeightController.text = '';
                });
              },
              child: Text('Close'),
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // Change to vibrant color
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue, // Change to vibrant color
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculate Anesthesia'),
        backgroundColor: Colors.green, // Change to vibrant color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _bodyWeightController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 18.0),
              decoration: InputDecoration(
                labelText: 'Body Weight (in kg)',
                labelStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _calculate,
              child: Text('Calculate', style: TextStyle(fontSize: 18.0)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 48.0, vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                primary: Colors.orange, // Change to vibrant color
              ),
            ),
            SizedBox(height: 24.0),
            if (_showDisclaimer)
              Text(
                'Disclaimer: This calculation is for veterinary use only. Consult a professional for accurate dosage information.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.purple, // Change to vibrant color
                ),
              ),
          ],
        ),
      ),
    );
  }
}
