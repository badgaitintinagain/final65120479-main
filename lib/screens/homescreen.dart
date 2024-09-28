import 'dart:io';
import 'package:flutter/material.dart';
import 'package:final65120479/backbone/database_helper.dart';
import 'package:final65120479/backbone/model.dart';
import 'package:final65120479/screens/plant_detail_screen.dart';
import 'package:final65120479/screens/add_plant_screen.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Plant>> _plantsFuture;
  late Future<List<Plant>> _randomPlantsFuture;
  bool _showAllPlants = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

 Future<void> _initializeDatabase() async {
    final dbHelper = DatabaseHelper();
    bool isDatabaseCreated = await dbHelper.isDatabaseCreated();

    if (!isDatabaseCreated) {
      // Database doesn't exist, create it
      await dbHelper.initDatabase();
    }

    // Database is now ready, load plants
    _refreshPlants();
  }

  void _refreshPlants() {
    setState(() {
      _isLoading = true;
    });
    _plantsFuture = DatabaseHelper().getPlants();
    _randomPlantsFuture = _getRandomPlants();
    _plantsFuture.then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<List<Plant>> _getRandomPlants() async {
    final dbHelper = DatabaseHelper();
    List<Plant> allPlants = await dbHelper.getPlants();
    allPlants.shuffle(Random());
    return allPlants.take(3).toList();
  }

  void _toggleAllPlants() {
    setState(() {
      _showAllPlants = !_showAllPlants;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plantipedia'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Random Plants',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                SizedBox(
                  height: 150,
                  child: FutureBuilder<List<Plant>>(
                    future: _randomPlantsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No plants available'));
                      } else {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final plant = snapshot.data![index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlantDetailScreen(plant: plant),
                                  ),
                                );
                              },
                              child: Card(
                                margin: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 120,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      plant.plantImage.startsWith('assets/')
                                          ? Image.asset(plant.plantImage, height: 80, width: 120, fit: BoxFit.cover)
                                          : Image.file(File(plant.plantImage), height: 80, width: 120, fit: BoxFit.cover),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          plant.plantName,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    'All Plants',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  trailing: IconButton(
                    icon: Icon(_showAllPlants ? Icons.expand_less : Icons.expand_more),
                    onPressed: _toggleAllPlants,
                  ),
                ),
                if (_showAllPlants)
                  Expanded(
                    child: PlantsList(plantsFuture: _plantsFuture),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPlantScreen()),
          );
          if (result == true) {
            _refreshPlants();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// PlantsList and PlantListTile classes remain unchanged


class PlantsList extends StatelessWidget {
  final Future<List<Plant>> plantsFuture;

  const PlantsList({super.key, required this.plantsFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Plant>>(
      future: plantsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No plants found'));
        } else {
          return ListView.separated(
            itemCount: snapshot.data!.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final plant = snapshot.data![index];
              return PlantListTile(plant: plant);
            },
          );
        }
      },
    );
  }
}

class PlantListTile extends StatelessWidget {
  final Plant plant;

  const PlantListTile({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        plant.plantName,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        plant.plantScientific,
        style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Color(0xFF54595D)),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFFA2A9B1)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantDetailScreen(plant: plant),
          ),
        );
      },
    );
  }
}