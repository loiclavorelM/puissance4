// En-tête d'authentification du serveur MCP de développement (E16), pour le
// `headersHelper` de Claude Code (`.mcp.json`) : se connecte au serveur de
// dev avec un compte e-mail et affiche {"Authorization": "Bearer <jeton>"}.
//
// Identifiants : `assistantMcpDevEmail` et `assistantMcpDevPassword` dans la
// section `development` de config/passwords.yaml (non versionné). Claude
// Code retire de l'environnement les variables qui ressemblent à des
// secrets : on lit donc un fichier.
//
// Le jeton (10 min) est gardé dans .dart_tool/ jusqu'à une minute de son
// expiration ; Claude Code relance ce script après un 401.
import 'dart:convert';
import 'dart:io';

import 'package:puissance4_client/puissance4_client.dart';
import 'package:yaml/yaml.dart';

Future<void> main() async {
  final root = File.fromUri(Platform.script).parent.parent;
  final cache = File('${root.path}/.dart_tool/assistant_mcp_token.json');
  final token = await _cached(cache) ?? await _login(root, cache);
  stdout.write(jsonEncode({'Authorization': 'Bearer $token'}));
}

Future<String?> _cached(File cache) async {
  if (!cache.existsSync()) return null;
  try {
    final json = jsonDecode(await cache.readAsString()) as Map<String, dynamic>;
    final expiresAt = DateTime.parse(json['expiresAt'] as String);
    if (expiresAt.isAfter(DateTime.now().add(const Duration(minutes: 1)))) {
      return json['token'] as String;
    }
  } on Object {
    // Cache illisible : on se reconnecte.
  }
  return null;
}

Future<String> _login(Directory root, File cache) async {
  final passwords =
      (loadYaml(File('${root.path}/config/passwords.yaml').readAsStringSync())
              as YamlMap)['development']
          as YamlMap;
  final email = passwords['assistantMcpDevEmail'] as String?;
  final password = passwords['assistantMcpDevPassword'] as String?;
  if (email == null || password == null) {
    stderr.writeln(
      'Add assistantMcpDevEmail and assistantMcpDevPassword to the '
      'development section of config/passwords.yaml.',
    );
    exit(1);
  }
  final api =
      (loadYaml(File('${root.path}/config/development.yaml').readAsStringSync())
              as YamlMap)['apiServer']
          as YamlMap;
  final client = Client('http://${api['publicHost']}:${api['publicPort']}/');
  try {
    final success = await client.emailIdp.login(
      email: email,
      password: password,
    );
    await cache.writeAsString(
      jsonEncode({
        'token': success.token,
        'expiresAt':
            (success.tokenExpiresAt ??
                    DateTime.now().add(const Duration(minutes: 10)))
                .toIso8601String(),
      }),
    );
    return success.token;
  } finally {
    client.close();
  }
}
