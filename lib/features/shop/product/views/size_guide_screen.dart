import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class SizeGuideScreen extends StatefulWidget {
  const SizeGuideScreen({super.key});

  @override
  State<SizeGuideScreen> createState() => _SizeGuideScreenState();
}

class _SizeGuideScreenState extends State<SizeGuideScreen> {
  bool _isShowCentimetersSize = false;

  void updateSizes() {
    setState(() {
      _isShowCentimetersSize = !_isShowCentimetersSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Size Guide"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Measurements",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ElevatedButton(
                  onPressed: updateSizes,
                  child: Text(_isShowCentimetersSize ? "Show Inches" : "Show Centimeters"),
                ),
              ],
            ),
            const SizedBox(height: defaultPadding),
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade100),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text("Size", style: Theme.of(context).textTheme.titleSmall),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text("XS", style: Theme.of(context).textTheme.titleSmall),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text("S", style: Theme.of(context).textTheme.titleSmall),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text("M", style: Theme.of(context).textTheme.titleSmall),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("Chest"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(_isShowCentimetersSize ? "76cm" : "30in"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(_isShowCentimetersSize ? "81cm" : "32in"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(_isShowCentimetersSize ? "86cm" : "34in"),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("Waist"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(_isShowCentimetersSize ? "61cm" : "24in"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(_isShowCentimetersSize ? "66cm" : "26in"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(_isShowCentimetersSize ? "71cm" : "28in"),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("Length"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(_isShowCentimetersSize ? "66cm" : "26in"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(_isShowCentimetersSize ? "69cm" : "27in"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(_isShowCentimetersSize ? "71cm" : "28in"),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
