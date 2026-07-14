import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> saveAndShareFile(List<int> bytes, String fileName) async {
  final output = await getTemporaryDirectory();
  final file = File('${output.path}/$fileName');
  await file.writeAsBytes(bytes);
  await Share.shareXFiles([XFile(file.path)], text: 'Financial Report - Barber 96');
}
