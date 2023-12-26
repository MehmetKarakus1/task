import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_gorev_uygulamasi/data/local_storage.dart';
import 'package:flutter_gorev_uygulamasi/main.dart';
import 'package:flutter_gorev_uygulamasi/models/task_model.dart';
import 'package:flutter_gorev_uygulamasi/widgets/custom_serach.dart';
import 'package:flutter_gorev_uygulamasi/widgets/task_list_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Task> _allTasks;
  late LocalStorage _localStorage;
  @override
  void initState() {
    super.initState();
    // başka veritabanı aracı kullandığımızda sadece main de ki kısmı değiştirmemiz yetecek
    _localStorage = locator<LocalStorage>();
    _allTasks = <Task>[];
    _getAllTaskFromDb();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //backgroundColor: Colors.yellow.shade200,
        appBar: AppBar(
          //backgroundColor: Colors.greenAccent,
          title: GestureDetector(
            // title a basılma özelliği kazandırır
            onTap: () {
              _showBottomSheet();
            },
            child: const Text(
              "Bu Gün Neler Yapacaksın ?",
              style: TextStyle(color: Colors.black),
            ),
          ),
          centerTitle: false, // başlığın ortalanmasını engelliyor
          actions: [
            IconButton(
                onPressed: () {
                  _showSearckPage();
                },
                icon: const Icon(Icons.search)),
            IconButton(
                onPressed: () {
                  _showBottomSheet();
                },
                icon: const Icon(Icons.add)),
          ],
        ),
        body: _allTasks.isNotEmpty
            ? ListView.builder(
                itemBuilder: (context, index) {
                  var _oankiListeElemani = _allTasks[index];
                  return Dismissible(
                      background: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.delete_forever,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Görev Silindi")
                        ],
                      ),
                      key: Key(_oankiListeElemani.id),
                      onDismissed: (direction) {
                        _allTasks.removeAt(index);
                        _localStorage.deleteTask(task: _oankiListeElemani);
                        setState(() {});
                      },
                      child: TaskItem(task: _oankiListeElemani));
                },
                itemCount: _allTasks.length,
              )
            : const Center(
                child: Text(
                  "Hadi Görev Ekle",
                  style: TextStyle(fontSize: 22),
                ),
              ));
  }

  void _showBottomSheet() {
    // modal bottom yarım ekran açıyor
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context)
                  .viewInsets
                  .bottom), // klavye açılırsa üst kısmını temsil eder
          width: MediaQuery.of(context).size.width,
          child: ListTile(
            title: TextField(
              autofocus: true, // yazı yazmak için tıklamaya gerek yok
              style: const TextStyle(fontSize: 22),
              decoration: const InputDecoration(
                  hintText: "Görev Nedir ?", border: InputBorder.none),

              onSubmitted: (value) {
                Navigator.of(context).pop();
                if (value.length > 3) {
                  DatePicker.showTimePicker(
                    context,
                    showSecondsColumn: false,
                    onConfirm: (time) async {
                      var yeniEklenecekGorev = Task.create(value, time);

                      _allTasks.insert(0, yeniEklenecekGorev);
                      await _localStorage.addTask(task: yeniEklenecekGorev);
                      setState(() {});
                    },
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  void _getAllTaskFromDb() async {
    _allTasks = await _localStorage.getAllTask();
    setState(() {});
  }

  void _showSearckPage() async {
    await showSearch(
        context: context, delegate: CustomSearchDelegate(allTasks: _allTasks));
    _getAllTaskFromDb();
  }
}
