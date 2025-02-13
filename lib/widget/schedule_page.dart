import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:honeyz_fan_app/model/schedule_model.dart';

List<String> sequence = [
  "honeyz",
  "honeychurros",
  "ayauke",
  "damyui",
  "ddddragon",
  "ohwayo",
  "mangnae"
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
          print(snapshot.id);
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
    return FutureBuilder(
      future: _loadFirestore(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분
        if (snapshot.hasData == false) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Color(0x0fff5e88).withOpacity(0.8),
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
          return ListView.separated(
            shrinkWrap: true,
            itemCount: _result.length,
            padding: EdgeInsets.all(15.0),
            itemBuilder: (context, index) {
              return SizedBox(
                height: 350,
                child: ScheduleCard(
                  imageURL: _result[index].scheduleURL!,
                ),
              );
            },
            separatorBuilder: (context, index) => SizedBox(
              height: 30.0,
            ),
          );
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ScheduleCard extends StatelessWidget {
  final String imageURL;

  const ScheduleCard({super.key, required this.imageURL});

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
              decoration: BoxDecoration(color: Colors.blue[900]),
              child: Center(child: Text('asd') //custom text and style
                  ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Image.network(
              imageURL,
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
    );
  }
}
