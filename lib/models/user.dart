class User {
  final int id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? phone;
  final String timezone;
  final String dateFormat;
  final String timeFormat;
  final String? profilePicture;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.phone,
    required this.timezone,
    required this.dateFormat,
    required this.timeFormat,
    this.profilePicture,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      fullName: json['full_name'],
      phone: json['phone'],
      timezone: json['timezone'],
      dateFormat: json['date_format'],
      timeFormat: json['time_format'],
      profilePicture: json['profile_picture'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'phone': phone,
      'timezone': timezone,
      'date_format': dateFormat,
      'time_format': timeFormat,
      'profile_picture': profilePicture,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}