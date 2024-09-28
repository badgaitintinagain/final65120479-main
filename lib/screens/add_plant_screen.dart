import 'dart:io';
import 'package:final65120479/screens/land_use_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:final65120479/backbone/database_helper.dart';
import 'package:final65120479/backbone/model.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  _AddPlantScreenState createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _scientificNameController = TextEditingController();
  File? _image;
  List<LandUse> _landUses = [];

  @override
  void dispose() {
    _nameController.dispose();
    _scientificNameController.dispose();
    super.dispose();
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Plant'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Plant Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the plant name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _scientificNameController,
                  decoration: const InputDecoration(
                    labelText: 'Scientific Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the scientific name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _getImage,
                  child: const Text('Select Image'),
                ),
                if (_image != null)
                  Image.file(_image!, height: 100, width: 100, fit: BoxFit.cover),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final newLandUse = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddLandUseScreen(plantId: 0)),
                    );
                    if (newLandUse != null && newLandUse is LandUse) {
                      setState(() {
                        _landUses.add(newLandUse); // Immediately add the new land use
                      });
                    }
                  },
                  child: const Text('Add New Land Use'),
                ),
                const SizedBox(height: 16),
                // Display added land uses
                const Text('Added Land Uses:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._landUses.map((landUse) => ListTile(
                  title: Text(landUse.landUseTypeName ?? 'Unknown'),
                  subtitle: Text('Description: ${landUse.landUseDescription}'),
                )),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Add Plant'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image')),
        );
        return;
      }

      try {
        final directory = await getApplicationDocumentsDirectory();
        final String fileName = path.basename(_image!.path);
        final String newPath = path.join(directory.path, fileName);
        await _image!.copy(newPath);

        final newPlant = Plant(
          plantID: 0,
          plantName: _nameController.text,
          plantScientific: _scientificNameController.text,
          plantImage: newPath,
        );

        final dbHelper = DatabaseHelper();
        final plantId = await dbHelper.insertPlant(newPlant);

        if (plantId > 0) {
          for (var landUse in _landUses) {
            final newLandUse = landUse.copyWith(plantID: plantId);
            await dbHelper.insertLandUse(newLandUse);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Plant and land uses added successfully')),
          );
          Navigator.pop(context, true);
        } else {
          throw Exception('Failed to insert plant');
        }
      } catch (e) {
        print('Error adding plant: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding plant: $e')),
        );
      }
    }
  }
}
