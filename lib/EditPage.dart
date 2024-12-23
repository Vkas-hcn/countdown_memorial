import 'dart:io';
import 'package:countdown_memorial/MainApp.dart';
import 'package:countdown_memorial/utils/AppUtils.dart';
import 'package:countdown_memorial/utils/LocalStorage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'ad/LoadingOverlay.dart';
import 'ad/ShowAdFun.dart';
import 'bean/Event.dart';
import 'bean/EventManager.dart';

class EditPage extends StatelessWidget {
  final Event event;

  const EditPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EditPageScreen(event: event),
    );
  }
}

class EditPageScreen extends StatefulWidget {
  final Event event;

  const EditPageScreen({super.key, required this.event});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<EditPageScreen> {
  final nameController = TextEditingController();
  int imgBg = 0;
  int styleCount = 1;
  int repeat = 1;
  DateTime selectedDate = DateTime.now();
  Event? events;
  String formattedDate = "";
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    setUiData();
    nameController.addListener(showWeightController);
  }
  void setUiData() {
    setState(() {
      events = widget.event;
      nameController.text = events!.name;
      selectedDate =
          DateTime.fromMillisecondsSinceEpoch(int.parse(events!.date) * 1000);
      imgBg = getBgIndex(events!.bgUrl);
      repeat = events!.repeat;
      styleCount = events!.style;
    });
  }

  int getBgIndex(String targetString) {
    return findIndexByString(AppUtils.getBgImageView(), targetString);
  }

  int findIndexByString(List<String> list, String target) {
    for (int i = 0; i < list.length; i++) {
      if (list[i] == target) {
        return i;
      }
    }
    return 0;
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
      Navigator.pop(context);
  }

  void deleteIntakeById(int timestamp) {
    setState(() {
      setUiData();
    });
  }

  void clickStye(int num) {
    setState(() {
      styleCount = num;
    });
  }

