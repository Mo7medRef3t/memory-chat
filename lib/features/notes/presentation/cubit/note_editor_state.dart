import 'package:equatable/equatable.dart';

enum NoteEditorStatus { initial, loading, success, failure }

class NoteEditorState extends Equatable {
  final NoteEditorStatus status;
  final String? errorMessage;

  const NoteEditorState({
    this.status = NoteEditorStatus.initial,
    this.errorMessage,
  });

  NoteEditorState copyWith({NoteEditorStatus? status, String? errorMessage}) {
    return NoteEditorState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
