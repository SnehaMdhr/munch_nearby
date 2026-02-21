import 'package:equatable/equatable.dart';
import '../../domain/entities/favourite_entity.dart';

enum FavouriteStatus {
  initial,
  loading,
  loaded,
  added,
  removed,
  error,
}

class FavouriteState extends Equatable {
  final FavouriteStatus status;
  final List<FavouriteEntity> favourites;
  final bool isFavourite;
  final String? errorMessage;

  const FavouriteState({
    this.status = FavouriteStatus.initial,
    this.favourites = const [],
    this.isFavourite = false,
    this.errorMessage,
  });

  FavouriteState copyWith({
    FavouriteStatus? status,
    List<FavouriteEntity>? favourites,
    bool? isFavourite,
    String? errorMessage,
  }) {
    return FavouriteState(
      status: status ?? this.status,
      favourites: favourites ?? this.favourites,
      isFavourite: isFavourite ?? this.isFavourite,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, favourites, isFavourite, errorMessage];
}