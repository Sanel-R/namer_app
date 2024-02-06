import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 53, 52, 51)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  // Add the logic that will add faviourite words in a list.
  var favourites = <WordPair>[];

  void toggleFavorite() {
    if (favourites.contains(current)) {
      favourites.remove(current);
    } else {
      favourites.add(current);
    }
    // notify the states that have change notifier implemened.
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // define variables we wany to track.
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // navigate different pages.
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: false,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  // set the state, this call is similar to notify users.
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
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    Icon icon;
    if (appState.favourites.contains(pair)) {
      icon = Icon(
        Icons.favorite,
        color: Colors.pink,
        size: 24.0,
        semanticLabel: 'Text to announce in accessibility modes',
      );
    } else {
      icon = Icon(
        Icons.favorite_border,
        size: 24.0,
        semanticLabel: 'Text to announce in accessibility modes',
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: icon,
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
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
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimary, fontFamily: 'Raleway');

    return Card(
      color: theme.colorScheme.primary,
      elevation: 15,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(pair.asLowerCase,
            style: style, semanticsLabel: "${pair.first} ${pair.second}"),
      ),
    );
  }
}

class Favorite extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var listOfFavoriteWords = appState.favourites;

    return Scaffold(
        appBar: AppBar(
          title: Text('Favorite words'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add_alert),
              tooltip: 'Favorite Words',
              onPressed: () => print("Testing"),
            ),
          ],
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: listOfFavoriteWords.length,
          itemBuilder: (context, index) => Container(
            height: 25,
            color: const Color.fromARGB(255, 64, 255, 182),
            child: Text('$index. ${listOfFavoriteWords[index]}'),
          ),
        ));
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favourites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            'You have '
            '${appState.favourites.length} favorites:',
            style: TextStyle(
              fontSize: 20,
              color: Color.fromARGB(255, 155, 30, 167),
            ),
          ),
        ),
        for (var pair in appState.favourites)
          ListTile(
            leading: Icon(
              Icons.favorite,
              color: const Color.fromARGB(255, 240, 4, 82),
            ),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

// Class tp remove the content.
class RemoveFavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favoriteList = appState.favourites;
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimary, fontFamily: 'Raleway');

    Icon icon;
    if (appState.favourites.contains(appState.current)) {
      icon = Icon(
        Icons.delete_sweep,
        color: Colors.pink,
        size: 24.0,
        semanticLabel: 'Text to announce in accessibility modes',
      );
    } else {
      icon = Icon(
        Icons.arrow_forward,
        size: 24.0,
        semanticLabel: 'Text to announce in accessibility modes',
      );
    }

    return Center(
      child: Column(children: [
        Card(
          color: theme.colorScheme.primary,
          elevation: 15,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              pair.asLowerCase,
              style: style,
            ),
          ),
        )
      ]),
    );
  }
}
