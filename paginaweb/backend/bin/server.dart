import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:mysql1/mysql1.dart';
import 'dart:convert';

void main() async {
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(_router);

  await io.serve(handler, 'localhost', 8080);
  print('Servidor en http://localhost:8080');
}

Future<Response> _router(Request request) async {
  if (request.method == 'OPTIONS') {
    return Response.ok('');
  }
  if (request.url.path == 'login' && request.method == 'POST') {
    return await handleLogin(request);
  }
  return Response.notFound('Ruta no encontrada');
}

Future<Response> handleLogin(Request request) async {
  final body = jsonDecode(await request.readAsString());
  final email = body['email'];
  final password = body['password'];

  final settings = ConnectionSettings(
    host: 'localhost',
    port: 3306,
    user: 'root',
    password: 'rootroot', 
    db: 'mi_app',
  );

  final conn = await MySqlConnection.connect(settings);

  final result = await conn.query(
    'SELECT * FROM usuarios WHERE email = ? AND password = ?',
    [email, password],
  );

  await conn.close();

  if (result.isNotEmpty) {
    return Response.ok(
      jsonEncode({'success': true, 'mensaje': 'Login exitoso'}),
      headers: {'Content-Type': 'application/json'},
    );
  } else {
    return Response(
      401,
      body: jsonEncode({'success': false, 'mensaje': 'Credenciales incorrectas'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}