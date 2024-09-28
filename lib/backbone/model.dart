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

  // Non-final properties
  String? componentName;
  String? landUseTypeName;
  String? componentIcon;

  // New properties for plant details
  String? plantName;          
  String? plantScientific;    
  String? plantImage;         

  LandUse({
    required this.landUseID,
    required this.plantID,
    required this.componentID,
    required this.landUseTypeID,
    required this.landUseDescription,
    this.componentName,
    this.landUseTypeName,
    this.componentIcon,
    this.plantName,
    this.plantScientific,
    this.plantImage,
  });

  LandUse copyWith({
    int? landUseID,
    int? plantID,
    int? componentID,
    int? landUseTypeID,
    String? landUseDescription,
    String? componentName,
    String? landUseTypeName,
    String? componentIcon,
    String? plantName,
    String? plantScientific,
    String? plantImage,
  }) {
    return LandUse(
      landUseID: landUseID ?? this.landUseID,
      plantID: plantID ?? this.plantID,
      componentID: componentID ?? this.componentID,
      landUseTypeID: landUseTypeID ?? this.landUseTypeID,
      landUseDescription: landUseDescription ?? this.landUseDescription,
      componentName: componentName ?? this.componentName,
      landUseTypeName: landUseTypeName ?? this.landUseTypeName,
      componentIcon: componentIcon ?? this.componentIcon,
      plantName: plantName ?? this.plantName,
      plantScientific: plantScientific ?? this.plantScientific,
      plantImage: plantImage ?? this.plantImage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'landUseID': landUseID,
      'plantID': plantID,
      'componentID': componentID,
      'landUseTypeID': landUseTypeID,
      'landUseDescription': landUseDescription,
      'componentName': componentName,
      'landUseTypeName': landUseTypeName,
      'componentIcon': componentIcon,
      'plantName': plantName,
      'plantScientific': plantScientific,
      'plantImage': plantImage,
    };
  }
}
