import '../../../../core/error/exceptions.dart';
import '../../../../core/network/rest/rest_client.dart';
import '../models/identity_model.dart';

abstract class IdentityRemoteDataSource {
  Future<IdentityModel> fetchRandomIdentity();
}

class IdentityRemoteDataSourceImpl implements IdentityRemoteDataSource {
  IdentityRemoteDataSourceImpl(this._client);

  final RestClient _client;

  @override
  Future<IdentityModel> fetchRandomIdentity() async {
    final list = await _client.readList<IdentityModel>(
      '/',
      IdentityModel.fromRandomUser,
      rootKey: 'results',
    );
    if (list.isEmpty) {
      throw ServerException('randomuser.me returned an empty results array.');
    }
    return list.first;
  }
}
