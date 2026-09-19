/// A local-only player profile, used when "Continuer sans compte" falls
/// back to offline mode because the server is unreachable. It has no
/// server-side `User` counterpart until the player signs in for real.
class GuestProfile {
  const GuestProfile({required this.username, required this.createdAt});

  final String username;
  final DateTime createdAt;

  factory GuestProfile.generate() {
    final now = DateTime.now();
    final suffix = now.microsecondsSinceEpoch.toRadixString(36).toUpperCase();
    return GuestProfile(
      username: 'Joueur-$suffix',
      createdAt: now,
    );
  }

  factory GuestProfile.fromJson(Map<String, dynamic> json) {
    return GuestProfile(
      username: json['username'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'createdAt': createdAt.toIso8601String(),
  };
}
