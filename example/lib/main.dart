import 'dart:typed_data';
import 'package:filesaverplus/filesaverplus.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder( // add Builder to make sure context is correct
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('FileSaverPlus Plugin'),
          ),
          body: const Center(
            child: Text(
              'Press the button to save files in Downloads folder.',
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _saveFile(context),
            tooltip: 'Save Files',
            child: const Icon(Icons.save),
          ),
        ),
      ),
    );
  }

  Future<void> _saveFile(BuildContext context) async {
    try {
      final htmlContent = "<h1>Header 1</h1><p>This is sample data</p>";
      final textContent = "Amit Kumar Tiwari a Mobile Developer";

      final htmlBytes = Uint8List.fromList(utf8.encode(htmlContent));
      final textBytes = Uint8List.fromList(utf8.encode(textContent));

      await FileSaverPlus().saveMultipleFiles(
        dataList: [htmlBytes, textBytes],
        fileNameList: ["htmlfile.html", "textfile.txt"],
        mimeTypeList: ["text/html", "text/plain"],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Files saved successfully!')),
      );
    } catch (e) {
      debugPrint('Error saving files: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save files: $e')),
      );
    }
  }
}
