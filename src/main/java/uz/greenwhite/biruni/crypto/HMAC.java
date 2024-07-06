package uz.greenwhite.biruni.crypto;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;

public class HMAC {
    /**
     * Computes a hash using the HmacSHA256 algorithm and Base64 encoding
     * @param message The message to compute the hash from.
     * @param secret The secret key to use for computing the hash.
     * @return A string representation of the computed hash value.
     * @throws NoSuchAlgorithmException If the HmacSHA256 algorithm is not available.
     * @throws InvalidKeyException If the secret key is invalid.
     */
    public static String computeHash(String message, String secret) throws NoSuchAlgorithmException, InvalidKeyException {
        Mac sha256HMAC = Mac.getInstance("HmacSHA256");
        SecretKeySpec secretKey = new SecretKeySpec(secret.getBytes(), "HmacSHA256");
        sha256HMAC.init(secretKey);
        byte[] hmacData = sha256HMAC.doFinal(message.getBytes());
        return Base64.getEncoder().encodeToString(hmacData);
    }
}
