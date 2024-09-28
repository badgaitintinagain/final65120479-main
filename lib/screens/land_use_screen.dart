import 'package:flutter/material.dart';
import 'package:final65120479/backbone/database_helper.dart';
import 'package:final65120479/backbone/model.dart';

class AddLandUseScreen extends StatefulWidget {
  final int plantId;

  const AddLandUseScreen({super.key, required this.plantId});

  @override
  _AddLandUseScreenState createState() => _AddLandUseScreenState();
}

class _AddLandUseScreenState extends State<AddLandUseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  int? _selectedComponentId;
  int? _selectedLandUseTypeId;

  late Future<List<PlantComponent>> _componentsFuture;
  late Future<List<LandUseType>> _landUseTypesFuture;

  @override
  void initState() {
    super.initState();
    _componentsFuture = DatabaseHelper().getPlantComponents();
    _landUseTypesFuture = DatabaseHelper().getLandUseTypes();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Land Use'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown for selecting Plant Components
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
                      decoration: const InputDecoration(labelText: 'Plant Component'),
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
                      validator: (value) => value == null ? 'Please select a component' : null,
                    );
                  }
                },
              ),
              const SizedBox(height: 16),

              // Dropdown for selecting Land Use Types
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
                      decoration: const InputDecoration(labelText: 'Land Use Type'),
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
                      validator: (value) => value == null ? 'Please select a land use type' : null,
                    );
                  }
                },
              ),
              const SizedBox(height: 16),

              // Text field for description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Button to submit the form
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Land Use'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
  if (_formKey.currentState!.validate()) {
    final landUse = LandUse(
      landUseID: 0,
      plantID: widget.plantId,
      componentID: _selectedComponentId!,
      landUseTypeID: _selectedLandUseTypeId!,
      landUseDescription: _descriptionController.text,
      componentName: '', // Will be filled after insertion
      landUseTypeName: '', // Will be filled after insertion
      componentIcon: '', // Will be filled after insertion
    );

    try {
      final dbHelper = DatabaseHelper();
      await dbHelper.insertLandUse(landUse);

      // Fetch the component and land use type names from the database
      final component = await dbHelper.getPlantComponents();
      final landUseType = await dbHelper.getLandUseTypes();

      landUse.componentName = component.firstWhere((c) => c.componentID == landUse.componentID).componentName!;
      landUse.landUseTypeName = landUseType.firstWhere((type) => type.landUseTypeID == landUse.landUseTypeID).landUseTypeName;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Land use added successfully')),
      );

      Navigator.pop(context, landUse); // Pass back the new land use
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding land use: $e')),
      );
    }
  }
}

}
