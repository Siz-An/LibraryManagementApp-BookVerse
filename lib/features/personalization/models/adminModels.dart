import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:book_Verse/utils/formatters/formatter.dart';

class AdminModel {
  final String id;
  String firstName;
  String lastName;
  final String userName;
  late final String email;
  String phoneNumber;
  String profilePicture;
  String role;
  List<String> permissions;

  AdminModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.email,
    required this.phoneNumber,
    required this.profilePicture,
    required this.role,
    required this.permissions,
  });

  /// Helper Function to Get the full Name
  String get fullName => '$firstName $lastName';

  /// Helper function to format phone Number
  String get formattedPhoneNo => TFormatter.formatPhoneNumber(phoneNumber);

  /// Static Function to split full name into first and Last name
  static List<String> nameParts(String fullName) => fullName.split(" ");

  /// Static function to generate a user name from full name
  static String generateUsername(String fullName) {
    List<String> nameParts = fullName.split(" ");
    String firstName = nameParts[0].toLowerCase();
    String lastName = nameParts.length > 1 ? nameParts[1].toLowerCase() : "";

    String camelCaseUsername = "$firstName$lastName"; // Combine First and Last name
    String usernameWithPrefix = "admin_$camelCaseUsername";
    return usernameWithPrefix;
  }

  /// Static Function to create an empty admin Model
  static AdminModel empty() => AdminModel(
    id: '',
    firstName: '',
    lastName: '',
    userName: '',
    email: '',
    phoneNumber: '',
    profilePicture: '',
    role: '',
    permissions: [],
  );

  /// Convert model to JSON structure for storing data in Firestore
  Map<String, dynamic> toJson() {
    return {
      'FirstName': firstName,
      'LastName': lastName,
      'UserName': userName,
      'Email': email,
      'PhoneNumber': phoneNumber,
      'ProfilePicture': profilePicture,
      'Role': role,
      'Permissions': permissions,
    };
  }

  factory AdminModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return AdminModel(
        id: document.id,
        firstName: data['FirstName'] ?? '',
        lastName: data['LastName'] ?? '',
        userName: data['UserName'] ?? '',
        email: data['Email'] ?? '',
        phoneNumber: data['PhoneNumber'] ?? '',
        profilePicture: data['ProfilePicture'] ?? '',
        role: data['Role'] ?? '',
        permissions: List<String>.from(data['Permissions'] ?? []),
      );
    } else {
      return AdminModel.empty();
    }
  }
}
