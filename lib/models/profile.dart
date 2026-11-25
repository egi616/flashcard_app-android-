class Profile {
  Profile({
    this.id,
    required this.name,
    required this.nim,
    required this.imageAsset,
    this.aboutme
  });
  
  final String name;
  final String nim;
  final String imageAsset;
  final String? aboutme;
  final int? id;

  static final List<Profile> profiles = [
    Profile(
      id: 1,
      name: 'Egi Jaelani Febriansyah',
      nim: '5520124039',
      imageAsset: 'assets/images/male.jpg',
      aboutme : 'Hello perkenalkan saya disini berperan sebagai penulis kode.'
    ),
    Profile(
      id: 2,
      name: 'Ghany Al-Adiat',
      nim: '5520124040',
      imageAsset: 'assets/images/male2.jpg',
      aboutme : 'Hello perkenalkan saya disini berperan sebagai penyusun power point.'
    ),
    Profile(
      id: 3,
      name: 'M Daud Wafdulloh',
      nim: '5520124042',
      imageAsset: 'assets/images/male1.jpg',
      aboutme : 'Hello perkenalkan saya disini berperan sebagai perancang desain.'
    ),
    Profile(
      id: 4,
      name: 'Maula Fajarina',
      nim: '5520124047',
      imageAsset: 'assets/images/female.jpg',
      aboutme : 'Hello perkenalkan saya disini berperan sebagai penulis laporan.'
    ),
  ];
}
