class Plant {
  final int plantID;
  final String plantName;
  final String plantScientific;
  final String plantImage;

  Plant({required this.plantID, required this.plantName, required this.plantScientific, required this.plantImage});

  Map<String, dynamic> toMap() {
    return {
      'plantID': plantID,
      'plantName': plantName,
      'plantScientific': plantScientific,
      'plantImage': plantImage,
    };
  }
}

class PlantComponent {
  final int componentID;
  final String componentName;
  final String componentIcon;

  PlantComponent({required this.componentID, required this.componentName, required this.componentIcon});

  Map<String, dynamic> toMap() {
    return {
      'componentID': componentID,
      'componentName': componentName,
      'componentIcon': componentIcon,
    };
  }
}

class LandUseType {
  final int landUseTypeID;
  final String landUseTypeName;
  final String landUseTypeDescription;

  LandUseType({required this.landUseTypeID, required this.landUseTypeName, required this.landUseTypeDescription});

  Map<String, dynamic> toMap() {
    return {
      'landUseTypeID': landUseTypeID,
      'landUseTypeName': landUseTypeName,
      'landUseTypeDescription': landUseTypeDescription,
    };
  }
}

class LandUse {
  final int landUseID;
  final int plantID;
  final int componentID;
  final int landUseTypeID;
  final String landUseDescription;
  final String? landUseTypeName; // เปลี่ยนเป็น nullable
  final String? componentName; // เปลี่ยนเป็น nullable
  final String? componentIcon; // เปลี่ยนเป็น nullable
  final String? plantName; // เปลี่ยนเป็น nullable
  final String? plantScientific; // เปลี่ยนเป็น nullable
  final String? plantImage; // เปลี่ยนเป็น nullable

  LandUse({
    required this.landUseID,
    required this.plantID,
    required this.componentID,
    required this.landUseTypeID,
    required this.landUseDescription,
    this.landUseTypeName, // ไม่ต้องใส่ required
    this.componentName, // ไม่ต้องใส่ required
    this.componentIcon, // ไม่ต้องใส่ required
    this.plantName, // ไม่ต้องใส่ required
    this.plantScientific, // ไม่ต้องใส่ required
    this.plantImage, // ไม่ต้องใส่ required
  });

  LandUse copyWith({
    int? landUseID,
    int? plantID,
    int? componentID,
    int? landUseTypeID,
    String? landUseDescription,
    String? landUseTypeName,
    String? componentName,
    String? componentIcon,
    String? plantName,           // Add plantName to copyWith
    String? plantScientific,     // Add plantScientific to copyWith
    String? plantImage,          // Add plantImage to copyWith
  }) {
    return LandUse(
      landUseID: landUseID ?? this.landUseID,
      plantID: plantID ?? this.plantID,
      componentID: componentID ?? this.componentID,
      landUseTypeID: landUseTypeID ?? this.landUseTypeID,
      landUseDescription: landUseDescription ?? this.landUseDescription,
      landUseTypeName: landUseTypeName ?? this.landUseTypeName,
      componentName: componentName ?? this.componentName,
      componentIcon: componentIcon ?? this.componentIcon,
      plantName: plantName ?? this.plantName,          // Copy plantName
      plantScientific: plantScientific ?? this.plantScientific,  // Copy plantScientific
      plantImage: plantImage ?? this.plantImage,       // Copy plantImage
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'landUseID': landUseID,
      'plantID': plantID,
      'componentID': componentID,
      'landUseTypeID': landUseTypeID,
      'landUseDescription': landUseDescription,
      'landUseTypeName': landUseTypeName,
      'componentName': componentName,
      'componentIcon': componentIcon,
      'plantName': plantName,        // Include plantName in the map
      'plantScientific': plantScientific,  // Include plantScientific in the map
      'plantImage': plantImage,      // Include plantImage in the map
    };
  }
}
