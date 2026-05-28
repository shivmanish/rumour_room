import '../../../../core/network/codecs.dart';
import '../../domain/entities/identity_entity.dart';

/// Decodes both the randomuser.me API shape and our local cache shape.
class IdentityModel extends IdentityEntity {
  const IdentityModel({
    required super.id,
    required super.displayName,
    required super.username,
    super.avatarUrl,
  });

  factory IdentityModel.fromRandomUser(JsonMap json) {
    final name = (json['name'] as Map?)?.cast<String, dynamic>() ?? const {};
    final login = (json['login'] as Map?)?.cast<String, dynamic>() ?? const {};
    final picture = (json['picture'] as Map?)?.cast<String, dynamic>();

    final first = (name['first'] as String?)?.trim() ?? '';
    final last = (name['last'] as String?)?.trim() ?? '';
    final display = [first, last].where((s) => s.isNotEmpty).join(' ');

    return IdentityModel(
      id: (login['uuid'] as String?) ?? '',
      displayName: display.isEmpty ? 'Anonymous' : display,
      username: (login['username'] as String?) ?? 'anon',
      avatarUrl: picture?['thumbnail'] as String?,
    );
  }

  factory IdentityModel.fromCache(JsonMap json) {
    return IdentityModel(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  JsonMap toCacheJson() => {
        'id': id,
        'displayName': displayName,
        'username': username,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      };
}
