import 'package:flutterbestplace/models/Rate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'dart:convert';

class RteController extends GetxController {
  final rateRef = FirebaseFirestore.instance.collection('rating');
  Rx<double> Rating = 0.0.obs;
  List<Rate> Rates = [];
  Future<void> SaveRate(id, rate,iduser) async {
    try {
      var isRating = false;
      Rates.forEach((index) {
        if (index.Iduser == iduser) {
          print("index.id : ${index.id}");
          rateRef.doc(index.id).update({
            'value': rate,
          }).then((value) => print("update rating"))
              .catchError((error) => print("Failed to update rate: $error"));
          isRating = true;
        }
      });
      if (isRating == false) {
        await rateRef.add({
          'id': id,
          'Iduser': iduser,
          'value': rate,
        }).then((value) => print("rate user Added"))
            .catchError((error) => print("Failed to add rating: $error"));
      }
    } catch (e) {
      return e.message;
    }
  }
  Future RateById(id) async {
    try {
      List<Rate> list = [];
      var listeRate = await rateRef.where('id',isEqualTo:id).get().then((snapshot) => snapshot.docs);;
      listeRate.forEach((rate)async{
        Rate Mrate =Rate(
          id:rate.id,
          Iduser:rate["Iduser"],
          value:rate["value"],
        );
        list.add(Mrate);
      });
      Rates=list;
      print("&&&&&&&&&&&&&&&&&&&&&&&& $Rates");
    } catch (e) {
      print("FAILED GET MARKER");
    }
  }


  CalculRating() {
    double some = 0;
    int cout = Rates.length;
    print("count : $cout");
    Rates.forEach((rate) {
      print(rate.value);
      some = some + rate.value;
    });
    Rating.value = some / cout;
    print("+++++++++++++++++++++++++++++++++++++++++++++++rating : ${Rating.value}");
  }
}
