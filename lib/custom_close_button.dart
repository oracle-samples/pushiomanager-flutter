class PIOInAppCloseButton {
  String? title;
  String? backgroundColor;
  String? titleColor;
  String? imageName;
  double? width;
  double? height;

  Map<String, dynamic> toJson() => {
        'title': title,
        'backgroundColor': backgroundColor,
        'titleColor': titleColor,
        'imageName': imageName,
        'width': width,
        'height': height,
      };
}
