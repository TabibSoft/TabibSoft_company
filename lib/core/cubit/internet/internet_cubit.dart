import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:tabib_soft_company/core/export.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InternetCubit extends Cubit<InternetState> {
  InternetCubit() : super(InternetInitial());

  late StreamSubscription<List<ConnectivityResult>> streamSubscription;

  void checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    switch (result.first) {
      case ConnectivityResult.none:
        notConnected();

      default:
        connected();
    }
  }

  void checkStreamConnection() {
    streamSubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      switch (result.first) {
        case ConnectivityResult.mobile:
        case ConnectivityResult.wifi:
          connected();

        default:
          notConnected();
      }
    });
  }

  void connected() {
    emit(ConnectedState(connection: InternetConnection.connected));
  }

  void notConnected() {
    emit(NotConnectedState(connection: InternetConnection.none));
  }

  @override
  Future<void> close() {
    streamSubscription.cancel();

    return super.close();
  }
}
