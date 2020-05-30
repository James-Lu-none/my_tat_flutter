import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/file/MyDownloader.dart';
import 'package:flutter_app/src/hotfix/AppHotFix.dart';
import 'package:flutter_app/src/notifications/Notifications.dart';
import 'package:flutter_app/src/providers/AppProvider.dart';
import 'package:flutter_app/src/update/AppUpdate.dart';
import 'file:///C:/Users/Morris/Desktop/NTUTCourseHelper-Flutter/lib/src/costants/Constants.dart';
import 'package:flutter_app/src/util/LanguageUtil.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:flutter_app/ui/pages/calendar/CalendarPage.dart';
import 'package:flutter_app/ui/pages/coursetable/CourseTablePage.dart';
import 'package:flutter_app/ui/pages/notification/NotificationPage.dart';
import 'package:flutter_app/ui/pages/other/OtherPage.dart';
import 'package:flutter_app/ui/pages/score/ScorePage.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _pageController = PageController();
  int _currentIndex = 0;
  int _closeAppCount = 0;
  List<Widget> _pageList = List<Widget>();
  FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  void initState() {
    super.initState();
    R.set(context);
    //載入儲存資料
    Model.instance.init().then((value) async {
      // 需重新初始化 list，PageController 才會清除 cache
      try {
        await AppHotFix.init();
        BuildContext contextKey = navigatorKey.currentState.overlay.context;
        if (Model.instance.getAccount().isEmpty) {
          contextKey = null; //不顯示對話框
        } else {
          _checkAppVersion();
        }
        //Crashlytics.instance.setString("StudentId", Model.instance.getAccount()); //設定發生問題學號
        Crashlytics.instance
            .setBool("inDevMode", AppHotFix.inDevMode); //設定是否加入內測版
        List<String> supportedABis = await AppHotFix.getSupportABis();
        Crashlytics.instance
            .setString("Supported ABis", supportedABis.toString());
        await AppHotFix.hotFixSuccess(contextKey);
      } catch (e) {
        Log.e(e.toString());
      }
      _pageList = List();
      _pageList.add(CourseTablePage());
      _pageList.add(NotificationPage());
      _pageList.add(CalendarPage());
      _pageList.add(ScoreViewerPage());
      _pageList.add(OtherPage(_pageController));
      await _setLang();
    });
    _flutterDownloaderInit();
    _notificationsInit();
  }

  void _checkAppVersion() async {
    BuildContext contextKey = navigatorKey.currentState.overlay.context;
    if (Model.instance.autoCheckAppUpdate) {
      if (Model.instance.getFirstUse(Model.appCheckUpdate)) {
        UpdateDetail value = await AppUpdate.checkUpdate();
        Model.instance.setAlreadyUse(Model.appCheckUpdate);
        if (value != null) {
          //檢查到app要更新
          AppUpdate.showUpdateDialog(contextKey, value);
        } else {
          //檢查捕丁
          PatchDetail patch = await AppHotFix.checkPatchVersion();
          if (patch != null) {
            bool v = await AppHotFix.showUpdateDialog(contextKey, patch);
            if (v) AppHotFix.downloadPatch(contextKey, patch);
          }
        }
      }
    }
  }

  void _flutterDownloaderInit() async {
    await MyDownloader.init();
  }

  void _notificationsInit() async {
    await Notifications.instance.init();
  }

  Future<void> _setLang() async {
    await LanguageUtil.init(context);
    setState(() {});
  }

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (BuildContext context, AppProvider appProvider, Widget child) {
        appProvider.navigatorKey = navigatorKey;
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: Constants.appName,
          theme: appProvider.theme,
          darkTheme: Constants.darkTheme,
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: analytics),
          ],
          home: WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
              backgroundColor: Colors.white,
              resizeToAvoidBottomPadding: false,
              body: _buildPageView(),
              bottomNavigationBar: _buildBottomNavigationBar(),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    var canPop = Navigator.of(context).canPop();
    //Log.d(canPop.toString());
    if (canPop) {
      Navigator.of(context).pop();
      _closeAppCount = 0;
    } else {
      _closeAppCount++;
      MyToast.show(R.current.closeOnce);
      Future.delayed(Duration(seconds: 2)).then((_) {
        _closeAppCount = 0;
      });
    }
    return (_closeAppCount >= 2);
  }

  Widget _buildPageView() {
    return PageView(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      children: _pageList,
      physics: NeverScrollableScrollPhysics(), // 禁止滑動
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: _onTap,
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            EvaIcons.clockOutline,
          ),
          title: Text(
            R.current.titleCourse,
          ),
        ),
        BottomNavigationBarItem(
          icon: Icon(
            EvaIcons.emailOutline,
          ),
          title: Text(
            R.current.titleNotification,
          ),
        ),
        BottomNavigationBarItem(
            icon: Icon(
              EvaIcons.calendarOutline,
            ),
            title: Text(
              R.current.calendar,
            )),
        BottomNavigationBarItem(
          icon: Icon(
            EvaIcons.bookOpenOutline,
          ),
          title: Text(
            R.current.titleScore,
          ),
        ),
        BottomNavigationBarItem(
          icon: Icon(
            EvaIcons.menu,
          ),
          title: Text(
            R.current.titleOther,
          ),
        ),
      ],
    );
  }

  void _onTap(int index) {
    _pageController.jumpToPage(index);
  }
}
