// GENERATED BY DARTANTIC BLOC GENERATOR

part of 'zbloc_test.dart';

abstract class DttBlocTestUserEvent extends Equatable {
  const DttBlocTestUserEvent() : super();
  @override
  List<Object?> get props {
    return [];
  }
}
class DttBlocTestUserUpdateName extends DttBlocTestUserEvent {
  final String name;
  const DttBlocTestUserUpdateName(this.name) : super();
  @override
  List<Object?> get props {
    return [name];
  }
}
class DttBlocTestUserUpdateAge extends DttBlocTestUserEvent {
  final int age;
  const DttBlocTestUserUpdateAge(this.age) : super();
  @override
  List<Object?> get props {
    return [age];
  }
}
class DttBlocTestUserUpdateEmail extends DttBlocTestUserEvent {
  final String? email;
  const DttBlocTestUserUpdateEmail(this.email) : super();
  @override
  List<Object?> get props {
    return [email];
  }
}
class DttBlocTestUserLoad extends DttBlocTestUserEvent {
  const DttBlocTestUserLoad() : super();
  @override
  List<Object?> get props {
    return [
      ];
  }
}
class DttBlocTestUserSave extends DttBlocTestUserEvent {
  const DttBlocTestUserSave() : super();
  @override
  List<Object?> get props {
    return [
      ];
  }
}
class DttBlocTestUserReset extends DttBlocTestUserEvent {
  const DttBlocTestUserReset() : super();
  @override
  List<Object?> get props {
    return [
      ];
  }
}
class DttBlocTestUserValidate extends DttBlocTestUserEvent {
  const DttBlocTestUserValidate() : super();
  @override
  List<Object?> get props {
    return [
      ];
  }
}
