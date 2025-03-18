import 'package:dartlize/dartlize.dart';

class UnsupportedDataTypeException implements Exception {
  final String field;
  final DataTypes type;

  UnsupportedDataTypeException(this.field, this.type);

  @override
  String toString() {
    return 'Unsupported data type "${type.type}" for field "$field".';
  }
}
