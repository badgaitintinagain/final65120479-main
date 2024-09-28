import 'dart:io';
import 'package:flutter/material.dart';
import 'package:final65120479/backbone/model.dart';
import 'package:final65120479/backbone/database_helper.dart';
import 'package:final65120479/screens/edit_plant_screen.dart';

class PlantDetailScreen extends StatefulWidget {
  final int plantId;

  const PlantDetailScreen({super.key, required this.plantId});

  @override
  _PlantDetailScreenState createState() => _PlantDetailScreenState();
}


class _PlantDetailScreenState extends State<PlantDetailScreen> {
  Plant _plant = Plant(plantID: 0, plantName: '', plantScientific: '', plantImage: '');
  late Future<List<LandUse>> _landUsesFuture = Future.value([]);

  @override
  void initState() {
    super.initState();
    _landUsesFuture = Future.value([]); // Initialize with an empty list
    _loadPlant();
  }

  Future<void> _loadPlant() async {
    final plant = await DatabaseHelper().getPlantById(widget.plantId);
    setState(() {
      _plant = plant;
      _loadLandUses();
    });
  }

  void _loadLandUses() {
    _landUsesFuture = DatabaseHelper().getLandUsesForPlant(_plant.plantID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_plant.plantName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editPlant(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlantDetailContent(plant: _plant),
            const SizedBox(height: 16),
            LandUseSection(landUsesFuture: _landUsesFuture),
          ],
        ),
      ),
    );
  }

  Future<void> _editPlant(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPlantScreen(plant: _plant),
      ),
    );
    if (result == true) {
      final updatedPlant = await DatabaseHelper().getPlantById(_plant.plantID);
      setState(() {
        _plant = updatedPlant;
        _loadLandUses();
      });
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Plant'),
          content: Text('Are you sure you want to delete ${_plant.plantName}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                await _deletePlant(context);
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(true); // Return to previous screen with refresh flag
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePlant(BuildContext context) async {
    try {
      final dbHelper = DatabaseHelper();
      await dbHelper.deletePlant(_plant.plantID);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_plant.plantName} has been deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting plant: $e')),
      );
    }
  }
}

class PlantDetailContent extends StatelessWidget {
  final Plant plant;

  const PlantDetailContent({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (plant.plantImage.isNotEmpty) PlantImage(imagePath: plant.plantImage),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plant.plantName,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                plant.plantScientific,
                style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Color(0xFF54595D)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PlantImage extends StatelessWidget {
  final String imagePath;

  const PlantImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: imagePath.startsWith('assets/')
          ? Image.asset(
              imagePath,
              fit: BoxFit.cover,
            )
          : Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Text('Error loading image'));
              },
            ),
    );
  }
}

class LandUseSection extends StatelessWidget {
  final Future<List<LandUse>> landUsesFuture;

  const LandUseSection({super.key, required this.landUsesFuture});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Land Uses',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<LandUse>>(
            future: landUsesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No land uses found for this plant.'));
              } else {
                return Column(
                  children: snapshot.data!.map((landUse) => LandUseCard(landUse: landUse)).toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class LandUseCard extends StatelessWidget {
  final LandUse landUse;

  const LandUseCard({super.key, required this.landUse});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(landUse.componentIcon ?? 'assets/default_icon.png'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    landUse.landUseTypeName ?? 'Unknown',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Component: ${landUse.componentName}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF54595D)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    landUse.landUseDescription,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}