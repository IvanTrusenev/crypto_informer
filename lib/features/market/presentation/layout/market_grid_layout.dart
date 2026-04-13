/// Число колонок сетки карточек по ширине контента.
int marketListCrossAxisCount(double width) {
  if (width >= 1200) return 4;
  if (width >= 900) return 3;
  if (width >= 600) return 2;
  return 1;
}
