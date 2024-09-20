class GuestModel {
  String name;
  String email;
  String mobile;
  String profilePictureUrl;

  GuestModel(
      {required this.name,
      required this.email,
      required this.mobile,
      required this.profilePictureUrl});

  factory GuestModel.fromFirestore(Map<String, dynamic> data) {
    return GuestModel(
      name: data['name'],
      email: data['email'],
      mobile: data['mobile'],
      profilePictureUrl: data['profilePictureUrl'],
    );
  }
}
