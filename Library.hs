module Library where

data Book = Book
    { title :: String
    , author :: String
    , bookISBN :: BookISBN
    , availableCopies :: Int
    , daysLeftForCheckout :: Int
    }
    deriving (Show, Eq)

data Member = Member
    { name :: String
    , cardNumber :: Int
    , checkedOutBooks :: [Book]
    }
    deriving (Show, Eq)

data Library = Library
    { books :: [Book]
    , members :: [Member]
    }
    deriving (Show)

newtype ErrorMsg = ErrorMsg {msg :: String} deriving (Show)
newtype BookISBN = BookISBN {isbn :: Int} deriving (Show, Eq)

-- Adding a member to library
addMember :: Member -> Library -> Library
addMember member (Library books members) = Library books (member : members)

-- Add book to library
addBook :: Book -> Library -> Library
addBook book (Library books members) = Library (book : books) members

-- Remove book from library
removeBook :: Book -> Library -> Library
removeBook book (Library books members) =
    let updatedBooks = filter (\x -> bookISBN x /= bookISBN book) books
     in Library updatedBooks members

-- Searching
findBookByTitle :: String -> Library -> [Book]
findBookByTitle searchTitle (Library books _) =
    filter (\x -> title x == searchTitle) books

findBookByAuthor :: String -> Library -> [Book]
findBookByAuthor authorName (Library books _) =
    filter (\x -> author x == authorName) books

findBookByISBN :: BookISBN -> Library -> Maybe Book
findBookByISBN searchIsbn (Library books _) =
    case foundBooks of
        [book] -> Just book
        [] -> Nothing
        _ -> Just (head foundBooks) -- Return first if multiple copies
  where
    foundBooks = filter (\x -> bookISBN x == searchIsbn) books

-- Find member by card number
findMemberByCard :: Int -> Library -> Maybe Member
findMemberByCard cardNum (Library _ members) =
    case foundMembers of
        [member] -> Just member
        [] -> Nothing
        _ -> Just (head foundMembers)
  where
    foundMembers = filter (\x -> cardNumber x == cardNum) members

-- Check book availability (fixed to use BookISBN)
isBookAvailable :: BookISBN -> Library -> Bool
isBookAvailable searchIsbn (Library books _) =
    any (\x -> availableCopies x > 0 && bookISBN x == searchIsbn) books

-- Check if member exists
memberExists :: Int -> Library -> Bool
memberExists cardNum library = case findMemberByCard cardNum library of
    Just _ -> True
    Nothing -> False

-- Update book copies
updateBookCopies :: BookISBN -> (Int -> Int) -> Library -> Library
updateBookCopies searchIsbn updateFn (Library books members) =
    let updatedBooks = map updateBook books
        updateBook book =
            if bookISBN book == searchIsbn
                then book{availableCopies = updateFn (availableCopies book)}
                else book
     in Library updatedBooks members

-- Update member's checked out books
updateMemberBooks :: Int -> (Member -> Member) -> Library -> Library
updateMemberBooks cardNum updateFn (Library books members) =
    let updatedMembers = map updateMember members
        updateMember member =
            if cardNumber member == cardNum
                then updateFn member
                else member
     in Library books updatedMembers

-- Check out book (completed implementation)
checkOutBook :: BookISBN -> Int -> Library -> Either ErrorMsg Library
checkOutBook searchIsbn memberCardNum library@(Library libraryBooks libraryMembers) =
    case canCheckOut of
        Right () -> Right updatedLibrary
        Left err -> Left err
  where
    canCheckOut = do
        -- Check if book exists and is available
        book <- case findBookByISBN searchIsbn library of
            Just b -> Right b
            Nothing -> Left (ErrorMsg "Book not found")

        -- Check if book is available
        if not (isBookAvailable searchIsbn library)
            then Left (ErrorMsg "Book not available")
            else Right ()

        -- Check if member exists
        member <- case findMemberByCard memberCardNum library of
            Just m -> Right m
            Nothing -> Left (ErrorMsg "Member not found")

        return ()

    updatedLibrary =
        let
            -- Decrease available copies
            withUpdatedBooks = updateBookCopies searchIsbn (\x -> x - 1) library
            -- Add book to member's checked out list
            Just bookToCheckOut = findBookByISBN searchIsbn library
            addBookToMember member = member{checkedOutBooks = bookToCheckOut : checkedOutBooks member}
         in
            updateMemberBooks memberCardNum addBookToMember withUpdatedBooks

-- Calculate when book should be returned
whenBookShouldBeReturned :: Member -> Book -> Maybe Int
whenBookShouldBeReturned member book =
    if book `elem` checkedOutBooks member
        then Just (daysLeftForCheckout book)
        else Nothing

-- Return book
returnBook :: Int -> BookISBN -> Library -> Either ErrorMsg Library
returnBook memberCardNum bookIsbn library =
    case canReturn of
        Right () -> Right updatedLibrary
        Left err -> Left err
  where
    canReturn = do
        -- Check if member exists
        member <- case findMemberByCard memberCardNum library of
            Just m -> Right m
            Nothing -> Left (ErrorMsg "Member not found")

        -- Check if book exists
        book <- case findBookByISBN bookIsbn library of
            Just b -> Right b
            Nothing -> Left (ErrorMsg "Book not found")

        -- Check if member has this book checked out
        if not (any (\b -> bookISBN b == bookIsbn) (checkedOutBooks member))
            then Left (ErrorMsg "Member doesn't have this book checked out")
            else Right ()

    updatedLibrary =
        let
            -- Increase available copies
            withUpdatedBooks = updateBookCopies bookIsbn (+ 1) library
            -- Remove book from member's checked out list
            removeBookFromMember member = member{checkedOutBooks = filter (\b -> bookISBN b /= bookIsbn) (checkedOutBooks member)}
         in
            updateMemberBooks memberCardNum removeBookFromMember withUpdatedBooks

-- Helper function to create empty library
emptyLibrary :: Library
emptyLibrary = Library [] []

-- Helper function to create a book
createBook :: String -> String -> Int -> Int -> Int -> Book
createBook bookTitle bookAuthor bookIsbn = Book bookTitle bookAuthor (BookISBN bookIsbn)

-- Helper function to create a member
createMember :: String -> Int -> Member
createMember memberName cardNum = Member memberName cardNum []
