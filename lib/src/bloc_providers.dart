import 'package:animal_stat/app/authentication/bloc/bloc.dart';
import 'package:animal_stat/app/login/bloc/bloc.dart';
import 'package:animal_stat/app/login/bloc/login_bloc.dart';
import 'package:animal_stat/app/user/user_repository.dart';
import 'package:animal_stat/src/providers/utility_provider.dart';
import 'package:animal_stat/src/utilities/utilities.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocProviders {
  static List<BlocProvider> get providers => [
        BlocProvider<AuthenticationBloc>(
          builder: (BuildContext context) => AuthenticationBloc(
            userRepository: RepositoryProvider.of<UserRepository>(context),
          )..add(AppStarted()),
        ),
        BlocProvider<LoginBloc>(
          builder: (BuildContext context) => LoginBloc(
            userRepository: RepositoryProvider.of<UserRepository>(context),
            validators: UtilityProvider.of<Validators>(context)),
          ),
      ];
}
