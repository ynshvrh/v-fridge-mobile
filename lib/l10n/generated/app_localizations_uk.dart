// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'V-Fridge';

  @override
  String get actionCancel => 'Скасувати';

  @override
  String get actionDelete => 'Видалити';

  @override
  String get actionSave => 'Зберегти';

  @override
  String get actionAdd => 'Додати';

  @override
  String get actionOk => 'OK';

  @override
  String get actionRetry => 'Повторити';

  @override
  String get actionEdit => 'Редагувати';

  @override
  String get actionLeave => 'Покинути';

  @override
  String get wordOr => 'або';

  @override
  String get navFridge => 'Холодильник';

  @override
  String get navShopping => 'Покупки';

  @override
  String get navPlanner => 'Планер';

  @override
  String get navChef => 'Шеф';

  @override
  String get navSettings => 'Налаштування';

  @override
  String get signinTitle => 'З поверненням';

  @override
  String get signinContinueWithGoogle => 'Продовжити з Google';

  @override
  String signinGoogleFailed(String error) {
    return 'Не вдалося увійти через Google: $error';
  }

  @override
  String get signinEmail => 'Email';

  @override
  String get signinPassword => 'Пароль';

  @override
  String get signinSubmit => 'Увійти';

  @override
  String get signinNoAccount => 'Ще немає акаунту? Зареєструйтесь';

  @override
  String get signinNotVerifiedTitle => 'Email ще не підтверджено.';

  @override
  String get signinNotVerifiedBody =>
      'Перевірте поштову скриньку або надішліть новий лист.';

  @override
  String get signinResend => 'Надіслати лист підтвердження ще раз';

  @override
  String get signinResendSent => 'Лист підтвердження надіслано';

  @override
  String get signupTitle => 'Створити акаунт';

  @override
  String get signupUsernameLabel => 'Відображуване ім\'я (необов\'язково)';

  @override
  String get signupUsernameHint =>
      'Залиште порожнім, щоб використати префікс email';

  @override
  String get signupPasswordLabel => 'Пароль (мінімум 6 символів)';

  @override
  String get signupSubmit => 'Створити акаунт';

  @override
  String get signupHaveAccount => 'Вже маєте акаунт? Увійти';

  @override
  String get signupDoneTitle => 'Перевірте поштову скриньку';

  @override
  String signupDoneBody(String email) {
    return 'Ми надіслали посилання для підтвердження на $email. Натисніть посилання в листі — і ви автоматично увійдете в акаунт.';
  }

  @override
  String get signupBackToSignIn => 'Назад до входу';

  @override
  String get dashboardEmptyTitle => 'Ваш холодильник порожній';

  @override
  String get dashboardEmptyBody => 'Додайте перший продукт, щоб почати.';

  @override
  String get dashboardAddProduct => 'Додати продукт';

  @override
  String dashboardConfirmDeleteTitle(String name) {
    return 'Видалити «$name»?';
  }

  @override
  String dashboardConsumeLogged(String name) {
    return '«$name» закінчилось — записано';
  }

  @override
  String get productActionMarkFinished => 'Позначити як закінчений';

  @override
  String get productNoDate => 'Без дати';

  @override
  String productExpired(String date) {
    return 'Прострочено $date';
  }

  @override
  String productDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'залишилось $count днів',
      many: 'залишилось $count днів',
      few: 'залишилось $count дні',
      one: 'залишився 1 день',
    );
    return '$_temp0';
  }

  @override
  String productFreshUntil(String date) {
    return 'Свіже до $date';
  }

  @override
  String get addProductTitle => 'Додати продукт';

  @override
  String get addProductEditTitle => 'Редагувати продукт';

  @override
  String get addProductActionAdd => 'Додати в холодильник';

  @override
  String get addProductScanBarcode => 'Сканувати штрих-код';

  @override
  String get addProductName => 'Назва';

  @override
  String get addProductQuantity => 'Кількість';

  @override
  String get addProductUnit => 'Одиниця';

  @override
  String get addProductCategory => 'Категорія';

  @override
  String get addProductExpiry => 'Термін придатності';

  @override
  String get addProductNameTooShort => 'Назва закоротка';

  @override
  String get addProductQuantityTooLow => 'Кількість має бути більшою за 0';

  @override
  String addProductFilledFromBarcode(String barcode) {
    return 'Заповнено зі штрих-коду $barcode';
  }

  @override
  String get barcodeTitle => 'Сканувати штрих-код';

  @override
  String get barcodeNotFound => 'Продукт не знайдено в OpenFoodFacts';

  @override
  String get chatTitle => 'AI шеф';

  @override
  String get chatSubtitle => 'онлайн і готовий';

  @override
  String get chatEmpty => 'Запитайте шефа, що приготувати з того, що є.';

  @override
  String get chatEmptyHero => 'Що готуємо сьогодні?';

  @override
  String get chatThinking => 'Шеф готує відповідь…';

  @override
  String get chatInputHint => 'Запитайте рецепт…';

  @override
  String get chatRateLimit => 'Забагато запитів. Спробуйте за хвилину.';

  @override
  String get chatClearTitle => 'Очистити історію чату?';

  @override
  String get chatClearAction => 'Очистити';

  @override
  String get chatPrompt1 => 'Що приготувати на вечерю?';

  @override
  String get chatPrompt2 => 'Допоможи використати те, що псується';

  @override
  String get chatPrompt3 => 'Швидка страва за 20 хвилин';

  @override
  String get chatPrompt4 => 'Щось легке і корисне';

  @override
  String get shoppingTitle => 'Список покупок';

  @override
  String get shoppingEmpty => 'Ваш список порожній.';

  @override
  String get shoppingToBuy => 'Купити';

  @override
  String get shoppingGotThem => 'Куплено';

  @override
  String get shoppingMoveToFridge => 'Перемістити в холодильник';

  @override
  String shoppingAddedToFridge(String name) {
    return '«$name» додано в холодильник';
  }

  @override
  String get shoppingAddSheetTitle => 'Додати в список покупок';

  @override
  String get shoppingFieldItem => 'Товар';

  @override
  String get shoppingFieldQty => 'К-сть';

  @override
  String get shoppingNameRequired => 'Назва обов\'язкова';

  @override
  String get plannerTitle => 'Планер страв';

  @override
  String get plannerEmptyTitle => 'Плану ще немає';

  @override
  String get plannerEmptyBody =>
      'Натисніть на чарівну паличку, щоб AI шеф запропонував п\'ять страв з вашого інвентарю.';

  @override
  String get plannerGenerate => 'Згенерувати план';

  @override
  String get plannerMissingIngredients => 'Бракує інгредієнтів';

  @override
  String get plannerAddToShopping => 'Додати в список покупок';

  @override
  String plannerImportResult(int created) {
    String _temp0 = intl.Intl.pluralLogic(
      created,
      locale: localeName,
      other: '$created додано в список покупок',
      many: '$created додано в список покупок',
      few: '$created додано в список покупок',
      one: '1 додано в список покупок',
    );
    return '$_temp0';
  }

  @override
  String plannerImportSkipped(int skipped) {
    return ' ($skipped вже є)';
  }

  @override
  String get plannerDayMonday => 'Понеділок';

  @override
  String get plannerDayTuesday => 'Вівторок';

  @override
  String get plannerDayWednesday => 'Середа';

  @override
  String get plannerDayThursday => 'Четвер';

  @override
  String get plannerDayFriday => 'П\'ятниця';

  @override
  String get plannerDaySaturday => 'Субота';

  @override
  String get plannerDaySunday => 'Неділя';

  @override
  String get settingsTitle => 'Налаштування';

  @override
  String get settingsAppearance => 'Вигляд';

  @override
  String get settingsThemeLight => 'Світла';

  @override
  String get settingsThemeDark => 'Темна';

  @override
  String get settingsThemeSystem => 'Системна';

  @override
  String get settingsLanguage => 'Мова';

  @override
  String get settingsLanguageAuto => 'Системна';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageUkrainian => 'Українська';

  @override
  String get settingsCuisine => 'Кухня';

  @override
  String get settingsCuisineHint =>
      'На що схиляється шеф, коли пропонує рецепти.';

  @override
  String get cuisineAny => 'Без переваг';

  @override
  String get cuisineUkrainian => 'Українська';

  @override
  String get cuisineGeorgian => 'Грузинська';

  @override
  String get cuisineItalian => 'Італійська';

  @override
  String get cuisineFrench => 'Французька';

  @override
  String get cuisineMexican => 'Мексиканська';

  @override
  String get cuisineMiddleEastern => 'Близькосхідна';

  @override
  String get cuisineIndian => 'Індійська';

  @override
  String get cuisineChinese => 'Китайська';

  @override
  String get cuisineJapanese => 'Японська';

  @override
  String get cuisineThai => 'Тайська';

  @override
  String get cuisineAmerican => 'Американська';

  @override
  String get settingsEmailVerified => 'Email підтверджено';

  @override
  String get settingsEmailNotVerified => 'Email не підтверджено';

  @override
  String get settingsSignOut => 'Вийти';

  @override
  String get settingsSignOutConfirm => 'Вийти з акаунту?';

  @override
  String get settingsDangerZone => 'Небезпечна зона';

  @override
  String get settingsClearProducts => 'Очистити всі продукти';

  @override
  String get settingsClearProductsSubtitle => 'Спорожняє активний холодильник';

  @override
  String get settingsClearProductsConfirm => 'Очистити всі продукти?';

  @override
  String get settingsFridgeCleared => 'Холодильник очищено';

  @override
  String get settingsDeleteChat => 'Видалити історію чату';

  @override
  String get settingsDeleteChatSubtitle => 'Стирає розмову з AI шефом';

  @override
  String get settingsDeleteChatConfirm => 'Видалити історію чату?';

  @override
  String get settingsChatCleared => 'Історію чату очищено';

  @override
  String get settingsCannotBeUndone => 'Цю дію не можна скасувати.';

  @override
  String get fridgesTitle => 'Холодильники';

  @override
  String get fridgesOwner => 'власник';

  @override
  String fridgesMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count учасників',
      many: '$count учасників',
      few: '$count учасники',
      one: '1 учасник',
    );
    return '$_temp0';
  }

  @override
  String get fridgesNewName => 'Назва нового холодильника';

  @override
  String get fridgesNewNameHint => 'Мій другий холодильник';

  @override
  String get fridgesInviteEmail => 'Запросити за email';

  @override
  String get fridgesInviteHint => 'invitee@example.com';

  @override
  String fridgesInviteSent(String email) {
    return 'Запрошення надіслано на $email';
  }

  @override
  String fridgesDeleteTitle(String name) {
    return 'Видалити «$name»?';
  }

  @override
  String get fridgesDeleteBody => 'Продукти та учасники будуть видалені.';

  @override
  String fridgesLeaveTitle(String name) {
    return 'Покинути «$name»?';
  }

  @override
  String get fridgesMenuInvite => 'Запросити';

  @override
  String get fridgesMenuDelete => 'Видалити';

  @override
  String get fridgesMenuLeave => 'Покинути';

  @override
  String get fridgesActiveHint =>
      'Обраний холодильник надсилається як X-Fridge-Id у кожному запиті. Якщо нічого не обрано — використовується ваш перший власний холодильник.';

  @override
  String get analyticsMostWasted => 'Найбільше викидається';

  @override
  String get analyticsMostWastedSubtitle => 'За останні 30 днів';

  @override
  String get analyticsFastestConsumed => 'Найшвидше з\'їдається';

  @override
  String get analyticsFastestConsumedSubtitle =>
      'Днів від додавання до закінчення';

  @override
  String analyticsDaysShort(int n) {
    return '$nд';
  }

  @override
  String get categoryDairy => 'Молочне';

  @override
  String get categoryMeatFish => 'М\'ясо та риба';

  @override
  String get categoryVegetables => 'Овочі та зелень';

  @override
  String get categoryFruits => 'Фрукти та ягоди';

  @override
  String get categoryBakery => 'Хліб та випічка';

  @override
  String get categoryPantry => 'Бакалія';

  @override
  String get categorySnacks => 'Снеки та солодощі';

  @override
  String get categoryDrinks => 'Напої';

  @override
  String get categoryAlcohol => 'Алкоголь';

  @override
  String get categorySauces => 'Соуси, олії, спеції';

  @override
  String get categoryFrozen => 'Заморозка';

  @override
  String get categoryCannedPrepared => 'Консерви та готові страви';

  @override
  String get categoryOther => 'Інше';
}
