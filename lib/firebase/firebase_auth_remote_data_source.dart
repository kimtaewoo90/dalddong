import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class FirebaseAuthRemoteDataSource {
  // TODO: 서버 url 교체해야함
  final String url = "https://us-central1-dalddong-firebase.cloudfunctions.net/createCustomToken";

  // 서버에서 토큰 받아오기
  Future<String> createCustomToken(Map<String, dynamic> user) async {
    final customTokenResponse = await http.post(Uri.parse(url), body: user);

    return customTokenResponse.body;
  }

  // API로 토큰 받아오기
  Future<String> createCustomTokenAPI() async {
    bool isInstalled = await isKakaoTalkInstalled();

    // exist token
    if (await AuthApi.instance.hasToken()) {
      try {
        AccessTokenInfo tokenInfo =
        await UserApi.instance.accessTokenInfo();
        print('토큰 유효성 체크 성공 ${tokenInfo.id} ${tokenInfo.expiresIn}');

        try {
          // 카카오 계정으로 로그인
          OAuthToken token = isInstalled
              ? await UserApi.instance.loginWithKakaoTalk()
              : await UserApi.instance.loginWithKakaoAccount();

          print('로그인 성공 ${token.accessToken}');
          return token.accessToken;
        } catch (error) {
          print('로그인 실패 $error');
          return '$error';
        }

      } catch (error) {
        if (error is KakaoException && error.isInvalidTokenError()) {
          print('토큰 만료 $error');
          return '$error';
        } else {
          print('토큰 정보 조회 실패 $error');
          return '$error';
        }
      }
    } else {
      print('발급된 토큰 없음');
      print(await KakaoSdk.origin);
      try {
        OAuthToken token = isInstalled
            ? await UserApi.instance.loginWithKakaoTalk()
            : await UserApi.instance.loginWithKakaoAccount();

        print('로그인 성공 ${token.accessToken}');
        return token.accessToken;
      } catch (error) {
        print('로그인 실패 $error');
        return '$error';
      }
    }
  }

}