import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


//grok api key-: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
//openai api key-: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

class HealthParameter {
  final String name;
  final String unit;
  final double value;
  final List<Map<String, dynamic>> history;
  final DateTime lastUpdated;

  HealthParameter({
    required this.name,
    required this.unit,
    required this.value,
    required this.history,
    required this.lastUpdated,
  });

  IconData get icon {
    final name = this.name.toLowerCase();
    if (name.contains('blood') && name.contains('sugar')) return Icons.water_drop;
    if (name.contains('blood') && name.contains('pressure')) return Icons.favorite;
    if (name.contains('cholesterol')) return Icons.analytics;
    if (name.contains('hemoglobin')) return Icons.bloodtype;
    if (name.contains('thyroid')) return Icons.assignment;
    if (name.contains('vitamin')) return Icons.brightness_7;
    return Icons.medical_information;
  }

  factory HealthParameter.fromJson(Map<String, dynamic> json) {
    return HealthParameter(
      name: json['name'],
      unit: json['unit'],
      value: double.parse(json['value'].toString()),
      history: List<Map<String, dynamic>>.from(json['history'] ?? []),
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'unit': unit,
      'value': value,
      'history': history,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}

class ReportProcessor {
  static Future<String> extractText(File file) async {
    if (file.path.toLowerCase().endsWith('.pdf')) {
      final bytes = await file.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      String text = '';
      
      for (int i = 0; i < document.pages.count; i++) {
        final page = document.pages[i];
        final extractor = PdfTextExtractor(document);
        text += await extractor.extractText(startPageIndex: i);
      }
      
      document.dispose();
      return text;
    } else {
      final inputImage = InputImage.fromFile(file);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();
      return recognizedText.text;
    }
  }

  static Future<List<HealthParameter>> processReport(String text) async {
    OpenAI.apiKey = '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'; // Store this securely!

    final completion = await OpenAI.instance.completion.create(
      model: 'gpt-3.5-turbo-instruct',
      prompt: '''Extract all health parameters from this medical report text.
      Text: $text
      
      Return a JSON array of objects, each containing:
      {
        "name": "parameter name (e.g., Hemoglobin, Blood Sugar, etc.)",
        "value": numerical value only,
        "unit": "measurement unit (e.g., g/dL, mg/dL, etc.)"
      }
      
      Example:
      [
        {"name": "Fasting Blood Sugar", "value": 95, "unit": "mg/dL"},
        {"name": "Hemoglobin", "value": 14.5, "unit": "g/dL"}
      ]
      ''',
      maxTokens: 1000,
    );

    final List<dynamic> parsed = jsonDecode(completion.choices.first.text);
    final DateTime now = DateTime.now();
    
    return parsed.map((item) => HealthParameter(
      name: item['name'],
      unit: item['unit'],
      value: double.parse(item['value'].toString()),
      history: [],
      lastUpdated: now,
    )).toList();
  }

  static Future<void> saveParameters(List<HealthParameter> parameters) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser!.id;

    for (final parameter in parameters) {
      // Get existing parameter if any
      final existing = await supabase
          .from('health_parameters')
          .select()
          .eq('user_id', userId)
          .eq('name', parameter.name)
          .single();

      if (existing != null) {
        // Update existing parameter
        List<Map<String, dynamic>> history = List.from(existing['history'] ?? []);
        history.add({
          'value': parameter.value,
          'date': parameter.lastUpdated.toIso8601String(),
        });

        await supabase
            .from('health_parameters')
            .update({
              'value': parameter.value,
              'history': history,
              'last_updated': parameter.lastUpdated.toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('name', parameter.name);
      } else {
        // Insert new parameter
        await supabase.from('health_parameters').insert({
          'user_id': userId,
          'name': parameter.name,
          'unit': parameter.unit,
          'value': parameter.value,
          'history': [
            {
              'value': parameter.value,
              'date': parameter.lastUpdated.toIso8601String(),
            }
          ],
          'last_updated': parameter.lastUpdated.toIso8601String(),
        });
      }
    }
  }
}