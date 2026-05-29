import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('en'),
    Locale('uk'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'V-Fridge'**
  String get appTitle;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get actionLeave;

  /// No description provided for @wordOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get wordOr;

  /// No description provided for @navFridge.
  ///
  /// In en, this message translates to:
  /// **'Fridge'**
  String get navFridge;

  /// No description provided for @navShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get navShopping;

  /// No description provided for @navPlanner.
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get navPlanner;

  /// No description provided for @navChef.
  ///
  /// In en, this message translates to:
  /// **'Chef'**
  String get navChef;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @signinTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get signinTitle;

  /// No description provided for @signinContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get signinContinueWithGoogle;

  /// No description provided for @signinGoogleFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed: {error}'**
  String signinGoogleFailed(String error);

  /// No description provided for @signinEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get signinEmail;

  /// No description provided for @signinPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signinPassword;

  /// No description provided for @signinSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signinSubmit;

  /// No description provided for @signinNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account yet? Sign up'**
  String get signinNoAccount;

  /// No description provided for @signinNotVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Email is not verified yet.'**
  String get signinNotVerifiedTitle;

  /// No description provided for @signinNotVerifiedBody.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox or send a new email.'**
  String get signinNotVerifiedBody;

  /// No description provided for @signinResend.
  ///
  /// In en, this message translates to:
  /// **'Resend verification email'**
  String get signinResend;

  /// No description provided for @signinResendSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent'**
  String get signinResendSent;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signupTitle;

  /// No description provided for @signupUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display name (optional)'**
  String get signupUsernameLabel;

  /// No description provided for @signupUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to use your email prefix'**
  String get signupUsernameHint;

  /// No description provided for @signupPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password (min 6 chars)'**
  String get signupPasswordLabel;

  /// No description provided for @signupSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signupSubmit;

  /// No description provided for @signupHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get signupHaveAccount;

  /// No description provided for @signupDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get signupDoneTitle;

  /// No description provided for @signupDoneBody.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to {email}. Tap the link in the email and you will land back here signed in.'**
  String signupDoneBody(String email);

  /// No description provided for @signupBackToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get signupBackToSignIn;

  /// No description provided for @dashboardEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your fridge is empty'**
  String get dashboardEmptyTitle;

  /// No description provided for @dashboardEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add the first product to get started.'**
  String get dashboardEmptyBody;

  /// No description provided for @dashboardAddProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get dashboardAddProduct;

  /// No description provided for @dashboardActiveFor.
  ///
  /// In en, this message translates to:
  /// **'Inventory for'**
  String get dashboardActiveFor;

  /// No description provided for @shoppingActiveFor.
  ///
  /// In en, this message translates to:
  /// **'Shopping list for'**
  String get shoppingActiveFor;

  /// No description provided for @plannerActiveFor.
  ///
  /// In en, this message translates to:
  /// **'Meal plan for'**
  String get plannerActiveFor;

  /// No description provided for @dashboardConfirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String dashboardConfirmDeleteTitle(String name);

  /// No description provided for @dashboardConsumeLogged.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" finished — logged'**
  String dashboardConsumeLogged(String name);

  /// No description provided for @productActionMarkFinished.
  ///
  /// In en, this message translates to:
  /// **'Mark finished'**
  String get productActionMarkFinished;

  /// No description provided for @productNoDate.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get productNoDate;

  /// No description provided for @productExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired {date}'**
  String productExpired(String date);

  /// No description provided for @productDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day left} other{{count} days left}}'**
  String productDaysLeft(int count);

  /// No description provided for @productFreshUntil.
  ///
  /// In en, this message translates to:
  /// **'Fresh until {date}'**
  String productFreshUntil(String date);

  /// No description provided for @addProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProductTitle;

  /// No description provided for @addProductEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get addProductEditTitle;

  /// No description provided for @addProductActionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to fridge'**
  String get addProductActionAdd;

  /// No description provided for @addProductScanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get addProductScanBarcode;

  /// No description provided for @addProductName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get addProductName;

  /// No description provided for @addProductQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get addProductQuantity;

  /// No description provided for @addProductUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get addProductUnit;

  /// No description provided for @addProductCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get addProductCategory;

  /// No description provided for @addProductExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get addProductExpiry;

  /// No description provided for @addProductNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name is too short'**
  String get addProductNameTooShort;

  /// No description provided for @addProductQuantityTooLow.
  ///
  /// In en, this message translates to:
  /// **'Quantity must be greater than 0'**
  String get addProductQuantityTooLow;

  /// No description provided for @addProductFilledFromBarcode.
  ///
  /// In en, this message translates to:
  /// **'Filled from barcode {barcode}'**
  String addProductFilledFromBarcode(String barcode);

  /// No description provided for @barcodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get barcodeTitle;

  /// No description provided for @barcodeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found in OpenFoodFacts'**
  String get barcodeNotFound;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'AI chef'**
  String get chatTitle;

  /// No description provided for @chatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'online and ready'**
  String get chatSubtitle;

  /// No description provided for @chatEmpty.
  ///
  /// In en, this message translates to:
  /// **'Ask the chef what to cook with what you have.'**
  String get chatEmpty;

  /// No description provided for @chatEmptyHero.
  ///
  /// In en, this message translates to:
  /// **'What are we cooking today?'**
  String get chatEmptyHero;

  /// No description provided for @chatThinking.
  ///
  /// In en, this message translates to:
  /// **'Chef is cooking up a reply…'**
  String get chatThinking;

  /// No description provided for @chatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask for a recipe…'**
  String get chatInputHint;

  /// No description provided for @chatRateLimit.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Try again in a minute.'**
  String get chatRateLimit;

  /// No description provided for @chatClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear chat history?'**
  String get chatClearTitle;

  /// No description provided for @chatClearAction.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get chatClearAction;

  /// No description provided for @chatPrompt1.
  ///
  /// In en, this message translates to:
  /// **'What can I cook tonight?'**
  String get chatPrompt1;

  /// No description provided for @chatPrompt2.
  ///
  /// In en, this message translates to:
  /// **'Help me use up what is expiring'**
  String get chatPrompt2;

  /// No description provided for @chatPrompt3.
  ///
  /// In en, this message translates to:
  /// **'A quick 20-minute meal'**
  String get chatPrompt3;

  /// No description provided for @chatPrompt4.
  ///
  /// In en, this message translates to:
  /// **'Something light and healthy'**
  String get chatPrompt4;

  /// No description provided for @shoppingTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get shoppingTitle;

  /// No description provided for @shoppingEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your list is empty.'**
  String get shoppingEmpty;

  /// No description provided for @shoppingToBuy.
  ///
  /// In en, this message translates to:
  /// **'To buy'**
  String get shoppingToBuy;

  /// No description provided for @shoppingGotThem.
  ///
  /// In en, this message translates to:
  /// **'Got them'**
  String get shoppingGotThem;

  /// No description provided for @shoppingMoveToFridge.
  ///
  /// In en, this message translates to:
  /// **'Move to fridge'**
  String get shoppingMoveToFridge;

  /// No description provided for @shoppingAddedToFridge.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" added to the fridge'**
  String shoppingAddedToFridge(String name);

  /// No description provided for @shoppingAddSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to shopping list'**
  String get shoppingAddSheetTitle;

  /// No description provided for @shoppingFieldItem.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get shoppingFieldItem;

  /// No description provided for @shoppingFieldQty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get shoppingFieldQty;

  /// No description provided for @shoppingNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get shoppingNameRequired;

  /// No description provided for @plannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal planner'**
  String get plannerTitle;

  /// No description provided for @plannerEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No plan yet'**
  String get plannerEmptyTitle;

  /// No description provided for @plannerEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the wand to ask the AI chef for five weekday meals from your inventory.'**
  String get plannerEmptyBody;

  /// No description provided for @plannerGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate plan'**
  String get plannerGenerate;

  /// No description provided for @plannerMissingIngredients.
  ///
  /// In en, this message translates to:
  /// **'Missing ingredients'**
  String get plannerMissingIngredients;

  /// No description provided for @plannerAddToShopping.
  ///
  /// In en, this message translates to:
  /// **'Add to shopping list'**
  String get plannerAddToShopping;

  /// No description provided for @plannerImportResult.
  ///
  /// In en, this message translates to:
  /// **'{created, plural, =1{1 added to shopping list} other{{created} added to shopping list}}'**
  String plannerImportResult(int created);

  /// No description provided for @plannerImportSkipped.
  ///
  /// In en, this message translates to:
  /// **' ({skipped} already there)'**
  String plannerImportSkipped(int skipped);

  /// No description provided for @plannerDayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get plannerDayMonday;

  /// No description provided for @plannerDayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get plannerDayTuesday;

  /// No description provided for @plannerDayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get plannerDayWednesday;

  /// No description provided for @plannerDayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get plannerDayThursday;

  /// No description provided for @plannerDayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get plannerDayFriday;

  /// No description provided for @plannerDaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get plannerDaySaturday;

  /// No description provided for @plannerDaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get plannerDaySunday;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageAuto.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsLanguageAuto;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageUkrainian.
  ///
  /// In en, this message translates to:
  /// **'Українська'**
  String get settingsLanguageUkrainian;

  /// No description provided for @settingsCuisine.
  ///
  /// In en, this message translates to:
  /// **'Cuisine'**
  String get settingsCuisine;

  /// No description provided for @settingsCuisineHint.
  ///
  /// In en, this message translates to:
  /// **'What the chef leans toward when suggesting recipes.'**
  String get settingsCuisineHint;

  /// No description provided for @cuisineAny.
  ///
  /// In en, this message translates to:
  /// **'No preference'**
  String get cuisineAny;

  /// No description provided for @cuisineUkrainian.
  ///
  /// In en, this message translates to:
  /// **'Ukrainian'**
  String get cuisineUkrainian;

  /// No description provided for @cuisineGeorgian.
  ///
  /// In en, this message translates to:
  /// **'Georgian'**
  String get cuisineGeorgian;

  /// No description provided for @cuisineItalian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get cuisineItalian;

  /// No description provided for @cuisineFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get cuisineFrench;

  /// No description provided for @cuisineMexican.
  ///
  /// In en, this message translates to:
  /// **'Mexican'**
  String get cuisineMexican;

  /// No description provided for @cuisineMiddleEastern.
  ///
  /// In en, this message translates to:
  /// **'Middle Eastern'**
  String get cuisineMiddleEastern;

  /// No description provided for @cuisineIndian.
  ///
  /// In en, this message translates to:
  /// **'Indian'**
  String get cuisineIndian;

  /// No description provided for @cuisineChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get cuisineChinese;

  /// No description provided for @cuisineJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get cuisineJapanese;

  /// No description provided for @cuisineThai.
  ///
  /// In en, this message translates to:
  /// **'Thai'**
  String get cuisineThai;

  /// No description provided for @cuisineAmerican.
  ///
  /// In en, this message translates to:
  /// **'American'**
  String get cuisineAmerican;

  /// No description provided for @settingsEmailVerified.
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get settingsEmailVerified;

  /// No description provided for @settingsEmailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email not verified'**
  String get settingsEmailNotVerified;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOut;

  /// No description provided for @settingsSignOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get settingsSignOutConfirm;

  /// No description provided for @settingsDangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get settingsDangerZone;

  /// No description provided for @settingsClearProducts.
  ///
  /// In en, this message translates to:
  /// **'Clear all products'**
  String get settingsClearProducts;

  /// No description provided for @settingsClearProductsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Empties the active fridge'**
  String get settingsClearProductsSubtitle;

  /// No description provided for @settingsClearProductsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear all products?'**
  String get settingsClearProductsConfirm;

  /// No description provided for @settingsFridgeCleared.
  ///
  /// In en, this message translates to:
  /// **'Fridge cleared'**
  String get settingsFridgeCleared;

  /// No description provided for @settingsDeleteChat.
  ///
  /// In en, this message translates to:
  /// **'Delete chat history'**
  String get settingsDeleteChat;

  /// No description provided for @settingsDeleteChatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Wipes the AI chef conversation'**
  String get settingsDeleteChatSubtitle;

  /// No description provided for @settingsDeleteChatConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete chat history?'**
  String get settingsDeleteChatConfirm;

  /// No description provided for @settingsChatCleared.
  ///
  /// In en, this message translates to:
  /// **'Chat history cleared'**
  String get settingsChatCleared;

  /// No description provided for @settingsCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get settingsCannotBeUndone;

  /// No description provided for @fridgesTitle.
  ///
  /// In en, this message translates to:
  /// **'Fridges'**
  String get fridgesTitle;

  /// No description provided for @fridgesOwner.
  ///
  /// In en, this message translates to:
  /// **'owner'**
  String get fridgesOwner;

  /// No description provided for @fridgesMembers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member} other{{count} members}}'**
  String fridgesMembers(int count);

  /// No description provided for @fridgesNewName.
  ///
  /// In en, this message translates to:
  /// **'New fridge name'**
  String get fridgesNewName;

  /// No description provided for @fridgesNewNameHint.
  ///
  /// In en, this message translates to:
  /// **'My second fridge'**
  String get fridgesNewNameHint;

  /// No description provided for @fridgesInviteEmail.
  ///
  /// In en, this message translates to:
  /// **'Invite by email'**
  String get fridgesInviteEmail;

  /// No description provided for @fridgesInviteHint.
  ///
  /// In en, this message translates to:
  /// **'invitee@example.com'**
  String get fridgesInviteHint;

  /// No description provided for @fridgesInviteSent.
  ///
  /// In en, this message translates to:
  /// **'Invite sent to {email}'**
  String fridgesInviteSent(String email);

  /// No description provided for @fridgesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String fridgesDeleteTitle(String name);

  /// No description provided for @fridgesDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Products and members will be gone.'**
  String get fridgesDeleteBody;

  /// No description provided for @fridgesLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave \"{name}\"?'**
  String fridgesLeaveTitle(String name);

  /// No description provided for @fridgesMenuInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get fridgesMenuInvite;

  /// No description provided for @fridgesMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get fridgesMenuDelete;

  /// No description provided for @fridgesMenuLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get fridgesMenuLeave;

  /// No description provided for @fridgesActiveHint.
  ///
  /// In en, this message translates to:
  /// **'Use the switcher in the top bar to change the active fridge. Shared fridges show up here once you accept an invite.'**
  String get fridgesActiveHint;

  /// No description provided for @fridgesNoneTitle.
  ///
  /// In en, this message translates to:
  /// **'No fridges yet'**
  String get fridgesNoneTitle;

  /// No description provided for @fridgesNoneBody.
  ///
  /// In en, this message translates to:
  /// **'Create your first fridge to start tracking groceries.'**
  String get fridgesNoneBody;

  /// No description provided for @fridgesNoneCta.
  ///
  /// In en, this message translates to:
  /// **'Create fridge'**
  String get fridgesNoneCta;

  /// No description provided for @analyticsMostWasted.
  ///
  /// In en, this message translates to:
  /// **'Most wasted'**
  String get analyticsMostWasted;

  /// No description provided for @analyticsMostWastedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get analyticsMostWastedSubtitle;

  /// No description provided for @analyticsFastestConsumed.
  ///
  /// In en, this message translates to:
  /// **'Fastest consumed'**
  String get analyticsFastestConsumed;

  /// No description provided for @analyticsFastestConsumedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Days from add to finished'**
  String get analyticsFastestConsumedSubtitle;

  /// No description provided for @analyticsDaysShort.
  ///
  /// In en, this message translates to:
  /// **'{n}d'**
  String analyticsDaysShort(int n);

  /// No description provided for @categoryDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get categoryDairy;

  /// No description provided for @categoryMeatFish.
  ///
  /// In en, this message translates to:
  /// **'Meat & fish'**
  String get categoryMeatFish;

  /// No description provided for @categoryVegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables & greens'**
  String get categoryVegetables;

  /// No description provided for @categoryFruits.
  ///
  /// In en, this message translates to:
  /// **'Fruits & berries'**
  String get categoryFruits;

  /// No description provided for @categoryBakery.
  ///
  /// In en, this message translates to:
  /// **'Bread & bakery'**
  String get categoryBakery;

  /// No description provided for @categoryPantry.
  ///
  /// In en, this message translates to:
  /// **'Pantry staples'**
  String get categoryPantry;

  /// No description provided for @categorySnacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks & sweets'**
  String get categorySnacks;

  /// No description provided for @categoryDrinks.
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get categoryDrinks;

  /// No description provided for @categoryAlcohol.
  ///
  /// In en, this message translates to:
  /// **'Alcohol'**
  String get categoryAlcohol;

  /// No description provided for @categorySauces.
  ///
  /// In en, this message translates to:
  /// **'Sauces, oils & spices'**
  String get categorySauces;

  /// No description provided for @categoryFrozen.
  ///
  /// In en, this message translates to:
  /// **'Frozen'**
  String get categoryFrozen;

  /// No description provided for @categoryCannedPrepared.
  ///
  /// In en, this message translates to:
  /// **'Canned & ready-to-eat'**
  String get categoryCannedPrepared;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;
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
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
