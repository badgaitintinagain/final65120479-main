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
  final String landUseTypeName;
  final String componentName;
  final String componentIcon; 

  LandUse({
    required this.landUseID,
    required this.plantID,
    required this.componentID,
    required this.landUseTypeID,
    required this.landUseDescription,
    required this.landUseTypeName,
    required this.componentName,
    required this.componentIcon,
  });

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
    };
  }
}