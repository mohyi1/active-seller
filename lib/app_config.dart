var this_year = DateTime.now().year.toString();

class AppConfig {
  static String copyright_text =
      "@ سوقمي " + this_year; //this shows in the splash screen
  static String app_name =
      "سوقمي البائعين"; //this shows in the splash screen
  static String purchase_code =
      "710362d1-4229-435b-854c-661e4a84278d"; //enter your purchase code for the app from codecanyon
  static String system_key =
      r"$2y$10$Hs5IZkNsV147gKdnne0YSeqZvPhGC3Qwg59PDLzp0JonYFFMbWYFS"; //enter your purchase code for the app from codecanyon

  static const bool HTTPS = true;

  //Default language config
  static String default_language = "sa";
  static String mobile_app_code = "ar";
  static bool app_language_rtl = true;

  //configure this

  static const DOMAIN_PATH = 'souqmy.com';

  //do not configure these below
  static const String API_ENDPATH = "api/v2";
  static const String PUBLIC_FOLDER = "public";
  static const String PROTOCOL = HTTPS ? "https://" : "http://";
  static const String SELLER_PREFIX = "seller";
  static const String RAW_BASE_URL = "${PROTOCOL}${DOMAIN_PATH}";
  static const String BASE_URL = "${RAW_BASE_URL}/${API_ENDPATH}";
  static const String BASE_URL_WITH_PREFIX = "${BASE_URL}/${SELLER_PREFIX}";
}
