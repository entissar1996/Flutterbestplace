class Rate{
  String id;
  String Iduser;
  double value;

  Rate({
    this.id,
    this.Iduser,
    this.value,
  });

  factory Rate.fromJson(Map<String, dynamic> json) {
    return Rate(
      id: json['id'],
      Iduser: json['Iduser'],
      value: json['value'],
    );
  }
  Map<String, dynamic> toJson() => {
        '_id': id,
        'Iduser': Iduser,
        'value': value,
      };
}
