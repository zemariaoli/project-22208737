enum GenericOperationType {
  GetNames, // exemplo
  GetWaitTimes,
}

abstract class GenericDataSource {

  Future<dynamic> execute({required GenericOperationType type, dynamic data});

}