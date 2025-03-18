class DataTypes {
  final String type;
  final List<int>? params;

  const DataTypes(this.type, [this.params]);

  static const DataTypes STRING = DataTypes('VARCHAR', [255]);
  static const DataTypes TEXT = DataTypes('TEXT');
  static const DataTypes BINARY = DataTypes('BINARY');
  static const DataTypes CITEXT = DataTypes('CITEXT');
  static const DataTypes TSVECTOR = DataTypes('TSVECTOR');
  static const DataTypes BOOLEAN = DataTypes('BOOLEAN'); // TINYINT(1)
  static const DataTypes INTEGER = DataTypes('INTEGER');
  static const DataTypes BIGINT = DataTypes('BIGINT');
  static const DataTypes FLOAT = DataTypes('FLOAT');
  static const DataTypes REAL = DataTypes('REAL');
  static const DataTypes DOUBLE = DataTypes('DOUBLE');
  static const DataTypes DECIMAL = DataTypes('DECIMAL', [10, 2]);
  static const DataTypes DATE = DataTypes('DATE');
  static const DataTypes DATEONLY = DataTypes('DATEONLY');
  static const DataTypes UUID = DataTypes('UUID');
  static const DataTypes UUIDV1 = DataTypes('UUIDV1');
  static const DataTypes UUIDV4 = DataTypes('UUIDV4');
  static const DataTypes BLOB = DataTypes('BLOB');

  @override
  String toString() {
    if (params != null && params!.isNotEmpty) {
      return '$type(${params!.join(",")})';
    }
    return type;
  }
}
