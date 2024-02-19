class Language {
  final String name;
  final int id;
  final String languageCode;

  Language(this.name, this.id, this.languageCode);
  static List<Language> languageList() {
    return <Language>[
      Language('English', 1, 'en'),
      Language('عربى', 2, 'ar'),
    ];
  }
}
