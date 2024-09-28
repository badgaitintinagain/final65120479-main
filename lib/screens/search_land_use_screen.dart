import 'dart:io';

import 'package:flutter/material.dart';
import 'package:final65120479/backbone/database_helper.dart';
import 'package:final65120479/backbone/model.dart';
import 'package:final65120479/screens/plant_detail_screen.dart'; // Import the plant detail screen

class SearchLandUseScreen extends StatefulWidget {
  const SearchLandUseScreen({Key? key}) : super(key: key);

  @override
  _SearchLandUseScreenState createState() => _SearchLandUseScreenState();
}

class _SearchLandUseScreenState extends State<SearchLandUseScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _plantName;
  int? _selectedComponentId;
  int? _selectedLandUseTypeId;

  late Future<List<PlantComponent>> _componentsFuture;
  late Future<List<LandUseType>> _landUseTypesFuture;
  late Future<List<LandUse>> _searchResultsFuture;

  @override
  void initState() {
    super.initState();
    _componentsFuture = DatabaseHelper().getPlantComponents();
    _landUseTypesFuture = DatabaseHelper().getLandUseTypes();
    _searchResultsFuture = Future.value([]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Land Use'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Plant Name (optional)'),
                onChanged: (value) {
                  _plantName = value.isNotEmpty ? value : null; // Allow empty input
                },
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<PlantComponent>>(
                future: _componentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No plant components available');
                  } else {
                    return DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Plant Component (optional)'),
                      value: _selectedComponentId,
                      items: snapshot.data!.map((component) {
                        return DropdownMenuItem<int>(
                          value: component.componentID,
                          child: Text(component.componentName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedComponentId = value;
                        });
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<LandUseType>>(
                future: _landUseTypesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No land use types available');
                  } else {
                    return DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Land Use Type (optional)'),
                      value: _selectedLandUseTypeId,
                      items: snapshot.data!.map((type) {
                        return DropdownMenuItem<int>(
                          value: type.landUseTypeID,
                          child: Text(type.landUseTypeName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLandUseTypeId = value;
                        });
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitSearch,
                child: const Text('Search'),
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<LandUse>>(
                future: _searchResultsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No results found'));
                  } else {
                    return Expanded(
                      child: ListView.separated(
                        itemCount: snapshot.data!.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final landUse = snapshot.data![index];
                          return ListTile(
                            leading: _buildImage(landUse.plantImage ?? ''), // Display image as icon
                            title: Text(landUse.plantName ?? 'Unknown'),
                            subtitle: Text('Land use: ${landUse.landUseTypeName}\nComponent: ${landUse.componentName}\nDescription: ${landUse.landUseDescription}'),
                            onTap: () {
                              // Navigate to plant details when tapped
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlantDetailScreen(plantId: landUse.plantID),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        height: 40, // Small icon size
        width: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 40),
      );
    } else if (File(imagePath).existsSync()) {
      return Image.file(
        File(imagePath),
        height: 40, // Small icon size
        width: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 40),
      );
    } else {
      return const Icon(Icons.image_not_supported, size: 40);
    }
  }

  Future<void> _submitSearch() async {
    if (_formKey.currentState!.validate()) {
      _searchResultsFuture = DatabaseHelper().searchLandUses(
        plantName: _plantName,
        componentID: _selectedComponentId,
        landUseTypeID: _selectedLandUseTypeId,
      );
      setState(() {}); // Refresh the UI to show search results
    }
  }
}
