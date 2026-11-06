import 'package:meta/meta.dart';

/// Typeface for the title on a book's spine.
enum SpineFont {
  serif('Classic serif'),
  serifItalic('Italic serif'),
  sans('Modern sans');

  final String label;
  const SpineFont(this.label);
}

/// A three-step size used for spine text, height and width.
enum SpineScale {
  small('Small'),
  medium('Medium'),
  large('Large');

  final String label;
  const SpineScale(this.label);
}

/// Decoration printed on the spine.
enum SpinePattern {
  plain('Plain'),
  bands('Gilt bands'),
  ribs('Raised ribs'),

  /// A strip of the cover photo, cropped to the spine.
  photo('Photo');

  final String label;
  const SpinePattern(this.label);
}

/// How the book stands on the shelf.
enum BookDisplay {
  /// Favorites face out, everything else shows its spine.
  auto('Automatic'),
  spine('Spine'),
  cover('Cover');

  final String label;
  const BookDisplay(this.label);
}

T _byName<T extends Enum>(List<T> values, Object? name, T fallback) =>
    values.where((v) => v.name == name).firstOrNull ?? fallback;

/// How a recipe looks as a book in the library: spine colour, typography,
/// size and whether it stands spine-out or face-out.
///
/// Colours are `#RRGGBB` strings; null means "derive from the recipe theme".
@immutable
class BookStyle {
  final String? spineColor;
  final String? textColor;
  final SpineFont font;
  final SpineScale textSize;
  final SpineScale height;
  final SpineScale width;
  final SpinePattern pattern;
  final BookDisplay display;

  const BookStyle({
    this.spineColor,
    this.textColor,
    this.font = SpineFont.serif,
    this.textSize = SpineScale.medium,
    this.height = SpineScale.medium,
    this.width = SpineScale.medium,
    this.pattern = SpinePattern.bands,
    this.display = BookDisplay.auto,
  });

  bool get isDefault => this == const BookStyle();

  BookStyle copyWith({
    String? spineColor,
    String? textColor,
    bool clearSpineColor = false,
    bool clearTextColor = false,
    SpineFont? font,
    SpineScale? textSize,
    SpineScale? height,
    SpineScale? width,
    SpinePattern? pattern,
    BookDisplay? display,
  }) => BookStyle(
    spineColor: clearSpineColor ? null : (spineColor ?? this.spineColor),
    textColor: clearTextColor ? null : (textColor ?? this.textColor),
    font: font ?? this.font,
    textSize: textSize ?? this.textSize,
    height: height ?? this.height,
    width: width ?? this.width,
    pattern: pattern ?? this.pattern,
    display: display ?? this.display,
  );

  Map<String, dynamic> toJson() => {
    if (spineColor != null) 'spineColor': spineColor,
    if (textColor != null) 'textColor': textColor,
    'font': font.name,
    'textSize': textSize.name,
    'height': height.name,
    'width': width.name,
    'pattern': pattern.name,
    'display': display.name,
  };

  factory BookStyle.fromJson(Object? json) {
    if (json is! Map) return const BookStyle();
    String? color(Object? v) => v is String && RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(v) ? v : null;
    return BookStyle(
      spineColor: color(json['spineColor']),
      textColor: color(json['textColor']),
      font: _byName(SpineFont.values, json['font'], SpineFont.serif),
      textSize: _byName(SpineScale.values, json['textSize'], SpineScale.medium),
      height: _byName(SpineScale.values, json['height'], SpineScale.medium),
      width: _byName(SpineScale.values, json['width'], SpineScale.medium),
      pattern: _byName(SpinePattern.values, json['pattern'], SpinePattern.bands),
      display: _byName(BookDisplay.values, json['display'], BookDisplay.auto),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BookStyle &&
      other.spineColor == spineColor &&
      other.textColor == textColor &&
      other.font == font &&
      other.textSize == textSize &&
      other.height == height &&
      other.width == width &&
      other.pattern == pattern &&
      other.display == display;

  @override
  int get hashCode => Object.hash(spineColor, textColor, font, textSize, height, width, pattern, display);
}
