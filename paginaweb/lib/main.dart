import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ByteAndBiteApp());
}

// ===================== COLORES =====================
const Color verdeOscuro = Color(0xFF114634);
const Color naranja = Color(0xFFf97f2c);
const Color verdeMedio = Color(0xFF6a9920);
const Color beige = Color(0xFFD6D1C5);
const Color verdeClaroBg = Color(0xFFe8f0e9);

// ===================== MODELOS =====================
class Persona {
  String nombre, edad, genero, peso, altura, condicion, alergias;
  Persona({
    this.nombre = '',
    this.edad = '',
    this.genero = '',
    this.peso = '',
    this.altura = '',
    this.condicion = '',
    this.alergias = '',
  });
}

class DatosFormulario {
  String presupuesto = '';
  String periodo = '';
  List<Persona> personas = [];
  String ciudad = '';
  List<String> tiendas = [];
  String objetivo = '';
  String extras = '';
}

// ===================== APP =====================
class ByteAndBiteApp extends StatelessWidget {
  const ByteAndBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Byte & Bite',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorSchemeSeed: verdeOscuro,
        scaffoldBackgroundColor: const Color(0xFFf5f5f5),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return const AppShell();
          }
          return const LoginPage();
        },
      ),
    );
  }
}

// ===================== LOGIN =====================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String error = '';
  bool cargando = false;
  bool mostrarRegistro = false;

  Future<void> login() async {
    setState(() { cargando = true; error = ''; });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );
    } on FirebaseAuthException {
      setState(() => error = 'Correo o contraseña incorrectos');
    } finally {
      setState(() => cargando = false);
    }
  }

  Future<void> registrar() async {
    setState(() { cargando = true; error = ''; });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        setState(() => error = 'La contraseña debe tener al menos 6 caracteres');
      } else if (e.code == 'email-already-in-use') {
        setState(() => error = 'Este correo ya está registrado');
      } else {
        setState(() => error = 'Error al registrar');
      }
    } finally {
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf5f5f5),
      body: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 380,
            padding: const EdgeInsets.all(36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.eco, color: verdeOscuro, size: 48),
                const SizedBox(height: 8),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                    children: [
                      TextSpan(text: 'Byte', style: TextStyle(color: verdeOscuro)),
                      TextSpan(text: '&', style: TextStyle(color: naranja)),
                      TextSpan(text: 'Bite', style: TextStyle(color: verdeOscuro)),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  mostrarRegistro ? 'Crear cuenta' : 'Iniciar sesión',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: emailCtrl,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                if (error.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(error, style: const TextStyle(color: Colors.red, fontSize: 13)),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: cargando ? null : (mostrarRegistro ? registrar : login),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: verdeOscuro,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: cargando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            mostrarRegistro ? 'Registrarse' : 'Entrar',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => setState(() { mostrarRegistro = !mostrarRegistro; error = ''; }),
                  child: Text(
                    mostrarRegistro
                        ? '¿Ya tienes cuenta? Inicia sesión'
                        : '¿No tienes cuenta? Regístrate',
                    style: const TextStyle(color: verdeOscuro, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===================== SHELL PRINCIPAL =====================
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int paginaActual = 1;
  final datos = DatosFormulario();
  String resultado = '';
  bool cargando = false;
  String errorResultado = '';

  static const String _apiKey = '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';

  void irA(int pagina) {
    setState(() => paginaActual = pagina);
  }

  Future<void> generarPlan() async {
    irA(4);
    setState(() {
      cargando = true;
      resultado = '';
      errorResultado = '';
    });

    final descPersonas = datos.personas.asMap().entries.map((e) {
      final i = e.key + 1;
      final p = e.value;
      final partes = <String>[];
      if (p.nombre.isNotEmpty) partes.add('Nombre: ${p.nombre}');
      if (p.edad.isNotEmpty) partes.add('Edad: ${p.edad} años');
      if (p.genero.isNotEmpty) partes.add('Género: ${p.genero}');
      if (p.peso.isNotEmpty) partes.add('Peso: ${p.peso}kg');
      if (p.altura.isNotEmpty) partes.add('Estatura: ${p.altura}cm');
      if (p.condicion.isNotEmpty) partes.add('Condición: ${p.condicion}');
      if (p.alergias.isNotEmpty) partes.add('Alergias: ${p.alergias}');
      return '  Persona $i: ${partes.join(', ')}';
    }).join('\n');

    final nombresTiendas = {
      'bodega': 'Bodega Aurrerá',
      'walmart': 'Walmart',
      'chedraui': 'Chedraui',
      'soriana': 'Soriana',
      'mercado': 'Mercado local',
      'oxxo': 'OXXO/tiendita',
    };
    final descTiendas = datos.tiendas.isNotEmpty
        ? datos.tiendas.map((t) => nombresTiendas[t] ?? t).join(', ')
        : 'Tiendas accesibles en México';

    final prompt = '''
Actúa como nutricionista profesional mexicano. El presupuesto que se te da, lo usas exclusivamente en la comida.
Usa precios reales de las tiendas seleccionadas

Presupuesto: \$${datos.presupuesto} (${datos.periodo})
Personas:
$descPersonas

Tiendas disponibles: $descTiendas
Objetivo: ${datos.objetivo}
Extras: ${datos.extras}

Genera:
- Menú según el periodo que se dio, de forma detallada (desayuno, comida y cena)
- Lista de compras con precios aproximados en pesos mexicanos
- Recomendación de consumo de agua diario para cada persona
- Consejos nutricionales
- Todo adaptado a México
- Nota: los precios son aproximados

Haz que el output sea lo mas sencillo posible y fácil de entender
''';

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          resultado = data['choices'][0]['message']['content'];
          cargando = false;
        });
      } else {
        setState(() {
          errorResultado = 'Error del servidor: ${response.statusCode}';
          cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        errorResultado = 'Error de conexión. Verifica tu internet e intenta nuevamente.';
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildNavbar(),
      body: IndexedStack(
        index: paginaActual - 1,
        children: [
          PaginaInicio(onIr: irA),
          PaginaOpciones(onIr: irA, datos: datos, onGenerarPlan: generarPlan),
          PaginaFormulario(onIr: irA, datos: datos, onGenerarPlan: generarPlan),
          PaginaResultado(
            datos: datos,
            resultado: resultado,
            cargando: cargando,
            error: errorResultado,
            onIr: irA,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildNavbar() {
    return AppBar(
      backgroundColor: verdeOscuro,
      elevation: 2,
      title: GestureDetector(
        onTap: () => irA(1),
        child: Row(
          children: [
            const Icon(Icons.eco, color: Colors.white, size: 26),
            const SizedBox(width: 6),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                children: [
                  TextSpan(text: 'Byte', style: TextStyle(color: Colors.white)),
                  TextSpan(text: '&', style: TextStyle(color: naranja)),
                  TextSpan(text: 'Bite', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ElevatedButton.icon(
            onPressed: () => irA(2),
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: const Text('Crear mi plan', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: verdeOscuro,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ),
        IconButton(
          onPressed: () => FirebaseAuth.instance.signOut(),
          icon: const Icon(Icons.logout, color: Colors.white),
          tooltip: 'Cerrar sesión',
        ),
      ],
    );
  }
}

// ===================== PÁGINA 1: INICIO =====================
class PaginaInicio extends StatelessWidget {
  final Function(int) onIr;
  const PaginaInicio({super.key, required this.onIr});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFe8f0e9), Color(0xFFf5f0e8)],
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFc8dcc0),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.restaurant, size: 16, color: verdeOscuro),
                      SizedBox(width: 6),
                      Text('Nutrición accesible para todos',
                          style: TextStyle(color: verdeOscuro, fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _buildLogo(),
                const SizedBox(height: 24),
                const Text(
                  'Genera un plan alimentario personalizado según tu presupuesto, familia y condiciones de salud. Con IA, comer nutritivo ya no es privilegio de pocos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF666666), fontSize: 16, height: 1.7),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: naranja),
                    const SizedBox(width: 5),
                    Text(
                      'Los precios mostrados son aproximados y pueden variar.',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Wrap(
                  spacing: 14,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => onIr(2),
                      icon: const Text('Crear mi plan gratuito', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      label: const Icon(Icons.arrow_forward, size: 20),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: verdeOscuro,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.help_outline, size: 20),
                      label: const Text('¿Cómo funciona?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: verdeOscuro,
                        side: const BorderSide(color: verdeOscuro, width: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                _buildStats(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
            child: Column(
              children: [
                const Text('Todo lo que necesitas para comer bien',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                GridView.count(
                  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.8,
                  children: const [
                    _CardFeature(icono: Icons.payments, titulo: 'Respeta tu presupuesto',
                        desc: 'Ingresa cuánto tienes disponible al mes, quincena o semana. La IA ajusta cada receta para no gastar de más.'),
                    _CardFeature(icono: Icons.family_restroom, titulo: 'Para toda tu familia',
                        desc: 'Personaliza el plan para cada integrante. Niños, adultos mayores, personas con diabetes, anemia o alergias.'),
                    _CardFeature(icono: Icons.shopping_cart, titulo: 'Lista de compras lista',
                        desc: 'Genera tu lista de súper con productos disponibles en Bodega Aurrerá, Walmart, Chedraui o tu mercado local.'),
                    _CardFeature(icono: Icons.restaurant, titulo: 'Recetas fáciles y rápidas',
                        desc: 'Instrucciones paso a paso sin ingredientes raros. Comida real, mexicana, nutritiva y accesible para todos.'),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 60, top: 10),
            child: Column(
              children: [
                const Text('¿Lista para empezar?',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => onIr(2),
                  icon: const Text('Crear mi plan ahora', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  label: const Icon(Icons.arrow_forward),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: verdeOscuro,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.eco, color: verdeOscuro, size: 36),
        const SizedBox(width: 8),
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
            children: [
              TextSpan(text: 'Byte', style: TextStyle(color: verdeOscuro)),
              TextSpan(text: '&', style: TextStyle(color: naranja)),
              TextSpan(text: 'Bite', style: TextStyle(color: verdeOscuro)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Wrap(
      spacing: 32,
      runSpacing: 24,
      alignment: WrapAlignment.center,
      children: const [
        _StatItem(numero: '52M', etiqueta: 'mexicanos en pobreza alimentaria'),
        _StatItem(numero: '25%', etiqueta: 'hogares con inseguridad alimentaria'),
        _StatItem(numero: '70%', etiqueta: 'adultos con sobrepeso u obesidad'),
        _StatItem(numero: '\$0', etiqueta: 'costo de usar Byte&Bite'),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String numero, etiqueta;
  const _StatItem({required this.numero, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        children: [
          Text(numero, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: verdeOscuro)),
          const SizedBox(height: 4),
          Text(etiqueta, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4)),
        ],
      ),
    );
  }
}

class _CardFeature extends StatelessWidget {
  final IconData icono;
  final String titulo, desc;
  const _CardFeature({required this.icono, required this.titulo, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFdddddd)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: verdeClaroBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icono, color: verdeOscuro, size: 26),
          ),
          const SizedBox(height: 12),
          Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(desc, style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5)),
        ],
      ),
    );
  }
}

// ===================== PÁGINA 2: OPCIONES =====================
class PaginaOpciones extends StatelessWidget {
  final Function(int) onIr;
  final DatosFormulario datos;
  final Future<void> Function() onGenerarPlan;

  const PaginaOpciones({super.key, required this.onIr, required this.datos, required this.onGenerarPlan});

  void _usarPlantilla(String clave) {
    final plantillas = {
      'mama3hijos': {
        'presupuesto': '2000', 'periodo': 'mensual',
        'personas': [
          Persona(nombre: 'Mamá', edad: '32', genero: 'Femenino', peso: '65', altura: '158'),
          Persona(nombre: 'Hijo 1', edad: '10', genero: 'Masculino', peso: '35', altura: '140'),
          Persona(nombre: 'Hijo 2', edad: '7', genero: 'Femenino', peso: '25', altura: '120'),
          Persona(nombre: 'Hijo 3', edad: '4', genero: 'Masculino', peso: '18', altura: '100'),
        ],
        'objetivo': '', 'extras': 'Comida fácil y rápida',
        'tiendas': ['bodega', 'mercado'],
      },
      'foraneo': {
        'presupuesto': '1200', 'periodo': 'mensual',
        'personas': [Persona(nombre: 'Yo', edad: '20', genero: 'Masculino', peso: '68', altura: '172')],
        'objetivo': 'Más energía en el día', 'extras': 'Sin mucho tiempo para cocinar',
        'tiendas': ['bodega', 'oxxo'],
      },
      'adultomayor': {
        'presupuesto': '1500', 'periodo': 'mensual',
        'personas': [
          Persona(nombre: 'Abuela', edad: '70', genero: 'Femenino', peso: '60', altura: '155', condicion: 'Hipertensión'),
          Persona(nombre: 'Abuelo', edad: '73', genero: 'Masculino', peso: '72', altura: '165', condicion: 'Diabetes'),
        ],
        'objetivo': '', 'extras': 'Poca sal, comida suave',
        'tiendas': ['walmart', 'soriana'],
      },
      'diabetes': {
        'presupuesto': '1800', 'periodo': 'mensual',
        'personas': [Persona(nombre: 'Yo', edad: '45', genero: 'Femenino', peso: '75', altura: '160', condicion: 'Diabetes', alergias: 'Sin azúcar')],
        'objetivo': 'Bajar de peso saludablemente', 'extras': 'Comida baja en carbohidratos',
        'tiendas': ['chedraui', 'mercado'],
      },
    };

    final t = plantillas[clave];
    if (t == null) return;
    datos.presupuesto = t['presupuesto'] as String;
    datos.periodo = t['periodo'] as String;
    datos.personas = t['personas'] as List<Persona>;
    datos.objetivo = t['objetivo'] as String;
    datos.extras = t['extras'] as String;
    datos.tiendas = List<String>.from(t['tiendas'] as List);
    onGenerarPlan();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () => onIr(1),
                icon: const Icon(Icons.arrow_back, size: 18, color: Colors.grey),
                label: const Text('Volver al inicio', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 16),
              const Text('¿Qué quieres hacer?',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Crea un plan personalizado o elige una plantilla ya lista.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 15)),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: _CardOpcion(
                    icono: Icons.auto_awesome,
                    titulo: 'Crear mi plan',
                    desc: 'Personaliza todo: presupuesto, número de personas, condiciones de salud, objetivos y tiendas preferidas.',
                    onTap: () => onIr(3),
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: _CardOpcion(
                    icono: Icons.assignment,
                    titulo: 'Usar plantilla',
                    desc: 'Elige un plan prediseñado para situaciones comunes y ajústalo a tu gusto.',
                    onTap: () => _usarPlantilla('mama3hijos'),
                  )),
                ],
              ),
              const SizedBox(height: 48),
              const Text('Plantillas populares',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 500 ? 2 : 1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3.5,
                children: [
                  _CardPlantilla(icono: Icons.family_restroom, titulo: 'Mamá con 3 hijos',
                      subtitulo: '\$2,000 / mes · 4 personas', onTap: () => _usarPlantilla('mama3hijos')),
                  _CardPlantilla(icono: Icons.school, titulo: 'Estudiante foráneo',
                      subtitulo: '\$1,200 / mes · 1 persona', onTap: () => _usarPlantilla('foraneo')),
                  _CardPlantilla(icono: Icons.elderly, titulo: 'Adulto mayor',
                      subtitulo: '\$1,500 / mes · 2 personas', onTap: () => _usarPlantilla('adultomayor')),
                  _CardPlantilla(icono: Icons.medication, titulo: 'Con diabetes',
                      subtitulo: '\$1,800 / mes · 1 persona', onTap: () => _usarPlantilla('diabetes')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardOpcion extends StatefulWidget {
  final IconData icono;
  final String titulo, desc;
  final VoidCallback onTap;
  const _CardOpcion({required this.icono, required this.titulo, required this.desc, required this.onTap});

  @override
  State<_CardOpcion> createState() => _CardOpcionState();
}

class _CardOpcionState extends State<_CardOpcion> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => hover = true),
        onExit: (_) => setState(() => hover = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: hover ? verdeOscuro : const Color(0xFFdddddd), width: 2),
            borderRadius: BorderRadius.circular(20),
            boxShadow: hover ? [BoxShadow(color: verdeOscuro.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, 5))] : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58, height: 58,
                decoration: BoxDecoration(color: verdeClaroBg, borderRadius: BorderRadius.circular(14)),
                child: Icon(widget.icono, color: verdeOscuro, size: 30),
              ),
              const SizedBox(height: 14),
              Text(widget.titulo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(widget.desc, style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.6)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardPlantilla extends StatelessWidget {
  final IconData icono;
  final String titulo, subtitulo;
  final VoidCallback onTap;
  const _CardPlantilla({required this.icono, required this.titulo, required this.subtitulo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFdddddd)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: verdeClaroBg, borderRadius: BorderRadius.circular(11)),
              child: Icon(icono, color: verdeOscuro, size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(titulo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(subtitulo, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== PÁGINA 3: FORMULARIO =====================
class PaginaFormulario extends StatefulWidget {
  final Function(int) onIr;
  final DatosFormulario datos;
  final Future<void> Function() onGenerarPlan;

  const PaginaFormulario({super.key, required this.onIr, required this.datos, required this.onGenerarPlan});

  @override
  State<PaginaFormulario> createState() => _PaginaFormularioState();
}

class _PaginaFormularioState extends State<PaginaFormulario> {
  int pasoActual = 1;

  final presupuestoCtrl = TextEditingController();
  final ciudadCtrl = TextEditingController();
  final extrasCtrl = TextEditingController();

  String periodoSeleccionado = '';
  String objetivoSeleccionado = '';
  List<String> tiendasSeleccionadas = [];
  List<Persona> personas = [];
  List<Map<String, TextEditingController>> personasCtrls = [];

  String error = '';

  @override
  void initState() {
    super.initState();
    _agregarPersona();
  }

  void _agregarPersona() {
    setState(() {
      personas.add(Persona());
      personasCtrls.add({
        'nombre': TextEditingController(),
        'edad': TextEditingController(),
        'peso': TextEditingController(),
        'altura': TextEditingController(),
        'alergias': TextEditingController(),
      });
    });
  }

  void _quitarPersona(int i) {
    setState(() {
      personas.removeAt(i);
      personasCtrls.removeAt(i);
    });
  }

  void _irPaso(int paso) {
    setState(() {
      pasoActual = paso;
      error = '';
    });
  }

  void _siguientePaso(int siguiente) {
    if (siguiente == 2) {
      if (presupuestoCtrl.text.isEmpty || double.tryParse(presupuestoCtrl.text) == null || double.parse(presupuestoCtrl.text) <= 0) {
        setState(() => error = 'Por favor ingresa un presupuesto mayor a \$0.');
        return;
      }
      if (periodoSeleccionado.isEmpty) {
        setState(() => error = 'Por favor selecciona el período de tu presupuesto.');
        return;
      }
      widget.datos.presupuesto = presupuestoCtrl.text;
      widget.datos.periodo = periodoSeleccionado;
    }
    if (siguiente == 3) { _guardarPersonas(); }
    if (siguiente == 4) {
      widget.datos.ciudad = ciudadCtrl.text;
      widget.datos.tiendas = tiendasSeleccionadas;
    }
    setState(() { pasoActual = siguiente; error = ''; });
  }

  void _guardarPersonas() {
    for (var i = 0; i < personas.length; i++) {
      personas[i].nombre = personasCtrls[i]['nombre']!.text;
      personas[i].edad = personasCtrls[i]['edad']!.text;
      personas[i].peso = personasCtrls[i]['peso']!.text;
      personas[i].altura = personasCtrls[i]['altura']!.text;
      personas[i].alergias = personasCtrls[i]['alergias']!.text;
    }
    widget.datos.personas = List.from(personas);
  }

  void _generarPlan() {
    _guardarPersonas();
    widget.datos.ciudad = ciudadCtrl.text;
    widget.datos.tiendas = tiendasSeleccionadas;
    widget.datos.objetivo = objetivoSeleccionado;
    widget.datos.extras = extrasCtrl.text;
    widget.onGenerarPlan();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          constraints: const BoxConstraints(maxWidth: 680),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Row(
                children: [
                  ...List.generate(4, (i) => Expanded(
                    child: Container(
                      height: 5,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: i < pasoActual ? verdeOscuro : const Color(0xFFc8dcc0),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  )),
                  Text('Paso $pasoActual de 4',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  children: [
                    if (error.isNotEmpty)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFffebee),
                          border: Border.all(color: const Color(0xFFef9a9a)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(error, style: const TextStyle(color: Color(0xFFc62828), fontSize: 14)),
                      ),
                    if (pasoActual == 1) _buildPaso1(),
                    if (pasoActual == 2) _buildPaso2(),
                    if (pasoActual == 3) _buildPaso3(),
                    if (pasoActual == 4) _buildPaso4(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaso1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _encabezadoPaso(Icons.payments, 'Tu presupuesto', '¿Cuánto tienes disponible para la comida de tu familia?'),
        _campoForm('Presupuesto (en pesos mexicanos)',
          child: TextField(
            controller: presupuestoCtrl,
            keyboardType: TextInputType.number,
            decoration: _inputDec('Ej: 2000'),
          )),
        _campoForm('¿Cada cuánto es ese presupuesto?',
          child: GridView.count(
            crossAxisCount: 2, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.2,
            children: [
              _opcionPeriodo('Mensual', 'Cada mes', Icons.calendar_month, 'mensual'),
              _opcionPeriodo('Quincenal', 'Cada 15 días', Icons.date_range, 'quincenal'),
              _opcionPeriodo('Semanal', 'Cada semana', Icons.view_week, 'semanal'),
              _opcionPeriodo('Diario', 'Por día', Icons.today, 'diario'),
            ],
          )),
        _navForm(
          atras: TextButton.icon(onPressed: () => widget.onIr(2),
            icon: const Icon(Icons.arrow_back, size: 18), label: const Text('Volver')),
          siguiente: () => _siguientePaso(2),
        ),
      ],
    );
  }

  Widget _buildPaso2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _encabezadoPaso(Icons.family_restroom, 'Tu familia', 'Cuéntanos sobre las personas para las que planearás la comida.'),
        ...List.generate(personas.length, (i) => _tarjetaPersona(i)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _agregarPersona,
          child: Container(
            width: double.infinity, height: 52,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFa5d6a7), width: 2),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add, color: verdeOscuro),
                SizedBox(width: 8),
                Text('Agregar persona', style: TextStyle(color: verdeOscuro, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        _navForm(
          atras: TextButton.icon(onPressed: () => _irPaso(1),
            icon: const Icon(Icons.arrow_back, size: 18), label: const Text('Anterior')),
          siguiente: () => _siguientePaso(3),
        ),
      ],
    );
  }

  Widget _buildPaso3() {
    final tiendas = [
      {'key': 'bodega', 'nombre': 'Bodega Aurrerá', 'icono': Icons.store},
      {'key': 'walmart', 'nombre': 'Walmart', 'icono': Icons.shopping_cart},
      {'key': 'chedraui', 'nombre': 'Chedraui', 'icono': Icons.storefront},
      {'key': 'soriana', 'nombre': 'Soriana', 'icono': Icons.local_mall},
      {'key': 'mercado', 'nombre': 'Mercado local', 'icono': Icons.local_florist},
      {'key': 'oxxo', 'nombre': 'OXXO / tiendita', 'icono': Icons.night_shelter},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _encabezadoPaso(Icons.location_on, 'Dónde compras', 'Selecciona las tiendas que tienes cerca.'),
        _campoForm('Tu ciudad o colonia',
          child: TextField(controller: ciudadCtrl, decoration: _inputDec('Ej: Puebla, Col. Centro...'))),
        _campoForm('Tiendas donde acostumbras comprar',
          child: GridView.count(
            crossAxisCount: 3, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.3,
            children: tiendas.map((t) {
              final seleccionado = tiendasSeleccionadas.contains(t['key']);
              return GestureDetector(
                onTap: () => setState(() {
                  if (seleccionado) tiendasSeleccionadas.remove(t['key']);
                  else tiendasSeleccionadas.add(t['key'] as String);
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: seleccionado ? verdeClaroBg : Colors.white,
                    border: Border.all(color: seleccionado ? verdeOscuro : const Color(0xFFdddddd), width: 2),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(t['icono'] as IconData, color: verdeOscuro, size: 22),
                      const SizedBox(height: 6),
                      Text(t['nombre'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            }).toList(),
          )),
        _navForm(
          atras: TextButton.icon(onPressed: () => _irPaso(2),
            icon: const Icon(Icons.arrow_back, size: 18), label: const Text('Anterior')),
          siguiente: () => _siguientePaso(4),
        ),
      ],
    );
  }

  Widget _buildPaso4() {
    final objetivos = [
      {'value': '', 'label': 'Solo comer bien y economizar'},
      {'value': 'Bajar de peso saludablemente', 'label': 'Bajar de peso saludablemente'},
      {'value': 'Subir de peso / ganar masa', 'label': 'Subir de peso / ganar masa'},
      {'value': 'Más energía en el día', 'label': 'Más energía en el día'},
      {'value': 'Mejorar salud digestiva', 'label': 'Mejorar salud digestiva'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _encabezadoPaso(Icons.flag, '¿Algún objetivo?', 'Si tienes alguna meta específica, la IA la tomará en cuenta.'),
        _campoForm('Objetivo principal',
          child: DropdownButtonFormField<String>(
            value: objetivoSeleccionado,
            decoration: _inputDec(''),
            items: objetivos.map((o) => DropdownMenuItem(
              value: o['value'],
              child: Text(o['label']!),
            )).toList(),
            onChanged: (v) => setState(() => objetivoSeleccionado = v ?? ''),
          )),
        _campoForm('Algo extra que quieras que sepa la IA',
          child: TextField(
            controller: extrasCtrl,
            maxLines: 3,
            decoration: _inputDec('Ej: No me gusta el picante, prefiero comida rápida...'),
          )),
        const SizedBox(height: 12),
        Row(
          children: [
            TextButton.icon(
              onPressed: () => _irPaso(3),
              icon: const Icon(Icons.arrow_back, size: 18, color: Colors.grey),
              label: const Text('Anterior', style: TextStyle(color: Colors.grey)),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _generarPlan,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Generar mi plan', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFe65100),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _tarjetaPersona(int i) {
    final p = personasCtrls[i];
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFe0e0e0)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.person, color: verdeOscuro, size: 20),
              const SizedBox(width: 6),
              Text('Persona ${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: verdeOscuro)),
              const Spacer(),
              if (i > 0)
                IconButton(
                  onPressed: () => _quitarPersona(i),
                  icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _miniCampo('Nombre (opcional)', p['nombre']!, 'Ana')),
            const SizedBox(width: 10),
            Expanded(child: _miniCampo('Edad', p['edad']!, '35', isNum: true)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _miniDropdown('Género', personas[i].genero,
                ['', 'Femenino', 'Masculino', 'Otro'],
                (v) => setState(() => personas[i].genero = v ?? ''))),
            const SizedBox(width: 10),
            Expanded(child: _miniCampo('Peso (kg)', p['peso']!, '60', isNum: true)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _miniCampo('Estatura (cm)', p['altura']!, '160', isNum: true)),
            const SizedBox(width: 10),
            Expanded(child: _miniDropdown('Condición de salud', personas[i].condicion,
                ['', 'Ninguna', 'Anemia', 'Diabetes', 'Hipertensión', 'Colesterol alto', 'Sobrepeso', 'Embarazo / lactancia', 'Otra'],
                (v) => setState(() => personas[i].condicion = v ?? ''))),
          ]),
          const SizedBox(height: 10),
          TextField(
            controller: p['alergias'],
            decoration: _inputDec('Alergias o alimentos que no le gustan').copyWith(
              labelText: 'Alergias / no le gusta',
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniCampo(String label, TextEditingController ctrl, String hint, {bool isNum = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          keyboardType: isNum ? TextInputType.number : TextInputType.text,
          decoration: _inputDec(hint),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _miniDropdown(String label, String valor, List<String> opciones, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: opciones.contains(valor) ? valor : '',
          decoration: _inputDec(''),
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          items: opciones.map((o) => DropdownMenuItem(value: o, child: Text(o.isEmpty ? 'Seleccionar' : o))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _opcionPeriodo(String nombre, String desc, IconData icono, String valor) {
    final sel = periodoSeleccionado == valor;
    return GestureDetector(
      onTap: () => setState(() => periodoSeleccionado = valor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: sel ? verdeClaroBg : Colors.white,
          border: Border.all(color: sel ? verdeOscuro : const Color(0xFFdddddd), width: 2),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, color: verdeOscuro, size: 22),
            const SizedBox(height: 4),
            Text(nombre, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text(desc, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  Widget _encabezadoPaso(IconData icono, String titulo, String subtitulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icono, color: verdeOscuro, size: 28),
            const SizedBox(width: 10),
            Text(titulo, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 6),
          Text(subtitulo, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _campoForm(String label, {required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 7),
          child,
        ],
      ),
    );
  }

  Widget _navForm({required Widget atras, required VoidCallback siguiente}) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              atras,
              ElevatedButton.icon(
                onPressed: siguiente,
                icon: const Text('Continuar', style: TextStyle(fontWeight: FontWeight.bold)),
                label: const Icon(Icons.arrow_forward, size: 18),
                style: ElevatedButton.styleFrom(
                  backgroundColor: verdeOscuro,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDec(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFdddddd), width: 2)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFdddddd), width: 2)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: verdeOscuro, width: 2)),
      filled: true,
      fillColor: Colors.white,
    );
  }
}

// ===================== PÁGINA 4: RESULTADO =====================
class PaginaResultado extends StatelessWidget {
  final DatosFormulario datos;
  final String resultado;
  final bool cargando;
  final String error;
  final Function(int) onIr;

  const PaginaResultado({
    super.key,
    required this.datos,
    required this.resultado,
    required this.cargando,
    required this.error,
    required this.onIr,
  });

  @override
  Widget build(BuildContext context) {
    final periodoLabel = {'mensual': 'Mensual', 'quincenal': 'Quincenal', 'semanal': 'Semanal', 'diario': 'Diario'};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: Column(
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.eco, color: verdeOscuro, size: 34),
                      SizedBox(width: 10),
                      Text('Tu Plan Byte&Bite',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(cargando ? 'Generando tu plan personalizado...' : 'Listo para consultar',
                      style: TextStyle(color: Colors.grey[500])),
                ],
              ),
              const SizedBox(height: 28),
              if (datos.presupuesto.isNotEmpty)
                Row(
                  children: [
                    Expanded(child: _Chip(valor: '\$${int.tryParse(datos.presupuesto) ?? datos.presupuesto}', etiq: periodoLabel[datos.periodo] ?? datos.periodo)),
                    const SizedBox(width: 12),
                    Expanded(child: _Chip(valor: '${datos.personas.length}', etiq: 'Personas')),
                    const SizedBox(width: 12),
                    Expanded(child: _Chip(valor: datos.tiendas.isNotEmpty ? '${datos.tiendas.length}' : '—', etiq: 'Tiendas')),
                  ],
                ),
              const SizedBox(height: 28),
              if (cargando)
                Column(
                  children: [
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 60, height: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: verdeOscuro,
                        backgroundColor: const Color(0xFFc8dcc0),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Cocinando tu plan...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Analizando presupuesto y necesidades nutricionales...', style: TextStyle(color: Colors.grey[500])),
                  ],
                ),
              if (error.isNotEmpty && !cargando)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFffebee),
                    border: Border.all(color: const Color(0xFFef9a9a)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(error, style: const TextStyle(color: Color(0xFFc62828), fontSize: 14)),
                ),
              if (resultado.isNotEmpty && !cargando)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFdddddd)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(resultado, style: const TextStyle(height: 1.8, fontSize: 15)),
                ),
              if (resultado.isNotEmpty && !cargando) ...[
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _BtnAccion(
                      icono: Icons.content_copy,
                      label: 'Copiar',
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: resultado));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Plan copiado al portapapeles')),
                        );
                      },
                    ),
                    _BtnAccion(icono: Icons.refresh, label: 'Nuevo plan', onTap: () => onIr(3)),
                    _BtnAccion(icono: Icons.home, label: 'Inicio', onTap: () => onIr(1)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String valor, etiq;
  const _Chip({required this.valor, required this.etiq});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFdddddd)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(valor, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: verdeOscuro)),
          const SizedBox(height: 3),
          Text(etiq, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }
}

class _BtnAccion extends StatelessWidget {
  final IconData icono;
  final String label;
  final VoidCallback onTap;
  const _BtnAccion({required this.icono, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icono, size: 17),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87,
        side: const BorderSide(color: Color(0xFFdddddd), width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}