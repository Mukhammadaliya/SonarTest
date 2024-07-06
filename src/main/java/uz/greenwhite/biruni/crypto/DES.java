package uz.greenwhite.biruni.crypto;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

public class DES {
    public static SecretKey generateSecretKey() throws Exception {
        KeyGenerator keygenerator = KeyGenerator.getInstance("DES");
        return keygenerator.generateKey();
    }

    public static String encodeSecretKey(SecretKey key) throws Exception {
        return Base64.getEncoder().encodeToString(key.getEncoded());
    }

    public static SecretKey decodeSecretKey(String keyBase64) {
        return new SecretKeySpec(Base64.getDecoder().decode(keyBase64), "DES");
    }

    public static String encrypt(String plainText, String secretKey) throws Exception {
        Cipher encryptCipher = Cipher.getInstance("DES");
        encryptCipher.init(Cipher.ENCRYPT_MODE, decodeSecretKey(secretKey));

        return Base64.getEncoder().encodeToString(encryptCipher.doFinal(plainText.getBytes(StandardCharsets.UTF_8)));
    }

    public static String decrypt(String encryptedText, String secretKey) throws Exception {
        Cipher decryptCipher = Cipher.getInstance("DES");
        decryptCipher.init(Cipher.DECRYPT_MODE, decodeSecretKey(secretKey));

        return new String(decryptCipher.doFinal(Base64.getDecoder().decode(encryptedText)), StandardCharsets.UTF_8);
    }
}
