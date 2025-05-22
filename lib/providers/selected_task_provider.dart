import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';

final selectedTaskProvider = StateProvider<Task?>((ref) => null); 