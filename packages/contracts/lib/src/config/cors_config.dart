class CORSConfig {
  final bool enabled;
  final dynamic origin;
  final dynamic methods;
  final dynamic headers;
  final dynamic exposeHeaders;
  final bool? credentials;
  final num? maxAge;

  const CORSConfig({
    this.enabled = true,
    this.origin,
    this.methods,
    this.headers,
    this.exposeHeaders,
    this.credentials,
    this.maxAge,
  });
}
