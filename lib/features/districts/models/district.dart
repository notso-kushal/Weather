class District{
  const District({required this.districtId, required this.name, required this.altName, required this.longitude, required this.latitude, required this.headQuater});
  final int districtId;
  final String name;
  final String altName;
  final double longitude;
  final double latitude;
  final HeadQuater headQuater;
}

class HeadQuater{
  const HeadQuater({required this.name, required this.altName});
  final String name;
  final String altName;
}