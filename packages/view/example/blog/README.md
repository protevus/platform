# View Composers Example

This example demonstrates different ways to use view composers in a blog application. View composers are a powerful feature that allows you to share data across multiple views or attach data to views whenever they are rendered.

## File Structure

```
blog/
  ├── views/
  │   ├── layout.blade.html   # Base layout with navigation and footer
  │   └── post.blade.html     # Blog post view that extends layout
  ├── main.dart              # Example code showing different composer types
  └── README.md             # This file
```

## Composer Examples

1. **Layout Composer**
   - Adds common data like user info, footer text, and social links to all layouts
   - Shows how to share data across multiple views

2. **Post Composer Class**
   - Demonstrates class-based composer implementation
   - Shows how to organize complex view data in a reusable class

3. **Related Posts Composer**
   - Uses wildcard pattern matching ('post.*')
   - Shows how to add data to multiple related views

4. **Comments Composer**
   - Shows conditional data injection
   - Demonstrates how to add dynamic content sections

5. **Analytics Composer**
   - Global composer using '*' pattern
   - Shows once-only registration
   - Demonstrates how to add data to every view

## Running the Example

1. Make sure you're in the example directory:
   ```bash
   cd packages/view/example/blog
   ```

2. Run the example:
   ```bash
   dart run main.dart
   ```

The example will:
1. Set up the view factory and blade engine
2. Register all the example composers
3. Render a blog post view that demonstrates all composer types in action

## Key Concepts

- **View Factory**: Central manager for views and composers
- **Blade Engine**: Template engine that processes blade syntax
- **Composers**: Functions or classes that inject data into views
- **Pattern Matching**: Use wildcards to target multiple views
- **Data Sharing**: Share common data across multiple views
- **Class-based Composers**: Organize complex view logic in classes

## Output

The example will render a blog post page that includes:
- Navigation with user info
- Blog post content
- Related posts section
- Comments section
- Footer with social links
- Analytics data

Each section demonstrates data injected by different types of composers.
