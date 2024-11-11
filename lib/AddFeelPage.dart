import 'dart:io';
import 'package:countdown_memorial/MainApp.dart';
import 'package:countdown_memorial/utils/AppUtils.dart';
import 'package:countdown_memorial/utils/LocalStorage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'bean/Event.dart';
import 'bean/EventManager.dart';

class AddFeelPage extends StatelessWidget {
  final Event event;
  final String? timestamp;
  const AddFeelPage({super.key, required this.event, this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AddFeelPageScreen(
        event: event, timestamp:timestamp
      ),
    );
  }
}

class AddFeelPageScreen extends StatefulWidget {
  final Event event;
  final String? timestamp;

  const AddFeelPageScreen({super.key, required this.event, this.timestamp});

  @override
  _AddFeelPageState createState() => _AddFeelPageState();
}

class _AddFeelPageState extends State<AddFeelPageScreen> {
  final nameController = TextEditingController();
  int imgBg = 0;
  int selectCount = 1;
  int repeat = 1;
  DateTime selectedDate = DateTime.now();
  Event? events;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    setState(() {
      setUiData();
    });
    nameController.addListener(showWeightController);
  }

  void setUiData() {
    events = widget.event;
    if(widget.timestamp!=null){
      //循环查找id相同的值
      events?.feelings.forEach((element) {
        if(element.time==widget.timestamp){
          nameController.text = element.message;
          selectCount = element.state;
        }
      });
    }
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
      selectCount = num;
    });
  }

  void saveData() {
    if (nameController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please enter the content");
      return;
    }
    Feeling value = Feeling(
        time:  (DateTime.now().microsecondsSinceEpoch).toString(),
        message: nameController.text.trim(),
        state: selectCount);
    if(widget.timestamp!=null){
      events?.feelings.removeWhere((element) => element.time==widget.timestamp);
    }
    events?.feelings.add(value);

    EventManager.updateEvent(events!);
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
                      const Text("Add Feelings",
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
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 308,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          controller: nameController,
                          maxLines: null,
                          maxLength: 500,
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
                            hintText: 'Feelings of this Moment',
                            hintStyle: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF999999),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 20.0, top: 28),
                      child: Text(
                        'Select your mood',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF010101),
                        ),
                      ),
                    ),
                    Spacer()
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        clickStye(1);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              SizedBox(
                                width: 74,
                                height: 74,
                                child:
                                    Image.asset(AppUtils.getSelectCountName(1)),
                              ),
                              if (selectCount == 1)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 15.0, right: 8),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: Image.asset(
                                        'assets/img/icon_check.webp'),
                                  ),
                                )
                            ],
                          ),
                          Text("Happy",
                              style: TextStyle(
                                color: selectCount == 1
                                    ? Color(0xFF1E293B)
                                    : Color(0xFF999999),
                                fontSize: 14,
                              )),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        clickStye(2);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              SizedBox(
                                width: 74,
                                height: 74,
                                child:
                                    Image.asset(AppUtils.getSelectCountName(2)),
                              ),
                              if (selectCount == 2)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 15.0, right: 8),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: Image.asset(
                                        'assets/img/icon_check.webp'),
                                  ),
                                )
                            ],
                          ),
                          Text("Neutral",
                              style: TextStyle(
                                color: selectCount == 2
                                    ? Color(0xFF1E293B)
                                    : Color(0xFF999999),
                                fontSize: 14,
                              )),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        clickStye(3);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              SizedBox(
                                width: 74,
                                height: 74,
                                child:
                                    Image.asset(AppUtils.getSelectCountName(3)),
                              ),
                              if (selectCount == 3)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 15.0, right: 8),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: Image.asset(
                                        'assets/img/icon_check.webp'),
                                  ),
                                )
                            ],
                          ),
                          Text("Unhappy",
                              style: TextStyle(
                                color: selectCount == 13
                                    ? Color(0xFF1E293B)
                                    : Color(0xFF999999),
                                fontSize: 14,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 36),
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
              child: AppUtils.getImagePath(img),
            ),
          ),
        ),
      ),
    );
  }
}
