import { Constants } from '../common/Constants';
import { LoginPage } from './LoginPage';
import { MainPage } from './MainPage';
import { preferences } from '@kit.ArkData';

@Entry
@Component
struct Index {
  @StorageLink(Constants.STORAGE_IS_LOGGED_IN) isLoggedIn: boolean = false;
  @State isLoading: boolean = true;
  @State showSplash: boolean = true;
  @State splashOpacity: number = 0;
  private context = getContext(this);

  aboutToAppear() {
    this.checkLoginState();
    this.playSplashAnimation();
  }

  playSplashAnimation() {
    setTimeout(() => {
      this.splashOpacity = 1;
    }, 100);
    setTimeout(() => {
      this.showSplash = false;
    }, 2100);
  }

  async checkLoginState() {
    const loggedIn = AppStorage.get<boolean>(Constants.STORAGE_IS_LOGGED_IN);
    if (loggedIn) {
      this.isLoading = false;
      return;
    }

    try {
      const store = await preferences.getPreferences(this.context, 'user_prefs');
      const userId = await store.get(Constants.STORAGE_USER_ID, 0);
      const userName = await store.get(Constants.STORAGE_USER_NAME, '');
      const isLogged = await store.get(Constants.STORAGE_IS_LOGGED_IN, false);

      if (isLogged && userId) {
        AppStorage.setOrCreate(Constants.STORAGE_USER_ID, userId);
        AppStorage.setOrCreate(Constants.STORAGE_USER_NAME, userName);
        AppStorage.setOrCreate(Constants.STORAGE_IS_LOGGED_IN, true);
      }
    } catch (e) {
      console.error('读取登录状态失败');
    }

    this.isLoading = false;
  }

  build() {
    Column() {
      if (this.showSplash) {
        Column() {
          Image($r('app.media.logo'))
            .width(120)
            .height(120)
            .borderRadius(24)
          Text('京东商城')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.ui_primary_red'))
            .margin({ top: 16 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.White)
        .opacity(this.splashOpacity)
        .animation({
          duration: 800,
          curve: Curve.EaseInOut
        })
      } else if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.White)
      } else if (this.isLoggedIn) {
        MainPage()
      } else {
        LoginPage()
      }
    }
    .width('100%')
    .height('100%')
  }
}
