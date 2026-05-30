// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'V-Fridge';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionSave => 'Save';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionOk => 'OK';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionLeave => 'Leave';

  @override
  String get wordOr => 'or';

  @override
  String get navFridge => 'Fridge';

  @override
  String get navShopping => 'Shopping';

  @override
  String get navPlanner => 'Planner';

  @override
  String get navChef => 'Chef';

  @override
  String get navSettings => 'Settings';

  @override
  String get signinTitle => 'Welcome back';

  @override
  String get signinContinueWithGoogle => 'Continue with Google';

  @override
  String signinGoogleFailed(String error) {
    return 'Google sign-in failed: $error';
  }

  @override
  String get signinEmail => 'Email';

  @override
  String get signinPassword => 'Password';

  @override
  String get signinSubmit => 'Sign in';

  @override
  String get signinNoAccount => 'No account yet? Sign up';

  @override
  String get signinNotVerifiedTitle => 'Email is not verified yet.';

  @override
  String get signinNotVerifiedBody => 'Check your inbox or send a new email.';

  @override
  String get signinResend => 'Resend verification email';

  @override
  String get signinResendSent => 'Verification email sent';

  @override
  String get signupTitle => 'Create account';

  @override
  String get signupUsernameLabel => 'Display name (optional)';

  @override
  String get signupUsernameHint => 'Leave empty to use your email prefix';

  @override
  String get signupPasswordLabel => 'Password (min 6 chars)';

  @override
  String get signupSubmit => 'Create account';

  @override
  String get signupHaveAccount => 'Already have an account? Sign in';

  @override
  String get signupDoneTitle => 'Check your inbox';

  @override
  String signupDoneBody(String email) {
    return 'We sent a verification link to $email. Tap the link in the email and you will land back here signed in.';
  }

  @override
  String get signupBackToSignIn => 'Back to sign in';

  @override
  String get dashboardEmptyTitle => 'Your fridge is empty';

  @override
  String get dashboardEmptyBody => 'Add the first product to get started.';

  @override
  String get dashboardAddProduct => 'Add product';

  @override
  String get dashboardActiveFor => 'Inventory for';

  @override
  String get shoppingActiveFor => 'Shopping list for';

  @override
  String get plannerActiveFor => 'Meal plan for';

  @override
  String dashboardConfirmDeleteTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String dashboardConsumeLogged(String name) {
    return '\"$name\" finished — logged';
  }

  @override
  String get productActionMarkFinished => 'Mark finished';

  @override
  String get productNoDate => 'No date';

  @override
  String productExpired(String date) {
    return 'Expired $date';
  }

  @override
  String productDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String productFreshUntil(String date) {
    return 'Fresh until $date';
  }

  @override
  String get addProductTitle => 'Add product';

  @override
  String get addProductEditTitle => 'Edit product';

  @override
  String get addProductActionAdd => 'Add to fridge';

  @override
  String get addProductScanBarcode => 'Scan barcode';

  @override
  String get addProductName => 'Name';

  @override
  String get addProductQuantity => 'Quantity';

  @override
  String get addProductUnit => 'Unit';

  @override
  String get addProductCategory => 'Category';

  @override
  String get addProductExpiry => 'Expiry date';

  @override
  String get addProductNameTooShort => 'Name is too short';

  @override
  String get addProductQuantityTooLow => 'Quantity must be greater than 0';

  @override
  String addProductFilledFromBarcode(String barcode) {
    return 'Filled from barcode $barcode';
  }

  @override
  String addProductIncompleteWarning(String fields) {
    return 'Some details are missing ($fields). Incomplete data can lead the AI chef to wrong suggestions. You can still add it.';
  }

  @override
  String get addProductIncompleteCategory => 'category';

  @override
  String get addProductIncompleteQuantity => 'quantity';

  @override
  String get addProductIncompleteExpiry => 'expiry date';

  @override
  String get barcodeTitle => 'Scan barcode';

  @override
  String get barcodeNotFound => 'Product not found in OpenFoodFacts';

  @override
  String get chatTitle => 'AI chef';

  @override
  String get chatSubtitle => 'online and ready';

  @override
  String get chatEmpty => 'Ask the chef what to cook with what you have.';

  @override
  String get chatEmptyHero => 'What are we cooking today?';

  @override
  String get chatThinking => 'Chef is cooking up a reply…';

  @override
  String get chatInputHint => 'Ask for a recipe…';

  @override
  String get chatRateLimit => 'Too many requests. Try again in a minute.';

  @override
  String get chatClearTitle => 'Clear chat history?';

  @override
  String get chatClearAction => 'Clear';

  @override
  String get chatPrompt1 => 'What can I cook tonight?';

  @override
  String get chatPrompt2 => 'Help me use up what is expiring';

  @override
  String get chatPrompt3 => 'A quick 20-minute meal';

  @override
  String get chatPrompt4 => 'Something light and healthy';

  @override
  String get shoppingTitle => 'Shopping list';

  @override
  String get shoppingEmpty => 'Your list is empty.';

  @override
  String get shoppingToBuy => 'To buy';

  @override
  String get shoppingGotThem => 'Got them';

  @override
  String get shoppingMoveToFridge => 'Move to fridge';

  @override
  String shoppingAddedToFridge(String name) {
    return '\"$name\" added to the fridge';
  }

  @override
  String get shoppingAddSheetTitle => 'Add to shopping list';

  @override
  String get shoppingFieldItem => 'Item';

  @override
  String get shoppingFieldQty => 'Qty';

  @override
  String get shoppingNameRequired => 'Name is required';

  @override
  String get plannerTitle => 'Meal planner';

  @override
  String get plannerEmptyTitle => 'No plan yet';

  @override
  String get plannerEmptyBody =>
      'Tap the wand to ask the AI chef for five weekday meals from your inventory.';

  @override
  String get plannerGenerate => 'Generate plan';

  @override
  String get plannerMissingIngredients => 'Missing ingredients';

  @override
  String get plannerAddToShopping => 'Add to shopping list';

  @override
  String plannerImportResult(int created) {
    String _temp0 = intl.Intl.pluralLogic(
      created,
      locale: localeName,
      other: '$created added to shopping list',
      one: '1 added to shopping list',
    );
    return '$_temp0';
  }

  @override
  String plannerImportSkipped(int skipped) {
    return ' ($skipped already there)';
  }

  @override
  String get plannerRegenerateDay => 'Regenerate this day';

  @override
  String get plannerRecipeSteps => 'Recipe';

  @override
  String get plannerIngredients => 'Ingredients';

  @override
  String get plannerNoRecipeDetails =>
      'No recipe details for this meal yet. Regenerate the day to get a full recipe.';

  @override
  String get plannerDayMonday => 'Monday';

  @override
  String get plannerDayTuesday => 'Tuesday';

  @override
  String get plannerDayWednesday => 'Wednesday';

  @override
  String get plannerDayThursday => 'Thursday';

  @override
  String get plannerDayFriday => 'Friday';

  @override
  String get plannerDaySaturday => 'Saturday';

  @override
  String get plannerDaySunday => 'Sunday';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageAuto => 'System';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageUkrainian => 'Українська';

  @override
  String get settingsCuisine => 'Cuisine';

  @override
  String get settingsCuisineHint =>
      'What the chef leans toward when suggesting recipes.';

  @override
  String get cuisineAny => 'No preference';

  @override
  String get cuisineUkrainian => 'Ukrainian';

  @override
  String get cuisineGeorgian => 'Georgian';

  @override
  String get cuisineItalian => 'Italian';

  @override
  String get cuisineFrench => 'French';

  @override
  String get cuisineMexican => 'Mexican';

  @override
  String get cuisineMiddleEastern => 'Middle Eastern';

  @override
  String get cuisineIndian => 'Indian';

  @override
  String get cuisineChinese => 'Chinese';

  @override
  String get cuisineJapanese => 'Japanese';

  @override
  String get cuisineThai => 'Thai';

  @override
  String get cuisineAmerican => 'American';

  @override
  String get settingsEmailVerified => 'Email verified';

  @override
  String get settingsEmailNotVerified => 'Email not verified';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsSignOutConfirm => 'Sign out?';

  @override
  String get settingsDangerZone => 'Danger zone';

  @override
  String get settingsClearProducts => 'Clear all products';

  @override
  String get settingsClearProductsSubtitle => 'Empties the active fridge';

  @override
  String get settingsClearProductsConfirm => 'Clear all products?';

  @override
  String get settingsFridgeCleared => 'Fridge cleared';

  @override
  String get settingsDeleteChat => 'Delete chat history';

  @override
  String get settingsDeleteChatSubtitle => 'Wipes the AI chef conversation';

  @override
  String get settingsDeleteChatConfirm => 'Delete chat history?';

  @override
  String get settingsChatCleared => 'Chat history cleared';

  @override
  String get settingsCannotBeUndone => 'This action cannot be undone.';

  @override
  String get fridgesTitle => 'Fridges';

  @override
  String get fridgesOwner => 'owner';

  @override
  String fridgesMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String get fridgesNewName => 'New fridge name';

  @override
  String get fridgesNewNameHint => 'My second fridge';

  @override
  String get fridgesInviteEmail => 'Invite by email';

  @override
  String get fridgesInviteHint => 'invitee@example.com';

  @override
  String fridgesInviteSent(String email) {
    return 'Invite sent to $email';
  }

  @override
  String fridgesDeleteTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get fridgesDeleteBody => 'Products and members will be gone.';

  @override
  String fridgesLeaveTitle(String name) {
    return 'Leave \"$name\"?';
  }

  @override
  String get fridgesMenuInvite => 'Invite';

  @override
  String get fridgesMenuDelete => 'Delete';

  @override
  String get fridgesMenuLeave => 'Leave';

  @override
  String get fridgesActiveHint =>
      'Use the switcher in the top bar to change the active fridge. Shared fridges show up here once you accept an invite.';

  @override
  String get fridgesNoneTitle => 'No fridges yet';

  @override
  String get fridgesNoneBody =>
      'Create your first fridge to start tracking groceries.';

  @override
  String get fridgesNoneCta => 'Create fridge';

  @override
  String get analyticsMostWasted => 'Most wasted';

  @override
  String get analyticsMostWastedSubtitle => 'Last 30 days';

  @override
  String get analyticsFastestConsumed => 'Fastest consumed';

  @override
  String get analyticsFastestConsumedSubtitle => 'Days from add to finished';

  @override
  String analyticsDaysShort(int n) {
    return '${n}d';
  }

  @override
  String get categoryDairy => 'Dairy';

  @override
  String get categoryMeatFish => 'Meat & fish';

  @override
  String get categoryVegetables => 'Vegetables & greens';

  @override
  String get categoryFruits => 'Fruits & berries';

  @override
  String get categoryBakery => 'Bread & bakery';

  @override
  String get categoryPantry => 'Pantry staples';

  @override
  String get categorySnacks => 'Snacks & sweets';

  @override
  String get categoryDrinks => 'Drinks';

  @override
  String get categoryAlcohol => 'Alcohol';

  @override
  String get categorySauces => 'Sauces, oils & spices';

  @override
  String get categoryFrozen => 'Frozen';

  @override
  String get categoryCannedPrepared => 'Canned & ready-to-eat';

  @override
  String get categoryOther => 'Other';
}
