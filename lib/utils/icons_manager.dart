class IconManager {
  static final List<String> iconPaths = [
    'assets/icons/userprofile.webp',
    'assets/icons/userprofile1.webp',
    'assets/icons/userprofile2.webp',
    'assets/icons/userprofile3.webp',
    'assets/icons/userprofile4.webp',
  ];

  /// Returns the icon asset path corresponding to the given index.
  static String getIconByIndex(int index) {
    return iconPaths[index % iconPaths.length];
  }
}
