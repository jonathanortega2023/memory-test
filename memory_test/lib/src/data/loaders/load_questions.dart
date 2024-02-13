import 'dart:async';
import 'package:flutter/services.dart';

const String fileName = "assets/questions.txt";

Future<List<String>> loadQuestions() async {
  try {
    // Load the file content as a string using rootBundle
    String resource = await rootBundle.loadString(fileName);

    // Split the string into lines
    List<String> lines = resource.split("\n");

    // Trim each line to remove leading and trailing whitespaces
    List<String> questions = lines.map((line) => line.trim()).toList();

    return questions;
  } catch (e) {
    // Print any error that occurs during loading
    print("Error loading questions: $e");
    // Return an empty list in case of error
    return [];
  }
}
