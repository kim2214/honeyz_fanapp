import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:honeyz_fan_app/model/schedule_model.dart';

import '../font_style_sheet.dart';

List<String> sequence = [
  // "honeyz",
  "honeychurros",
  "ayauke",
  "damyui",
  "ddddragon",
  "ohwayo",
  "mangnae",
];

List<String> nameList = [
  // "허니즈",
  "허니츄러스",
  "아야",
  "담유이",
  "디디디용",
  "오화요",
  "망내",
];

class SchedulePageWidget extends StatefulWidget {
  const SchedulePageWidget({super.key});

  @override
  State<SchedulePageWidget> createState() => _SchedulePageWidgetState();
}

class _SchedulePageWidgetState extends State<SchedulePageWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
  }

  List<ScheduleModel> _result = [];

  Future<List<ScheduleModel>> _loadFirestore() async {
    if (_result.isEmpty) {
      FirebaseFirestore _firestore = FirebaseFirestore.instance;

      QuerySnapshot<Map<String, dynamic>> _snapshot =
          await _firestore.collection("schedule").get();

      for (int i = 0; i < sequence.length; i++) {
        for (var snapshot in _snapshot.docs) {
          if (sequence[i] == snapshot.id) {
            _result.add(ScheduleModel.fromJson(snapshot.data()));
          }
        }
      }
    }

    return _result;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 30.0),
          child: Text(
            "허니즈 맴버들의 주간 스케줄 표 입니다.",
            style: FontStyleSheet.title,
          ),
        ),
        FutureBuilder(
          future: _loadFirestore(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분
            if (snapshot.hasData == false) {
              return Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Color(0x0fff5e88).withOpacity(1.0),
                  ),
                ),
              );
            }
            //error가 발생하게 될 경우 반환하게 되는 부분
            else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(fontSize: 15),
                ),
              );
            }
            // 데이터를 정상적으로 받아오게 되면 다음 부분을 실행
            else {
              return Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _result.length,
                  padding: EdgeInsets.all(15.0),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      height: 350,
                      child: InkWell(
                        onTap: () {
                          context.push(
                              '/scheduleDetail?url=${_result[index].scheduleURL}&name=${nameList[index]}');
                        },
                        child: ScheduleCard(
                          imageURL: _result[index].scheduleURL!,
                          index: index,
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => SizedBox(
                    height: 30.0,
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ScheduleCard extends StatelessWidget {
  final String imageURL;
  final int index;

  const ScheduleCard({super.key, required this.imageURL, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          border: Border.all(width: 2.0)),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0x0fff5e88).withOpacity(1.0),
              ),
              child: Center(
                child: Text(
                  nameList[index],
                  style: FontStyleSheet.listItem,
                ),
              ),
            ),
          ),
          imageURL.isNotEmpty
              ? Expanded(
                  flex: 5,
                  child: ExtendedImage.network(
                    imageURL,
                    fit: BoxFit.fill,
                    mode: ExtendedImageMode.gesture, // 줌/팬 모드 활성화
                    initGestureConfigHandler: (state) => GestureConfig(
                      minScale: 1.0,
                      maxScale: 5.0,
                      speed: 1.0,
                      initialScale: 1.0,
                    ),
                  ))
              : Expanded(
                  flex: 5,
                  child: Center(
                    child: Text('금주의 ${nameList[index]}님은 방송이 없습니다.',
                        style: FontStyleSheet.listItem),
                  ),
                ),
        ],
      ),
    );
  }
}
