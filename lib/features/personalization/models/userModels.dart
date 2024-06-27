import 'package:book_Verse/utils/formatters/formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  String firstName;
  String lastName;
  final String userName;
  final String email;
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

  /// Helper Function to Get the full Name
  String get fullName => '$firstName $lastName';

  /// Helper function to format phone Number
  String get formattedPhoneNo => TFormatter.formatPhoneNumber(phoneNo);

  /// Static Function to split full name into first and Last name
  static List<String> nameParts(fullName) => fullName.split(" ");

  /// static function to generate a user name from full name.
  static String generateUsername(fullName) {
    List<String> nameParts = fullName.split(" ");
    String firstName = nameParts[0].toLowerCase();
    String lastName = nameParts.length > 1 ? nameParts[1].toLowerCase() : " ";

    String camelCaseUsername = "$firstName$lastName"; //Combine First and Last name
    String usernameWithPrefix = "cwt_$camelCaseUsername";
    return usernameWithPrefix;
  }

  /// Static Function to create an empty user Model
  static UserModel empty() =>
      UserModel(id: '',
          firstName: '',
          lastName: '',
          userName: '',
          email: '',
          phoneNo: '',
          profilePicture: '');

  /// convert model to JSON structure for Storing data in fireBase
  Map<String, dynamic> toJson() {
    return {
      'FirstName': firstName,
      'LastName': lastName,
      'UserName': userName,
      'Email': email,
      'PhoneNumber': phoneNo,
      'ProfilePicture': profilePicture,
    };
  }

  // Create a UserModel object from a Firestore map
  factory UserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data();
      return UserModel(
        id: document.id,
        firstName: data['firstName'] ?? ' ',
        lastName: data['lastName'] ?? ' ',
        userName: data['userName'] ?? ' ',
        email: data['email'] ?? ' ',
        phoneNo: data['phoneNo'] ?? ' ',
        profilePicture: data['profilePicture'] ?? ' ',
      );
    }


    // Create a UserModel object from Firestore DocumentSnapshot
    factory UserModel.fromDocumentSnapshot(DocumentSnapshot doc)
    {
      final data = doc.data() as Map<String, dynamic>;
      return UserModel.fromMap(data);
    }
  }
}
