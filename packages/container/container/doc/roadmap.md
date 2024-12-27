Let me summarize what we should add to match Laravel's functionality:

Core Container Enhancements:
- Add alias management (alias(), getAlias(), isAlias())
- Add service extenders (extend())
- Add rebound callbacks (rebinding(), refresh())
- Add parameter override stack
- Implement ArrayAccess equivalent
Method Binding Improvements:
- Support Class@method syntax
- Add parameter dependency injection
- Add variadic parameter support
- Add __invoke support
Contextual Binding Enhancements:
- Support array of concrete types
- Add giveTagged() and giveConfig()
- Add attribute-based binding
Additional Methods:
- Add bindIf() and singletonIf()
- Add wrap() for closure injection
- Add factory() for deferred resolution
- Add makeWith() alias
- Add flush() for container reset
Error Handling:
- Better circular dependency detection
- More specific exception types
- Better error messages with build stack