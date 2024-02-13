import 'package:flutter/services.dart';

const filePath = "assets/facts.txt";
var resource;

Future<List<String>> loadFacts() async {
  try {
    resource = await rootBundle.loadString(filePath);
  } catch (e) {
    print(e);
  }
  resource = resource.split("\n");
  for (var i = 0; i < resource.length; i++) {
    resource[i] = resource[i].trim();
  }
  return resource;
}