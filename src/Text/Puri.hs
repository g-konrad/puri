module Text.Puri where

import qualified Data.Text as T
import Data.Void (Void)
import Text.Megaparsec hiding (State)
import Text.Megaparsec.Char
import qualified Text.Megaparsec.Char.Lexer as L

type Parser = Parsec Void T.Text

data Uri = Uri
  { uriScheme :: Scheme,
    uriAuthority :: Maybe Authority
  }
  deriving stock (Eq, Show)

data Authority = Authority
  { authUser :: Maybe (T.Text, T.Text),
    authHost :: T.Text,
    authPort :: Maybe Int
  }
  deriving stock (Eq, Show)

data Scheme
  = SchemeData
  | SchemeFile
  | SchemeFtp
  | SchemeHttp
  | SchemeHttps
  | SchemeIrc
  | SchemeMailto
  deriving stock (Eq, Show)

parseScheme :: Parser Scheme
parseScheme =
  choice
    [ SchemeData <$ string "data",
      SchemeFile <$ string "file",
      SchemeFtp <$ string "ftp",
      SchemeHttps <$ string "https",
      SchemeHttp <$ string "http",
      SchemeIrc <$ string "irc",
      SchemeMailto <$ string "mailto"
    ]

parseUri :: Parser Uri
parseUri = do
  uriScheme <- parseScheme
  _ <- char ':'
  uriAuthority <- optional $ do
    _ <- string "//"
    authUser <- optional . try $ parseUserAuth
    authHost <- parseHost
    authPort <- optional parsePort
    pure $ Authority authUser authHost authPort
  pure $ Uri uriScheme uriAuthority
  where
    parseUserAuth = do
      user <- T.pack <$> Text.Megaparsec.some alphaNumChar
      _ <- char ':'
      password <- T.pack <$> Text.Megaparsec.some alphaNumChar
      _ <- char '@'
      pure (user, password)

    parseHost = T.pack <$> Text.Megaparsec.some (alphaNumChar <|> char '.')

    parsePort = char ':' *> L.decimal
