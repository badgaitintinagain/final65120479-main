import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:final65120479/backbone/model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

   Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'plants.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<bool> isDatabaseCreated() async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
      return tables.isNotEmpty;
    } catch (e) {
      print('Error checking database: $e');
      return false;
    }
  }

  Future<void> initDatabase() async {
    if (!await isDatabaseCreated()) {
      Database db = await database;
      await _onCreate(db, 2);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE plant (
        plantID INTEGER PRIMARY KEY,
        plantName TEXT NOT NULL,
        plantScientific TEXT NOT NULL,
        plantImage TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE plantComponent (
        componentID INTEGER PRIMARY KEY,
        componentName TEXT NOT NULL,
        componentIcon TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE LandUseType (
        landUseTypeID INTEGER PRIMARY KEY,
        landUseTypeName TEXT NOT NULL,
        landUseTypeDescription TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE LandUse (
        landUseID INTEGER PRIMARY KEY,
        plantID INTEGER NOT NULL,
        componentID INTEGER NOT NULL,
        landUseTypeID INTEGER NOT NULL,
        landUseDescription TEXT NOT NULL,
        FOREIGN KEY (plantID) REFERENCES plant (plantID),
        FOREIGN KEY (componentID) REFERENCES plantComponent (componentID),
        FOREIGN KEY (landUseTypeID) REFERENCES LandUseType (landUseTypeID)
      )
    ''');

    await _insertInitialData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
   
    }
  }

  Future<void> _insertInitialData(Database db) async {
    await db.insert('plant', Plant(plantID: 1001, plantName: 'Mango', plantScientific: 'Mangifera indica', plantImage: 'assets/images/plants/mango.jpg').toMap());
    await db.insert('plant', Plant(plantID: 1002, plantName: 'Neem', plantScientific: 'Azadirachta indica', plantImage: 'assets/images/plants/neem.jpg').toMap());
    await db.insert('plant', Plant(plantID: 1003, plantName: 'Bamboo', plantScientific: 'Bambusa vulgaris', plantImage: 'assets/images/plants/bamboo.jpg').toMap());
    await db.insert('plant', Plant(plantID: 1004, plantName: 'Ginger', plantScientific: 'Zingiber officinale', plantImage: 'assets/images/plants/ginger.jpg').toMap());

    await db.insert('plantComponent', PlantComponent(componentID: 1101, componentName: 'Leaf', componentIcon: 'assets/images/icons/leaf_icon.jpg').toMap());
    await db.insert('plantComponent', PlantComponent(componentID: 1102, componentName: 'Flower', componentIcon: 'assets/images/icons/flower_icon.jpg').toMap());
    await db.insert('plantComponent', PlantComponent(componentID: 1103, componentName: 'Fruit', componentIcon: 'assets/images/icons/fruit_icon.jpg').toMap());
    await db.insert('plantComponent', PlantComponent(componentID: 1104, componentName: 'Stem', componentIcon: 'assets/images/icons/stem_icon.jpg').toMap());
    await db.insert('plantComponent', PlantComponent(componentID: 1105, componentName: 'Root', componentIcon: 'assets/images/icons/root_icon.jpg').toMap());

    await db.insert('LandUseType', LandUseType(landUseTypeID: 1301, landUseTypeName: 'Food', landUseTypeDescription: 'Used as food or ingredients').toMap());
    await db.insert('LandUseType', LandUseType(landUseTypeID: 1302, landUseTypeName: 'Medicine', landUseTypeDescription: 'Used for medicinal purposes').toMap());
    await db.insert('LandUseType', LandUseType(landUseTypeID: 1303, landUseTypeName: 'Insecticide', landUseTypeDescription: 'Used to repel insects').toMap());
    await db.insert('LandUseType', LandUseType(landUseTypeID: 1304, landUseTypeName: 'Construction', landUseTypeDescription: 'Used in building materials').toMap());
    await db.insert('LandUseType', LandUseType(landUseTypeID: 1305, landUseTypeName: 'Culture', landUseTypeDescription: 'Used in traditional practices').toMap());

    await db.insert('LandUse', {
      'landUseID': 2001,
      'plantID': 1001,
      'componentID': 1103,
      'landUseTypeID': 1301,
      'landUseDescription': 'Mango fruit is eaten fresh or dried'
    });
    await db.insert('LandUse', {
      'landUseID': 2002,
      'plantID': 1002,
      'componentID': 1101,
      'landUseTypeID': 1302,
      'landUseDescription': 'Neem leaves are used to treat skin infections'
    });
    await db.insert('LandUse', {
      'landUseID': 2003,
      'plantID': 1003,
      'componentID': 1104,
      'landUseTypeID': 1304,
      'landUseDescription': 'Bamboo stems are used in building houses'
    });
    await db.insert('LandUse', {
      'landUseID': 2004,
      'plantID': 1004,
      'componentID': 1105,
      'landUseTypeID': 1302,
      'landUseDescription': 'Ginger roots are used for digestive issues'
    });
  }

  Future<List<Plant>> getPlants() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('plant');
    return List.generate(maps.length, (i) {
      return Plant(
        plantID: maps[i]['plantID'],
        plantName: maps[i]['plantName'],
        plantScientific: maps[i]['plantScientific'],
        plantImage: maps[i]['plantImage'],
      );
    });
  }

  Future<List<LandUse>> getLandUsesForPlant(int plantId) async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT 
      LandUse.*,
      LandUseType.landUseTypeName,
      plantComponent.componentName,
      plantComponent.componentIcon
    FROM LandUse
    JOIN LandUseType ON LandUse.landUseTypeID = LandUseType.landUseTypeID
    JOIN plantComponent ON LandUse.componentID = plantComponent.componentID
    WHERE LandUse.plantID = ?
  ''', [plantId]);

  return List.generate(maps.length, (i) {
    return LandUse(
      landUseID: maps[i]['landUseID'],
      plantID: maps[i]['plantID'],
      componentID: maps[i]['componentID'],
      landUseTypeID: maps[i]['landUseTypeID'],
      landUseDescription: maps[i]['landUseDescription'],
      landUseTypeName: maps[i]['landUseTypeName'],
      componentName: maps[i]['componentName'],
      componentIcon: maps[i]['componentIcon'], // Add this line
    );
  });
}

    Future<List<LandUseType>> getLandUseTypes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('LandUseType');
    return List.generate(maps.length, (i) {
      return LandUseType(
        landUseTypeID: maps[i]['landUseTypeID'],
        landUseTypeName: maps[i]['landUseTypeName'],
        landUseTypeDescription: maps[i]['landUseTypeDescription'],
      );
    });
  }

Future<int> insertPlant(Plant plant) async {
  final db = await database;
  return await db.insert(
    'plant',
    plant.toMap()..remove('plantID'),  // Remove plantID to let SQLite auto-increment
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

  Future<int> insertLandUse(LandUse landUse) async {
    final db = await database;
    return await db.insert(
      'LandUse',
      {
        'plantID': landUse.plantID,
        'componentID': landUse.componentID,
        'landUseTypeID': landUse.landUseTypeID,
        'landUseDescription': landUse.landUseDescription,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

   Future<void> deletePlant(int plantId) async {
    final db = await database;
    await db.transaction((txn) async {
      // Delete related land uses first
      await txn.delete(
        'LandUse',
        where: 'plantID = ?',
        whereArgs: [plantId],
      );
      // Then delete the plant
      await txn.delete(
        'plant',
        where: 'plantID = ?',
        whereArgs: [plantId],
      );
    });
  }

  Future<void> updatePlant(Plant plant) async {
  final db = await database;
  await db.update(
    'plant',
    plant.toMap(),
    where: 'plantID = ?',
    whereArgs: [plant.plantID],
  );
}

Future<Plant> getPlantById(int plantId) async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query(
    'plant',
    where: 'plantID = ?',
    whereArgs: [plantId],
  );

  if (maps.isNotEmpty) {
    return Plant(
      plantID: maps[0]['plantID'],
      plantName: maps[0]['plantName'],
      plantScientific: maps[0]['plantScientific'],
      plantImage: maps[0]['plantImage'],
    );
  } else {
    throw Exception('Plant not found');
  }
}

}