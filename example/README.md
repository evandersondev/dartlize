# Kartx Query Builder - Documentação Oficial

Kartx é um **Query Builder** em Dart para gerar consultas SQL de forma dinâmica e segura. Ele permite criar comandos **SELECT, INSERT, UPDATE e DELETE**, com suporte a **joins, funções SQL, ordenação e paginação**.

---

## 🚀 Recursos Principais

✅ **Gera SQL dinamicamente**
✅ **Evita SQL Injection (valores parametrizados)**  
✅ **Suporte a JOINs** (`INNER`, `LEFT`, `RIGHT`)
✅ **Funções SQL (`COUNT`, `SUM`, `AVG`, etc.)**
✅ **Suporte a ORDER BY, LIMIT e OFFSET**

---

## 📦 Instalação

Kartx é uma classe independente e pode ser adicionada diretamente ao seu projeto Dart. Basta copiar a classe para o seu projeto.

---

## 🛠️ Uso Básico

### Criar uma instância

```dart
var query = QueryBuilder();
```

### **1. SELECT Simples**

```dart
var sql = QueryBuilder()
    .from('users')
    .select(['id', 'name'])
    .where('status', '=', 'active')
    .orderBy('name')
    .toSql();

print(sql);
// Saída: SELECT id, name FROM users WHERE status = ? ORDER BY name ASC;
```

### **2. SELECT com JOIN**

```dart
var sql = QueryBuilder()
    .from('users')
    .select(['users.id', 'users.name', 'orders.total'])
    .join('orders', 'users.id', 'orders.user_id')
    .where('users.status', '=', 'active')
    .toSql();

print(sql);
// Saída: SELECT users.id, users.name, orders.total FROM users INNER JOIN orders ON users.id = orders.user_id WHERE users.status = ?;
```

### **3. INSERT**

```dart
var sql = QueryBuilder()
    .from('users')
    .insert({'name': 'João', 'age': 25, 'email': 'joao@email.com'})
    .toSql();

print(sql);
// Saída: INSERT INTO users (name, age, email) VALUES (?, ?, ?);
```

### **4. UPDATE**

```dart
var sql = QueryBuilder()
    .from('users')
    .update({'age': 30, 'status': 'active'})
    .where('id', '=', 5)
    .toSql();

print(sql);
// Saída: UPDATE users SET age = ?, status = ? WHERE id = ?;
```

### **5. DELETE**

```dart
var sql = QueryBuilder()
    .from('users')
    .delete()
    .where('id', '=', 10)
    .toSql();

print(sql);
// Saída: DELETE FROM users WHERE id = ?;
```

### **6. Funções SQL (COUNT, SUM, etc.)**

```dart
var sql = QueryBuilder()
    .from('users')
    .function('COUNT', '*', 'total_users')
    .toSql();

print(sql);
// Saída: SELECT COUNT(*) AS total_users FROM users;
```

---

## 📖 API Completa

### `from(String table)`

Define a tabela da consulta.

```dart
QueryBuilder().from('users');
```

### `select(List<String> columns)`

Define as colunas da consulta SELECT.

```dart
QueryBuilder().from('users').select(['id', 'name']);
```

### `where(String column, String operator, dynamic value)`

Adiciona uma condição WHERE.

```dart
QueryBuilder().from('users').where('id', '=', 10);
```

### `orderBy(String column, [String direction = 'ASC'])`

Ordena os resultados.

```dart
QueryBuilder().from('users').orderBy('name', 'DESC');
```

### `limit(int value)`

Define um limite de resultados.

```dart
QueryBuilder().from('users').limit(10);
```

### `offset(int value)`

Define um deslocamento nos resultados.

```dart
QueryBuilder().from('users').limit(10).offset(5);
```

### `insert(Map<String, dynamic> data)`

Monta uma query de inserção.

```dart
QueryBuilder().from('users').insert({'name': 'João', 'age': 25});
```

### `update(Map<String, dynamic> data)`

Monta uma query de atualização.

```dart
QueryBuilder().from('users').update({'status': 'active'}).where('id', '=', 5);
```

### `delete()`

Monta uma query de deleção.

```dart
QueryBuilder().from('users').delete().where('id', '=', 10);
```

### `join(String table, String column1, String column2, {String type = 'INNER'})`

Adiciona uma junção (JOIN).

```dart
QueryBuilder().from('users').join('orders', 'users.id', 'orders.user_id');
```

### `function(String function, String column, String alias)`

Executa funções SQL.

```dart
QueryBuilder().from('orders').function('SUM', 'total', 'total_sales');
```

### `toSql()`

Retorna a query SQL montada.

```dart
String sql = QueryBuilder().from('users').select(['id']).toSql();
```

### `getParameters()`

Retorna a lista de parâmetros utilizados.

```dart
List<dynamic> params = QueryBuilder().getParameters();
```

---

## 📌 Observações

- **Ordem correta para SELECT:** `.from() -> .join() -> .where() -> .orderBy() -> .limit() -> .offset() -> .toSql();`
- **As queries utilizam valores parametrizados** para evitar SQL Injection.
- **JOINs** podem ser `INNER`, `LEFT`, `RIGHT` e `FULL`.

---

## 📜 Licença

Kartx é um projeto open-source e pode ser utilizado livremente!

---

Agora você pode gerar consultas SQL com Dart de forma **fácil, segura e flexível!** 🚀
