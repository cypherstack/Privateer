import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackduo/db/main_db.dart';

final mainDBProvider = Provider((ref) => MainDB.instance);
