import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String id;
  String firstName;
  String lastName;
  String userName;
  String email;
  String phoneNo;
  String profilePicture;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.email,
    required this.phoneNo,
    required this.profilePicture,
  });

  // Convert a UserModel object into a map to save in Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'userName': userName,
      'email': email,
      'phoneNo': phoneNo,
      'profilePicture': profilePicture,
    };
  }

  // Create a UserModel object from a Firestore map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      userName: map['userName'],
      email: map['email'],
      phoneNo: map['phoneNo'],
      profilePicture: map['profilePicture'],
    );
  }

  // Create a UserModel object from Firestore DocumentSnapshot
  factory UserModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data);
  }
}
