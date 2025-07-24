// -------------------------------------------------------------------
// features/auth/domain/entities/user_entity.dart
// La representación "pura" de un usuario en la lógica de negocio.

import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;

  const UserEntity({required this.id, required this.name});

  @override
  List<Object> get props => [id, name];
}
