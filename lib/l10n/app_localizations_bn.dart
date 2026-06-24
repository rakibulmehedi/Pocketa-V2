// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'হেল্ম';

  @override
  String get appTagline => 'এখন আপনি আসলে কত টাকা খরচ করতে পারবেন?';

  @override
  String get continueSetupSafeToSpend =>
      'এগিয়ে যান — নিরাপদ ব্যয়সীমা সেট করুন';

  @override
  String get setUpLater => 'পরে সেট করব';

  @override
  String get signInToHelm => 'হেল্ম-এ সাইন ইন করুন';

  @override
  String get magicLinkSubtitle =>
      'আপনার ইমেইল দিন — আমরা সাথে সাথে সাইন ইনের একটি ম্যাজিক লিংক পাঠাব।';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get sendMagicLink => 'ম্যাজিক লিংক পাঠান';

  @override
  String get sending => 'পাঠানো হচ্ছে...';

  @override
  String get checkYourInbox => 'আপনার ইনবক্স দেখুন';

  @override
  String magicLinkSentSubtitle(String email) {
    return '$email-এ একটি লিংক পাঠানো হয়েছে।\nনিচে কোড দিন, অথবা ইমেইলের লিংকে ট্যাপ করুন।';
  }

  @override
  String get pasteVerificationCode => 'ভেরিফিকেশন কোড পেস্ট করুন';

  @override
  String get verifyAndSignIn => 'যাচাই করুন এবং সাইন ইন করুন';

  @override
  String get verifying => 'যাচাই হচ্ছে...';

  @override
  String get useDifferentEmail => '← অন্য ইমেইল ব্যবহার করুন';

  @override
  String get errorEnterEmail => 'আপনার ইমেইল ঠিকানা দিন';

  @override
  String get errorInvalidEmail => 'সঠিক ইমেইল ঠিকানা দিন';

  @override
  String get errorTooManyRequests =>
      'অনেকবার চেষ্টা করা হয়েছে। একটু পরে আবার লিংক চান।';

  @override
  String get errorEnterCode => 'ভেরিফিকেশন কোড দিন বা লিংক পেস্ট করুন';

  @override
  String get errorInvalidCode =>
      'কোডটি ভুল বা মেয়াদ শেষ হয়ে গেছে। নতুন কোড চান।';

  @override
  String get qualifyingQuestion =>
      'আপনি কি কখনো মনে করে টাকা খরচ করেছেন যে পেমেন্ট ক্লিয়ার হয়েছে,\nপরে দেখেছেন হয়নি?';

  @override
  String get qualifyingSubtext =>
      'যদি আপনি USD-এ আয় করেন এবং BDT-তে খরচ করেন — Upwork, Fiverr বা Payoneer-এর মাধ্যমে — এটা প্রায়ই হয়।';

  @override
  String get qualifyingRephraseBn =>
      'আপনি কি কখনো টাকা খরচ করে ফেলেছেন ভেবে যে\nপেমেন্ট ক্লিয়ার হয়েছে, পরে দেখেছেন হয়নি?';

  @override
  String get doesThatSoundFamiliar => 'এটা কি আপনার সাথে মেলে?';

  @override
  String get yesHappenedToMe => 'হ্যাঁ, আমার সাথে এটা হয়';

  @override
  String get noAlwaysKnow => 'না, আমি সবসময় জানি কতটুকু ক্লিয়ার হয়েছে';

  @override
  String get disqualifyHeading =>
      'হেল্ম বাংলাদেশের USD-আয়কারী ফ্রিল্যান্সারদের জন্য তৈরি।';

  @override
  String get disqualifySubtext =>
      'যখন আন্তর্জাতিক কাজ শুরু করবেন, তখন ফিরে আসুন।';

  @override
  String get close => 'বন্ধ করুন';

  @override
  String get liquidBalanceQuestion => 'এখন আপনার কাছে মোটামুটি কত টাকা আছে?';

  @override
  String get liquidBalanceSubtext =>
      'বিকাশ, ব্যাংক, এবং নগদ — সব মিলিয়ে। একটা আনুমানিক সংখ্যাই যথেষ্ট, পরে ঠিক করা যাবে।';

  @override
  String get liquidBalanceFieldLabel => 'বর্তমান লিকুইড ব্যালেন্স (BDT)';

  @override
  String get liquidBalanceError =>
      'নিরাপদ ব্যয়সীমা হিসাব করতে বর্তমান BDT ব্যালেন্স দিন।';

  @override
  String get fixedCostsQuestion => 'আপনার মাসিক নির্দিষ্ট খরচ কী কী?';

  @override
  String get fixedCostsSubtext =>
      'আগামী ৩০ দিনে যে খরচগুলো আসবে। যেগুলো প্রযোজ্য সেগুলো ট্যাপ করুন।';

  @override
  String get fixedCostsNoneSelected =>
      'কোনো মাসিক নির্দিষ্ট খরচ নির্বাচন করা হয়নি।';

  @override
  String get fixedCostsNoneExplainer =>
      'নির্দিষ্ট খরচ নিরাপদ ব্যয়সীমা কমায়। পরে সেটিংস থেকে যোগ করতে পারবেন।';

  @override
  String get skipForNow => 'এখন বাদ দিন';

  @override
  String get letMeAddSome => 'যোগ করতে চাই';

  @override
  String get firstPipelineQuestion => 'শীঘ্রই কোনো টাকা আসছে?';

  @override
  String get firstPipelineSubtext =>
      'প্রত্যাশিত আয় যোগ করলে নিরাপদ ব্যয়সীমা প্রথম দিন থেকেই পুরো চিত্র দেখাবে।';

  @override
  String get clientOrSource => 'ক্লায়েন্ট বা সোর্স';

  @override
  String get clientOrSourceHint => 'যেমন: Upwork, Client X';

  @override
  String get whoIsThisFrom => 'এটা কার কাছ থেকে?';

  @override
  String get pipelineEntryNote =>
      'এটা \"প্রত্যাশিত\" হিসেবে রাখা হবে। পরে স্ট্যাটাস পরিবর্তন করতে পারবেন।';

  @override
  String get addToMyPipeline => 'পাইপলাইনে যোগ করুন';

  @override
  String get skipAddLater => 'এখন বাদ দিন — পরে যোগ করব';

  @override
  String get safeToSpendLabel => 'নিরাপদ ব্যয়সীমা';

  @override
  String get safeToSpendSubLabel => 'নির্দিষ্ট খরচ ও বাফার বাদে';

  @override
  String get receivedOnly => 'শুধু প্রাপ্ত';

  @override
  String get tapToSeeMath => 'হিসাব দেখতে নম্বরে ট্যাপ করুন';

  @override
  String get addPipelineEntry => 'আয় যোগ করুন';

  @override
  String get fixedCostsSectionTitle => 'নির্দিষ্ট খরচ';

  @override
  String get fixedCostsSectionSubtitle => 'আগামী ৩০ দিনে দেয় মাসিক খরচ';

  @override
  String get fixedCostsEmpty =>
      'এখনো কোনো নির্দিষ্ট খরচ যোগ করা হয়নি। যোগ করলে নিরাপদ ব্যয়সীমা আরও নির্ভুল হবে।';

  @override
  String get addFixedCostsLink => 'নির্দিষ্ট খরচ যোগ করুন →';

  @override
  String get safetyBufferTitle => 'সেফটি বাফার';

  @override
  String get safetyBufferSubtitle =>
      'লক করা নয় — হিসাবের ভেতরে একটি নিরাপত্তা মার্জিন';

  @override
  String get safetyBufferEmpty =>
      'কোনো সেফটি বাফার সেট করা নেই। পুরো লিকুইড BDT দিয়ে নিরাপদ ব্যয়সীমা হিসাব হবে।';

  @override
  String get notCountedTitle => 'এখনো গণনায় নেই';

  @override
  String get notCountedSubtitle => 'এখনো গণনায় নেই — প্রত্যাশিত পেমেন্ট';

  @override
  String get notCountedEmpty =>
      'যখন ইনভয়েস করবেন বা টাকা আশা করবেন তখন প্রত্যাশিত পেমেন্ট যোগ করুন।';

  @override
  String get addExpectedPaymentLink => 'প্রত্যাশিত পেমেন্ট যোগ করুন →';

  @override
  String get pending => 'পেন্ডিং';

  @override
  String get expected => 'প্রত্যাশিত';

  @override
  String get received => 'প্রাপ্ত';

  @override
  String get ifAllCounted => 'সব গণনায় ধরলে:';

  @override
  String get addIncome => 'আয় যোগ করুন';

  @override
  String get editIncome => 'আয় সম্পাদনা করুন';

  @override
  String get updateIncome => 'আয় আপডেট করুন';

  @override
  String get saveIncome => 'আয় সংরক্ষণ করুন';

  @override
  String get clientName => 'ক্লায়েন্টের নাম';

  @override
  String get clientNameHint => 'যেমন: Upwork, Client X';

  @override
  String get clientNameRequired => 'ক্লায়েন্টের নাম দেওয়া আবশ্যক';

  @override
  String get projectName => 'প্রজেক্টের নাম';

  @override
  String get projectNameHint => 'যেমন: Website Redesign';

  @override
  String get projectNameRequired => 'প্রজেক্টের নাম দেওয়া আবশ্যক';

  @override
  String get amount => 'পরিমাণ';

  @override
  String get amountRequired => 'পরিমাণ দেওয়া আবশ্যক';

  @override
  String get amountInvalid => '০-এর বেশি একটি সঠিক পরিমাণ দিন';

  @override
  String get fxRateLabel => 'FX রেট (প্রতি USD-এ BDT)';

  @override
  String get fxRateHint => 'যেমন: ১১০.৫';

  @override
  String get fxRateRequired => 'FX রেট দেওয়া আবশ্যক';

  @override
  String get statusLabel => 'স্ট্যাটাস';

  @override
  String get expectedDate => 'প্রত্যাশিত তারিখ';

  @override
  String get receivedDate => 'প্রাপ্তির তারিখ';

  @override
  String get selectDate => 'তারিখ বেছে নিন';

  @override
  String get selectReceivedDate => 'প্রাপ্তির তারিখ বেছে নিন';

  @override
  String get pleaseSelectReceivedDate => 'প্রাপ্তির তারিখ নির্বাচন করুন।';

  @override
  String get notesOptional => 'নোট (ঐচ্ছিক)';

  @override
  String get addANote => 'একটি নোট লিখুন…';

  @override
  String get paymentSourceOptional => 'পেমেন্ট সোর্স (ঐচ্ছিক)';

  @override
  String get paymentSourceHint => 'যেমন: Upwork, Fiverr, সরাসরি ক্লায়েন্ট';

  @override
  String get excludeFromSafeToSpend => 'নিরাপদ ব্যয়সীমা থেকে বাদ দিন';

  @override
  String get excludeFromSafeToSpendSubtitle =>
      'যখন এই পেমেন্ট আপনার হিসাবে প্রভাব ফেলবে না';

  @override
  String get incomeUpdatedSuccess => 'আয় সফলভাবে আপডেট হয়েছে';

  @override
  String get incomeSavedSuccess => 'আয় সফলভাবে সংরক্ষিত হয়েছে';

  @override
  String get incomeFailedToSave => 'আয় সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get incomeEntryNotFound => 'আয়ের এন্ট্রি পাওয়া যায়নি';

  @override
  String get incomeEntryDeleted =>
      'এই আয়ের এন্ট্রিটি মুছে ফেলা হয়ে থাকতে পারে।';

  @override
  String get goBack => 'ফিরে যান';

  @override
  String get excluded => 'বাদ দেওয়া হয়েছে';

  @override
  String get undo => 'পূর্বাবস্থায় ফেরান';

  @override
  String get confirmReceived => 'নিশ্চিত করুন — লিকুইডে যোগ হবে';

  @override
  String get notYet => 'এখনো না';

  @override
  String get amountReceived => 'প্রাপ্ত পরিমাণ';

  @override
  String get fxRateBdtPerUsd => 'FX রেট (প্রতি USD-এ BDT)';

  @override
  String get dateReceived => 'প্রাপ্তির তারিখ';

  @override
  String get enterValidAmount => 'সঠিক পরিমাণ দিন';

  @override
  String get notifications => 'নোটিফিকেশন';

  @override
  String get clearAll => 'সব মুছুন';

  @override
  String get allNotificationsCleared => 'সব নোটিফিকেশন মুছে ফেলা হয়েছে';

  @override
  String get noNotificationsYet => 'এখনো কোনো নোটিফিকেশন নেই';

  @override
  String get notificationsWillShowHere =>
      'নাজ ও আপডেটগুলো পাওয়া গেলে এখানে দেখা যাবে।';

  @override
  String get notificationRemoved => 'নোটিফিকেশন সরানো হয়েছে';

  @override
  String get dateGroupToday => 'আজ';

  @override
  String get dateGroupYesterday => 'গতকাল';

  @override
  String get dateGroupThisWeek => 'এই সপ্তাহ';

  @override
  String get dateGroupOlder => 'আগের';

  @override
  String get notificationPreferences => 'নোটিফিকেশন পছন্দ';

  @override
  String get checkInFrequency => 'চেক-ইন ফ্রিকোয়েন্সি';

  @override
  String get notificationPrefsSaved => 'নোটিফিকেশন পছন্দ সংরক্ষিত হয়েছে';

  @override
  String get save => 'সংরক্ষণ';

  @override
  String get cancel => 'বাতিল';

  @override
  String get settings => 'সেটিংস';

  @override
  String get dashboard => 'ড্যাশবোর্ড';

  @override
  String get devResetOnboarding => 'অনবোর্ডিং রিসেট করুন (শুধু ডেভ)';

  @override
  String get useAsGuest => 'গেস্ট হিসেবে ব্যবহার করুন';

  @override
  String get safeToSpendSettingsTitle => 'নিরাপদ ব্যয়সীমা সেটিংস';

  @override
  String get taxReserveRate => 'ট্যাক্স রিজার্ভের হার';

  @override
  String get taxReserveRateDescription =>
      'আয়ের কত শতাংশ ট্যাক্সের জন্য রাখবেন তার অনুমান।';

  @override
  String get breathingRoom => 'নিরাপদ মার্জিন';

  @override
  String get breathingRoomDescription =>
      'আশা করা আয়ের এই শতাংশ নিরাপদ মার্জিন হিসেবে রাখুন';

  @override
  String breathingRoomPercentOfExpected(String percent) {
    return 'আশা করা আয়ের $percent%';
  }

  @override
  String get fixedCosts => 'ফিক্সড খরচ';

  @override
  String get fixedCostsDescription =>
      'প্রতি মাসে নিরাপদ ব্যয়সীমা থেকে কাটা ফিক্সড খরচ।';

  @override
  String get noFixedCostsYet => 'এখনো কোনো ফিক্সড খরচ যোগ করা হয়নি।';

  @override
  String get addFixedCost => 'ফিক্সড খরচ যোগ করুন';

  @override
  String get saveFixedCost => 'ফিক্সড খরচ সংরক্ষণ করুন';

  @override
  String get editFixedCost => 'ফিক্সড খরচ সম্পাদনা করুন';

  @override
  String get exportMyData => 'আমার ডেটা এক্সপোর্ট করুন';

  @override
  String get changeHistory => 'পরিবর্তনের ইতিহাস';

  @override
  String get deleteAllData => 'সব ডেটা মুছে ফেলুন';

  @override
  String nbaOverdueTitle(int count) {
    return '$countটি পেমেন্ট ওভারডিউ';
  }

  @override
  String get nbaOverdueDescription =>
      'ওভারডিউ পাইপলাইন পেমেন্টের স্ট্যাটাস আপডেট করুন।';

  @override
  String get nbaOverdueAction => 'রিভিউ করুন';

  @override
  String get nbaAtRiskTitle => 'নিরাপদ ব্যয়সীমা কম';

  @override
  String get nbaAtRiskDescription =>
      'চাপ কমাতে নির্দিষ্ট মাসিক খরচ রিভিউ করুন।';

  @override
  String get nbaAtRiskAction => 'নির্দিষ্ট খরচ রিভিউ';

  @override
  String get nbaReliefTitle => 'পাইপলাইন আপ টু ডেট';

  @override
  String get nbaReliefDescription => 'সব পেমেন্ট সময়মতো এবং ট্র্যাক করা আছে।';

  @override
  String get nbaSetupTitle => 'প্রথম প্রত্যাশিত পেমেন্ট যোগ করুন';

  @override
  String get nbaSetupDescription =>
      'নিরাপদ ব্যয়সীমা হিসাব করতে আসন্ন আয় ট্র্যাক করুন।';

  @override
  String get nbaSetupAction => 'পেমেন্ট যোগ করুন';

  @override
  String get calcTraceTitle => 'হিসাবটি যেভাবে করা হয়েছে';

  @override
  String get calcTraceSubtitle => 'বিস্তারিত জানতে যেকোনো লাইনে ট্যাপ করুন';

  @override
  String get calcTraceReceivedIncome => '+ প্রাপ্ত আয়';

  @override
  String get calcTraceCashOut => '− ক্যাশ আউট';

  @override
  String get calcTraceLiquidBdt => '= লিকুইড BDT';

  @override
  String get calcTraceTaxReserve => '− ট্যাক্স রিজার্ভ (হোল্ড)';

  @override
  String get calcTraceFixedCosts => '− দেয় নির্দিষ্ট খরচ';

  @override
  String get calcTraceSafetyBuffer => '− সেফটি বাফার';

  @override
  String get calcTraceSafeToSpend => '= নিরাপদ ব্যয়সীমা';

  @override
  String get trustStripTapToAudit => 'অডিট করতে ট্যাপ করুন';

  @override
  String get trustStripUpdatedJustNow => 'এইমাত্র আপডেট হয়েছে';

  @override
  String trustStripUpdatedMinAgo(int count) {
    return '$count মিনিট আগে আপডেট হয়েছে';
  }

  @override
  String trustStripUpdatedAt(String time) {
    return '$time-এ আপডেট হয়েছে';
  }

  @override
  String get pipelineOverdue => 'ওভারডিউ';

  @override
  String daysOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count দিন ওভারডিউ',
      one: '১ দিন ওভারডিউ',
    );
    return '$_temp0';
  }

  @override
  String get dateToday => 'আজ';

  @override
  String get dateTomorrow => 'আগামীকাল';

  @override
  String get duplicateAsNextMonth => 'পরের মাসের জন্য ডুপ্লিকেট করুন';

  @override
  String get swipeConfirmReceived => 'রিসিভ নিশ্চিত করুন';

  @override
  String get pipelineTitle => 'পাইপলাইন';

  @override
  String get pipelineNeedsDecision => 'সিদ্ধান্ত প্রয়োজন';

  @override
  String get pipelineOverdueAttention => 'ওভারডিউ — মনোযোগ প্রয়োজন';

  @override
  String get fxRateInvalid => 'একটি বৈধ পজিটিভ রেট দিন';

  @override
  String get projectNameRecommended => 'প্রজেক্টের নাম (প্রস্তাবিত)';

  @override
  String get pinCreateTitle => 'আপনার PIN তৈরি করুন';

  @override
  String get pinConfirmTitle => 'আপনার PIN নিশ্চিত করুন';

  @override
  String get pinMismatchError => 'PIN মিলছে না। আবার চেষ্টা করুন।';

  @override
  String get pinEnterTitle => 'আপনার PIN দিন';

  @override
  String pinIncorrectAttempts(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: 'ভুল PIN — $remainingটি চেষ্টা বাকি',
      one: 'ভুল PIN — ১টি চেষ্টা বাকি',
    );
    return '$_temp0';
  }

  @override
  String get pinTooManyAttempts =>
      'অনেকবার চেষ্টা হয়ে গেছে। পরে আবার চেষ্টা করুন।';

  @override
  String get pinTryAgain => 'আবার চেষ্টা করুন।';

  @override
  String pinLockedCountdown(String minutes, String seconds) {
    return 'লক আছে। $minutesমি $secondsসে পর চেষ্টা করুন';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'অনবোর্ডিং ধাপ $step এর মধ্যে $total';
  }

  @override
  String get liquidBalanceInputSemantics => 'বর্তমান লিকুইড ব্যালেন্স ইনপুট';

  @override
  String get liquidBalanceRoughEstimate =>
      'একটা আনুমানিক সংখ্যাই যথেষ্ট — পরে আপডেট করা যাবে।';

  @override
  String get saveLiquidBalance => 'সংরক্ষণ — নিরাপদ ব্যয়সীমা আপডেট হবে';

  @override
  String get incomePatternQuestion => 'আপনার আয় সাধারণত কীভাবে আসে?';

  @override
  String get incomePatternSubtext =>
      'আপনার বেশিরভাগ উপার্জনের সাথে মানানসই প্যাটার্ন বেছে নিন।';

  @override
  String get incomePatternMarketplaceTitle => 'Marketplace escrow';

  @override
  String get incomePatternMarketplacePlatform => 'Upwork, Fiverr, Payoneer';

  @override
  String get incomePatternMarketplaceSubtitle =>
      'মাইলস্টোন বা কাজ শেষ না হওয়া পর্যন্ত পেমেন্ট আটকে থাকে';

  @override
  String get incomePatternDirectTitle => 'সরাসরি ক্লায়েন্ট';

  @override
  String get incomePatternDirectPlatform =>
      'আপনি সরাসরি ক্লায়েন্টকে ইনভয়েস করেন';

  @override
  String get incomePatternDirectSubtitle =>
      'প্রতিটি ক্লায়েন্টের সাথে পেমেন্টের শর্ত নির্ধারিত';

  @override
  String get incomePatternRetainerTitle => 'রিটেইনার / পুনরাবৃত্তি';

  @override
  String get incomePatternRetainerPlatform =>
      'একই ক্লায়েন্ট, প্রতি মাসে একই পরিমাণ';

  @override
  String get incomePatternRetainerSubtitle => 'পূর্বানুমানযোগ্য মাসিক আয়';

  @override
  String get incomePatternSelectError =>
      'চালিয়ে যেতে একটি আয়ের প্যাটার্ন নির্বাচন করুন।';

  @override
  String get saveIncomePattern => 'সংরক্ষণ — আয়ের প্যাটার্ন সেট হবে';

  @override
  String get bufferTitle => 'আপনার সেফটি বাফার সেট করুন';

  @override
  String get bufferSubtext =>
      'এটা লক করা টাকা নয়। এটা হিসাবের ভেতরে একটি নিরাপত্তা মার্জিন।';

  @override
  String bufferSliderSemantics(int percent) {
    return 'সেফটি বাফার স্লাইডার: $percent%';
  }

  @override
  String bufferSliderValue(int percent) {
    return '$percent শতাংশ';
  }

  @override
  String bufferS2sPreviewPositive(int percent) {
    return 'নিরাপদ ব্যয়সীমা প্রিভিউ: মোটের $percent% বাফার';
  }

  @override
  String get bufferS2sPreviewNegative =>
      'নিরাপদ ব্যয়সীমা প্রিভিউতে নেতিবাচক ব্যালেন্স দেখাচ্ছে';

  @override
  String get bufferSafeToSpendLabel => 'নিরাপদ ব্যয়সীমা';

  @override
  String get bufferCostsExceedBalance =>
      'আপনার খরচ লিকুইড ব্যালেন্স ছাড়িয়ে গেছে। বাফার কমান বা প্রত্যাশিত আয় যোগ করুন।';

  @override
  String get saveBuffer => 'সংরক্ষণ — নিরাপদ ব্যয়সীমা সেটআপ শেষ';

  @override
  String get fixedCostsDueDayTooltip =>
      'Due day হলো মাসের যে দিন এই খরচটা সাধারণত দেওয়া হয় (বিলিং সাইকেল মেলাতে ১-২৮)';

  @override
  String get fixedCostsDueDay => 'due day';

  @override
  String get fixedCostsAmountHint => 'পরিমাণ';

  @override
  String fixedCostsCategorySemantics(String label, String state) {
    return '$label, $state';
  }

  @override
  String get fixedCostsCategorySelected => 'নির্বাচিত';

  @override
  String get fixedCostsCategoryNotSelected => 'নির্বাচিত নয়';

  @override
  String get continueButton => 'চালিয়ে যান';

  @override
  String get fixedCostsCategoryRentHousing => 'ভাড়া / বাড়ি';

  @override
  String get fixedCostsCategoryInternet => 'ইন্টারনেট';

  @override
  String get fixedCostsCategoryMobilePhone => 'মোবাইল / ফোন';

  @override
  String get fixedCostsCategorySubscriptions => 'সাবস্ক্রিপশন';

  @override
  String get fixedCostsCategoryFamilySupport => 'পরিবার সহায়তা / বাবা-মা';

  @override
  String get fixedCostsCategoryLoanEmi => 'ঋণের EMI';

  @override
  String get fixedCostsCategoryOther => 'অন্যান্য নির্দিষ্ট খরচ';

  @override
  String get pipelineClientNameSemantics => 'ক্লায়েন্ট বা সোর্সের নাম ইনপুট';

  @override
  String pipelineAmountSemantics(String currency) {
    return '$currency-তে পরিমাণ ইনপুট';
  }

  @override
  String get pipelineCurrencySemantics => 'কারেন্সি নির্বাচন';

  @override
  String get pipelineEntryNoteSemantics =>
      'তথ্য: এটা প্রত্যাশিত হিসেবে রাখা হবে। পরে স্ট্যাটাস পরিবর্তন করতে পারবেন।';

  @override
  String get pipelineSkipSemantics => 'পাইপলাইন এন্ট্রি বাদ দিয়ে হোমে যান';

  @override
  String get pipelineAddAndContinue => 'যোগ করুন এবং চালিয়ে যান';

  @override
  String get pipelineAdding => 'যোগ হচ্ছে...';

  @override
  String get pipelineAmountMustBePositive => '০-এর বেশি হতে হবে';

  @override
  String get auditLogLoadError => 'ইতিহাস লোড করা যায়নি।';

  @override
  String get auditLogEmpty => 'এখনো কোনো পরিবর্তন রেকর্ড হয়নি।';

  @override
  String get auditEntityIncome => 'আয়';

  @override
  String get auditEntityTransaction => 'লেনদেন';

  @override
  String get auditEntitySettings => 'সেটিংস';

  @override
  String get auditEntityFixedCost => 'ফিক্সড খরচ';

  @override
  String get auditEntityRecord => 'রেকর্ড';

  @override
  String auditEventAdded(String entity) {
    return '$entity যোগ হয়েছে';
  }

  @override
  String auditEventUpdated(String entity) {
    return '$entity আপডেট হয়েছে';
  }

  @override
  String auditEventDeleted(String entity) {
    return '$entity মুছে ফেলা হয়েছে';
  }

  @override
  String auditEventConfirmed(String entity) {
    return '$entity নিশ্চিত হয়েছে';
  }

  @override
  String auditEventExported(String entity) {
    return '$entity এক্সপোর্ট হয়েছে';
  }

  @override
  String auditEventChanged(String entity) {
    return '$entity পরিবর্তিত হয়েছে';
  }

  @override
  String get deleteCannotBeUndone => 'এটা পূর্বাবস্থায় ফেরানো যাবে না';

  @override
  String get deleteWarningBody =>
      'আপনার ডেটা মুছে ফেললে এই ডিভাইস থেকে সব আয়ের এন্ট্রি, লেনদেন, সেটিংস এবং পরিবর্তনের ইতিহাস চিরতরে মুছে যাবে। এই ডেটা পুনরুদ্ধার করার কোনো উপায় নেই।';

  @override
  String get deleteWhatWillBeDeleted => 'যা মুছে যাবে';

  @override
  String get deleteItemAllIncomeEntries => 'সব আয়ের এন্ট্রি';

  @override
  String get deleteItemAllTransactions => 'সব লেনদেন';

  @override
  String get deleteItemAllFixedCosts => 'সব ফিক্সড খরচ';

  @override
  String get deleteItemYourSettings => 'আপনার সেটিংস';

  @override
  String get deleteContinue => 'মুছতে এগিয়ে যান';

  @override
  String get deletePinConfirmTitle => 'নিশ্চিত করতে PIN দিন';

  @override
  String get deleteIncorrectPin => 'ভুল PIN';

  @override
  String deleteLockoutMessage(String minutes) {
    return 'অনেকবার চেষ্টা হয়ে গেছে। $minutes মিনিট পরে আবার চেষ্টা করুন।';
  }

  @override
  String get deleteTypeConfirmTitle => 'নিশ্চিত করতে \"DELETE\" টাইপ করুন';

  @override
  String get deleteConfirmHint => 'DELETE';

  @override
  String get exportDataBelongsToYou => 'আপনার ডেটা আপনার';

  @override
  String get exportDescription =>
      'আপনার সব হেল্ম ডেটা CSV ফাইল হিসেবে এক্সপোর্ট করুন। যেকোনো স্প্রেডশিট অ্যাপে খুলুন — Excel, Google Sheets বা Numbers।';

  @override
  String get exportWarning =>
      'এক্সপোর্ট করা ফাইলগুলো এনক্রিপ্টেড নয় এবং ক্লায়েন্টের নাম ও পরিমাণসহ সংবেদনশীল তথ্য থাকতে পারে। শুধুমাত্র বিশ্বস্ত মাধ্যমে শেয়ার করুন এবং কাজ শেষে ডিভাইস থেকে ফাইলগুলো মুছে দিন।';

  @override
  String get exportWhatWillBeExported => 'যা এক্সপোর্ট হবে';

  @override
  String get exportItemIncomeEntries => 'আয়ের এন্ট্রি';

  @override
  String get exportItemTransactions => 'লেনদেন';

  @override
  String get exportItemFixedCosts => 'ফিক্সড খরচ';

  @override
  String get exportItemSettings => 'সেটিংস';

  @override
  String get exportAllData => 'সব ডেটা এক্সপোর্ট করুন';

  @override
  String exportFailed(String error) {
    return 'এক্সপোর্ট ব্যর্থ: $error';
  }

  @override
  String get exportShareSubject => 'হেল্ম ডেটা এক্সপোর্ট';

  @override
  String taxRateSemantics(String percent) {
    return 'ট্যাক্স রেট: $percent%';
  }

  @override
  String safetyBufferSemantics(String percent) {
    return 'সেফটি বাফার: $percent%';
  }

  @override
  String itemDeleted(String label) {
    return '$label মুছে ফেলা হয়েছে';
  }

  @override
  String dueDay(String day) {
    return 'দেয়: $day তারিখ';
  }

  @override
  String get fixedCostLabelHint => 'লেবেল (যেমন: ইন্টারনেট, ভাড়া)';

  @override
  String get fixedCostLabelRequired => 'লেবেল দেওয়া আবশ্যক';

  @override
  String get amountMustBePositive => '০-এর বেশি হতে হবে';

  @override
  String get dueDayLabel => 'দেয় তারিখ';

  @override
  String get dueDayHint => '১-২৮';

  @override
  String get dueDayValidation => 'শুধুমাত্র ১-২৮';

  @override
  String get preferredCheckInTime => 'পছন্দের চেক-ইন সময়';

  @override
  String get alertChannels => 'অ্যালার্ট চ্যানেল';

  @override
  String get pushNotifications => 'পুশ নোটিফিকেশন';

  @override
  String get pushNotificationsSubtitle => 'প্রত্যাশিত তারিখে অ্যালার্ট পান';

  @override
  String get inAppNotificationBanner => 'ইন-অ্যাপ নোটিফিকেশন ব্যানার';

  @override
  String get inAppNotificationSubtitle => 'ড্যাশবোর্ডে বিল সতর্কতা দেখান';

  @override
  String get quietAffirmations => 'নিরব নিশ্চিতি';

  @override
  String get quietAffirmationsSubtitle =>
      'হিরো ব্লকে শান্ত নিশ্চিতকরণ স্ট্যাটাস দেখান';

  @override
  String get savePreferences => 'পছন্দ সংরক্ষণ করুন';

  @override
  String get editTransaction => 'লেনদেন সম্পাদনা করুন';

  @override
  String get transactionNotFound => 'লেনদেন পাওয়া যায়নি';

  @override
  String get transactionMayBeDeleted =>
      'এই পেমেন্টটি মুছে ফেলা হয়ে থাকতে পারে।';

  @override
  String get editCashOut => 'ক্যাশ আউট সম্পাদনা করুন';

  @override
  String get recordCashOut => 'ক্যাশ আউট রেকর্ড করুন';

  @override
  String get transactionTitle => 'শিরোনাম';

  @override
  String get transactionTitleHint => 'যেমন: দুপুরের খাবার, Uber, বেতন';

  @override
  String get titleRequired => 'শিরোনাম দেওয়া আবশ্যক';

  @override
  String get enterValidAmountGreaterThanZero =>
      '০-এর বেশি একটি সঠিক পরিমাণ দিন';

  @override
  String get date => 'তারিখ';

  @override
  String get noteOptional => 'নোট (ঐচ্ছিক)';

  @override
  String get addNoteHint => 'একটি নোট লিখুন…';

  @override
  String get updateTransaction => 'লেনদেন আপডেট করুন';

  @override
  String get saveTransaction => 'লেনদেন সংরক্ষণ করুন';

  @override
  String get transactionUpdated => 'লেনদেন সফলভাবে আপডেট হয়েছে';

  @override
  String get transactionSaved => 'লেনদেন সফলভাবে সংরক্ষিত হয়েছে';

  @override
  String get transactionSaveError =>
      'পেমেন্ট সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String ledgerVerified(int count) {
    return 'লেজার যাচাই করা হয়েছে · $count টি রেকর্ড';
  }

  @override
  String get ledgerIntegrityIssue => 'অখণ্ডতার সমস্যা শনাক্ত হয়েছে';

  @override
  String get ledgerVerifying => 'লেজার যাচাই করা হচ্ছে…';

  @override
  String historyRetentionNote(int days) {
    return 'ইতিহাস সর্বশেষ $days দিন সংরক্ষণ করে';
  }

  @override
  String get historyGroupToday => 'আজ';

  @override
  String get historyGroupYesterday => 'গতকাল';

  @override
  String get historyGroupThisWeek => 'এই সপ্তাহে';

  @override
  String get historyGroupEarlier => 'আগের';

  @override
  String get auditDetailBefore => 'আগে';

  @override
  String get auditDetailAfter => 'পরে';

  @override
  String get auditDetailDescription => 'বিবরণ';

  @override
  String get auditDetailTimestamp => 'কখন';

  @override
  String get auditDetailEntity => 'রেকর্ড';

  @override
  String get auditDetailRecordHash => 'রেকর্ড হ্যাশ';

  @override
  String get auditRelativeJustNow => 'এইমাত্র';

  @override
  String auditRelativeMinutesAgo(int minutes) {
    return '$minutes মিনিট আগে';
  }

  @override
  String auditRelativeHoursAgo(int hours) {
    return '$hours ঘণ্টা আগে';
  }

  @override
  String get spendTitle => 'ব্যয়';

  @override
  String get spendSummaryLabel => 'এই মাসে ব্যয় · নিরাপদ ব্যয়সীমা কমায়';

  @override
  String get spendEmptyTitle => 'এখনো কিছু ব্যয় হয়নি';

  @override
  String get spendEmptyBody =>
      'আপনি যে অর্থ ইতিমধ্যে পরিশোধ করেছেন তা রেকর্ড করুন — প্রতিটি পেমেন্ট আপনার নিরাপদ ব্যয়সীমা আপডেট করে।';

  @override
  String get spendFabLabel => 'পেমেন্ট যোগ করুন';

  @override
  String get tabHome => 'হোম';

  @override
  String get tabPipeline => 'পাইপলাইন';

  @override
  String get tabSpend => 'ব্যয়';

  @override
  String get tabHomeTip => 'নিরাপদ ব্যয়সীমা';

  @override
  String get tabPipelineTip => 'আয়ের পাইপলাইন';

  @override
  String get tabSpendTip => 'ব্যয় হয়েছে';

  @override
  String get viewAuditTrail => 'অডিট ট্রেইল দেখুন';

  @override
  String get viewTrace => 'ট্রেস দেখুন';

  @override
  String get compromisedDeviceTitle => 'এই ডিভাইসটি ঝুঁকিপূর্ণ মনে হচ্ছে';

  @override
  String get compromisedDeviceBody =>
      'রুটেড বা জেলব্রেক করা ডিভাইসে হেল্ম চলতে পারে না কারণ আপনার স্থানীয় আর্থিক ডেটা প্রকাশ হয়ে যেতে পারে। অনুগ্রহ করে একটি অপরিবর্তিত ডিভাইস ব্যবহার করুন।';

  @override
  String get closeHelm => 'হেল্ম বন্ধ করুন';

  @override
  String get cautionCritical => 'সংকটজনক';

  @override
  String get cautionWarning => 'সতর্কতা';

  @override
  String get csvExportWarning =>
      'CSV এক্সপোর্টে আনএনক্রিপ্টেড আর্থিক তথ্য রয়েছে। শুধুমাত্র বিশ্বস্ত প্রাপকদের সাথে শেয়ার করুন।';

  @override
  String get deleteConfirmTitle => 'মুছে ফেলা নিশ্চিত করুন';

  @override
  String get delete => 'মুছুন';

  @override
  String get rateLimitError =>
      'অনেকবার চেষ্টা হয়েছে। ১ মিনিট পরে আবার চেষ্টা করুন।';

  @override
  String accountLockedError(int minutes) {
    return 'অ্যাকাউন্ট সাময়িক বন্ধ। $minutes মিনিট পরে আবার চেষ্টা করুন।';
  }

  @override
  String get exportError => 'রপ্তানি ব্যর্থ হয়েছে। স্টোরেজ পার্মিশন চেক করুন।';

  @override
  String get exportWarningTitle => 'আর্থিক তথ্য শেয়ার করা হচ্ছে';

  @override
  String get exportWarningBody =>
      'আপনার আর্থিক তথ্য শেয়ার করতে যাচ্ছেন। শুধুমাত্র বিশ্বস্ত ব্যক্তির সাথে শেয়ার করুন।';

  @override
  String get ok => 'ঠিক আছে';
}
