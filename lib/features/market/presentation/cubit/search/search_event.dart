sealed class SearchEvent {
  const SearchEvent();
}

class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged(this.query);

  final String query;
}

class SearchCleared extends SearchEvent {
  const SearchCleared();
}

class SearchTriggered extends SearchEvent {
  const SearchTriggered(this.query);

  final String query;
}
