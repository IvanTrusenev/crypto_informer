// Generic parser contract intentionally has a single method.
// ignore_for_file: one_member_abstracts

abstract interface class ResponseParser<TInput, TOutput> {
  TOutput parse(TInput input);
}