  void saveData() {
    if (nameController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please enter the name");
      return;
    }
    if (selectedDate == null) {
      Fluttertoast.showToast(msg: "Please enter the date");
      return;
    }
    Event event = Event(
      id: events!.id,
      name: nameController.text,
      date: (selectedDate.millisecondsSinceEpoch ~/ 1000).toString(),
      bgUrl: AppUtils.getBgImageView()[imgBg],
      repeat: repeat,
      style: styleCount,
      feelings: events!.feelings,
    );
    EventManager.updateEvent(event);
    Fluttertoast.showToast(msg: "The modification was successful");
    Navigator.pop(context);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      AppUtils.addImageToTop(image.path);
      setState(() {
        AppUtils.getBgImageView();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    formattedDate = selectedDate != null
        ? DateFormat('yyyy/MM/dd').format(selectedDate)
        : 'No date selected';
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
                  padding: EdgeInsets.only(top: 42, left: 20, right: 20),
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
                      SizedBox(
                        width: 8,
                      ),
                      const Text("Anniversary",
                          style: TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 16,
                          )),
                      Spacer(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 32, right: 20, left: 20),
                  child: Container(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: Image.asset('assets/img/icon_name.webp'),
                        ),
                        SizedBox(width: 12),
                        SizedBox(
                          width: 250,
                          child: TextField(
                            keyboardType: TextInputType.text,
                            controller: nameController,
                            maxLines: 1,
                            maxLength: 100,
                            buildCounter: (
                              BuildContext context, {
                              required int currentLength,
                              required bool isFocused,
                              required int? maxLength,
                            }) {
                              return null;
                            },
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF262626),
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Enter Name',
                              hintStyle: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF999999),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 32, right: 20, left: 20),
                  child: GestureDetector(
                    onTap: () {
                      _selectDate(context);
                    },
                    child: Container(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: Image.asset('assets/img/icon_date.webp'),
                          ),
                          SizedBox(width: 12),
                          const Text(
                            'Date',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF999999),
                            ),
                          ),
                          Spacer(),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_right,
                            color: Color(0xFF999999),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 32, right: 20, left: 20),
                  child: Container(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: Image.asset('assets/img/icon_bg.webp'),
                        ),
                        SizedBox(width: 12),
                        const Text(
                          'Background Image',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 24.0, left: 20, right: 20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _pickImage();
                        },
                        child: SizedBox(
                          width: 83,
                          height: 103,
                          child: Image.asset(
                            'assets/img/icon_add.webp',
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      SizedBox(width: 10), // 添加间隔以分隔第一个元素和列表
                      Expanded(
                        // 使用 Expanded 包裹 ListView.builder
                        child: SizedBox(
                          height: 103,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: AppUtils.getBgImageView().length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    imgBg = index;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 15.0),
                                  child: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Center(
                                        child: CustomCircle(
                                          img: AppUtils.getBgImageView()[index],
                                        ),
                                      ),
                                      if (imgBg == index)
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: Image.asset(
                                              'assets/img/icon_check.webp',
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.only(top: 32, right: 20, left: 20),
                //   child: GestureDetector(
                //     onTap: () {
                //       _showBottomSheet();
                //     },
                //     child: Container(
                //       child: Row(
                //         children: [
                //           SizedBox(
                //             width: 32,
                //             height: 32,
                //             child: Image.asset('assets/img/icon_repeat.webp'),
                //           ),
                //           SizedBox(width: 12),
                //           const Text(
                //             'Repeat',
                //             style: TextStyle(
                //               fontSize: 14,
                //               color: Color(0xFF999999),
                //             ),
                //           ),
                //           Spacer(),
                //           Text(
                //             AppUtils.getOptionsData()[repeat],
                //             style: const TextStyle(
                //               fontSize: 14,
                //               color: Color(0xFF1E293B),
                //             ),
                //           ),
                //           const Icon(
                //             Icons.keyboard_arrow_right,
                //             color: Color(0xFF999999),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.only(top: 32, right: 20, left: 20),
                  child: Container(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: Image.asset('assets/img/icon_count.webp'),
                        ),
                        SizedBox(width: 12),
                        const Text(
                          'Countdown Style',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          clickStye(1);
                        },
                        child: Container(
                          width: 162,
                          height: 56,
                          decoration: BoxDecoration(
                            color: styleCount == 1
                                ? const Color(0xFF262626)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                '10d 5h 17m 34s',
                                style: TextStyle(
                                  color: styleCount == 1
                                      ? const Color(0xFFFFFFFF)
                                      : const Color(0xFF9B9B9B),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          clickStye(2);
                        },
                        child: Container(
                          width: 162,
                          height: 56,
                          decoration: BoxDecoration(
                            color: styleCount == 2
                                ? const Color(0xFF262626)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                '10 Days 5 Hours 17 minutes 34 Seconds',
                                style: TextStyle(
                                  color: styleCount == 2
                                      ? const Color(0xFFFFFFFF)
                                      : const Color(0xFF9B9B9B),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
                  child: GestureDetector(
                    onTap: () {
                      clickStye(3);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 162,
                          height: 56,
                          decoration: BoxDecoration(
                            color: styleCount == 3
                                ? const Color(0xFF262626)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                '4831877 Seconds',
                                style: TextStyle(
                                  color: styleCount == 3
                                      ? const Color(0xFFFFFFFF)
                                      : const Color(0xFF9B9B9B),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: GestureDetector(
                    onTap: () {
                        saveData();
                    },
                    child: Container(
                      width: 243,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDE496E),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          width: 351,
          height: 312,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(AppUtils.getOptionsData().length, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    repeat = index;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: repeat == index
                        ? Color(0xFFF1F5F9)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      AppUtils.getOptionsData()[index],
                      style: TextStyle(
                        color: repeat == index
                            ? Color(0xFF1E293B)
                            : Color(0xFF999999),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      // 初始日期为明天
      firstDate: DateTime.now().add(const Duration(days: 1)),
      // 最早日期为明天
      lastDate: DateTime(2100),
      // 设置一个合理的未来日期
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // 主色
              onPrimary: Colors.white, // 文字颜色
              onSurface: Colors.black, // 表面颜色
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // 按钮文字颜色
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        print("pickedDate=====$pickedDate");
      });
    }
  }
}

class CustomCircle extends StatelessWidget {
  final String img;

  const CustomCircle({Key? key, required this.img}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 83,
      height: 103,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            width: 83,
            height: 103,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FutureBuilder<Image>(
                future: AppUtils.getImagePath(img),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return snapshot.data!;
                  } else {
                    // 占位符，例如加载中的进度指示器
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
