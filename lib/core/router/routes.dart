enum Routes {
  home('/', 'home'),
  modes('/modes', 'modes'),
  play('/play', 'play'),
  results('/results', 'results');

  final String path;
  final String routeName;

  const Routes(this.path, this.routeName);
}
