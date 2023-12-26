import 'package:flutter/material.dart';
import 'package:flutter_gorev_uygulamasi/data/local_storage.dart';
import 'package:flutter_gorev_uygulamasi/main.dart';
import 'package:flutter_gorev_uygulamasi/models/task_model.dart';
import 'package:flutter_gorev_uygulamasi/widgets/task_list_item.dart';

class CustomSearchDelegate extends SearchDelegate {
  final List<Task> allTasks;

  CustomSearchDelegate({required this.allTasks});

  // aarama kısmının sağ tarafındaki ikonlaı
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query.isEmpty ? null : query = "";
          },
          icon: Icon(Icons.cancel))
    ];
  }

  //en baştaki ikonları
  @override
  Widget? buildLeading(BuildContext context) {
    return GestureDetector(
      onTap: () {
        close(context, null); //arama cubuğunu kapatmak için
      },
      child: Icon(
        Icons.arrow_back,
        size: 22,
      ),
    );
  }

  //aram yapıp sonuçların nasıl cıkacağını göstermek istediğimiz yer
  //arama tuşuna bastığında sonuçlar gelir
  // tüm görevleri aldık hepsini küçük harfe çevirdik aranan değerle eşleşen sonuçlar gösterilecek
  @override
  Widget buildResults(BuildContext context) {
    List<Task> filteredList = allTasks
        .where(
            (gorev) => gorev.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return filteredList.length > 0
        ? ListView.builder(
          // arama kısmın daki yapılan değişiklikleri ana sayfayada yasntımamızı sağladık
            itemBuilder: (context, index) {
              var _oankiListeElemani = filteredList[index];
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
                  onDismissed: (direction) async {
                    filteredList.removeAt(index);
                    await locator<LocalStorage>().deleteTask(task: _oankiListeElemani);
                    
                  },
                  child: TaskItem(task: _oankiListeElemani));
            },
            itemCount: filteredList.length,
          )
        : Center(
            child: Text("Sonuç Bulunamadı"),
          );
  }

  // bir iki harf yazdığında sonuç gösterilmesi
  //arama tuşuna basmadan sonuçların gelmesi
  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
