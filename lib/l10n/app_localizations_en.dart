// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Helm';

  @override
  String get appTagline => 'How much BDT can you actually spend right now?';

  @override
  String get continueSetupSafeToSpend =>
      'Continue — sets up your Safe-to-Spend';

  @override
  String get setUpLater => 'Set up later';

  @override
  String get signInToHelm => 'Sign in to Helm';

  @override
  String get magicLinkSubtitle =>
      'Enter your email — we\'ll send you a magic link to sign in instantly.';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get sendMagicLink => 'Send Magic Link';

  @override
  String get sending => 'Sending...';

  @override
  String get checkYourInbox => 'Check your inbox';

  @override
  String magicLinkSentSubtitle(String email) {
    return 'We sent a link to $email.\nEnter the code below, or tap the link in your email.';
  }

  @override
  String get pasteVerificationCode => 'Paste verification code';

  @override
  String get verifyAndSignIn => 'Verify & Sign In';

  @override
  String get verifying => 'Verifying...';

  @override
  String get useDifferentEmail => '← Use a different email';

  @override
  String get errorEnterEmail => 'Please enter your email address';

  @override
  String get errorInvalidEmail => 'Please enter a valid email address';

  @override
  String get errorTooManyRequests =>
      'Too many requests. Please wait before requesting another link.';

  @override
  String get errorEnterCode =>
      'Please enter the verification code or paste the link';

  @override
  String get errorInvalidCode =>
      'Invalid or expired verification code. Request a new one.';

  @override
  String get qualifyingQuestion =>
      'Have you ever spent money thinking a\npayment cleared, then realized it hadn\'t?';

  @override
  String get qualifyingSubtext =>
      'If you earn in USD and spend in BDT — through\nUpwork, Fiverr, or Payoneer — this happens a lot.';

  @override
  String get qualifyingRephraseBn =>
      'আপনি কি কখনো টাকা খরচ করে ফেলেছেন ভেবে যে\nপেমেন্ট ক্লিয়ার হয়েছে, পরে দেখেছেন হয়নি?';

  @override
  String get doesThatSoundFamiliar => 'Does that sound familiar?';

  @override
  String get yesHappenedToMe => 'Yes, that happens to me';

  @override
  String get noAlwaysKnow => 'No, I always know exactly what cleared';

  @override
  String get disqualifyHeading =>
      'Helm is built for USD-earning freelancers in Bangladesh.';

  @override
  String get disqualifySubtext =>
      'Come back when you start billing internationally.';

  @override
  String get close => 'Close';

  @override
  String get liquidBalanceQuestion => 'Roughly how much do you have right now?';

  @override
  String get liquidBalanceSubtext =>
      'bKash, bank, and cash — combined. A rough number is fine. You can refine it later.';

  @override
  String get liquidBalanceFieldLabel => 'Current liquid balance in BDT';

  @override
  String get liquidBalanceError =>
      'Enter your current liquid BDT to calculate Safe-to-Spend.';

  @override
  String get fixedCostsQuestion => 'What are your fixed monthly costs?';

  @override
  String get fixedCostsSubtext =>
      'Monthly costs due in the next 30 days. Tap any that apply.';

  @override
  String get fixedCostsNoneSelected => 'No fixed monthly costs selected.';

  @override
  String get fixedCostsNoneExplainer =>
      'Fixed costs reduce Safe-to-Spend. You can add them in Settings later.';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get letMeAddSome => 'Let me add some';

  @override
  String get firstPipelineQuestion => 'Any money coming in soon?';

  @override
  String get firstPipelineSubtext =>
      'Adding expected income helps Safe-to-Spend show you the full picture from day one.';

  @override
  String get clientOrSource => 'Client or source';

  @override
  String get clientOrSourceHint => 'e.g. Upwork, Client X';

  @override
  String get whoIsThisFrom => 'Who is this from?';

  @override
  String get pipelineEntryNote =>
      'This will be marked as \"Expected\". You can update the status later.';

  @override
  String get addToMyPipeline => 'Add to my pipeline';

  @override
  String get skipAddLater => 'Skip — I\'ll add it later';

  @override
  String get safeToSpendLabel => 'SAFE-TO-SPEND';

  @override
  String get safeToSpendSubLabel => 'after fixed costs + safety buffer';

  @override
  String get receivedOnly => 'Received only';

  @override
  String get tapToSeeMath => 'Tap the number to see the math';

  @override
  String get addPipelineEntry => 'Add income entry';

  @override
  String get fixedCostsSectionTitle => 'Fixed costs';

  @override
  String get fixedCostsSectionSubtitle =>
      'Monthly costs due in the next 30 days';

  @override
  String get fixedCostsEmpty =>
      'No fixed costs added yet. Add them to improve Safe-to-Spend accuracy.';

  @override
  String get addFixedCostsLink => 'Add fixed costs →';

  @override
  String get safetyBufferTitle => 'Safety buffer';

  @override
  String get safetyBufferSubtitle =>
      'Not locked — a safety margin inside the calculation';

  @override
  String get safetyBufferEmpty =>
      'No safety buffer set. Safe-to-Spend uses your full liquid BDT.';

  @override
  String get notCountedTitle => 'Not counted yet';

  @override
  String get notCountedSubtitle => 'Not counted yet — expected payments';

  @override
  String get notCountedEmpty =>
      'Add an expected payment when you invoice or expect money.';

  @override
  String get addExpectedPaymentLink => 'Add expected payment →';

  @override
  String get pending => 'Pending';

  @override
  String get expected => 'Expected';

  @override
  String get received => 'Received';

  @override
  String get ifAllCounted => 'If all counted:';

  @override
  String get addIncome => 'Add Income';

  @override
  String get editIncome => 'Edit Income';

  @override
  String get updateIncome => 'Update Income';

  @override
  String get saveIncome => 'Save Income';

  @override
  String get clientName => 'Client Name';

  @override
  String get clientNameHint => 'e.g. Upwork, Client X';

  @override
  String get clientNameRequired => 'Client name is required';

  @override
  String get projectName => 'Project Name';

  @override
  String get projectNameHint => 'e.g. Website Redesign';

  @override
  String get projectNameRequired => 'Project name is required';

  @override
  String get amount => 'Amount';

  @override
  String get amountRequired => 'Amount is required';

  @override
  String get amountInvalid => 'Enter a valid amount greater than 0';

  @override
  String get fxRateLabel => 'FX Rate (BDT per USD)';

  @override
  String get fxRateHint => 'e.g. 110.5';

  @override
  String get fxRateRequired => 'FX rate required';

  @override
  String get statusLabel => 'Status';

  @override
  String get expectedDate => 'Expected Date';

  @override
  String get receivedDate => 'Received Date';

  @override
  String get selectDate => 'Select date';

  @override
  String get selectReceivedDate => 'Select received date';

  @override
  String get pleaseSelectReceivedDate => 'Please select a received date.';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get addANote => 'Add a note…';

  @override
  String get paymentSourceOptional => 'Payment Source (optional)';

  @override
  String get paymentSourceHint => 'e.g. Upwork, Fiverr, Direct client';

  @override
  String get excludeFromSafeToSpend => 'Exclude from Safe-to-Spend';

  @override
  String get excludeFromSafeToSpendSubtitle =>
      'Use when this payment shouldn\'t affect your numbers';

  @override
  String get incomeUpdatedSuccess => 'Income updated successfully';

  @override
  String get incomeSavedSuccess => 'Income saved successfully';

  @override
  String get incomeFailedToSave => 'Failed to save income. Please try again.';

  @override
  String get incomeEntryNotFound => 'Income entry not found';

  @override
  String get incomeEntryDeleted => 'This income entry may have been deleted.';

  @override
  String get goBack => 'Go Back';

  @override
  String get excluded => 'Excluded';

  @override
  String get undo => 'Undo';

  @override
  String get confirmReceived => 'Confirm — adds to liquid';

  @override
  String get notYet => 'Not yet';

  @override
  String get amountReceived => 'Amount received';

  @override
  String get fxRateBdtPerUsd => 'FX rate (BDT per USD)';

  @override
  String get dateReceived => 'Date received';

  @override
  String get enterValidAmount => 'Enter a valid amount';

  @override
  String get notifications => 'Notifications';

  @override
  String get clearAll => 'Clear all';

  @override
  String get allNotificationsCleared => 'All notifications cleared';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get notificationsWillShowHere =>
      'Nudges and updates will show here when available.';

  @override
  String get notificationRemoved => 'Notification removed';

  @override
  String get dateGroupToday => 'Today';

  @override
  String get dateGroupYesterday => 'Yesterday';

  @override
  String get dateGroupThisWeek => 'This Week';

  @override
  String get dateGroupOlder => 'Older';

  @override
  String get notificationPreferences => 'Notification Preferences';

  @override
  String get checkInFrequency => 'Check-in Frequency';

  @override
  String get notificationPrefsSaved => 'Notification preferences saved';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get settings => 'Settings';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get devResetOnboarding => 'Reset onboarding (dev only)';

  @override
  String get useAsGuest => 'Use as Guest';

  @override
  String get safeToSpendSettingsTitle => 'Safe-to-Spend Settings';

  @override
  String get taxReserveRate => 'Tax Reserve Rate';

  @override
  String get taxReserveRateDescription =>
      'Estimated percentage of income to reserve for taxes.';

  @override
  String get breathingRoom => 'Breathing room';

  @override
  String get breathingRoomDescription =>
      'Reserve this % of expected income as a buffer';

  @override
  String breathingRoomPercentOfExpected(String percent) {
    return '$percent% of expected income';
  }

  @override
  String get fixedCosts => 'Fixed Costs';

  @override
  String get fixedCostsDescription =>
      'Fixed costs deducted from Safe-to-Spend each month.';

  @override
  String get noFixedCostsYet => 'No fixed costs added yet.';

  @override
  String get addFixedCost => 'Add Fixed Cost';

  @override
  String get saveFixedCost => 'Save Fixed Cost';

  @override
  String get editFixedCost => 'Edit Fixed Cost';

  @override
  String get exportMyData => 'Export my data';

  @override
  String get changeHistory => 'Change history';

  @override
  String get deleteAllData => 'Delete all data';

  @override
  String nbaOverdueTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count payments overdue',
      one: '1 payment overdue',
    );
    return '$_temp0';
  }

  @override
  String get nbaOverdueDescription =>
      'Update status of overdue pipeline payments.';

  @override
  String get nbaOverdueAction => 'Review';

  @override
  String get nbaAtRiskTitle => 'Safe-to-spend is tight';

  @override
  String get nbaAtRiskDescription =>
      'Review your fixed monthly costs to release pressure.';

  @override
  String get nbaAtRiskAction => 'Review fixed costs';

  @override
  String get nbaReliefTitle => 'Pipeline up to date';

  @override
  String get nbaReliefDescription =>
      'All payments are on schedule and tracked.';

  @override
  String get nbaSetupTitle => 'Add your first expected payment';

  @override
  String get nbaSetupDescription =>
      'Track upcoming income to compute Safe-to-Spend.';

  @override
  String get nbaSetupAction => 'Add payment';

  @override
  String get calcTraceTitle => 'How we calculated this';

  @override
  String get calcTraceSubtitle => 'Tap any line to learn more';

  @override
  String get calcTraceReceivedIncome => '+ Received income';

  @override
  String get calcTraceCashOut => '− Cash out';

  @override
  String get calcTraceLiquidBdt => '= Liquid BDT';

  @override
  String get calcTraceTaxReserve => '− Tax reserve (hold)';

  @override
  String get calcTraceFixedCosts => '− Fixed costs due';

  @override
  String get calcTraceSafetyBuffer => '− Safety buffer';

  @override
  String get calcTraceSafeToSpend => '= Safe-to-Spend';

  @override
  String get trustStripTapToAudit => 'Tap to audit';

  @override
  String get trustStripUpdatedJustNow => 'Updated just now';

  @override
  String trustStripUpdatedMinAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Updated $count mins ago',
      one: 'Updated 1 min ago',
    );
    return '$_temp0';
  }

  @override
  String trustStripUpdatedAt(String time) {
    return 'Updated $time';
  }

  @override
  String get pipelineOverdue => 'Overdue';

  @override
  String daysOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days overdue',
      one: '1 day overdue',
    );
    return '$_temp0';
  }

  @override
  String get dateToday => 'today';

  @override
  String get dateTomorrow => 'tomorrow';

  @override
  String get duplicateAsNextMonth => 'Duplicate as next month';

  @override
  String get swipeConfirmReceived => 'Confirm received';

  @override
  String get pipelineTitle => 'Pipeline';

  @override
  String get pipelineNeedsDecision => 'Needs decision';

  @override
  String get pipelineOverdueAttention => 'Overdue — needs attention';

  @override
  String get fxRateInvalid => 'Enter a valid positive rate';

  @override
  String get projectNameRecommended => 'Project Name (recommended)';

  @override
  String get pinCreateTitle => 'Create your PIN';

  @override
  String get pinConfirmTitle => 'Confirm your PIN';

  @override
  String get pinMismatchError => 'PINs don\'t match. Try again.';

  @override
  String get pinEnterTitle => 'Enter your PIN';

  @override
  String pinIncorrectAttempts(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: 'Incorrect PIN — $remaining attempts remaining',
      one: 'Incorrect PIN — 1 attempt remaining',
    );
    return '$_temp0';
  }

  @override
  String get pinTooManyAttempts => 'Too many attempts. Try again later.';

  @override
  String get pinTryAgain => 'Try again.';

  @override
  String pinLockedCountdown(String minutes, String seconds) {
    return 'Locked. Try again in ${minutes}m ${seconds}s';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Onboarding step $step of $total';
  }

  @override
  String get liquidBalanceInputSemantics => 'Current liquid balance input';

  @override
  String get liquidBalanceRoughEstimate =>
      'A rough estimate is fine — you can update it later.';

  @override
  String get saveLiquidBalance => 'Save — updates Safe-to-Spend';

  @override
  String get incomePatternQuestion => 'How does your income usually arrive?';

  @override
  String get incomePatternSubtext =>
      'Pick the pattern that fits most of your earnings.';

  @override
  String get incomePatternMarketplaceTitle => 'Marketplace escrow';

  @override
  String get incomePatternMarketplacePlatform => 'Upwork, Fiverr, Payoneer';

  @override
  String get incomePatternMarketplaceSubtitle =>
      'Payment held until milestone or job completion';

  @override
  String get incomePatternDirectTitle => 'Direct client';

  @override
  String get incomePatternDirectPlatform => 'You invoice clients directly';

  @override
  String get incomePatternDirectSubtitle =>
      'Payment terms agreed with each client';

  @override
  String get incomePatternRetainerTitle => 'Retainer / Recurring';

  @override
  String get incomePatternRetainerPlatform =>
      'Same client, same amount each month';

  @override
  String get incomePatternRetainerSubtitle => 'Predictable monthly income';

  @override
  String get incomePatternSelectError =>
      'Please select an income pattern to continue.';

  @override
  String get saveIncomePattern => 'Save — sets income pattern';

  @override
  String get bufferTitle => 'Set your safety buffer';

  @override
  String get bufferSubtext =>
      'This is not locked money. It is a safety margin inside the calculation.';

  @override
  String bufferSliderSemantics(int percent) {
    return 'Safety buffer slider: $percent%';
  }

  @override
  String bufferSliderValue(int percent) {
    return '$percent percent';
  }

  @override
  String bufferS2sPreviewPositive(int percent) {
    return 'Safe to spend preview: $percent% buffer of total';
  }

  @override
  String get bufferS2sPreviewNegative =>
      'Safe to spend preview shows negative balance';

  @override
  String get bufferSafeToSpendLabel => 'Safe-to-Spend';

  @override
  String get bufferCostsExceedBalance =>
      'Your costs exceed liquid balance. Adjust buffer or add expected income.';

  @override
  String get saveBuffer => 'Save — finish Safe-to-Spend setup';

  @override
  String get fixedCostsDueDayTooltip =>
      'Due day is the day of month when this cost is usually paid (1-28 to align with billing cycles)';

  @override
  String get fixedCostsDueDay => 'due day';

  @override
  String get fixedCostsAmountHint => 'amount';

  @override
  String fixedCostsCategorySemantics(String label, String state) {
    return '$label, $state';
  }

  @override
  String get fixedCostsCategorySelected => 'selected';

  @override
  String get fixedCostsCategoryNotSelected => 'not selected';

  @override
  String get continueButton => 'Continue';

  @override
  String get fixedCostsCategoryRentHousing => 'Rent / Housing';

  @override
  String get fixedCostsCategoryInternet => 'Internet';

  @override
  String get fixedCostsCategoryMobilePhone => 'Mobile / Phone';

  @override
  String get fixedCostsCategorySubscriptions => 'Subscriptions';

  @override
  String get fixedCostsCategoryFamilySupport => 'Family support / Parents';

  @override
  String get fixedCostsCategoryLoanEmi => 'Loan EMI';

  @override
  String get fixedCostsCategoryOther => 'Other fixed cost';

  @override
  String get pipelineClientNameSemantics => 'Client or source name input';

  @override
  String pipelineAmountSemantics(String currency) {
    return 'Amount input in $currency';
  }

  @override
  String get pipelineCurrencySemantics => 'Currency selector';

  @override
  String get pipelineEntryNoteSemantics =>
      'Information: This will be marked as Expected. You can update the status later.';

  @override
  String get pipelineSkipSemantics =>
      'Skip adding pipeline entry and continue to home';

  @override
  String get pipelineAddAndContinue => 'Add and continue';

  @override
  String get pipelineAdding => 'Adding...';

  @override
  String get pipelineAmountMustBePositive => 'Must be > 0';

  @override
  String get auditLogLoadError => 'Unable to load history.';

  @override
  String get auditLogEmpty => 'No changes recorded yet.';

  @override
  String get auditEntityIncome => 'Income';

  @override
  String get auditEntityTransaction => 'Transaction';

  @override
  String get auditEntitySettings => 'Settings';

  @override
  String get auditEntityFixedCost => 'Fixed cost';

  @override
  String get auditEntityRecord => 'Record';

  @override
  String auditEventAdded(String entity) {
    return '$entity added';
  }

  @override
  String auditEventUpdated(String entity) {
    return '$entity updated';
  }

  @override
  String auditEventDeleted(String entity) {
    return '$entity deleted';
  }

  @override
  String auditEventConfirmed(String entity) {
    return '$entity confirmed';
  }

  @override
  String auditEventExported(String entity) {
    return '$entity exported';
  }

  @override
  String auditEventChanged(String entity) {
    return '$entity changed';
  }

  @override
  String get deleteCannotBeUndone => 'This cannot be undone';

  @override
  String get deleteWarningBody =>
      'Deleting your data will permanently remove all your income entries, transactions, settings, and change history from this device. There is no way to recover this data.';

  @override
  String get deleteWhatWillBeDeleted => 'What will be deleted';

  @override
  String get deleteItemAllIncomeEntries => 'All income entries';

  @override
  String get deleteItemAllTransactions => 'All transactions';

  @override
  String get deleteItemAllFixedCosts => 'All fixed costs';

  @override
  String get deleteItemYourSettings => 'Your settings';

  @override
  String get deleteContinue => 'Continue to delete';

  @override
  String get deletePinConfirmTitle => 'Enter your PIN to confirm';

  @override
  String get deleteIncorrectPin => 'Incorrect PIN';

  @override
  String deleteLockoutMessage(String minutes) {
    return 'Too many attempts. Try again in ${minutes}m.';
  }

  @override
  String get deleteTypeConfirmTitle => 'Type \"DELETE\" to confirm';

  @override
  String get deleteConfirmHint => 'DELETE';

  @override
  String get exportDataBelongsToYou => 'Your data belongs to you';

  @override
  String get exportDescription =>
      'Export all your Helm data as CSV files. Open them in any spreadsheet app — Excel, Google Sheets, or Numbers.';

  @override
  String get exportWarning =>
      'Exported files are not encrypted and may contain sensitive information such as client names and amounts. Only share them through trusted channels and delete the files from your device when you are done.';

  @override
  String get exportWhatWillBeExported => 'What will be exported';

  @override
  String get exportItemIncomeEntries => 'Income entries';

  @override
  String get exportItemTransactions => 'Transactions';

  @override
  String get exportItemFixedCosts => 'Fixed costs';

  @override
  String get exportItemSettings => 'Settings';

  @override
  String get exportAllData => 'Export all data';

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get exportShareSubject => 'Helm data export';

  @override
  String taxRateSemantics(String percent) {
    return 'Tax rate: $percent%';
  }

  @override
  String safetyBufferSemantics(String percent) {
    return 'Safety buffer: $percent%';
  }

  @override
  String itemDeleted(String label) {
    return '$label deleted';
  }

  @override
  String dueDay(String day) {
    return 'Due: Day $day';
  }

  @override
  String get fixedCostLabelHint => 'Label (e.g. Internet, Rent)';

  @override
  String get fixedCostLabelRequired => 'Label is required';

  @override
  String get amountMustBePositive => 'Must be > 0';

  @override
  String get dueDayLabel => 'Due Day';

  @override
  String get dueDayHint => '1-28';

  @override
  String get dueDayValidation => '1-28 only';

  @override
  String get preferredCheckInTime => 'Preferred Check-in Time';

  @override
  String get alertChannels => 'Alert Channels';

  @override
  String get pushNotifications => 'Push notifications';

  @override
  String get pushNotificationsSubtitle => 'Receive alerts on expected dates';

  @override
  String get inAppNotificationBanner => 'In-app notification banner';

  @override
  String get inAppNotificationSubtitle =>
      'Show bill warning hints in dashboard';

  @override
  String get quietAffirmations => 'Quiet affirmations';

  @override
  String get quietAffirmationsSubtitle =>
      'Display calm confirmation status on hero block';

  @override
  String get savePreferences => 'Save Preferences';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get transactionNotFound => 'Transaction not found';

  @override
  String get transactionMayBeDeleted => 'This payment may have been deleted.';

  @override
  String get editCashOut => 'Edit cash out';

  @override
  String get recordCashOut => 'Record cash out';

  @override
  String get transactionTitle => 'Title';

  @override
  String get transactionTitleHint => 'e.g. Lunch, Uber, Salary';

  @override
  String get titleRequired => 'Title is required';

  @override
  String get enterValidAmountGreaterThanZero =>
      'Enter a valid amount greater than 0';

  @override
  String get date => 'Date';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get addNoteHint => 'Add a note…';

  @override
  String get updateTransaction => 'Update Transaction';

  @override
  String get saveTransaction => 'Save Transaction';

  @override
  String get transactionUpdated => 'Transaction updated successfully';

  @override
  String get transactionSaved => 'Transaction saved successfully';

  @override
  String get transactionSaveError => 'Could not save payment. Try again.';

  @override
  String ledgerVerified(int count) {
    return 'Ledger verified · $count records';
  }

  @override
  String get ledgerIntegrityIssue => 'Integrity issue detected';

  @override
  String get ledgerVerifying => 'Verifying ledger…';

  @override
  String historyRetentionNote(int days) {
    return 'History keeps the last $days days';
  }

  @override
  String get historyGroupToday => 'Today';

  @override
  String get historyGroupYesterday => 'Yesterday';

  @override
  String get historyGroupThisWeek => 'This week';

  @override
  String get historyGroupEarlier => 'Earlier';

  @override
  String get auditDetailBefore => 'Before';

  @override
  String get auditDetailAfter => 'After';

  @override
  String get auditDetailDescription => 'Description';

  @override
  String get auditDetailTimestamp => 'When';

  @override
  String get auditDetailEntity => 'Record';

  @override
  String get auditDetailRecordHash => 'Record hash';

  @override
  String get auditRelativeJustNow => 'Just now';

  @override
  String auditRelativeMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String auditRelativeHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String get spendTitle => 'Spend';

  @override
  String get spendSummaryLabel => 'Spent this month · reduces Safe-to-Spend';

  @override
  String get spendEmptyTitle => 'Nothing spent yet';

  @override
  String get spendEmptyBody =>
      'Record money you have already paid out — each payment updates your Safe-to-Spend.';

  @override
  String get spendFabLabel => 'Add a payment';

  @override
  String get tabHome => 'Home';

  @override
  String get tabPipeline => 'Pipeline';

  @override
  String get tabSpend => 'Spend';

  @override
  String get tabHomeTip => 'Safe-to-Spend';

  @override
  String get tabPipelineTip => 'Income pipeline';

  @override
  String get tabSpendTip => 'Money spent';

  @override
  String get viewAuditTrail => 'View audit trail';

  @override
  String get viewTrace => 'View trace';

  @override
  String get compromisedDeviceTitle => 'This device appears to be compromised';

  @override
  String get compromisedDeviceBody =>
      'Helm cannot run on rooted or jailbroken devices because your local financial data could be exposed. Please use an unmodified device.';

  @override
  String get closeHelm => 'Close Helm';

  @override
  String get cautionCritical => 'Critical';

  @override
  String get cautionWarning => 'Warning';

  @override
  String get csvExportWarning =>
      'CSV export contains unencrypted financial data. Only share with trusted recipients.';

  @override
  String get deleteConfirmTitle => 'Confirm deletion';

  @override
  String get delete => 'Delete';
}
