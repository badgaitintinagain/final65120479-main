import 'dart:io';
import 'package:flutter/material.dart';
import 'package:final65120479/screens/land_use_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:final65120479/backbone/database_helper.dart';
import 'package:final65120479/backbone/model.dart';

class EditPlantScreen extends StatefulWidget {
  final Plant plant;

  const EditPlantScreen({Key? key, required this.plant}) : super(key: key);

  @override
  _EditPlantScreenState createState() => _EditPlantScreenState();
}

class _EditPlantScreenState extends State<EditPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _scientificNameController;
  File? _image;
  List<LandUse> _landUses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plant.plantName);
    _scientificNameController = TextEditingController(text: widget.plant.plantScientific);
    if (widget.plant.plantImage.isNotEmpty) {
      _image = File(widget.plant.plantImage);
    }
    _loadLandUses();
  }

  Future<void> _loadLandUses() async {
    final landUses = await DatabaseHelper().getLandUsesForPlant(widget.plant.plantID);
    setState(() {
      _landUses = landUses;
      _isLoading = false;
    });
  }

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
        title: const Text('Edit Plant'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Plant Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Plant Name',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _scientificNameController,
                        decoration: InputDecoration(
                          labelText: 'Scientific Name',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        validator: (value) => value!.isEmpty ? 'Please enter a scientific name' : null,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _getImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Change Image'),
                      ),
                      const SizedBox(height: 16),
                      if (_image != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_image!, height: 100, width: 100, fit: BoxFit.cover),
                        ),
                      const SizedBox(height: 16),
                      const Text('Land Uses:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ..._landUses.map((landUse) => LandUseEditTile(
                            landUse: landUse,
                            onUpdate: (updatedLandUse) {
                              setState(() {
                                final index = _landUses.indexWhere((lu) => lu.landUseID == updatedLandUse.landUseID);
                                if (index != -1) {
                                  _landUses[index] = updatedLandUse;
                                }
                              });
                            },
                            onDelete: () async {
                              await DatabaseHelper().deleteLandUse(landUse.landUseID);
                              setState(() {
                                _landUses.removeWhere((lu) => lu.landUseID == landUse.landUseID);
                              });
                            },
                          )),
                      ElevatedButton(
                        onPressed: () async {
                          final newLandUse = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddLandUseScreen(plantId: widget.plant.plantID)),
                          );
                          if (newLandUse != null) {
                            setState(() {
                              if (newLandUse is LandUse) {
                                _landUses.add(newLandUse);
                              }
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Add New Land Use'),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Update Plant'),
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
      if (_image == null && widget.plant.plantImage.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image')),
        );
        return;
      }

      String imagePath = widget.plant.plantImage;
      if (_image != null && _image!.path != widget.plant.plantImage) {
        final directory = await getApplicationDocumentsDirectory();
        final String fileName = path.basename(_image!.path);
        final String newPath = path.join(directory.path, fileName);
        await _image!.copy(newPath);
        imagePath = newPath;
      }

      final updatedPlant = Plant(
        plantID: widget.plant.plantID,
        plantName: _nameController.text,
        plantScientific: _scientificNameController.text,
        plantImage: imagePath,
      );

      final dbHelper = DatabaseHelper();
      await dbHelper.updatePlant(updatedPlant);

      for (var landUse in _landUses) {
        await dbHelper.updateLandUse(landUse);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plant and land uses updated successfully')),
      );

      Navigator.pop(context, true);
    }
  }
}

class LandUseEditTile extends StatefulWidget {
  final LandUse landUse;
  final Function(LandUse) onUpdate;
  final VoidCallback onDelete;

  const LandUseEditTile({
    Key? key,
    required this.landUse,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  _LandUseEditTileState createState() => _LandUseEditTileState();
}

class _LandUseEditTileState extends State<LandUseEditTile> {
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.landUse.landUseDescription);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${widget.landUse.landUseTypeName}'),
            Text('Component: ${widget.landUse.componentName}'),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              onChanged: (value) {
                final updatedLandUse = LandUse(
                  landUseID: widget.landUse.landUseID,
                  plantID: widget.landUse.plantID,
                  componentID: widget.landUse.componentID,
                  landUseTypeID: widget.landUse.landUseTypeID,
                  landUseDescription: value,
                  landUseTypeName: widget.landUse.landUseTypeName,
                  componentName: widget.landUse.componentName,
                  componentIcon: widget.landUse.componentIcon,
                  plantName: widget.landUse.plantName,
                  plantScientific: widget.landUse.plantScientific,
                  plantImage: widget.landUse.plantImage,
                );
                widget.onUpdate(updatedLandUse);
              },
            ),
            ElevatedButton(
              onPressed: widget.onDelete,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}
