# Library Management System 📚

A functional library management system built in Haskell, demonstrating pure functional programming principles, algebraic data types, and type-safe error handling.

## Features

- 📖 Add and remove books from library inventory
- 👥 Member registration and management
- 🔍 Search books by title, author, or ISBN
- ✅ Check out and return books with availability tracking
- ⚠️ Comprehensive error handling with descriptive messages
- 🛡️ Type-safe operations using Haskell's type system

## Usage Examples

```haskell
-- Create a new library
library = emptyLibrary

-- Add books and members
libraryWithBooks = addBook (createBook "1984" "George Orwell" 12345 3 14) $
                   addMember (createMember "Alice Smith" 1001) library

-- Check out a book
result = checkOutBook (BookISBN 12345) 1001 libraryWithBooks
-- Returns: Right Library (updated state) or Left ErrorMsg

-- Search for books
books = findBookByAuthor "George Orwell" library
available = isBookAvailable (BookISBN 12345) library

-- Return a book
returnResult = returnBook 1001 (BookISBN 12345) library
```

## Key Operations

- **Book Management**: `addBook`, `removeBook`, `findBookByTitle`, `findBookByAuthor`, `findBookByISBN`
- **Member Management**: `addMember`, `findMemberByCard`
- **Checkout System**: `checkOutBook`, `returnBook`, `isBookAvailable`
- **Utilities**: `whenBookShouldBeReturned`, helper creation functions

## Running the Code

1. **Install GHC** (Glasgow Haskell Compiler):
   ```bash
   # On macOS with Homebrew
   brew install ghc
   
   # Or install Haskell Platform
   curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
   ```

2. **Load in GHCi**:
   ```bash
   ghci Library.hs
   ```

3. **Try it out**:
   ```haskell
   *Library> let lib = addBook (createBook "Test Book" "Author" 123 1 7) emptyLibrary
   *Library> findBookByTitle "Test Book" lib
   ```

## Functional Programming Concepts

This project explores several key Haskell concepts:

- **Algebraic Data Types** - Modeling domain with custom types
- **Newtype Wrappers** - Type safety with `BookISBN`
- **Monadic Error Handling** - Using `Either ErrorMsg Library` for safe operations
- **Immutable Data** - All operations return new library states
- **Pattern Matching** - Destructuring data in function definitions
- **Higher-Order Functions** - Using `map`, `filter`, and function composition

## License

MIT