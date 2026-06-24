import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Helm'**
  String get appName;

  /// Welcome screen tagline
  ///
  /// In en, this message translates to:
  /// **'How much BDT can you actually spend right now?'**
  String get appTagline;

  /// Welcome screen primary CTA
  ///
  /// In en, this message translates to:
  /// **'Continue — sets up your Safe-to-Spend'**
  String get continueSetupSafeToSpend;

  /// Onboarding skip button
  ///
  /// In en, this message translates to:
  /// **'Set up later'**
  String get setUpLater;

  /// Magic link screen heading
  ///
  /// In en, this message translates to:
  /// **'Sign in to Helm'**
  String get signInToHelm;

  /// Magic link email step subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter your email — we\'ll send you a magic link to sign in instantly.'**
  String get magicLinkSubtitle;

  /// Email field hint text
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// Button to send magic link
  ///
  /// In en, this message translates to:
  /// **'Send Magic Link'**
  String get sendMagicLink;

  /// Loading state for send magic link button
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// Magic link verify step heading
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get checkYourInbox;

  /// Magic link sent confirmation text
  ///
  /// In en, this message translates to:
  /// **'We sent a link to {email}.\nEnter the code below, or tap the link in your email.'**
  String magicLinkSentSubtitle(String email);

  /// Token field hint text
  ///
  /// In en, this message translates to:
  /// **'Paste verification code'**
  String get pasteVerificationCode;

  /// Verify token button label
  ///
  /// In en, this message translates to:
  /// **'Verify & Sign In'**
  String get verifyAndSignIn;

  /// Loading state for verify button
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get verifying;

  /// Back to email step link
  ///
  /// In en, this message translates to:
  /// **'← Use a different email'**
  String get useDifferentEmail;

  /// Validation: email empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get errorEnterEmail;

  /// Validation: email format invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get errorInvalidEmail;

  /// Rate-limited error message
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait before requesting another link.'**
  String get errorTooManyRequests;

  /// Validation: token empty
  ///
  /// In en, this message translates to:
  /// **'Please enter the verification code or paste the link'**
  String get errorEnterCode;

  /// Invalid token error message
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired verification code. Request a new one.'**
  String get errorInvalidCode;

  /// Onboarding qualifying question heading
  ///
  /// In en, this message translates to:
  /// **'Have you ever spent money thinking a\npayment cleared, then realized it hadn\'t?'**
  String get qualifyingQuestion;

  /// Qualifying question supporting text
  ///
  /// In en, this message translates to:
  /// **'If you earn in USD and spend in BDT — through\nUpwork, Fiverr, or Payoneer — this happens a lot.'**
  String get qualifyingSubtext;

  /// Bangla rephrase shown after 12s inactivity
  ///
  /// In en, this message translates to:
  /// **'আপনি কি কখনো টাকা খরচ করে ফেলেছেন ভেবে যে\nপেমেন্ট ক্লিয়ার হয়েছে, পরে দেখেছেন হয়নি?'**
  String get qualifyingRephraseBn;

  /// Qualifying question follow-up
  ///
  /// In en, this message translates to:
  /// **'Does that sound familiar?'**
  String get doesThatSoundFamiliar;

  /// Qualifying: affirm button
  ///
  /// In en, this message translates to:
  /// **'Yes, that happens to me'**
  String get yesHappenedToMe;

  /// Qualifying: disqualify button
  ///
  /// In en, this message translates to:
  /// **'No, I always know exactly what cleared'**
  String get noAlwaysKnow;

  /// Disqualify state heading
  ///
  /// In en, this message translates to:
  /// **'Helm is built for USD-earning freelancers in Bangladesh.'**
  String get disqualifyHeading;

  /// Disqualify state supporting text
  ///
  /// In en, this message translates to:
  /// **'Come back when you start billing internationally.'**
  String get disqualifySubtext;

  /// Close / disqualify button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Onboarding liquid balance heading
  ///
  /// In en, this message translates to:
  /// **'Roughly how much do you have right now?'**
  String get liquidBalanceQuestion;

  /// Liquid balance supporting text
  ///
  /// In en, this message translates to:
  /// **'bKash, bank, and cash — combined. A rough number is fine. You can refine it later.'**
  String get liquidBalanceSubtext;

  /// Semantics label for balance field
  ///
  /// In en, this message translates to:
  /// **'Current liquid balance in BDT'**
  String get liquidBalanceFieldLabel;

  /// Validation error for empty balance
  ///
  /// In en, this message translates to:
  /// **'Enter your current liquid BDT to calculate Safe-to-Spend.'**
  String get liquidBalanceError;

  /// Fixed costs onboarding heading
  ///
  /// In en, this message translates to:
  /// **'What are your fixed monthly costs?'**
  String get fixedCostsQuestion;

  /// Fixed costs supporting text
  ///
  /// In en, this message translates to:
  /// **'Monthly costs due in the next 30 days. Tap any that apply.'**
  String get fixedCostsSubtext;

  /// Zero state reask heading
  ///
  /// In en, this message translates to:
  /// **'No fixed monthly costs selected.'**
  String get fixedCostsNoneSelected;

  /// Zero state reask body
  ///
  /// In en, this message translates to:
  /// **'Fixed costs reduce Safe-to-Spend. You can add them in Settings later.'**
  String get fixedCostsNoneExplainer;

  /// Skip fixed costs button
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// Return to fixed costs list button
  ///
  /// In en, this message translates to:
  /// **'Let me add some'**
  String get letMeAddSome;

  /// First pipeline page heading
  ///
  /// In en, this message translates to:
  /// **'Any money coming in soon?'**
  String get firstPipelineQuestion;

  /// First pipeline supporting text
  ///
  /// In en, this message translates to:
  /// **'Adding expected income helps Safe-to-Spend show you the full picture from day one.'**
  String get firstPipelineSubtext;

  /// Pipeline client name field label
  ///
  /// In en, this message translates to:
  /// **'Client or source'**
  String get clientOrSource;

  /// Pipeline client name field hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Upwork, Client X'**
  String get clientOrSourceHint;

  /// Validation: client name empty
  ///
  /// In en, this message translates to:
  /// **'Who is this from?'**
  String get whoIsThisFrom;

  /// Info note on first pipeline entry
  ///
  /// In en, this message translates to:
  /// **'This will be marked as \"Expected\". You can update the status later.'**
  String get pipelineEntryNote;

  /// Submit first pipeline entry button
  ///
  /// In en, this message translates to:
  /// **'Add to my pipeline'**
  String get addToMyPipeline;

  /// Skip first pipeline entry
  ///
  /// In en, this message translates to:
  /// **'Skip — I\'ll add it later'**
  String get skipAddLater;

  /// Hero block label above the S2S number
  ///
  /// In en, this message translates to:
  /// **'SAFE-TO-SPEND'**
  String get safeToSpendLabel;

  /// Hero block subtitle under the S2S number
  ///
  /// In en, this message translates to:
  /// **'after fixed costs + safety buffer'**
  String get safeToSpendSubLabel;

  /// Trust strip source label
  ///
  /// In en, this message translates to:
  /// **'Received only'**
  String get receivedOnly;

  /// One-time S2S hint shown on first dashboard view
  ///
  /// In en, this message translates to:
  /// **'Tap the number to see the math'**
  String get tapToSeeMath;

  /// FAB tooltip on dashboard and income list
  ///
  /// In en, this message translates to:
  /// **'Add income entry'**
  String get addPipelineEntry;

  /// Committed section heading
  ///
  /// In en, this message translates to:
  /// **'Fixed costs'**
  String get fixedCostsSectionTitle;

  /// Committed section sub-label
  ///
  /// In en, this message translates to:
  /// **'Monthly costs due in the next 30 days'**
  String get fixedCostsSectionSubtitle;

  /// Committed section empty state
  ///
  /// In en, this message translates to:
  /// **'No fixed costs added yet. Add them to improve Safe-to-Spend accuracy.'**
  String get fixedCostsEmpty;

  /// Committed section CTA link
  ///
  /// In en, this message translates to:
  /// **'Add fixed costs →'**
  String get addFixedCostsLink;

  /// Reserve section heading
  ///
  /// In en, this message translates to:
  /// **'Safety buffer'**
  String get safetyBufferTitle;

  /// Reserve section sub-label
  ///
  /// In en, this message translates to:
  /// **'Not locked — a safety margin inside the calculation'**
  String get safetyBufferSubtitle;

  /// Reserve section empty state
  ///
  /// In en, this message translates to:
  /// **'No safety buffer set. Safe-to-Spend uses your full liquid BDT.'**
  String get safetyBufferEmpty;

  /// Not counted section heading
  ///
  /// In en, this message translates to:
  /// **'Not counted yet'**
  String get notCountedTitle;

  /// Not counted section sub-label
  ///
  /// In en, this message translates to:
  /// **'Not counted yet — expected payments'**
  String get notCountedSubtitle;

  /// Not counted section empty state
  ///
  /// In en, this message translates to:
  /// **'Add an expected payment when you invoice or expect money.'**
  String get notCountedEmpty;

  /// Not counted section CTA link
  ///
  /// In en, this message translates to:
  /// **'Add expected payment →'**
  String get addExpectedPaymentLink;

  /// Pipeline status: pending
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Pipeline status: expected
  ///
  /// In en, this message translates to:
  /// **'Expected'**
  String get expected;

  /// Pipeline status: received
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// Horizon number label in not-counted section
  ///
  /// In en, this message translates to:
  /// **'If all counted:'**
  String get ifAllCounted;

  /// Add income screen title and empty state button
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get addIncome;

  /// Edit income screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Income'**
  String get editIncome;

  /// Update button in edit income screen
  ///
  /// In en, this message translates to:
  /// **'Update Income'**
  String get updateIncome;

  /// Save button in add income screen
  ///
  /// In en, this message translates to:
  /// **'Save Income'**
  String get saveIncome;

  /// Income form: client name label
  ///
  /// In en, this message translates to:
  /// **'Client Name'**
  String get clientName;

  /// Income form: client name hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Upwork, Client X'**
  String get clientNameHint;

  /// Validation: client name empty
  ///
  /// In en, this message translates to:
  /// **'Client name is required'**
  String get clientNameRequired;

  /// Income form: project name label
  ///
  /// In en, this message translates to:
  /// **'Project Name'**
  String get projectName;

  /// Income form: project name hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Website Redesign'**
  String get projectNameHint;

  /// Validation: project name empty
  ///
  /// In en, this message translates to:
  /// **'Project name is required'**
  String get projectNameRequired;

  /// Income form: amount label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Validation: amount empty
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get amountRequired;

  /// Validation: amount invalid
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount greater than 0'**
  String get amountInvalid;

  /// Income form: FX rate label
  ///
  /// In en, this message translates to:
  /// **'FX Rate (BDT per USD)'**
  String get fxRateLabel;

  /// Income form: FX rate hint
  ///
  /// In en, this message translates to:
  /// **'e.g. 110.5'**
  String get fxRateHint;

  /// Validation: FX rate empty for USD
  ///
  /// In en, this message translates to:
  /// **'FX rate required'**
  String get fxRateRequired;

  /// Income form: status section label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// Income form: expected date label
  ///
  /// In en, this message translates to:
  /// **'Expected Date'**
  String get expectedDate;

  /// Income form: received date label
  ///
  /// In en, this message translates to:
  /// **'Received Date'**
  String get receivedDate;

  /// Date picker placeholder
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// Received date picker placeholder
  ///
  /// In en, this message translates to:
  /// **'Select received date'**
  String get selectReceivedDate;

  /// Validation: received date missing
  ///
  /// In en, this message translates to:
  /// **'Please select a received date.'**
  String get pleaseSelectReceivedDate;

  /// Income form: notes label
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// Income form: notes hint
  ///
  /// In en, this message translates to:
  /// **'Add a note…'**
  String get addANote;

  /// Income form: payment source label
  ///
  /// In en, this message translates to:
  /// **'Payment Source (optional)'**
  String get paymentSourceOptional;

  /// Income form: payment source hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Upwork, Fiverr, Direct client'**
  String get paymentSourceHint;

  /// Income form: exclude toggle title
  ///
  /// In en, this message translates to:
  /// **'Exclude from Safe-to-Spend'**
  String get excludeFromSafeToSpend;

  /// Income form: exclude toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'Use when this payment shouldn\'t affect your numbers'**
  String get excludeFromSafeToSpendSubtitle;

  /// Toast on successful income update
  ///
  /// In en, this message translates to:
  /// **'Income updated successfully'**
  String get incomeUpdatedSuccess;

  /// Toast on successful income save
  ///
  /// In en, this message translates to:
  /// **'Income saved successfully'**
  String get incomeSavedSuccess;

  /// Toast on income save failure
  ///
  /// In en, this message translates to:
  /// **'Failed to save income. Please try again.'**
  String get incomeFailedToSave;

  /// Error heading when income entity is missing
  ///
  /// In en, this message translates to:
  /// **'Income entry not found'**
  String get incomeEntryNotFound;

  /// Error body when income entity is missing
  ///
  /// In en, this message translates to:
  /// **'This income entry may have been deleted.'**
  String get incomeEntryDeleted;

  /// Go back button in error state
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// Badge on excluded income card
  ///
  /// In en, this message translates to:
  /// **'Excluded'**
  String get excluded;

  /// Undo action label in toasts and snackbars
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Confirm received sheet primary button
  ///
  /// In en, this message translates to:
  /// **'Confirm — adds to liquid'**
  String get confirmReceived;

  /// Dismiss confirm received sheet
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get notYet;

  /// Confirm received sheet: amount field label
  ///
  /// In en, this message translates to:
  /// **'Amount received'**
  String get amountReceived;

  /// Confirm received sheet: FX rate label
  ///
  /// In en, this message translates to:
  /// **'FX rate (BDT per USD)'**
  String get fxRateBdtPerUsd;

  /// Confirm received sheet: date label
  ///
  /// In en, this message translates to:
  /// **'Date received'**
  String get dateReceived;

  /// Validation: amount in confirm sheet
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get enterValidAmount;

  /// Notification center screen title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Notification center: clear all button
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// Toast after clearing all notifications
  ///
  /// In en, this message translates to:
  /// **'All notifications cleared'**
  String get allNotificationsCleared;

  /// Notification center empty state title
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// Notification center empty state body
  ///
  /// In en, this message translates to:
  /// **'Nudges and updates will show here when available.'**
  String get notificationsWillShowHere;

  /// Toast after dismissing a notification
  ///
  /// In en, this message translates to:
  /// **'Notification removed'**
  String get notificationRemoved;

  /// Notification center date group: today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateGroupToday;

  /// Notification center date group: yesterday
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dateGroupYesterday;

  /// Notification center date group: this week
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get dateGroupThisWeek;

  /// Notification center date group: older
  ///
  /// In en, this message translates to:
  /// **'Older'**
  String get dateGroupOlder;

  /// Cadence sheet title
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get notificationPreferences;

  /// Cadence sheet: frequency section label
  ///
  /// In en, this message translates to:
  /// **'Check-in Frequency'**
  String get checkInFrequency;

  /// Toast after saving notification preferences
  ///
  /// In en, this message translates to:
  /// **'Notification preferences saved'**
  String get notificationPrefsSaved;

  /// Generic save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Generic cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Settings screen title / nav label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Dashboard nav label
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Dev-only reset tooltip on dashboard
  ///
  /// In en, this message translates to:
  /// **'Reset onboarding (dev only)'**
  String get devResetOnboarding;

  /// Magic link screen: skip identity verification and use app locally
  ///
  /// In en, this message translates to:
  /// **'Use as Guest'**
  String get useAsGuest;

  /// STS settings screen app bar title
  ///
  /// In en, this message translates to:
  /// **'Safe-to-Spend Settings'**
  String get safeToSpendSettingsTitle;

  /// STS settings: tax rate section label
  ///
  /// In en, this message translates to:
  /// **'Tax Reserve Rate'**
  String get taxReserveRate;

  /// STS settings: tax rate section description
  ///
  /// In en, this message translates to:
  /// **'Estimated percentage of income to reserve for taxes.'**
  String get taxReserveRateDescription;

  /// STS settings: buffer section label
  ///
  /// In en, this message translates to:
  /// **'Breathing room'**
  String get breathingRoom;

  /// STS settings: buffer section description
  ///
  /// In en, this message translates to:
  /// **'Reserve this % of expected income as a buffer'**
  String get breathingRoomDescription;

  /// STS settings: buffer value subtitle
  ///
  /// In en, this message translates to:
  /// **'{percent}% of expected income'**
  String breathingRoomPercentOfExpected(String percent);

  /// STS settings: fixed costs section label
  ///
  /// In en, this message translates to:
  /// **'Fixed Costs'**
  String get fixedCosts;

  /// STS settings: fixed costs section description
  ///
  /// In en, this message translates to:
  /// **'Fixed costs deducted from Safe-to-Spend each month.'**
  String get fixedCostsDescription;

  /// STS settings: fixed costs empty state
  ///
  /// In en, this message translates to:
  /// **'No fixed costs added yet.'**
  String get noFixedCostsYet;

  /// STS settings: add fixed cost button
  ///
  /// In en, this message translates to:
  /// **'Add Fixed Cost'**
  String get addFixedCost;

  /// STS settings: save fixed cost button
  ///
  /// In en, this message translates to:
  /// **'Save Fixed Cost'**
  String get saveFixedCost;

  /// STS settings: edit fixed cost sheet title
  ///
  /// In en, this message translates to:
  /// **'Edit Fixed Cost'**
  String get editFixedCost;

  /// STS settings: export data list item
  ///
  /// In en, this message translates to:
  /// **'Export my data'**
  String get exportMyData;

  /// STS settings: audit log list item
  ///
  /// In en, this message translates to:
  /// **'Change history'**
  String get changeHistory;

  /// STS settings: delete all data list item
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get deleteAllData;

  /// NBA card: overdue payments title
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 payment overdue} other{{count} payments overdue}}'**
  String nbaOverdueTitle(int count);

  /// NBA card: overdue description
  ///
  /// In en, this message translates to:
  /// **'Update status of overdue pipeline payments.'**
  String get nbaOverdueDescription;

  /// NBA card: overdue CTA
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get nbaOverdueAction;

  /// NBA card: at-risk title
  ///
  /// In en, this message translates to:
  /// **'Safe-to-spend is tight'**
  String get nbaAtRiskTitle;

  /// NBA card: at-risk description
  ///
  /// In en, this message translates to:
  /// **'Review your fixed monthly costs to release pressure.'**
  String get nbaAtRiskDescription;

  /// NBA card: at-risk CTA
  ///
  /// In en, this message translates to:
  /// **'Review fixed costs'**
  String get nbaAtRiskAction;

  /// NBA card: relief title
  ///
  /// In en, this message translates to:
  /// **'Pipeline up to date'**
  String get nbaReliefTitle;

  /// NBA card: relief description
  ///
  /// In en, this message translates to:
  /// **'All payments are on schedule and tracked.'**
  String get nbaReliefDescription;

  /// NBA card: setup title
  ///
  /// In en, this message translates to:
  /// **'Add your first expected payment'**
  String get nbaSetupTitle;

  /// NBA card: setup description
  ///
  /// In en, this message translates to:
  /// **'Track upcoming income to compute Safe-to-Spend.'**
  String get nbaSetupDescription;

  /// NBA card: setup CTA
  ///
  /// In en, this message translates to:
  /// **'Add payment'**
  String get nbaSetupAction;

  /// Calculation trace sheet title
  ///
  /// In en, this message translates to:
  /// **'How we calculated this'**
  String get calcTraceTitle;

  /// Calculation trace sheet subtitle
  ///
  /// In en, this message translates to:
  /// **'Tap any line to learn more'**
  String get calcTraceSubtitle;

  /// Calc trace: received income line
  ///
  /// In en, this message translates to:
  /// **'+ Received income'**
  String get calcTraceReceivedIncome;

  /// Calc trace: cash out line
  ///
  /// In en, this message translates to:
  /// **'− Cash out'**
  String get calcTraceCashOut;

  /// Calc trace: liquid BDT result line
  ///
  /// In en, this message translates to:
  /// **'= Liquid BDT'**
  String get calcTraceLiquidBdt;

  /// Calc trace: tax reserve deduction
  ///
  /// In en, this message translates to:
  /// **'− Tax reserve (hold)'**
  String get calcTraceTaxReserve;

  /// Calc trace: fixed costs deduction
  ///
  /// In en, this message translates to:
  /// **'− Fixed costs due'**
  String get calcTraceFixedCosts;

  /// Calc trace: safety buffer deduction
  ///
  /// In en, this message translates to:
  /// **'− Safety buffer'**
  String get calcTraceSafetyBuffer;

  /// Calc trace: final safe-to-spend result
  ///
  /// In en, this message translates to:
  /// **'= Safe-to-Spend'**
  String get calcTraceSafeToSpend;

  /// Trust strip: audit tap affordance
  ///
  /// In en, this message translates to:
  /// **'Tap to audit'**
  String get trustStripTapToAudit;

  /// Trust strip: updated moments ago
  ///
  /// In en, this message translates to:
  /// **'Updated just now'**
  String get trustStripUpdatedJustNow;

  /// Trust strip: updated N minutes ago
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Updated 1 min ago} other{Updated {count} mins ago}}'**
  String trustStripUpdatedMinAgo(int count);

  /// Trust strip: updated at specific time
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String trustStripUpdatedAt(String time);

  /// Pipeline badge label: overdue status
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get pipelineOverdue;

  /// Pipeline card: days overdue relative date
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day overdue} other{{count} days overdue}}'**
  String daysOverdue(int count);

  /// Pipeline card: relative date for today
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get dateToday;

  /// Pipeline card: relative date for tomorrow
  ///
  /// In en, this message translates to:
  /// **'tomorrow'**
  String get dateTomorrow;

  /// Pipeline card long-press action
  ///
  /// In en, this message translates to:
  /// **'Duplicate as next month'**
  String get duplicateAsNextMonth;

  /// Pipeline card: swipe hint text
  ///
  /// In en, this message translates to:
  /// **'Confirm received'**
  String get swipeConfirmReceived;

  /// Pipeline screen: app bar title
  ///
  /// In en, this message translates to:
  /// **'Pipeline'**
  String get pipelineTitle;

  /// Pipeline screen: section header for items needing decision
  ///
  /// In en, this message translates to:
  /// **'Needs decision'**
  String get pipelineNeedsDecision;

  /// Pipeline screen: section header for overdue items
  ///
  /// In en, this message translates to:
  /// **'Overdue — needs attention'**
  String get pipelineOverdueAttention;

  /// Validation: FX rate must be positive number
  ///
  /// In en, this message translates to:
  /// **'Enter a valid positive rate'**
  String get fxRateInvalid;

  /// Income form: project name label when optional
  ///
  /// In en, this message translates to:
  /// **'Project Name (recommended)'**
  String get projectNameRecommended;

  /// PIN setup: create step heading
  ///
  /// In en, this message translates to:
  /// **'Create your PIN'**
  String get pinCreateTitle;

  /// PIN setup: confirm step heading
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN'**
  String get pinConfirmTitle;

  /// PIN setup: mismatch error message
  ///
  /// In en, this message translates to:
  /// **'PINs don\'t match. Try again.'**
  String get pinMismatchError;

  /// PIN entry: unlock heading
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get pinEnterTitle;

  /// PIN entry: incorrect PIN with remaining attempts
  ///
  /// In en, this message translates to:
  /// **'{remaining, plural, =1{Incorrect PIN — 1 attempt remaining} other{Incorrect PIN — {remaining} attempts remaining}}'**
  String pinIncorrectAttempts(int remaining);

  /// PIN entry: lockout message
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later.'**
  String get pinTooManyAttempts;

  /// PIN entry: lockout expired prompt
  ///
  /// In en, this message translates to:
  /// **'Try again.'**
  String get pinTryAgain;

  /// PIN entry: lockout countdown timer
  ///
  /// In en, this message translates to:
  /// **'Locked. Try again in {minutes}m {seconds}s'**
  String pinLockedCountdown(String minutes, String seconds);

  /// Semantics label for onboarding step progress
  ///
  /// In en, this message translates to:
  /// **'Onboarding step {step} of {total}'**
  String onboardingStepOf(int step, int total);

  /// Semantics label for liquid balance text field
  ///
  /// In en, this message translates to:
  /// **'Current liquid balance input'**
  String get liquidBalanceInputSemantics;

  /// Error hint below liquid balance field
  ///
  /// In en, this message translates to:
  /// **'A rough estimate is fine — you can update it later.'**
  String get liquidBalanceRoughEstimate;

  /// Liquid balance page primary CTA button
  ///
  /// In en, this message translates to:
  /// **'Save — updates Safe-to-Spend'**
  String get saveLiquidBalance;

  /// Income pattern page heading
  ///
  /// In en, this message translates to:
  /// **'How does your income usually arrive?'**
  String get incomePatternQuestion;

  /// Income pattern page supporting text
  ///
  /// In en, this message translates to:
  /// **'Pick the pattern that fits most of your earnings.'**
  String get incomePatternSubtext;

  /// Income pattern card: marketplace title
  ///
  /// In en, this message translates to:
  /// **'Marketplace escrow'**
  String get incomePatternMarketplaceTitle;

  /// Income pattern card: marketplace platform list
  ///
  /// In en, this message translates to:
  /// **'Upwork, Fiverr, Payoneer'**
  String get incomePatternMarketplacePlatform;

  /// Income pattern card: marketplace subtitle
  ///
  /// In en, this message translates to:
  /// **'Payment held until milestone or job completion'**
  String get incomePatternMarketplaceSubtitle;

  /// Income pattern card: direct client title
  ///
  /// In en, this message translates to:
  /// **'Direct client'**
  String get incomePatternDirectTitle;

  /// Income pattern card: direct client platform
  ///
  /// In en, this message translates to:
  /// **'You invoice clients directly'**
  String get incomePatternDirectPlatform;

  /// Income pattern card: direct client subtitle
  ///
  /// In en, this message translates to:
  /// **'Payment terms agreed with each client'**
  String get incomePatternDirectSubtitle;

  /// Income pattern card: retainer title
  ///
  /// In en, this message translates to:
  /// **'Retainer / Recurring'**
  String get incomePatternRetainerTitle;

  /// Income pattern card: retainer platform
  ///
  /// In en, this message translates to:
  /// **'Same client, same amount each month'**
  String get incomePatternRetainerPlatform;

  /// Income pattern card: retainer subtitle
  ///
  /// In en, this message translates to:
  /// **'Predictable monthly income'**
  String get incomePatternRetainerSubtitle;

  /// Income pattern page: validation error when none selected
  ///
  /// In en, this message translates to:
  /// **'Please select an income pattern to continue.'**
  String get incomePatternSelectError;

  /// Income pattern page primary CTA button
  ///
  /// In en, this message translates to:
  /// **'Save — sets income pattern'**
  String get saveIncomePattern;

  /// Buffer comfort page heading
  ///
  /// In en, this message translates to:
  /// **'Set your safety buffer'**
  String get bufferTitle;

  /// Buffer comfort page supporting text
  ///
  /// In en, this message translates to:
  /// **'This is not locked money. It is a safety margin inside the calculation.'**
  String get bufferSubtext;

  /// Semantics label for buffer slider
  ///
  /// In en, this message translates to:
  /// **'Safety buffer slider: {percent}%'**
  String bufferSliderSemantics(int percent);

  /// Semantics value for buffer slider
  ///
  /// In en, this message translates to:
  /// **'{percent} percent'**
  String bufferSliderValue(int percent);

  /// Semantics label for S2S preview card when positive
  ///
  /// In en, this message translates to:
  /// **'Safe to spend preview: {percent}% buffer of total'**
  String bufferS2sPreviewPositive(int percent);

  /// Semantics label for S2S preview card when negative
  ///
  /// In en, this message translates to:
  /// **'Safe to spend preview shows negative balance'**
  String get bufferS2sPreviewNegative;

  /// Safe-to-Spend label in buffer preview card
  ///
  /// In en, this message translates to:
  /// **'Safe-to-Spend'**
  String get bufferSafeToSpendLabel;

  /// Warning shown in buffer card when S2S is negative
  ///
  /// In en, this message translates to:
  /// **'Your costs exceed liquid balance. Adjust buffer or add expected income.'**
  String get bufferCostsExceedBalance;

  /// Buffer comfort page primary CTA button
  ///
  /// In en, this message translates to:
  /// **'Save — finish Safe-to-Spend setup'**
  String get saveBuffer;

  /// Tooltip for the due day dropdown in fixed costs
  ///
  /// In en, this message translates to:
  /// **'Due day is the day of month when this cost is usually paid (1-28 to align with billing cycles)'**
  String get fixedCostsDueDayTooltip;

  /// Label next to due day dropdown in fixed costs row
  ///
  /// In en, this message translates to:
  /// **'due day'**
  String get fixedCostsDueDay;

  /// Hint text for amount field in fixed cost row
  ///
  /// In en, this message translates to:
  /// **'amount'**
  String get fixedCostsAmountHint;

  /// Semantics label for fixed cost category checkbox
  ///
  /// In en, this message translates to:
  /// **'{label}, {state}'**
  String fixedCostsCategorySemantics(String label, String state);

  /// State text for selected fixed cost category
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get fixedCostsCategorySelected;

  /// State text for unselected fixed cost category
  ///
  /// In en, this message translates to:
  /// **'not selected'**
  String get fixedCostsCategoryNotSelected;

  /// Generic continue button label
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Fixed costs category: rent or housing
  ///
  /// In en, this message translates to:
  /// **'Rent / Housing'**
  String get fixedCostsCategoryRentHousing;

  /// Fixed costs category: internet
  ///
  /// In en, this message translates to:
  /// **'Internet'**
  String get fixedCostsCategoryInternet;

  /// Fixed costs category: mobile or phone
  ///
  /// In en, this message translates to:
  /// **'Mobile / Phone'**
  String get fixedCostsCategoryMobilePhone;

  /// Fixed costs category: subscriptions
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get fixedCostsCategorySubscriptions;

  /// Fixed costs category: family support or parents
  ///
  /// In en, this message translates to:
  /// **'Family support / Parents'**
  String get fixedCostsCategoryFamilySupport;

  /// Fixed costs category: loan EMI
  ///
  /// In en, this message translates to:
  /// **'Loan EMI'**
  String get fixedCostsCategoryLoanEmi;

  /// Fixed costs category: other
  ///
  /// In en, this message translates to:
  /// **'Other fixed cost'**
  String get fixedCostsCategoryOther;

  /// Semantics label for client name field in first pipeline page
  ///
  /// In en, this message translates to:
  /// **'Client or source name input'**
  String get pipelineClientNameSemantics;

  /// Semantics label for amount field in first pipeline page
  ///
  /// In en, this message translates to:
  /// **'Amount input in {currency}'**
  String pipelineAmountSemantics(String currency);

  /// Semantics label for currency dropdown in first pipeline page
  ///
  /// In en, this message translates to:
  /// **'Currency selector'**
  String get pipelineCurrencySemantics;

  /// Semantics label for pipeline entry info note
  ///
  /// In en, this message translates to:
  /// **'Information: This will be marked as Expected. You can update the status later.'**
  String get pipelineEntryNoteSemantics;

  /// Semantics label for skip button in first pipeline page
  ///
  /// In en, this message translates to:
  /// **'Skip adding pipeline entry and continue to home'**
  String get pipelineSkipSemantics;

  /// First pipeline page: submit button label
  ///
  /// In en, this message translates to:
  /// **'Add and continue'**
  String get pipelineAddAndContinue;

  /// First pipeline page: loading state for submit button
  ///
  /// In en, this message translates to:
  /// **'Adding...'**
  String get pipelineAdding;

  /// Validation error for pipeline amount field
  ///
  /// In en, this message translates to:
  /// **'Must be > 0'**
  String get pipelineAmountMustBePositive;

  /// Audit log: error state message
  ///
  /// In en, this message translates to:
  /// **'Unable to load history.'**
  String get auditLogLoadError;

  /// Audit log: empty state message
  ///
  /// In en, this message translates to:
  /// **'No changes recorded yet.'**
  String get auditLogEmpty;

  /// Audit log: entity label for income
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get auditEntityIncome;

  /// Audit log: entity label for transaction
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get auditEntityTransaction;

  /// Audit log: entity label for settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get auditEntitySettings;

  /// Audit log: entity label for fixed cost
  ///
  /// In en, this message translates to:
  /// **'Fixed cost'**
  String get auditEntityFixedCost;

  /// Audit log: entity label for unknown record
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get auditEntityRecord;

  /// Audit log: entity was created
  ///
  /// In en, this message translates to:
  /// **'{entity} added'**
  String auditEventAdded(String entity);

  /// Audit log: entity was updated
  ///
  /// In en, this message translates to:
  /// **'{entity} updated'**
  String auditEventUpdated(String entity);

  /// Audit log: entity was deleted
  ///
  /// In en, this message translates to:
  /// **'{entity} deleted'**
  String auditEventDeleted(String entity);

  /// Audit log: entity was confirmed
  ///
  /// In en, this message translates to:
  /// **'{entity} confirmed'**
  String auditEventConfirmed(String entity);

  /// Audit log: entity was exported
  ///
  /// In en, this message translates to:
  /// **'{entity} exported'**
  String auditEventExported(String entity);

  /// Audit log: entity had an unknown change
  ///
  /// In en, this message translates to:
  /// **'{entity} changed'**
  String auditEventChanged(String entity);

  /// Delete account: warning heading
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone'**
  String get deleteCannotBeUndone;

  /// Delete account: warning body text
  ///
  /// In en, this message translates to:
  /// **'Deleting your data will permanently remove all your income entries, transactions, settings, and change history from this device. There is no way to recover this data.'**
  String get deleteWarningBody;

  /// Delete account: section heading for deletion list
  ///
  /// In en, this message translates to:
  /// **'What will be deleted'**
  String get deleteWhatWillBeDeleted;

  /// Delete account: deletion list item — income entries
  ///
  /// In en, this message translates to:
  /// **'All income entries'**
  String get deleteItemAllIncomeEntries;

  /// Delete account: deletion list item — transactions
  ///
  /// In en, this message translates to:
  /// **'All transactions'**
  String get deleteItemAllTransactions;

  /// Delete account: deletion list item — fixed costs
  ///
  /// In en, this message translates to:
  /// **'All fixed costs'**
  String get deleteItemAllFixedCosts;

  /// Delete account: deletion list item — settings
  ///
  /// In en, this message translates to:
  /// **'Your settings'**
  String get deleteItemYourSettings;

  /// Delete account: destructive action button label
  ///
  /// In en, this message translates to:
  /// **'Continue to delete'**
  String get deleteContinue;

  /// Delete account: PIN dialog heading
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to confirm'**
  String get deletePinConfirmTitle;

  /// Delete account: wrong PIN error message
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN'**
  String get deleteIncorrectPin;

  /// Delete account: lockout message with time remaining
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in {minutes}m.'**
  String deleteLockoutMessage(String minutes);

  /// Delete account: type-DELETE dialog heading
  ///
  /// In en, this message translates to:
  /// **'Type \"DELETE\" to confirm'**
  String get deleteTypeConfirmTitle;

  /// Delete account: text field hint in type-DELETE dialog
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get deleteConfirmHint;

  /// Export screen: section heading
  ///
  /// In en, this message translates to:
  /// **'Your data belongs to you'**
  String get exportDataBelongsToYou;

  /// Export screen: description paragraph
  ///
  /// In en, this message translates to:
  /// **'Export all your Helm data as CSV files. Open them in any spreadsheet app — Excel, Google Sheets, or Numbers.'**
  String get exportDescription;

  /// Export screen: security warning paragraph
  ///
  /// In en, this message translates to:
  /// **'Exported files are not encrypted and may contain sensitive information such as client names and amounts. Only share them through trusted channels and delete the files from your device when you are done.'**
  String get exportWarning;

  /// Export screen: section heading for export list
  ///
  /// In en, this message translates to:
  /// **'What will be exported'**
  String get exportWhatWillBeExported;

  /// Export screen: export list item — income entries
  ///
  /// In en, this message translates to:
  /// **'Income entries'**
  String get exportItemIncomeEntries;

  /// Export screen: export list item — transactions
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get exportItemTransactions;

  /// Export screen: export list item — fixed costs
  ///
  /// In en, this message translates to:
  /// **'Fixed costs'**
  String get exportItemFixedCosts;

  /// Export screen: export list item — settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get exportItemSettings;

  /// Export screen: primary export button label
  ///
  /// In en, this message translates to:
  /// **'Export all data'**
  String get exportAllData;

  /// Export screen: error toast message
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// Export screen: share sheet subject line
  ///
  /// In en, this message translates to:
  /// **'Helm data export'**
  String get exportShareSubject;

  /// STS settings: semantics label for tax rate slider
  ///
  /// In en, this message translates to:
  /// **'Tax rate: {percent}%'**
  String taxRateSemantics(String percent);

  /// STS settings: semantics label for safety buffer slider
  ///
  /// In en, this message translates to:
  /// **'Safety buffer: {percent}%'**
  String safetyBufferSemantics(String percent);

  /// STS settings: toast shown after dismissing a fixed cost
  ///
  /// In en, this message translates to:
  /// **'{label} deleted'**
  String itemDeleted(String label);

  /// STS settings: fixed cost list tile subtitle
  ///
  /// In en, this message translates to:
  /// **'Due: Day {day}'**
  String dueDay(String day);

  /// STS settings: fixed cost label field hint
  ///
  /// In en, this message translates to:
  /// **'Label (e.g. Internet, Rent)'**
  String get fixedCostLabelHint;

  /// STS settings: validation error for empty label
  ///
  /// In en, this message translates to:
  /// **'Label is required'**
  String get fixedCostLabelRequired;

  /// STS settings: validation error for non-positive amount
  ///
  /// In en, this message translates to:
  /// **'Must be > 0'**
  String get amountMustBePositive;

  /// STS settings: due day field label
  ///
  /// In en, this message translates to:
  /// **'Due Day'**
  String get dueDayLabel;

  /// STS settings: due day field hint text
  ///
  /// In en, this message translates to:
  /// **'1-28'**
  String get dueDayHint;

  /// STS settings: validation error for out-of-range due day
  ///
  /// In en, this message translates to:
  /// **'1-28 only'**
  String get dueDayValidation;

  /// Cadence sheet: time picker section label
  ///
  /// In en, this message translates to:
  /// **'Preferred Check-in Time'**
  String get preferredCheckInTime;

  /// Cadence sheet: channels section label
  ///
  /// In en, this message translates to:
  /// **'Alert Channels'**
  String get alertChannels;

  /// Cadence sheet: push notifications switch title
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get pushNotifications;

  /// Cadence sheet: push notifications switch subtitle
  ///
  /// In en, this message translates to:
  /// **'Receive alerts on expected dates'**
  String get pushNotificationsSubtitle;

  /// Cadence sheet: in-app banner switch title
  ///
  /// In en, this message translates to:
  /// **'In-app notification banner'**
  String get inAppNotificationBanner;

  /// Cadence sheet: in-app banner switch subtitle
  ///
  /// In en, this message translates to:
  /// **'Show bill warning hints in dashboard'**
  String get inAppNotificationSubtitle;

  /// Cadence sheet: quiet affirmations switch title
  ///
  /// In en, this message translates to:
  /// **'Quiet affirmations'**
  String get quietAffirmations;

  /// Cadence sheet: quiet affirmations switch subtitle
  ///
  /// In en, this message translates to:
  /// **'Display calm confirmation status on hero block'**
  String get quietAffirmationsSubtitle;

  /// Cadence sheet: save button label
  ///
  /// In en, this message translates to:
  /// **'Save Preferences'**
  String get savePreferences;

  /// Transaction screen: app bar title in edit mode (not found)
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// Transaction screen: error heading when transaction is missing
  ///
  /// In en, this message translates to:
  /// **'Transaction not found'**
  String get transactionNotFound;

  /// Transaction screen: error body when transaction is missing
  ///
  /// In en, this message translates to:
  /// **'This payment may have been deleted.'**
  String get transactionMayBeDeleted;

  /// Transaction screen: app bar title in edit mode
  ///
  /// In en, this message translates to:
  /// **'Edit cash out'**
  String get editCashOut;

  /// Transaction screen: app bar title in add mode
  ///
  /// In en, this message translates to:
  /// **'Record cash out'**
  String get recordCashOut;

  /// Transaction screen: title field label
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get transactionTitle;

  /// Transaction screen: title field hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Lunch, Uber, Salary'**
  String get transactionTitleHint;

  /// Transaction screen: validation error for empty title
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// Transaction screen: validation error for invalid amount
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount greater than 0'**
  String get enterValidAmountGreaterThanZero;

  /// Transaction screen: date field label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Transaction screen: note field label
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// Transaction screen: note field hint
  ///
  /// In en, this message translates to:
  /// **'Add a note…'**
  String get addNoteHint;

  /// Transaction screen: submit button label in edit mode
  ///
  /// In en, this message translates to:
  /// **'Update Transaction'**
  String get updateTransaction;

  /// Transaction screen: submit button label in add mode
  ///
  /// In en, this message translates to:
  /// **'Save Transaction'**
  String get saveTransaction;

  /// Transaction screen: success toast in edit mode
  ///
  /// In en, this message translates to:
  /// **'Transaction updated successfully'**
  String get transactionUpdated;

  /// Transaction screen: success toast in add mode
  ///
  /// In en, this message translates to:
  /// **'Transaction saved successfully'**
  String get transactionSaved;

  /// Transaction screen: error toast on save failure
  ///
  /// In en, this message translates to:
  /// **'Could not save payment. Try again.'**
  String get transactionSaveError;

  /// History integrity strip, intact state
  ///
  /// In en, this message translates to:
  /// **'Ledger verified · {count} records'**
  String ledgerVerified(int count);

  /// History integrity strip, broken state
  ///
  /// In en, this message translates to:
  /// **'Integrity issue detected'**
  String get ledgerIntegrityIssue;

  /// History integrity strip, loading state
  ///
  /// In en, this message translates to:
  /// **'Verifying ledger…'**
  String get ledgerVerifying;

  /// Footer note on History tab about retention
  ///
  /// In en, this message translates to:
  /// **'History keeps the last {days} days'**
  String historyRetentionNote(int days);

  /// History date group header
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get historyGroupToday;

  /// History date group header
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get historyGroupYesterday;

  /// History date group header
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get historyGroupThisWeek;

  /// History date group header
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get historyGroupEarlier;

  /// Audit detail sheet, before value label
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get auditDetailBefore;

  /// Audit detail sheet, after value label
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get auditDetailAfter;

  /// Audit detail sheet, description label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get auditDetailDescription;

  /// Audit detail sheet, timestamp label
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get auditDetailTimestamp;

  /// Audit detail sheet, entity label
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get auditDetailEntity;

  /// Audit detail sheet, hash label
  ///
  /// In en, this message translates to:
  /// **'Record hash'**
  String get auditDetailRecordHash;

  /// Relative time, under one minute
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get auditRelativeJustNow;

  /// Relative time in minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String auditRelativeMinutesAgo(int minutes);

  /// Relative time in hours
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String auditRelativeHoursAgo(int hours);

  /// Spend tab screen title
  ///
  /// In en, this message translates to:
  /// **'Spend'**
  String get spendTitle;

  /// Spend tab summary strip label
  ///
  /// In en, this message translates to:
  /// **'Spent this month · reduces Safe-to-Spend'**
  String get spendSummaryLabel;

  /// Spend tab empty-state title
  ///
  /// In en, this message translates to:
  /// **'Nothing spent yet'**
  String get spendEmptyTitle;

  /// Spend tab empty-state teaching body
  ///
  /// In en, this message translates to:
  /// **'Record money you have already paid out — each payment updates your Safe-to-Spend.'**
  String get spendEmptyBody;

  /// Spend tab add-payment FAB label
  ///
  /// In en, this message translates to:
  /// **'Add a payment'**
  String get spendFabLabel;

  /// Bottom navigation tab label: home / dashboard
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// Bottom navigation tab label: income pipeline
  ///
  /// In en, this message translates to:
  /// **'Pipeline'**
  String get tabPipeline;

  /// Bottom navigation tab label: spend / cash-out
  ///
  /// In en, this message translates to:
  /// **'Spend'**
  String get tabSpend;

  /// Bottom navigation tab tooltip: home
  ///
  /// In en, this message translates to:
  /// **'Safe-to-Spend'**
  String get tabHomeTip;

  /// Bottom navigation tab tooltip: pipeline
  ///
  /// In en, this message translates to:
  /// **'Income pipeline'**
  String get tabPipelineTip;

  /// Bottom navigation tab tooltip: spend
  ///
  /// In en, this message translates to:
  /// **'Money spent'**
  String get tabSpendTip;

  /// Tooltip on history icon buttons in app bar
  ///
  /// In en, this message translates to:
  /// **'View audit trail'**
  String get viewAuditTrail;

  /// Label on the trace TextButton inside HelmNextEventCard
  ///
  /// In en, this message translates to:
  /// **'View trace'**
  String get viewTrace;

  /// Heading on the non-dismissible compromised-device blocking screen
  ///
  /// In en, this message translates to:
  /// **'This device appears to be compromised'**
  String get compromisedDeviceTitle;

  /// Body copy on the compromised-device blocking screen
  ///
  /// In en, this message translates to:
  /// **'Helm cannot run on rooted or jailbroken devices because your local financial data could be exposed. Please use an unmodified device.'**
  String get compromisedDeviceBody;

  /// Button label on the compromised-device blocking screen
  ///
  /// In en, this message translates to:
  /// **'Close Helm'**
  String get closeHelm;

  /// Severity word used in HelmCautionCard semantics label when isCritical=true
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get cautionCritical;

  /// Severity word used in HelmCautionCard semantics label when isCritical=false
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get cautionWarning;

  /// H-24: security warning shown above the CSV export button
  ///
  /// In en, this message translates to:
  /// **'CSV export contains unencrypted financial data. Only share with trusted recipients.'**
  String get csvExportWarning;

  /// H-39: confirmation dialog title before deleting an item
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get deleteConfirmTitle;

  /// H-39: confirm delete action label in confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// M-33: rate limit error shown when too many auth attempts occur
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait 1 minute.'**
  String get rateLimitError;

  /// M-33: account lockout error with time remaining
  ///
  /// In en, this message translates to:
  /// **'Account temporarily locked. Try again in {minutes} minutes.'**
  String accountLockedError(int minutes);

  /// M-33: user-friendly export failure message
  ///
  /// In en, this message translates to:
  /// **'Export failed. Check storage permissions.'**
  String get exportError;

  /// L-9: one-time pre-share warning dialog title
  ///
  /// In en, this message translates to:
  /// **'Sharing financial data'**
  String get exportWarningTitle;

  /// L-9: one-time pre-share warning dialog body
  ///
  /// In en, this message translates to:
  /// **'You are about to share financial data. Only share with trusted recipients.'**
  String get exportWarningBody;

  /// Generic acknowledgement button label
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
