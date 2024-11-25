import 'package:countdown_memorial/AddFeelPage.dart';
import 'package:countdown_memorial/utils/AppUtils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'ad/LoadingOverlay.dart';
import 'ad/ShowAdFun.dart';
import 'bean/Event.dart';

class FeelListPage extends StatelessWidget {
  final Event event;

  const FeelListPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeelListPageScreen(
        event: event,
      ),
    );
  }
}

class FeelListPageScreen extends StatefulWidget {
  final Event event;

  const FeelListPageScreen({super.key, required this.event});

  @override
  _FeelListPageState createState() => _FeelListPageState();
}

class _FeelListPageState extends State<FeelListPageScreen> {
  final nameController = TextEditingController();
  int selectCount = 1;
  int repeat = 1;
  DateTime selectedDate = DateTime.now();
  Event? events;
  late ShowAdFun adManager;
  final LoadingOverlay _loadingOverlay = LoadingOverlay();

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    nameController.addListener(showWeightController);
    nameController.text = "";
    adManager = AppUtils.getMobUtils(context);
    setUiData();
  }

  void showAdNextPaper(AdWhere adWhere,Function() nextJump) async {
    if (!adManager.canShowAd(adWhere)) {
      adManager.loadAd(adWhere);
    }
    setState(() {
      _loadingOverlay.show(context);
    });
    AppUtils.showScanAd(context, adWhere, 5, () {
      setState(() {
        _loadingOverlay.hide();
      });
    }, () {
      setState(() {
        _loadingOverlay.hide();
      });
      nextJump();
    });
  }

  void setUiData() async {
    events = widget.event;
    setState(() {}); // Call setState after data is loaded to rebuild the UI
    print("object==feelings==${events?.feelings.length}");
  }

  @override
  void dispose() {
    super.dispose();
    nameController.removeListener(showWeightController);
  }

  void showWeightController() async {
    nameController.text.trim();
  }

  void backToNextPaper() async {
    showAdNextPaper(AdWhere.BACKINT,  () {
      Navigator.pop(context);
    });
  }

  void deleteIntakeById(int timestamp) {
    setState(() {
      setUiData();
    });
  }

  void clickStye(int num) {
    setState(() {
      selectCount = num;
    });
  }

  void saveData() {
    if (nameController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please enter the content");
      return;
    }
    Feeling value = Feeling(
        time: DateTime.now().millisecondsSinceEpoch.toString(),
        message: nameController.text.trim(),
        state: selectCount);
    events?.feelings.add(value);
    // EventManager.updateEvent(events!);
    Fluttertoast.showToast(msg: "Saved Successfully");
    backToNextPaper();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          backToNextPaper();
          return false;
        },
        child: Container(
          decoration: const BoxDecoration(),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 42, left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      GestureDetector(
                        onTap: () {
                          backToNextPaper();
                        },
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: Image.asset('assets/img/icon_back.webp'),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      const Text("Feelings Record",
                          style: TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 16,
                          )),
                      Spacer(),
                    ],
                  ),
                ),
                if (events!.feelings.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: events?.feelings.length ?? 0,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          showAdNextPaper(AdWhere.SAVE,() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddFeelPage(
                                        event: events!,
                                        timestamp: events!.feelings[index].time,
                                      )),
                            ).then((value) {
                              setState(() {
                                setUiData();
                              });
                            });
                          });
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 12),
                              child: Container(
                                width: double.infinity,
                                height: 170,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: DecorationImage(
                                    image: AssetImage(AppUtils.getBgFeelName(
                                        events!.feelings[index].state)),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppUtils.getMoodName(
                                            events!.feelings[index].state),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Color(0xFF010101),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Stack(
                                          alignment: Alignment.topRight,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      events!.feelings[index]
                                                          .message,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xFF646668),
                                                      ),
                                                      maxLines: 3, // 设置最多显示3行
                                                      overflow: TextOverflow
                                                          .ellipsis, // 超出部分显示省略号
                                                    ),
                                                    const Spacer(),
                                                    Row(
                                                      children: [
                                                        const Spacer(),
                                                        Text(
                                                          AppUtils
                                                              .getTimeFromTimestamp(
                                                                  events!
                                                                      .feelings[
                                                                          index]
                                                                      .time),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            color: Color(
                                                                0xFF999999),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Transform.translate(
                                              offset: const Offset(0, -35),
                                              child: Image.asset(
                                                AppUtils.getSelectCountName(
                                                    events!
                                                        .feelings[index].state),
                                                width: 58,
                                                height: 58,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  )
                else
                  const Padding(
                    padding: EdgeInsets.only(top: 208.0),
                    child: Center(
                      child: Text('No Data found.'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
