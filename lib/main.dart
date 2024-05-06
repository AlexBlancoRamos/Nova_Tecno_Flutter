import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  runApp(MyApp());
}


//Empieza el codigo como en Angular configurando la pagina principal(*)


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Compra App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

//Aqui empieza la aplicacion como tal con las variables, listas y funciones necesarias

class MyAppState extends ChangeNotifier {
  MyAppState() {
    _loadFavorites(); 
    _loadItemQuantities();
  }
  var current = 0; 
  final List<String> wordList = [
  'Arroz',  'Pasta',  'Aceite de girasol',  'Sal',  'Azúcar',  'Harina',  'Leche',  'Huevos',  'Pan',  'Galletas',  'Café',
  'Té',  'Sopa',  'Verduras',  'Frutas',  'Carne',  'Pollo',  'Pescado',  'Jamón',  'Queso',  'Yogur',  'Mantequilla',
  'Mermelada',  'Salsa de tomate',  'Salsa de soja',  'Vinagre',  'Mostaza',  'Mayonesa',  'Ketchup',  'Papas',  'Cebollas',  'Ajos',
  'Zanahorias',  'Tomates',  'Pepinos',  'Lechuga',  'Espinacas',  'Avena',  'Nueces',  'Almendras',  'Cacahuetes',  'Mantequilla de maní',
  'Aceitunas',  'Natillas',  'Aceite de oliva',  'Vinagre balsámico',  'Pimienta',  'Especies',  'Condimentos',  'Pimientos',
  'Champiñones',  'Pan rallado',  'Levadura',  'Bicarbonato de sodio',  'Esponjas',  'Detergente para ropa',  'Suavizante de telas',
  'Limpiador multiusos',  'Papel higiénico',  'Toallas de papel',  'Servilletas de papel',  'Aluminio',  'Papel de aluminio',  'Film transparente',
  'Bolsas de basura',  'Recipientes de almacenamiento',  'Bolsas de congelación',  'Bolsas de patatas fritas',  'Botellas de agua',
  'Refrescos',  'Cerveza',  'Vino',  'Zumos',  'Cajas de cereales',  'Bolsas de congelación',  'Recipientes de almacenamiento',  'Bolsas de basura',
];

Map<String, int> itemQuantities = {};

//Aqui tengo definidas algunas funciones tales como (Guardar favoritos, guardar cantidad del producto, incrementa cantidad y disminuir cantidad)

Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', favorites);
  }

 Future<void> saveItemQuantities() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = json.encode(itemQuantities);
  await prefs.setString('itemQuantities', jsonString);
}

  void increaseQuantity(String word) {
    if (itemQuantities.containsKey(word)) {
      itemQuantities[word] = itemQuantities[word]! + 1;
    } else {
      itemQuantities[word] = 1;
    }
    saveFavorites();
    saveItemQuantities();
    notifyListeners();
  }

  void decreaseQuantity(String word) {
    if (itemQuantities.containsKey(word) && itemQuantities[word]! > 1) {
      itemQuantities[word] = itemQuantities[word]! - 1;
      saveFavorites();
      saveItemQuantities();
      notifyListeners();
    } else if (itemQuantities.containsKey(word) && itemQuantities[word]! == 1) {
      itemQuantities.remove(word);
      saveFavorites();
      saveItemQuantities();
      notifyListeners();
    }
  }

  int getQuantity(String word) {
    return itemQuantities[word] ?? 0;
  }

  var favorites = <String>[];

  void getNext() {
    final random = Random();
    current = random.nextInt(wordList.length);
    notifyListeners();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteList = prefs.getStringList('favorites') ?? [];
    favorites = favoriteList;
    notifyListeners();
  }

  Future<void> _loadItemQuantities() async {
  final prefs = await SharedPreferences.getInstance();
  final itemQuantitiesMap = prefs.getString('itemQuantities');
  if (itemQuantitiesMap != null) {
    final Map<String, dynamic> parsedMap = json.decode(itemQuantitiesMap);
    itemQuantities = parsedMap.map((key, value) => MapEntry(key, value as int));
  }
  notifyListeners();
}

  void toggleFavorite(String word) {
    if (favorites.contains(word)) {
      favorites.remove(word);
      itemQuantities.remove(word);
    } else {
      favorites.add(word);
      itemQuantities.putIfAbsent(word, () => 1);
    }
    saveFavorites(); 
    saveItemQuantities(); 
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


//Aqui empieza el Layout del menu de navegacion 


class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
  case 0:
    page = GeneratorPage();
    break;
  case 1:
    page = FavoritesPage();
    break;
  default:
    throw UnimplementedError('no widget for $selectedIndex');
}
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Articulos'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.shopping_cart),
                      label: Text('Comprar'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}


//Layout de la pagina de compra 


class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No hay nada para comprar aún.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Hay ${appState.favorites.length} artículos para comprar:'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: appState.favorites.length,
            itemBuilder: (context, index) {
              final word = appState.favorites[index];
              return ListTile(
                leading: Icon(Icons.circle,
                  size: 12, 
                  color: Colors.grey, 
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(word),
                    ),
                    QuantitySelector(appState: appState, word: word), 
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    appState.toggleFavorite(word);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$word ha sido eliminado de la lista de la compra.')),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


//Clase para crear la seleccion de cantidad


class QuantitySelector extends StatelessWidget {
  final MyAppState appState;
  final String word;

  QuantitySelector({required this.appState, required this.word});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: () {
            appState.decreaseQuantity(word);
          },
        ),
        Consumer<MyAppState>(
          builder: (context, appState, child) {
            final quantity = appState.getQuantity(word);
            return Text(
              '$quantity', 
              style: TextStyle(fontSize: 16),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            appState.increaseQuantity(word);
          },
        ),
      ],
    );
  }
}

//Esta es la clase para el layout y el funcionamiento de la pagina principal

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var word = appState.wordList[appState.current];

    IconData icon;
    if (appState.favorites.contains(word)) {
      icon = Icons.shopping_cart;
    } else {
      icon = Icons.shopping_cart;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(word: word),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite(word);
                  final message = appState.favorites.contains(word)
                      ? '$word ha sido añadido a la lista de la compra.'
                      : '$word ha sido eliminado de la lista de compra.';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                },
                icon: Icon(icon),
                label: Text('Comprar'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Siguiente'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.word,
  }) : super(key: key);

  final String word;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          word,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}