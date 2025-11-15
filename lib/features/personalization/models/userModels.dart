import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:book_Verse/utils/formatters/formatter.dart';

class UserModel {
  final String id;
  String firstName;
  String lastName;
  final String userName;
  final String email;
  String phoneNumber;
  String profilePicture;
  String role; // Added role field
  String canLogin; // Added can_login field for user activation

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.email,
    required this.phoneNumber,
    required this.profilePicture,
    required this.role, // Added role to constructor
    this.canLogin = 'no', // Default to 'no' for new users
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
    String usernameWithPrefix = "cwt_$camelCaseUsername";
    return usernameWithPrefix;
  }

  /// Static Function to create an empty user Model
  static UserModel empty() => UserModel(
    id: '',
    firstName: '',
    lastName: '',
    userName: '',
    email: '',
    phoneNumber: '',
    profilePicture: '',
    role: '', // Default empty role
    canLogin: 'no', // Default to 'no' for new users
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
      'Role': role, // Added role to JSON conversion
      'can_login': canLogin, // Added can_login to JSON conversion
    };
  }

  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return UserModel(
        id: document.id,
        firstName: data['FirstName'] ?? '',
        lastName: data['LastName'] ?? '',
        userName: data['UserName'] ?? '',
        email: data['Email'] ?? '',
        phoneNumber: data['PhoneNumber'] ?? '',
        profilePicture: data['ProfilePicture'] ?? '',
        role: data['Role'] ?? '', // Added role field
        canLogin: data['can_login'] ?? 'no', // Added can_login field with default 'no'
      );
    } else {
      return UserModel.empty();
    }
  }
}