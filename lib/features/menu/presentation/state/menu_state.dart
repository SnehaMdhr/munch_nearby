import 'package:equatable/equatable.dart';
import '../../domain/entities/menu_entity.dart';

enum MenuStatus {
  initial,
  loading,
  loaded,
  error,
}

class MenuState extends Equatable {
  final MenuStatus status;
  final List<MenuEntity> menus;
  final String? errorMessage;

  const MenuState({
    this.status = MenuStatus.initial,
    this.menus = const [],
    this.errorMessage,
  });

  MenuState copyWith({
    MenuStatus? status,
    List<MenuEntity>? menus,
    String? errorMessage,
  }) {
    return MenuState(
      status: status ?? this.status,
      menus: menus ?? this.menus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, menus, errorMessage];
}