module P2P.Crypto where

import           Codec.Crypto.AES
import           Codec.Crypto.RSA hiding (sign, verify)
import qualified Codec.Crypto.RSA as RSA (sign, verify)
import           Codec.Digest.SHA (Length(..))
import qualified Codec.Digest.SHA as SHA

import           Control.Monad.Error (throwError)

import           Crypto.Random (CryptoRandomGen, genBytes)
import           Crypto.Types.PubKey.RSA

import           Data.ByteString (ByteString)
import qualified Data.ByteString as BS

import           Data.String (fromString)
import           Data.Text.Encoding (encodeUtf8)

import           P2P
import           P2P.Types
import           P2P.Util

-- Wrapper functions for Codec.Crypto.RSA

encryptRSA :: PublicKey -> ByteString -> P2P ByteString
encryptRSA pk bs = withRandomGen $ \gen ->
  let (res, g) = encrypt gen pk (toLazy bs) in return (fromLazy res, g)

decryptRSA :: PrivateKey -> ByteString -> ByteString
decryptRSA = wrapLazy . decrypt

sign :: PrivateKey -> ByteString -> ByteString
sign = wrapLazy . RSA.sign

verify :: PublicKey -> ByteString -> ByteString -> Bool
verify pk msg sig = RSA.verify pk (toLazy msg) (toLazy sig)

-- Wrapper functions for Codec.Crypto.AES

encryptAES :: AESKey -> ByteString -> P2P ByteString
encryptAES key bs = withRandomGen $ \gen ->
  case genBytes 16 gen of
    Left e        -> throwError $ "IV generation failed: " ++ show e
    Right (iv, g) -> return (iv `BS.append` crypt' CFB key iv Encrypt bs, g)

decryptAES :: AESKey -> ByteString -> ByteString
decryptAES key msg = crypt' CFB key iv Decrypt bs
  where (iv, bs) = BS.splitAt 16 msg

-- Wrapper functions for Codec.Digest.SHA

chanKey :: Name -> ByteString
chanKey = SHA.hash SHA256 . encodeUtf8 . fromString

-- Wrapper functions for random key generation

genKeyPair :: P2P (PublicKey, PrivateKey)
genKeyPair = withRandomGen $ \gen ->
  let (pub, priv, new) = generateKeyPair gen 2048
  in  return ((pub, priv), new)

genAESKey :: P2P AESKey
genAESKey = withRandomGen $ \gen ->
  case genBytes 32 gen of
    Left e  -> throwError $ "AES key generation failed: " ++ show e
    Right x -> return x
