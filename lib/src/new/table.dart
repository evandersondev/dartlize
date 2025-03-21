// Classe que representa uma tabela no estilo Drizzle.
class Table {
  final String name;
  final Map<String, String> columns;
  Table(this.name, this.columns);
}

// Funções para criar tabelas para diferentes bancos de dados.
// Se o ColumnType possuir um columnName, esse nome será utilizado,
// caso contrário, a chave do mapa será utilizada.
Table mysqlTable(String name, Map<String, ColumnType> columns) {
  final cols = columns.entries.map((e) {
    final colName = e.value.columnName ?? e.key;
    return MapEntry(colName, e.value.toString());
  });
  return Table(name, Map.fromEntries(cols));
}

Table sqliteTable(String name, Map<String, ColumnType> columns) {
  final cols = columns.entries.map((e) {
    final colName = e.value.columnName ?? e.key;
    return MapEntry(colName, e.value.toString());
  });
  return Table(name, Map.fromEntries(cols));
}

Table pgTable(String name, Map<String, ColumnType> columns) {
  final cols = columns.entries.map((e) {
    final colName = e.value.columnName ?? e.key;
    return MapEntry(colName, e.value.toString());
  });
  return Table(name, Map.fromEntries(cols));
}

/// Classe que auxilia na criação de definições de colunas com modificadores.
class ColumnType {
  final String? columnName;
  final String baseType;
  final List<String> modifiers = [];

  // Aceita um parâmetro opcional columnName.
  ColumnType(this.baseType, [this.columnName]);

  ColumnType notNull() {
    modifiers.add("NOT NULL");
    return this;
  }

  ColumnType unique() {
    modifiers.add("UNIQUE");
    return this;
  }

  ColumnType primaryKey({bool autoIncrement = true}) {
    if (autoIncrement) {
      modifiers.add("PRIMARY KEY AUTOINCREMENT");
    } else {
      modifiers.add("PRIMARY KEY");
    }
    return this;
  }

  @override
  String toString() {
    // Retorna a definição completa da coluna, sem o nome, pois o nome é definido pela chave do mapa
    return "$baseType ${modifiers.join(' ')}".trim();
  }
}

/// Funções para tipos de colunas com sintaxe inspirada no Drizzle.
/// Agora as funções utilizam parâmetros nomeados para permitir fornecer o nome da coluna.
ColumnType serial({String? columnName}) => ColumnType("SERIAL", columnName);
ColumnType varchar({String? columnName, int length = 255}) =>
    ColumnType("VARCHAR($length)", columnName);
ColumnType integer({String? columnName}) => ColumnType("INTEGER", columnName);
ColumnType text({String? columnName}) => ColumnType("TEXT", columnName);
ColumnType uuid({String? columnName}) => ColumnType("UUID", columnName);
