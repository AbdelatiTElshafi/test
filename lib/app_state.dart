import 'package:flutter/material.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  String _code = '';
  String get code => _code;
  set code(String value) {
    _code = value;
  }

  List<String> _scannedCodes = [];
  List<String> get scannedCodes => _scannedCodes;
  set scannedCodes(List<String> value) {
    _scannedCodes = value;
  }

  void addToScannedCodes(String value) {
    scannedCodes.add(value);
  }

  void removeFromScannedCodes(String value) {
    scannedCodes.remove(value);
  }

  void removeAtIndexFromScannedCodes(int index) {
    scannedCodes.removeAt(index);
  }

  void updateScannedCodesAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    scannedCodes[index] = updateFn(_scannedCodes[index]);
  }

  void insertAtIndexInScannedCodes(int index, String value) {
    scannedCodes.insert(index, value);
  }
}
