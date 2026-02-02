import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? phoneNumber;
  final String? photoURL;
  final String role;
  final String status;
  final String companyId;
  final String? branchId;
  final List<Permission> permissions;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;
  final bool emailVerified;
  final UserPreferences? preferences;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.phoneNumber,
    this.photoURL,
    required this.role,
    required this.status,
    required this.companyId,
    this.branchId,
    this.permissions = const [],
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    this.emailVerified = false,
    this.preferences,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoURL,
    String? role,
    String? status,
    String? companyId,
    String? branchId,
    List<Permission>? permissions,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    bool? emailVerified,
    UserPreferences? preferences,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoURL: photoURL ?? this.photoURL,
      role: role ?? this.role,
      status: status ?? this.status,
      companyId: companyId ?? this.companyId,
      branchId: branchId ?? this.branchId,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      emailVerified: emailVerified ?? this.emailVerified,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        phoneNumber,
        photoURL,
        role,
        status,
        companyId,
        branchId,
        permissions,
        createdAt,
        updatedAt,
        lastLoginAt,
        emailVerified,
        preferences,
      ];

  bool get isAdmin => role == 'admin';
  bool get isManager => role == 'manager';
  bool get isSalesRep => role == 'sales_rep';
  bool get isActive => status == 'active';
}

@JsonSerializable()
class Permission extends Equatable {
  final String resource;
  final List<String> actions;

  const Permission({
    required this.resource,
    required this.actions,
  });

  factory Permission.fromJson(Map<String, dynamic> json) =>
      _$PermissionFromJson(json);
  Map<String, dynamic> toJson() => _$PermissionToJson(this);

  @override
  List<Object?> get props => [resource, actions];
}

@JsonSerializable()
class UserPreferences extends Equatable {
  final String language;
  final String theme;
  final NotificationPreferences notifications;

  const UserPreferences({
    this.language = 'ar',
    this.theme = 'light',
    this.notifications = const NotificationPreferences(),
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);

  @override
  List<Object?> get props => [language, theme, notifications];
}

@JsonSerializable()
class NotificationPreferences extends Equatable {
  final bool email;
  final bool push;
  final bool sms;

  const NotificationPreferences({
    this.email = true,
    this.push = true,
    this.sms = false,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationPreferencesToJson(this);

  @override
  List<Object?> get props => [email, push, sms];
}

@JsonSerializable()
class AuthResponse extends Equatable {
  final User user;
  final String token;

  const AuthResponse({
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);

  @override
  List<Object?> get props => [user, token];
}
