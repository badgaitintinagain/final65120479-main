import 'dart:io';
import 'package:flutter/material.dart';
import 'package:final65120479/screens/land_use_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:final65120479/backbone/database_helper.dart';
import 'package:final65120479/backbone/model.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({Key? key}) : super(key: key);

  @override
  _AddPlantScreenState createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _scientificNameController = TextEditingController();
  File? _image;
  final List<LandUse> _landUses = [];

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
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter Plant Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Plant Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.green),
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter the plant name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _scientificNameController,
                  decoration: InputDecoration(
                    labelText: 'Scientific Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.green),
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter the scientific name' : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _getImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Select Image'),
                ),
                const SizedBox(height: 16),
                if (_image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_image!, height: 100, width: 100, fit: BoxFit.cover),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final newLandUse = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddLandUseScreen(plantId: 0)),
                    );
                    if (newLandUse != null && newLandUse is LandUse) {
                      setState(() {
                        _landUses.add(newLandUse);
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Add New Land Use'),
                ),
                const SizedBox(height: 16),
                const Text('Added Land Uses:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._landUses.map((landUse) {
                  print('Land Use: ${landUse.landUseTypeName}, Icon: ${landUse.componentIcon}'); // Debug line
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: _getComponentIcon(landUse.componentIcon),
                            backgroundColor: Colors.grey[200],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  landUse.landUseTypeName ?? 'Unknown',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Component: ${landUse.componentName ?? 'N/A'}',
                                  style: const TextStyle(color: Color(0xFF54595D)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Description: ${landUse.landUseDescription}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Add Plant'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ImageProvider<Object> _getComponentIcon(String? iconPath) {
    if (iconPath != null && iconPath.isNotEmpty) {
      return AssetImage(iconPath);
    } else {
      return const AssetImage('assets/images/icons/default_icon.png'); // Ensure this path exists
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_image == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an image')));
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

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plant and land uses added successfully')));
          Navigator.pop(context, true);
        } else {
          throw Exception('Failed to insert plant');
        }
      } catch (e) {
        print('Error adding plant: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding plant: $e')));
      }
    }
  }
}
